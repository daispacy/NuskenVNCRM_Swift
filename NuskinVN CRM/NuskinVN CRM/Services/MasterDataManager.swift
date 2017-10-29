//
//  MasterDataManager.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 10/28/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import Foundation
import CoreData

class MasterDataManager: NSObject {
    static func saveDataWith(_ array: [JSON]) {
        MasterDataManager.clearData({
            if array.count > 0 {
                _ = array.map{MasterDataManager.createDataEntityFrom(dictionary: $0)}
            }
            do {
                try CoreDataStack.sharedInstance.persistentContainer.viewContext.save()
            } catch let error {
                print(error)
            }
        })
    }
    
    static func getData(_ type:String) -> [MasterDataDO]{
        // Initialize Fetch Request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "MasterDataDO")
        fetchRequest.returnsObjectsAsFaults = false
        let predicate3 = NSPredicate(format: "data_type == %@ AND status == 1",type)
        
        let predicateCompound = NSCompoundPredicate.init(type: .and, subpredicates: [predicate3])
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        fetchRequest.predicate = predicateCompound
        
        do {
            let result = try CoreDataStack.sharedInstance.persistentContainer.viewContext.fetch(fetchRequest)
            var list:[MasterDataDO] = []
            list = result.flatMap({$0 as? MasterDataDO})
            return list
            
        } catch {
            let fetchError = error as NSError
            print(fetchError)
            return []
        }
    }
    
    static func createDataEntityFrom(dictionary: JSON) -> NSManagedObject? {
        let context = CoreDataStack.sharedInstance.persistentContainer.viewContext
        if let object = NSEntityDescription.insertNewObject(forEntityName: "MasterDataDO", into: context) as? MasterDataDO {
            
            if let data = dictionary["id"] as? String {
                object.id = Int64(data)!
            } else if let data = dictionary["id"] as? Int64 {
                object.id = data
            }
            
            if let data = dictionary["data_value"] as? String {
                object.data_value = Int64(data)!
            } else if let data = dictionary["data_value"] as? Int64 {
                object.data_value = data
            }
            
            if let data = dictionary["status"] as? String {
                object.status = Int64(data)!
            } else if let data = dictionary["status"] as? Int64 {
                object.status = data
            }
            
            if let data = dictionary["data_type"] as? String {
                object.data_type = data
            }
            
            if let data = dictionary["data_name"] as? String {
                object.data_name = data
            }
            
            if let data = dictionary["data_text"] as? String {
                object.data_text = data
            }
            
            return object
        }
        return nil
    }
    
    static func clearData(_ complete:(()->Void)) {
        do {
            
            let context = CoreDataStack.sharedInstance.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "MasterDataDO")
            fetchRequest.returnsObjectsAsFaults = false
            do {
                let objects  = try context.fetch(fetchRequest) as? [NSManagedObject]
                _ = objects.map {
                    $0.map({context.delete($0)})
                }
                CoreDataStack.sharedInstance.saveContext()
                complete()
            } catch let error {
                print("ERROR DELETING : \(error)")
                complete()
            }
        }
    }
}
