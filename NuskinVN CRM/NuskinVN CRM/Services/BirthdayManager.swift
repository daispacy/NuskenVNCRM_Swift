//
//  ProductManager.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 10/20/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import UIKit
import CoreData

class BirthdayManager: NSObject {
    
    static func saveBirthday( array: [JSON]) {
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
            if checkBirthday(list) {
                _ = BirthdayManager.createBirthdayEntityFrom(dictionary: $0)
            }
        }
        do {
            try CoreDataStack.sharedInstance.managedObjectContext.save()
        } catch let error {
            print(error)
        }
    }
    
    static func checkBirthday(_ customerID:[Int64] = []) -> Bool {
        if customerID.count == 0 {return true}
        // Initialize Fetch Request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "BirthdayDO")
        
        let predicate3 = NSPredicate(format: "(customer_id IN %@ OR customer_local_id IN %@)",customerID,customerID)
        
        let predicateCompound = NSCompoundPredicate.init(type: .and, subpredicates: [predicate3])
//        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "group_name", ascending: true)]
        fetchRequest.predicate = predicateCompound
        
        do {
            let result = try CoreDataStack.sharedInstance.managedObjectContext.fetch(fetchRequest)
            return result.count == 0
            
            
        } catch {
            return true
        }
    }
    
    
    
    static func createBirthdayEntityFrom(dictionary: JSON) -> NSManagedObject? {
        let context = CoreDataStack.sharedInstance.managedObjectContext
        if let object = NSEntityDescription.insertNewObject(forEntityName: "BirthdayDO", into: context) as? BirthdayDO {
            
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
                       
            if let data = dictionary["birthday"] as? NSDate {
                object.birthday = data
            }
            
            return object
        }
        return nil
    }
    
    static func clearData(_ onComplete:@escaping (()->Void)) {
        let container = CoreDataStack.sharedInstance.persistentContainer
        container.performBackgroundTask() { (context) in
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "BirthdayDO")
            
            fetchRequest.predicate = NSPredicate(format: "birthday > %@ AND birthday < %@",Date(timeIntervalSinceNow: 0) as NSDate,Date(timeIntervalSinceNow: 0) as NSDate)
            do {
                let objects  = try context.fetch(fetchRequest) as? [NSManagedObject]
                _ = objects.map {_ = $0.map({context.delete($0)})}
                try context.save()
                 onComplete()
            } catch {
                 onComplete()
            }
        }
    }
}
