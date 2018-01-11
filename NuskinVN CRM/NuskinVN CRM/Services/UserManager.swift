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
    
    static func getDataDashboard(_ fromDate:NSDate? = nil, toDate:NSDate? = nil, isLifeTime:Bool = true, onComplete:@escaping ((JSON)->Void)) {
        CustomerManager.getReportCustomers(fromDate: fromDate, toDate: toDate, isLifeTime: isLifeTime){ list in
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
                if $0.getNumberOrders() == 0 {
                    notorderd += 1
                } else {
                    ordered += 1
                }
            })
            dict["total_customers_ordered"] = ordered
            dict["total_customers_not_ordered"] = notorderd
            DispatchQueue.main.async {
                GroupManager.getReportGroup(fromDate: fromDate, toDate: toDate, isLifeTime: isLifeTime,{ listGroup in
                    var listCustomer:[JSON] = []
                    _ = listGroup.map({
                        listCustomer.append(["id":$0.id,"name":$0.group_name,"total":Double($0.customers(fromDate: fromDate, toDate: toDate, isLifeTime: isLifeTime).count)])
                    })
                    dict["customers"] = listCustomer
                    
                    //total_orders_amount
                    var listOrderitems:[OrderItem] = []
                     DispatchQueue.main.async {
                    OrderManager.getReportOrders(fromDate: fromDate, toDate: toDate, isLifeTime: isLifeTime){ listOrder in
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
                            if $0.numberOrderItems() > 0 {
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
                                    if let pro = item.product() {
                                        listTemp.append(["total":item.price*item.quantity,"quantity":item.quantity,"product":pro])
                                    } else {
                                        print("fuck")
                                    }
                                } else {
                                    for it in listTemp {
                                        if let pr = it["product"] as? Product,
                                            let pr1 = item.product(){
                                            if pr.id == pr1.id {
                                                index = i
                                                listTemp[index]["total"] = Int64(listTemp[index]["total"] as! Int64) + item.price*item.quantity
                                                listTemp[index]["quantity"] = Int64(listTemp[index]["quantity"] as! Int64) + item.quantity
                                                break
                                            }
                                        }
                                        i += 1
                                    }
                                    if index == -1 {
                                        listTemp.append(["total":item.price*item.quantity,"quantity":item.quantity,"product":item.product()!])
                                    }
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
                    }
                    
                }
                })
            }
        }
    }
    
    static func getDataOrderStatus(_ fromDate:NSDate? = nil, toDate:NSDate? = nil, isLifeTime:Bool = true,_ customer:Customer? = nil, onComplete:@escaping (([JSON])->Void)) {
        var listDay:[JSON] = []
        if let to = toDate as Date?{
            let currentMonth = to.currentMonth
            let currentYear = to.currentYear
            
            listDay.append(["month":currentMonth,"year":currentYear,"day":to.listDay])
            for i in (1...2) {
                var y = Int(currentYear)!
                var m = Int(currentMonth)! - i
                if m == 0 {
                    m = 12
                    y -= 1
                } else if m < 0 {
                    m = 12 + m
                    y -= 1
                }
                let date = "\(y)-\(m)-\(15) 00:00:00".toDate2()
                listDay.append(["month":"\(m)","year":"\(y)","day":date.listDay])
            }
        }
        
        var listResult:[JSON] = []
        
        var day = 0
        for item in listDay {
            if let m = item["month"], let y = item["year"], let listDa:[String] = item["day"] as? [String] {
                var dict:JSON = [:]
                //        dict["total_customers"] = Int64(list.filter{$0.status == 1}.count)
                var totalPriceOrdersprocess:Double = 0
                var totalPriceOrdersunprocess:Double = 0
                var totaOrdersprocess:Double = 0
                var totalOrdersunprocess:Double = 0
                var totalOrdersinvalid:Double = 0
                var totalOrdersPaid:Double = 0
                var totalOrdersUnpaid:Double = 0
                
                let from = "\(y)-\(m)-\(listDa.first!) 00:00:00".toDate2() as NSDate
                let to = "\(y)-\(m)-\(listDa.last!) 00:00:00".toDate2() as NSDate
                
                //total_orders_amount
                var listOrderitems:[OrderItem] = []
                
                OrderManager.getReportOrders(fromDate: from, toDate: to, isLifeTime: false, customer: customer){ listOrder in
                    _ = listOrder.map({
                        if $0.status != 0 { // invalid
                            if $0.status == 1 { // process
                                totaOrdersprocess += 1
                                totalPriceOrdersprocess += Double($0.totalPrice)
                            } else if $0.status == 3 { // unprocess
                                totalOrdersunprocess += 1
                                totalPriceOrdersunprocess += Double($0.totalPrice )
                            }
                        } else {
                            totalOrdersinvalid += 1
                        }
                        if $0.payment_status == 1 {
                            totalOrdersPaid += 1
                        } else if $0.payment_status == 2 {
                            totalOrdersUnpaid += 1
                        }
                        if $0.numberOrderItems() > 0 {
                            listOrderitems.append(contentsOf:$0.orderItems())
                        }
                    })
                    
                    dict["total_orders_processed"] = totaOrdersprocess.cleanValue
                    dict["total_orders_not_processed"] = totalOrdersunprocess.cleanValue
                    dict["total_orders_invalid"] = totalOrdersinvalid.cleanValue
                    dict["total_orders_no_charge"] = totalOrdersUnpaid.cleanValue
                    dict["total_orders_money_collected"] = totalOrdersPaid.cleanValue
                    dict["total_orders_price_process"] = totalPriceOrdersprocess.cleanValue
                    dict["total_orders_price_unprocess"] = totalPriceOrdersunprocess.cleanValue
                    listResult.append(["date":(to as Date).toString(dateFormat: "MM/yyyy") ,"data":dict])
                    // return result
                    if day == listDay.count - 1 {
                        onComplete(listResult.sorted(by: {($0["date"] as! String).toDate3().compare(($1["date"] as! String).toDate3()) == .orderedAscending}))
                    }
                    day += 1
                }
                
            }
            
        }
    }
    
    static func getDataCustomerDashboard(_ fromDate:NSDate? = nil, toDate:NSDate? = nil, isLifeTime:Bool = true, customer:Customer? = nil, onComplete:@escaping ((JSON)->Void)) {
        guard let cus = customer else {onComplete([:]); return }
        var dict:JSON = [:]
        var totalAmountOrders:Int64 = 0
        var totalPVOrders:Int64 = 0
        var totaOrdersprocess:Double = 0
        var totalOrdersunprocess:Double = 0
        var totalOrdersinvalid:Double = 0
        var totalOrdersPaid:Double = 0
        var totalOrdersUnpaid:Double = 0
        var top10Product:[JSON] = []
        
        
        
        //total_orders_amount
        var listOrderitems:[OrderItem] = []
        OrderManager.getReportOrders(fromDate: fromDate, toDate: toDate, isLifeTime: isLifeTime, customer:cus,{ listOrder in
            _ = listOrder.map({
                if $0.status != 0 { // invalid
                    totalAmountOrders += $0.totalPrice
                    totalPVOrders += $0.totalPV
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
                if $0.numberOrderItems() > 0 {
                    listOrderitems.append(contentsOf:$0.orderItems())
                }
            })
            
            //hanlde product
            var listTemp:[[String:Any]] = []
            if listOrderitems.count > 0 {
                _ = listOrderitems.map({item  in
                    // check listTemp has store this product
                    if listTemp.count == 0 {
                        listTemp.append(["total":item.price*item.quantity,"quantity":item.quantity,"product":item.product()!])
                    } else {
                        var index = -1
                        var i = 0
                        for it in listTemp {
                            if let pr = it["product"] as? Product,
                                let pr1 = item.product(){
                                if pr.id == pr1.id {
                                    index = i
                                    listTemp[index]["total"] = Int64(listTemp[index]["total"] as! Int64) + item.price*item.quantity
                                    listTemp[index]["quantity"] = Int64(listTemp[index]["quantity"] as! Int64) + item.quantity
                                    break
                                }
                            }
                            i += 1
                        }
                        if index == -1 {
                            listTemp.append(["total":item.price*item.quantity,"quantity":item.quantity,"product":item.product()!])
                        }
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
            dict["total_pv_amount"] = totalPVOrders
            dict["total_orders_no_charge"] = totalOrdersUnpaid.cleanValue
            dict["total_orders_money_collected"] = totalOrdersPaid.cleanValue
            dict["top_ten_product"] = top10Product
            // return result
            onComplete(dict)
        })
    }
    
    static func currentUser() -> UserDO? {
        // Initialize Fetch Request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserDO")
        do {
            let result = try CoreDataStack.sharedInstance.managedObjectContext.fetch(fetchRequest)
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
        let context = CoreDataStack.sharedInstance.managedObjectContext
        do {
            try context.save()
        } catch {
            // TODO: handle the error
        }
    }
    
    static func reset() {
        let context = CoreDataStack.sharedInstance.managedObjectContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserDO")
        
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(deleteRequest)
        } catch {
            // TODO: handle the error
        }
    }
    
    static func saveUserWith(dictionary: JSON,_ context:NSManagedObjectContext) -> UserDO? {
        clearData([dictionary])
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
            
            let context = CoreDataStack.sharedInstance.managedObjectContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserDO")
            
            do {
                let objects  = try context.fetch(fetchRequest) as? [NSManagedObject]
                _ = objects.map {
                    $0.map({context.delete($0)})
                }
            } catch let error {
                print("ERROR DELETING : \(error)")
            }
        }
    }
}
