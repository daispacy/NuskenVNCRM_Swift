//
//  ProductManager.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 10/20/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import UIKit
import CoreData

class UserManager: NSObject {
    
    static func getDataDashboard(_ fromDate:NSDate? = nil, toDate:NSDate? = nil, isLifeTime:Bool = true,onComplete:((JSON)->Void)) {
        CustomerManager.getReportCustomers(fromDate: fromDate, toDate: toDate, isLifeTime: isLifeTime, onComplete: { list in
            var dict:JSON = [:]
            dict["total_customers"] = Int64(list.filter{$0.status == 1}.count)
            var ordered:Int64 = 0
            var notorderd:Int64 = 0
            var totalAmountOrders:Int64 = 0            
            var totaOrdersprocess:Double = 0
            var totalOrdersunprocess:Double = 0
            var totalOrdersinvalid:Double = 0
            var totalOrdersPaid:Double = 0
            var totalOrdersUnpaid:Double = 0
            var top10Product:[JSON] = []
            _ = list.map({
                if $0.listOrders().count == 0 {
                    notorderd += 1
                } else {
                    ordered += 1
                }
            })
            dict["total_customers_ordered"] = ordered
            dict["total_customers_not_ordered"] = notorderd
            GroupManager.getReportGroup(fromDate: fromDate, toDate: toDate, isLifeTime: isLifeTime, onComplete: { listGroup in
                var listCustomer:[JSON] = []
                _ = listGroup.map({
                    listCustomer.append(["id":$0.id,"name":$0.group_name ?? "","total":Double($0.customers(fromDate: fromDate, toDate: toDate, isLifeTime: isLifeTime).count)])
                })
                dict["customers"] = listCustomer
                
                //total_orders_amount
                var listOrderitems:[OrderItemDO] = []
                OrderManager.getReportOrders(fromDate: fromDate, toDate: toDate, isLifeTime: isLifeTime, onComplete: { listOrder in
                    _ = listOrder.map({
                        if $0.status != 0 { // invalid
                            totalAmountOrders += $0.totalPrice
                            if $0.status == 1 { // process
                                totaOrdersprocess += 1
                            } else if $0.status == 3 { // unprocess
                                totalOrdersunprocess += 1
                            }
                        } else {
                            totalOrdersinvalid += 1
                        }
                        if $0.payment_status == 1 {
                            totalOrdersPaid += 1
                        } else if $0.payment_status == 2 {
                            totalOrdersUnpaid += 1
                        }
                        if $0.orderItems().count > 0 {
                            listOrderitems.append(contentsOf:$0.orderItems())
                        }
                    })
                    
                    //hanlde product
                    var listTemp:[[String:Any]] = []
                    if listOrderitems.count > 0 {
                        _ = listOrderitems.map({item  in
                            // check listTemp has store this product
                            var index = -1
                            var i = 0
                            if listTemp.count == 0 {
                                listTemp.append(["total":item.price*item.quantity,"quantity":item.quantity,"product":item.product()!])
                            } else {
                                for it in listTemp {
                                    if let pr = it["product"] as? ProductDO,
                                        let pr1 = item.product(){
                                        if pr.id == pr1.id {
                                            index = i
                                            break
                                        }
                                    }
                                    i += 1
                                }
                            }
                            if index != -1 {
                                listTemp[index]["total"] = Int64(listTemp[index]["total"] as! Int64) + item.price*item.quantity
                                listTemp[index]["quantity"] = Int64(listTemp[index]["quantity"] as! Int64) + item.quantity
                            } else {                                listTemp.append(["total":item.price*item.quantity,"quantity":item.quantity,"product":item.product()!])
                            }
                        })
                    }
                    if listTemp.count > 0 {
                        top10Product = listTemp                        
                    }
                    
                    dict["total_orders_processed"] = totaOrdersprocess.cleanValue
                    dict["total_orders_not_processed"] = totalOrdersunprocess.cleanValue
                    dict["total_orders_invalid"] = totalOrdersinvalid.cleanValue
                    dict["total_orders_amount"] = totalAmountOrders
                    dict["total_orders_no_charge"] = totalOrdersUnpaid.cleanValue
                    dict["total_orders_money_collected"] = totalOrdersPaid.cleanValue
                    dict["top_ten_product"] = top10Product
                    // return result
                    onComplete(dict)
                })
                
                
            })
            
        })
    }
    
    static func currentUser() -> UserDO? {
        // Initialize Fetch Request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserDO")
        
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let result = try CoreDataStack.sharedInstance.persistentContainer.viewContext.fetch(fetchRequest)
            var list:[UserDO] = []
            list = result.flatMap({$0 as? UserDO})
            if list.count > 0 {
                return list.last!
            } else {
                return nil
            }
            
        } catch {
            let fetchError = error as NSError
            print(fetchError)
            return nil
        }
    }
    
    static func save() {
        let context = CoreDataStack.sharedInstance.persistentContainer.viewContext
        do {
            try context.save()
        } catch {
            // TODO: handle the error
        }
    }
    
    static func reset() {
        let context = CoreDataStack.sharedInstance.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserDO")
        fetchRequest.returnsObjectsAsFaults = false
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(deleteRequest)
        } catch {
            // TODO: handle the error
        }
    }
    
    static func saveUserWith(dictionary: JSON) -> UserDO? {
        clearData([dictionary])
        let context = CoreDataStack.sharedInstance.persistentContainer.viewContext
        if let object = NSEntityDescription.insertNewObject(forEntityName: "UserDO", into: context) as? UserDO {
            if let data = dictionary["id_card_no"] as? String {
                object.id_card_no = Int64(data)!
            } else if let data = dictionary["id_card_no"] as? Int64 {
                object.id_card_no = data
            }
            
            if let data = dictionary["id"] as? String {
                object.id = Int64(data)!
            } else if let data = dictionary["id"] as? Int64 {
                object.id = data
            }
            
            if let data = dictionary["status"] as? String {
                object.status = Int64(data)!
            } else if let data = dictionary["status"] as? Int64 {
                object.status = data
            }
            
            if let data = dictionary["store_id"] as? String {
                object.store_id = Int64(data)!
            } else if let data = dictionary["store_id"] as? Int64 {
                object.store_id = data
            }
            
            if let data = dictionary["username"] as? String {
                object.username = data
            }

            if let data = dictionary["fullname"] as? String {
                object.fullname = data
            }
            
            if let data = dictionary["address"] as? String {
                object.address = data
            }
            
            if let data = dictionary["email"] as? String {
                object.email = data
            }
            
            if let data = dictionary["tel"] as? String {
                object.tel = data
            }
            
            if let data = dictionary["cell"] as? String {
                object.cell = data
            }
            
            if let data = dictionary["type"] as? String {
                object.type = Int64(data)!
            } else if let data = dictionary["type"] as? Int64 {
                object.type = data
            }
            
            if let data = dictionary["date_created"] as? String {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                if let myDate = dateFormatter.date(from: data) {
                    object.date_created = myDate as NSDate
                }
            }
            if let data = dictionary["last_login"] as? String {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                if let myDate = dateFormatter.date(from: data) {
                    object.last_login = myDate as NSDate
                }
            }
            
            if let properties = dictionary["properties"] as? JSON {
                let jsonData = try! JSONSerialization.data(withJSONObject: properties)
                if let pro = String(data: jsonData, encoding: .utf8) {
                    object.properties = pro
                }
                if let avatar = properties["avatar"] as? String {
                    object.avatar = avatar
                }
            }
            
            return object
        }
        return nil
    }
    
    static func clearData(_ fromList:[JSON]) {
        do {
            
            let context = CoreDataStack.sharedInstance.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserDO")
            fetchRequest.returnsObjectsAsFaults = false
            do {
                let objects  = try context.fetch(fetchRequest) as? [NSManagedObject]
                _ = objects.map {
                    $0.map({context.delete($0)})
                }
                CoreDataStack.sharedInstance.saveContext()
            } catch let error {
                print("ERROR DELETING : \(error)")
            }
        }
    }
}
