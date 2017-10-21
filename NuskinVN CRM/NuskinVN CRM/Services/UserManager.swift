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
    
    static func currentUser() -> UserDO {
        // Initialize Fetch Request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        
        // Create Entity Description
        let entityDescription = NSEntityDescription.entity(forEntityName: "UserDO", in: CoreDataStack.sharedInstance.persistentContainer.viewContext)
        
        // Configure Fetch Request
        fetchRequest.entity = entityDescription
        
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
