//
//  ProductManager.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 10/20/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import UIKit
import CoreData

class NotOrder30DOManager: NSObject {
    
    static func saveRemind( array: [JSON]) {
        _ = array.map{
            
            var customer_id:Int64 = 0
            var customer_local_id:Int64 = 0
            if let data = $0["customer_id"] as? String {
                customer_id = Int64(data)!
            } else if let data = $0["customer_id"] as? Int64 {
                customer_id = data
            }
            
            if let data = $0["customer_local_id"] as? String {
                customer_local_id = Int64(data)!
            } else if let data = $0["customer_local_id"] as? Int64 {
                customer_local_id = data
            }
            var list:[Int64] = [customer_id,customer_local_id]
            list = list.filter{$0 != 0}
            if !checkRemind(list) {
                _ = NotOrder30DOManager.createBirthdayEntityFrom(dictionary: $0)
            }
        }
        do {
            try CoreDataStack.sharedInstance.saveManagedObjectContext.save()
        } catch let error {
            print(error)
        }
    }
    
    static func checkRemind(_ customerID:[Int64] = []) -> Bool {
        if customerID.count == 0 {return false}
        // Initialize Fetch Request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "NotOrder30DO")
        
        let predicate3 = NSPredicate(format: "(customer_id IN %@ OR customer_local_id IN %@)",customerID,customerID)
        
        let predicateCompound = NSCompoundPredicate.init(type: .and, subpredicates: [predicate3])
//        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "group_name", ascending: true)]
        fetchRequest.predicate = predicateCompound
        
        do {
            let result = try CoreDataStack.sharedInstance.saveManagedObjectContext.fetch(fetchRequest)
            let a = result.flatMap{$0 as? NotOrder30DO}
            let b = a.filter({if Int(($0.date_remind?.timeIntervalSinceNow)!) > -2592000 {
                return true
                } else {
                    return false
                }
            })
            return b.count > 0
            
            
        } catch {
            return false
        }
    }
    
    
    
    static func createBirthdayEntityFrom(dictionary: JSON) -> NSManagedObject? {
        let context = CoreDataStack.sharedInstance.saveManagedObjectContext
        if let object = NSEntityDescription.insertNewObject(forEntityName: "NotOrder30DO", into: context) as? NotOrder30DO {
            
            if let data = dictionary["customer_id"] as? String {
                object.customer_id = Int64(data)!
            } else if let data = dictionary["customer_id"] as? Int64 {
                object.customer_id = data
            }
            
            if let data = dictionary["customer_local_id"] as? String {
                object.customer_local_id = Int64(data)!
            } else if let data = dictionary["customer_local_id"] as? Int64 {
                object.customer_local_id = data
            }
                       
            if let data = dictionary["date_remind"] as? NSDate {
                object.date_remind = data
            }
            
            return object
        }
        return nil
    }
}
