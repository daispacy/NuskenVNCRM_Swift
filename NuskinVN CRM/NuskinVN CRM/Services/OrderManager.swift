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
    
    static func getReportOrders(fromDate:NSDate? = nil,toDate:NSDate? = nil, isLifeTime:Bool = true, customer:Customer? = nil,_ onComplete:@escaping (([Order])->Void)) {
        // Initialize Fetch Request
        guard let user = UserManager.currentUser() else { onComplete([]); return }
        
        let context = CoreDataStack.sharedInstance.managedObjectContext
        context.perform {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "OrderDO")
            
            var predicate2 = NSPredicate(format: "1 > 0")
            
            var predicate3 = NSPredicate(format: "1 > 0")
            if let cus = customer {
                predicate3 = NSPredicate(format: "customer_id IN %@",[cus.local_id,cus.id].filter{$0 != 0})
            }
            
            let predicate1 = NSPredicate(format: "distributor_id IN %@", [user.id])
            
            if !isLifeTime {
                if let from = fromDate,
                    let to = toDate {
                    predicate2 = NSPredicate(format: "date_created >= %@ AND date_created <= %@",from,to)
                }
            }
            
            let predicateCompound = NSCompoundPredicate.init(type: .and, subpredicates: [predicate2,predicate1,predicate3])
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "last_updated", ascending: false),
                                            NSSortDescriptor(key: "status", ascending: false)]
            fetchRequest.predicate = predicateCompound
            
            do {
                let result = try context.fetch(fetchRequest)
                var list:[Order] = []
                list = result.flatMap({$0 as? OrderDO}).flatMap{Order.parse(dictionary: $0.toDictionary)}
                onComplete(list)
            } catch {
                let fetchError = error as NSError
                onComplete([])
                print(fetchError)
            }
        }
    }
    
    static func getAllOrders(search:String? = nil,status:Int64? = nil, paymentStatus:Int64? = nil, customer_id:[Int64]? = nil,fromDate:NSDate? = nil, toDate:NSDate? = nil, isLifeTime:Bool = true, onComplete:@escaping (([Order])->Void)) {
        guard let user = UserManager.currentUser() else {onComplete([]); return}
        // Initialize Fetch Request
        let context = CoreDataStack.sharedInstance.persistentContainer.viewContext
        context.perform {
            let fetchRequest = NSFetchRequest<OrderDO>(entityName: "OrderDO")
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
                    predicate5 = NSPredicate(format: "customer_id IN %@",psta.filter{$0 != 0})
                }
            }
            var predicate6 = NSPredicate(format: "1 > 0")
            if !isLifeTime {
                if let from = fromDate,
                    let to = toDate {
                    predicate6 = NSPredicate(format: "date_created >= %@ AND date_created <= %@",from,to)
                }
            }
            
            let predicateCompound = NSCompoundPredicate.init(type: .and, subpredicates: [predicate2,predicate1,predicate3,predicate4,predicate5,predicate6])
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "last_updated", ascending: false),
                                            NSSortDescriptor(key: "status", ascending: false)]
            fetchRequest.predicate = predicateCompound
            
            do {
                let result = try context.fetch(fetchRequest)
                var list:[Order] = []
                list = result.flatMap({$0}).flatMap({Order.parse(dictionary: $0.toDictionary)})
                DispatchQueue.main.async {
                    onComplete(list)
                }
            } catch {
                DispatchQueue.main.async {
                    onComplete([])
                }
            }
        }
    }
    
    static func getAllOrdersNotSynced(onComplete:(([Order])->Void)) {
        // Initialize Fetch Request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "OrderDO")
        
        var predicate1 = NSPredicate(format: "1 > 0")
        if let user = UserManager.currentUser() {
            predicate1 = NSPredicate(format: "distributor_id IN %@", [user.id])
        }
        let predicate3 = NSPredicate(format: "synced == false")
        
        let predicateCompound = NSCompoundPredicate.init(type: .and, subpredicates: [predicate1,predicate3])
//        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "fullname", ascending: true)]
        fetchRequest.predicate = predicateCompound
        
        do {
            let result = try CoreDataStack.sharedInstance.managedObjectContext.fetch(fetchRequest)
            var list:[Order] = []
            list = result.flatMap({$0 as? OrderDO}).flatMap({Order.parse(dictionary: $0.toDictionary)})
            onComplete(list)
            
        } catch {
            let fetchError = error as NSError
            onComplete([])
            print(fetchError)
        }
    }
    
    static func saveOrderWith(array: [JSON],_ onComplete:@escaping (()->Void)) {
        let container = CoreDataStack.sharedInstance.managedObjectContext
        container.perform {
            for jsonObject in array {
                OrderManager.createOrderEntityFrom(dictionary:jsonObject,container)
            }
            onComplete()
        }
        
    }
    
    static func markSynced(_ list:[Int64],_ done:@escaping (()->Void)) {
        if list.count == 0 {
            done()
            return
        }
        
        let container = CoreDataStack.sharedInstance.persistentContainer
        container.performBackgroundTask() { (context) in
                let entity = NSEntityDescription.entity(forEntityName: "OrderDO", in: context)
                let batchRequest = NSBatchUpdateRequest(entity: entity!)
                batchRequest.resultType = .statusOnlyResultType
                batchRequest.predicate = NSPredicate(format: "id IN %@ OR local_id IN %@",list.filter{$0 != 0},list.filter{$0 != 0});
                batchRequest.propertiesToUpdate = ["synced": true]
                do {
                    try context.execute(batchRequest)
                    done()
                } catch {
                    done()
                }
        }
    }
    
    static func update(_ list:[JSON],_ done:@escaping (()->Void)) {
        if list.count == 0 {
            done()
            return
        }
        
        let container = CoreDataStack.sharedInstance.managedObjectContext
        container.perform {
            var i =  1
            for item in list {
                
                let order = Order.parse(dictionary: item)
                
                let listIDS = [order.id].filter{$0 != 0}
                
                if listIDS.count == 0 {
                    print("WARNING: UPDATE ORDER WITH ID == 0. IT'S PREVENTED !!!!")
                    return
                }
                
                let entity = NSEntityDescription.entity(forEntityName: "OrderDO", in: container)
                let batchRequest = NSBatchUpdateRequest(entity: entity!)
                batchRequest.resultType = .statusOnlyResultType
                batchRequest.predicate = NSPredicate(format: "id IN %@",listIDS);
                batchRequest.propertiesToUpdate = order.toDO
                do {
                    try container.execute(batchRequest)
                    if i == list.count {
                        done()
                    }
                } catch {
                    if i == list.count {
                        done()
                    }
                    i += 1
                    print(error)
                }
                i += 1
            }
        }
    }
    
    static func updateOrderEntity(_ product:NSManagedObject, onComplete:(()->Void)) {
        product.managedObjectContext?.mergePolicy = NSMergePolicy(merge: NSMergePolicyType.mergeByPropertyObjectTrumpMergePolicyType)
        do {
            try! product.managedObjectContext?.save()
            print("order saved!")
        } catch {
            
        }
        onComplete()
    }
    
    static func createOrderEntityFrom(dictionary: JSON,_ context:NSManagedObjectContext) {
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
            if let data = dictionary["address"] as? String {
                object.address = data
            }
            if let data = dictionary["tel"] as? String {
                object.tel = data
            }
            if let data = dictionary["cell"] as? String {
                object.cell = data
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
            } else if let data = dictionary["date_created"] as? NSDate {
                object.date_created = data
            }
            
            if let data = dictionary["last_updated"] as? String {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                if let myDate = dateFormatter.date(from: data) {
                    object.last_updated = myDate as NSDate
                }
            } else if let data = dictionary["last_updated"] as? NSDate {
                object.last_updated = data
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
            } else if let properties = dictionary["properties"] as? String{
                object.properties = properties
            }
            
            if let data = dictionary["synced"] as? Bool {
                object.synced = data
            }
            
            if let add = dictionary["ship_address"] as? String {
                object.address = add
            }
            if let data = dictionary["payment_option"] as? String {
                object.payment_option = Int64(data)!
            } else if let data = dictionary["payment_option"] as? Int64 {
                object.payment_option = data
            }
            
            if let data = dictionary["shiping"] as? String {
                object.shipping_unit = Int64(data)!
            } else if let data = dictionary["shiping"] as? Int64 {
                object.shipping_unit = data
            }
            
            if let data = dictionary["svd"] as? String {
                object.svd = data
            }
            
            do {try? context.save()}
        }
    }
    
    static func clearAllDataSynced(_ onComplete:@escaping (()->Void)) {
        
        let container = CoreDataStack.sharedInstance.persistentContainer
        container.performBackgroundTask() { (context) in
            do {
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "OrderDO")
                
                fetchRequest.predicate = NSPredicate(format: "synced == true")
                let objects  = try context.fetch(fetchRequest) as? [NSManagedObject]
                _ = objects.map {_ = $0.map({context.delete($0)})}
                try context.save()
                onComplete()
            } catch {
                onComplete()
            }
        }
    }
    
    static func clearData(_ fromList:[JSON], onComplete:@escaping (([JSON])->Void)) {
        do {
            var list:[JSON] = []
            let container = CoreDataStack.sharedInstance.persistentContainer
            container.performBackgroundTask() { (context) in
                do {
                    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "OrderDO")
                    
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
                    try context.save()
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
                } catch {
                }
            }
        }
    }
}
