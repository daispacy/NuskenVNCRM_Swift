//
//  ProductManager.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 10/20/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import UIKit
import CoreData

class GroupManager: NSObject {
    
    static func saveGroupWith(array: [JSON],_ onComplete:@escaping (()->Void)) {
        GroupManager.clearData(array,onComplete: { array in
            let save = CoreDataStack.sharedInstance.managedObjectContext
            save.perform {
                for jsonObject in array.reversed() {
                    _ = GroupManager.createGroupEntityFrom(dictionary: jsonObject, save)
                }
                do {
                    try save.save()
                    onComplete()
                } catch {
                    onComplete()
                }
            }            
        })
    }
    
    static func markSynced(_ list:[Int64],_ done:@escaping (()->Void)) {
        let container = CoreDataStack.sharedInstance.persistentContainer
        container.performBackgroundTask() { (context) in
            let entity = NSEntityDescription.entity(forEntityName: "GroupDO", in: context)
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
    
    static func getReportGroup(fromDate:NSDate? = nil,toDate:NSDate? = nil, isLifeTime:Bool = true,_ onComplete:@escaping (([Group])->Void)) {
        // Initialize Fetch Request
        guard let user = UserManager.currentUser() else {onComplete([]);  return}
        
        let context = CoreDataStack.sharedInstance.managedObjectContext
        context.perform {
            do {
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "GroupDO")
                
                
                let predicate3 = NSPredicate(format: "status == 1")
                let predicate2 = NSPredicate(format: "distributor_id IN %@ OR distributor_id == 0", [user.id])
                
                let predicateCompound = NSCompoundPredicate.init(type: .and, subpredicates: [predicate2,predicate3])
                fetchRequest.sortDescriptors = [NSSortDescriptor(key: "group_name", ascending: true)]
                fetchRequest.predicate = predicateCompound
                
                let result = try context.fetch(fetchRequest)
                var list:[Group] = []
                list = result.flatMap({$0 as? GroupDO}).flatMap{Group.parse($0.toDictionary)}
                onComplete(list)
            } catch {
                onComplete([])
            }
        }
        
        
        
        /*
         if !isLifeTime {
         if let from = fromDate,
         let to = toDate {
         predicate2 = NSPredicate(format: "(date_created >= %@ AND date_created <= %@ AND distributor_id IN %@) OR distributor_id == 0",from,to,[user.id])
         }
         }
         */
        
    }
    
    static func getAllGroup(onComplete:(([Group])->Void)) {
        // Initialize Fetch Request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "GroupDO")
        
        var predicate1 = NSPredicate(format: "1 > 0")
        if let user = UserManager.currentUser() {
            predicate1 = NSPredicate(format: "distributor_id IN %@ OR distributor_id == 0", [user.id])
        }
        let predicate3 = NSPredicate(format: "status == 1")
        //        let predicate2 = NSPredicate(format: "SUBQUERY(customers,$x, ANY $x == customers).@count >= 0")
        let predicateCompound = NSCompoundPredicate.init(type: .and, subpredicates: [predicate1,predicate3])
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "group_name", ascending: true)]
        fetchRequest.predicate = predicateCompound
        
        do {
            let result = try CoreDataStack.sharedInstance.managedObjectContext.fetch(fetchRequest)
            var list:[Group] = []
            let temp = result.flatMap({$0 as? GroupDO})
            list = temp.flatMap{Group.parse($0.toDictionary)}
            
            onComplete(list)
            
        } catch {
            let fetchError = error as NSError
            onComplete([])
            print(fetchError)
        }
    }
    
    static func getAllGroupSynced(onComplete:@escaping (([Group])->Void)) {
        // Initialize Fetch Request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "GroupDO")
        
        var predicate1 = NSPredicate(format: "1 > 0")
        if let user = UserManager.currentUser() {
            predicate1 = NSPredicate(format: "distributor_id IN %@ OR distributor_id == 0", [user.id])
        }
        let predicate3 = NSPredicate(format: "synced == false")
        //        let predicate2 = NSPredicate(format: "SUBQUERY(customers,$x, ANY $x == customers).@count >= 0")
        let predicateCompound = NSCompoundPredicate.init(type: .and, subpredicates: [predicate1,predicate3])
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "group_name", ascending: true)]
        fetchRequest.predicate = predicateCompound
        
        let container = CoreDataStack.sharedInstance.persistentContainer
        container.performBackgroundTask() { (context) in
            do {
                let result = try context.fetch(fetchRequest)
                var list:[Group] = []
                list = result.flatMap({$0 as? GroupDO}).flatMap{Group.parse($0.toDictionary)}
                
                onComplete(list)
            } catch {
                let fetchError = error as NSError
                onComplete([])
                print(fetchError)
            }
        }
    }
    
    static func update(_ list:[JSON],_ done:@escaping (()->Void)) {
        if list.count == 0 {
            done()
            return
        }
        
        let container = CoreDataStack.sharedInstance.persistentContainer
        container.performBackgroundTask() { (context) in
            var i =  1
            for item in list {
                
                let group = Group.parse(item)
                
                let listIDS = [group.id].filter{$0 != 0}
                
                if listIDS.count == 0 {
                    print("WARNING: UPDATE GroupDO WITH ID == 0. IT'S PREVENTED !!!!")
                    return
                }
                
                let entity = NSEntityDescription.entity(forEntityName: "GroupDO", in: context)
                let batchRequest = NSBatchUpdateRequest(entity: entity!)
                batchRequest.resultType = .statusOnlyResultType
                batchRequest.predicate = NSPredicate(format: "id IN %@",[group.id]);
                batchRequest.propertiesToUpdate = group.toDO
                do {
                    try context.execute(batchRequest)
                    if i == list.count {
                        try context.save()
                        DispatchQueue.main.sync {
                            done()
                        }
                    }
                } catch {
                    if i == list.count {
                        DispatchQueue.main.sync {
                            done()
                        }
                    }
                    i += 1
                    print(error)
                }
                i += 1
            }
        }
    }
    
    static func updateGroupEntity(_ group:NSManagedObject, onComplete:(()->Void)) {
        let context = CoreDataStack.sharedInstance.managedObjectContext        
        do {
            try context.save()
            print("group saved!")
        } catch let error as NSError  {
            print("Could not saved \(error), \(error.userInfo)")
        } catch {
            
        }
        onComplete()
    }
    
    static func deleteGroupEntity(_ group:NSManagedObject, onComplete:(()->Void)) {
        let context = CoreDataStack.sharedInstance.managedObjectContext
        
        do {
            context.delete(group)
            try context.save()
            print("group deleted")
        } catch let error as NSError  {
            print("Could not deleted \(error), \(error.userInfo)")
        } catch {
            
        }
        onComplete()
    }
    
    static func createGroupEntityFrom(dictionary: JSON,_ context:NSManagedObjectContext) -> NSManagedObject? {
        if let object = NSEntityDescription.insertNewObject(forEntityName: "GroupDO", into: context) as? GroupDO {
            
            object.synced = true
            
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
            
            if let data = dictionary["status"] as? String {
                object.status = Int64(data)!
            } else if let data = dictionary["status"] as? Int64 {
                object.status = data
            }
            
            if let data = dictionary["min_pv"] as? String {
                object.min_pv = Int64(data)!
            } else if let data = dictionary["min_pv"] as? Int64 {
                object.min_pv = data
            }
            
            if let data = dictionary["position"] as? String {
                object.position = Int64(data)!
            } else if let data = dictionary["position"] as? Int64 {
                object.position = data
            }
            
            if let data = dictionary["group_name"] as? String {
                object.group_name = data
            }
            
            if let data = dictionary["date_created"] as? NSDate {
                object.date_created = data
            }
            
            if let properties = dictionary["properties"] as? JSON {
                let jsonData = try! JSONSerialization.data(withJSONObject: properties)
                if let pro = String(data: jsonData, encoding: .utf8) {
                    object.properties = pro
                }
            }
            return object
        }
        return nil
    }
    
    static func clearAllDataSynced(_ onComplete:@escaping (()->Void)) {
        
        let container = CoreDataStack.sharedInstance.persistentContainer
        container.performBackgroundTask() { (context) in
            do {
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "GroupDO")
                
                fetchRequest.predicate = NSPredicate(format: "1 > 0")
                let objects  = try context.fetch(fetchRequest) as? [NSManagedObject]
                _ = objects.map {_ = $0.map({context.delete($0)})}
                try context.save()
                onComplete()
            } catch {
                onComplete()
            }
        }
    }
    
    static func clearData(_ fromList:[JSON], onComplete:(([JSON])->Void)) {
        do {
            var list:[JSON] = []
            let context = CoreDataStack.sharedInstance.managedObjectContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "GroupDO")
            
            do {
                let objects  = try context.fetch(fetchRequest) as? [NSManagedObject]
                _ = objects.map {
                    let obj = $0
                    _ = fromList.contains(where: { (item) -> Bool in
                        if let data = item["id"] as? String {
                            if let id = Int64(data) {
                                _ = obj.map{
                                    let customerDO = $0 as! GroupDO
                                    if id == customerDO.id && customerDO.synced == true {
                                        list.append(item)
                                        context.delete($0)
                                    }
                                }
                            }
                        }
                        return false
                    })
                }
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
