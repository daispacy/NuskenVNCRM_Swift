//
//  ProductManager.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 10/20/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import UIKit
import CoreData

class OrderManager: NSObject {
    
    static func getReportOrders(fromDate:NSDate? = nil,toDate:NSDate? = nil, isLifeTime:Bool = true, onComplete:(([OrderDO])->Void)) {
        // Initialize Fetch Request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "OrderDO")
        fetchRequest.returnsObjectsAsFaults = false
        var predicate1 = NSPredicate(format: "1 > 0")
        if let user = UserManager.currentUser() {
            predicate1 = NSPredicate(format: "distributor_id IN %@", [user.id])
        }
        var predicate2 = NSPredicate(format: "1 > 0")
        if !isLifeTime {
            if let from = fromDate,
                let to = toDate {
                predicate2 = NSPredicate(format: "date_created >= %@ AND date_created <= %@",from,to)
            }
        }
        
        let predicateCompound = NSCompoundPredicate.init(type: .and, subpredicates: [predicate2,predicate1])
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "last_updated", ascending: false),
                                        NSSortDescriptor(key: "status", ascending: false)]
        fetchRequest.predicate = predicateCompound
        
        do {
            let result = try CoreDataStack.sharedInstance.persistentContainer.viewContext.fetch(fetchRequest)
            var list:[OrderDO] = []
            list = result.flatMap({$0 as? OrderDO})
            onComplete(list)
            
        } catch {
            let fetchError = error as NSError
            onComplete([])
            print(fetchError)
        }
    }
    
    static func getAllOrders(search:String? = nil,status:Int64? = nil, paymentStatus:Int64? = nil, customer_id:[Int64]? = nil, onComplete:(([OrderDO])->Void)) {
        guard let user = UserManager.currentUser() else {onComplete([]); return}
        // Initialize Fetch Request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "OrderDO")
        fetchRequest.returnsObjectsAsFaults = false
        
        let predicate1 = NSPredicate(format: "distributor_id IN %@", [user.id])
        var predicate2 = NSPredicate(format: "1 > 0")
        var predicate3 = NSPredicate(format: "1 > 0")
        var predicate4 = NSPredicate(format: "1 > 0")
        var predicate5 = NSPredicate(format: "1 > 0")
        
        if let text = search {
            if text.characters.count > 0 {
                predicate2 = NSPredicate(format: "code contains[cd] %@",text)
            }
        }
        if let sta = status {
            predicate3 = NSPredicate(format: "status IN %@",[sta])
        }
        if let psta = paymentStatus {
            predicate4 = NSPredicate(format: "payment_status IN %@",[psta])
        }
        
        if let psta = customer_id {
            if psta.count > 0 {
                predicate5 = NSPredicate(format: "customer_id IN %@",psta)
            }
        }
        
        let predicateCompound = NSCompoundPredicate.init(type: .and, subpredicates: [predicate2,predicate1,predicate3,predicate4,predicate5])
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "last_updated", ascending: false),
        NSSortDescriptor(key: "status", ascending: false)]
        fetchRequest.predicate = predicateCompound
        
        do {
            let result = try CoreDataStack.sharedInstance.persistentContainer.viewContext.fetch(fetchRequest)
            var list:[OrderDO] = []
            list = result.flatMap({$0 as? OrderDO})
            onComplete(list)
            
        } catch {
            let fetchError = error as NSError
            onComplete([])
            print(fetchError)
        }
    }
    
    static func getAllOrdersNotSynced(onComplete:(([OrderDO])->Void)) {
        // Initialize Fetch Request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "OrderDO")
        fetchRequest.returnsObjectsAsFaults = false
        var predicate1 = NSPredicate(format: "1 > 0")
        if let user = UserManager.currentUser() {
            predicate1 = NSPredicate(format: "distributor_id IN %@", [user.id])
        }
        let predicate3 = NSPredicate(format: "synced == false")
        
        let predicateCompound = NSCompoundPredicate.init(type: .and, subpredicates: [predicate1,predicate3])
//        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "fullname", ascending: true)]
        fetchRequest.predicate = predicateCompound
        
        do {
            let result = try CoreDataStack.sharedInstance.persistentContainer.viewContext.fetch(fetchRequest)
            var list:[OrderDO] = []
            list = result.flatMap({$0 as? OrderDO})
            onComplete(list)
            
        } catch {
            let fetchError = error as NSError
            onComplete([])
            print(fetchError)
        }
    }
    
    static func saveOrderWith(array: [JSON]) {
        OrderManager.clearData(array,onComplete: { array in
            if array.count > 0 {
                _ = array.map{OrderManager.createOrderEntityFrom(dictionary:$0)}
            }
            do {
                try CoreDataStack.sharedInstance.persistentContainer.viewContext.save()
            } catch let error {
                print(error)
            }
        })
    }
    
    static func updateOrderEntity(_ product:NSManagedObject, onComplete:(()->Void)) {
        let context = CoreDataStack.sharedInstance.persistentContainer.viewContext
        do {
            try context.save()
            print("order saved!")
        } catch let error as NSError  {
            print("Could not saved \(error), \(error.userInfo)")
        } catch {
            
        }
        onComplete()
    }
    
    static func createOrderEntityFrom(dictionary: JSON) -> NSManagedObject? {
        let context = CoreDataStack.sharedInstance.persistentContainer.viewContext
        if let object = NSEntityDescription.insertNewObject(forEntityName: "OrderDO", into: context) as? OrderDO {
            if let data = dictionary["id"] as? String {
                object.id = Int64(data)!
            } else if let data = dictionary["id"] as? Int64 {
                object.id = data
            }
            
            if let data = dictionary["local_id"] as? String {
                object.local_id = Int64(data)!
            } else if let data = dictionary["local_id"] as? Int64 {
                object.local_id = data
            }
            
            if let data = dictionary["customer_id"] as? String {
                object.customer_id = Int64(data)!
            } else if let data = dictionary["customer_id"] as? Int64 {
                object.customer_id = data
            }
            
            if let data = dictionary["store_id"] as? String {
                object.store_id = Int64(data)!
            } else if let data = dictionary["store_id"] as? Int64 {
                object.store_id = data
            }
            
            if let data = dictionary["distributor_id"] as? String {
                object.distributor_id = Int64(data)!
            } else if let data = dictionary["distributor_id"] as? Int64 {
                object.distributor_id = data
            }
            
            if let data = dictionary["payment_option"] as? String {
                object.payment_option = Int64(data)!
            } else if let data = dictionary["payment_option"] as? Int64 {
                object.payment_option = data
            }
            
            if let data = dictionary["shipping_unit"] as? String {
                object.shipping_unit = Int64(data)!
            } else if let data = dictionary["shipping_unit"] as? Int64 {
                object.shipping_unit = data
            }
            
            if let data = dictionary["email"] as? String {
                object.email = data
            }
            if let data = dictionary["raddress"] as? String {
                object.address = data
            }
            if let data = dictionary["tel"] as? String {
                object.tel = data
            }
            if let data = dictionary["cell"] as? String {
                object.cell = data
            }
            
            if let data = dictionary["svd"] as? String {
                object.svd = data
            }
            if let data = dictionary["status"] as? String {
                object.status = Int64(data)!
            } else if let data = dictionary["status"] as? Int64 {
                object.status = data
            }
            
            if let data = dictionary["payment_status"] as? String {
                object.payment_status = Int64(data)!
            } else if let data = dictionary["payment_status"] as? Int64 {
                object.payment_status = data
            }
           
            if let data = dictionary["name"] as? String {
                object.name = data
            }
            if let data = dictionary["code"] as? String {
                object.code = data
            }
            
            if let data = dictionary["date_created"] as? String {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                if let myDate = dateFormatter.date(from: data) {
                    object.date_created = myDate as NSDate
                }
            }
            if let data = dictionary["last_updated"] as? String {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                if let myDate = dateFormatter.date(from: data) {
                    object.last_updated = myDate as NSDate
                }
            }
            
            if let properties = dictionary["properties"] as? JSON {
                let jsonData = try! JSONSerialization.data(withJSONObject: properties)
                if let pro = String(data: jsonData, encoding: .utf8) {
                    object.properties = pro
                }
                if let add = properties["ship_address"] as? String {
                    object.address = add
                }
                if let data = properties["payment_option"] as? String {
                    object.payment_option = Int64(data)!
                } else if let data = properties["payment_option"] as? Int64 {
                    object.payment_option = data
                }
                
                if let data = properties["shiping"] as? String {
                    object.shipping_unit = Int64(data)!
                } else if let data = properties["shiping"] as? Int64 {
                    object.shipping_unit = data
                }
                if let data = properties["svd"] as? String {
                    object.svd = data
                }
                if let data = properties["city"] as? String {
                    object.setCity(data)
                }
                
                if let data = properties["district"] as? String {
                    object.setDistrict(data)
                }
                
                if let data = properties["transporter_other"] as? String {
                    object.setOtherTransporter(data)
                }
            }
            
            return object
        }
        return nil
    }
    
    static func clearAllDataSynced(onComplete:(()->Void)) {
        do {
            let context = CoreDataStack.sharedInstance.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "OrderDO")
            fetchRequest.returnsObjectsAsFaults = false
            fetchRequest.predicate = NSPredicate(format: "synced == true")
            do {
                let objects  = try context.fetch(fetchRequest) as? [NSManagedObject]
                _ = objects.map {_ = $0.map({context.delete($0)})}
                
                onComplete()
                
            } catch let error {
                print("ERROR DELETING : \(error)")
            }
        }
    }
    
    static func clearData(_ fromList:[JSON], onComplete:(([JSON])->Void)) {
        do {
            var list:[JSON] = []
            let context = CoreDataStack.sharedInstance.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "OrderDO")
            fetchRequest.returnsObjectsAsFaults = false
            do {
                let objects  = try context.fetch(fetchRequest) as? [NSManagedObject]
                _ = objects.map {
                    let obj = $0
                    _ = fromList.contains(where: { (item) -> Bool in
                        if let data = item["id"] as? String {
                            if let id = Int64(data) {
                                _ = obj.map{
                                    let orderDO = $0 as! OrderDO
                                    if id == orderDO.id {
                                        list.append(item)
                                        context.delete($0)
                                    }
                                }
                            }
                        }
                        return false
                    })
                }
                CoreDataStack.sharedInstance.saveContext()
                list = fromList.filter {
                    if let dt = $0["id"] as? String {
                        if let hID = Int64(dt) {
                            if list.count == 0 {
                                return true
                            }
                            return list.contains(where: { (item) -> Bool in
                                if let data = item["id"] as? String {
                                    if let id = Int64(data) {
                                        if id == hID {
                                            return false
                                        }
                                    }
                                }
                                return true
                            })
                        }
                    }
                    return true
                }
                onComplete(list)
            } catch let error {
                print("ERROR DELETING : \(error)")
            }
        }
    }
}
