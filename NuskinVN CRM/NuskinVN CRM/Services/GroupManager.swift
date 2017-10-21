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
    
    static func syncGroups(onComplete:@escaping (([GroupDO])->Void)) {
        SyncService.shared.getAllGroup(completion: { result in
            switch result {
            case .success(let data):
                if data.count > 0 {
                    print("SAVE GROUP TO CORE DATA")
                    GroupManager.saveGroupWith(array: data)
                }
                GroupManager.getAllGroup(onComplete: { (list) in
                    onComplete(list)
                })
                
            case .failure(_):
                print("Error: cant get group from server 2")
                onComplete([])
                break
            }
        })
    }
    
    static func saveGroupWith(array: [JSON]) {
        clearData(array,onComplete: { array in
            if array.count > 0 {
                _ = array.map{GroupManager.createGroupEntityFrom(dictionary: $0)}
            }
            do {
                try CoreDataStack.sharedInstance.persistentContainer.viewContext.save()
            } catch let error {
                print(error)
            }
        })
    }
    
    static func getAllGroup(onComplete:(([GroupDO])->Void)) {
        // Initialize Fetch Request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        let predicate1 = NSPredicate(format: "distributor_id == %d OR distributor_id == 0", UserManager.currentUser().id_card_no)
        let predicate3 = NSPredicate(format: "status == 1")
//        let predicate2 = NSPredicate(format: "SUBQUERY(customers,$x, ANY $x == customers).@count >= 0")
        let predicateCompound = NSCompoundPredicate.init(type: .and, subpredicates: [predicate1,predicate3])
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "group_name", ascending: true)]
        fetchRequest.predicate = predicateCompound
        // Create Entity Description
        let entityDescription = NSEntityDescription.entity(forEntityName: "GroupDO", in: CoreDataStack.sharedInstance.persistentContainer.viewContext)
        
        // Configure Fetch Request
        fetchRequest.entity = entityDescription
        
        do {
            let result = try CoreDataStack.sharedInstance.persistentContainer.viewContext.fetch(fetchRequest)
            var list:[GroupDO] = []
            list = result.flatMap({$0 as? GroupDO})
            onComplete(list)
            
        } catch {
            let fetchError = error as NSError
            onComplete([])
            print(fetchError)
        }
    }
    
    static func updateGroupEntity(_ group:NSManagedObject, onComplete:(()->Void)) {
        let context = CoreDataStack.sharedInstance.persistentContainer.viewContext        
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
        let context = CoreDataStack.sharedInstance.persistentContainer.viewContext
    
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
    
    static func createGroupEntityFrom(dictionary: JSON) -> NSManagedObject? {
        let context = CoreDataStack.sharedInstance.persistentContainer.viewContext
        if let object = NSEntityDescription.insertNewObject(forEntityName: "GroupDO", into: context) as? GroupDO {
            
            object.synced = true
            
            if let data = dictionary["id"] as? String {
                object.id = Int64(data)!
            } else if let data = dictionary["id"] as? Int64 {
                object.id = data
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
    
    static func clearData(_ fromList:[JSON], onComplete:(([JSON])->Void)) {
        do {
            var list:[JSON] = []
            let context = CoreDataStack.sharedInstance.persistentContainer.viewContext
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
