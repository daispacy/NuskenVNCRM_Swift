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
    
    static func getDataDashboard(onComplete:((JSON)->Void)) {
        CustomerManager.getAllCustomers { list in
            var dict:JSON = [:]
            dict["total_customers"] = list.count
            var ordered:Int64 = 0
            var notorderd:Int64 = 0
            var totalAmountOrders:Int64 = 0
            var totaOrdersprocess:Double = 0
            var totalOrdersunprocess:Double = 0
            _ = list.map({
                if $0.listOrders().count == 0 {
                    notorderd += 1
                } else {
                    ordered += 1
                }
            })
            dict["total_customers_ordered"] = ordered
            dict["total_customers_not_ordered"] = notorderd
            GroupManager.getAllGroup(onComplete: { listGroup in
                var listCustomer:[JSON] = []
                _ = listGroup.map({
                    listCustomer.append(["id":$0.id,"name":$0.group_name ?? "","total":Double($0.customers().count)])
                })
                dict["customers"] = listCustomer
                
                //total_orders_amount
                OrderManager.getAllOrders(onComplete: { listOrder in
                    _ = listOrder.map({
                        if $0.status != 0 {
                            totalAmountOrders += $0.totalPrice
                            if $0.status == 1 {
                                totaOrdersprocess += 1
                            } else if $0.status == 3 {
                                totalOrdersunprocess += 1
                            }
                        }
                    })
                    dict["total_orders_processed"] = totaOrdersprocess
                    dict["total_orders_not_processed"] = totalOrdersunprocess
                    dict["total_orders_amount"] = totalAmountOrders
                                        
                    // return result
                    onComplete(dict)
                })
                
                
            })
            
        }
    }
    
    static func currentUser() -> UserDO {
        // Initialize Fetch Request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserDO")
        
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let result = try CoreDataStack.sharedInstance.persistentContainer.viewContext.fetch(fetchRequest)
            var list:[UserDO] = []
            list = result.flatMap({$0 as? UserDO})
            if list.count > 0 {
                return list.first!
            } else {
                return NSEntityDescription.insertNewObject(forEntityName: "UserDO", into: CoreDataStack.sharedInstance.persistentContainer.viewContext) as! UserDO
            }
            
        } catch {
            let fetchError = error as NSError
            print(fetchError)
            return NSEntityDescription.insertNewObject(forEntityName: "UserDO", into: CoreDataStack.sharedInstance.persistentContainer.viewContext) as! UserDO
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
            
            if let data = dictionary["store_id"] as? String {
                object.store_id = Int64(data)!
            } else if let data = dictionary["store_id"] as? Int64 {
                object.store_id = data
            }
            
            if let data = dictionary["username"] as? String {
                object.username = data
            }

            if let data = dictionary["email"] as? String {
                object.email = data
            }
            
//            if let properties = dictionary["properties"] as? JSON {
//                let jsonData = try! JSONSerialization.data(withJSONObject: properties)
//                if let pro = String(data: jsonData, encoding: .utf8) {
//                    object.properties = pro
//                }
//            }
            
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
