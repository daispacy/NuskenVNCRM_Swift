//
//  CustomerDO+CoreDataClass.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 10/20/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//
//

import Foundation
import CoreData

@objc(CustomerDO)
public class CustomerDO: NSManagedObject {

    static func isExist(email:String,except:Bool) -> Bool{
        
        if email.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines).characters.count == 0 {
            return false
        }
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CustomerDO")
        
        var predicate = NSPredicate(format: "email = '%@'", email)
        if except {
            predicate = NSPredicate(format: "email = '%@' AND email <> '%@'", email,email)
        }
        
        fetchRequest.predicate = predicate
        do {
            
            let results = try CoreDataStack.sharedInstance.persistentContainer.viewContext.fetch(fetchRequest)
            
            return results.count == 0
            
        } catch let error as NSError {
            
            print(error)
            
        }
        return true
    }
    
    var isShouldOpenFunctionView:Bool {
        return zalo != nil && facebook != nil && viber != nil && skype != nil
    }
}
