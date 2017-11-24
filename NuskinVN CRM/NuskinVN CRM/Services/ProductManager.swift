//
//  ProductManager.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 10/20/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import UIKit
import CoreData

class ProductManager: NSObject {
    
    static func getAllProducts(search:String? = nil,groupID:Int64? = 0, onComplete:(([ProductDO])->Void)) {
        // Initialize Fetch Request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ProductDO")
        fetchRequest.returnsObjectsAsFaults = false
        var predicate2 = NSPredicate(format: "1 > 0")
        var predicate1 = NSPredicate(format: "1 > 0")
        let predicate3 = NSPredicate(format: "status == 1")
        if let text = search {
            if text.characters.count > 0 {
                predicate2 = NSPredicate(format: "name contains[cd] %@ OR keyword contains[cd] %@",text,text)
            }
        }
        if let id = groupID {
            if id > 0 {
                predicate1 = NSPredicate(format: "cat_id IN %@",[id])
            }
        }
        
        let predicateCompound = NSCompoundPredicate.init(type: .and, subpredicates: [predicate1,predicate2,predicate3])
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "price", ascending: true)]
        fetchRequest.predicate = predicateCompound
        
        do {
            let result = try CoreDataStack.sharedInstance.persistentContainer.viewContext.fetch(fetchRequest)
            var list:[ProductDO] = []
            list = result.flatMap({$0 as? ProductDO})
            onComplete(list)
            
        } catch {
            let fetchError = error as NSError
            onComplete([])
            print(fetchError)
        }
    }
    
    static func getAllGroups(_ onComplete:(([GroupProductDO])->Void)) {
        // Initialize Fetch Request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "GroupProductDO")
        fetchRequest.returnsObjectsAsFaults = false
        
        let predicate3 = NSPredicate(format: "status == 1")
        let predicateCompound = NSCompoundPredicate.init(type: .and, subpredicates: [predicate3])
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        fetchRequest.predicate = predicateCompound
        
        do {
            let result = try CoreDataStack.sharedInstance.persistentContainer.viewContext.fetch(fetchRequest)
            var list:[GroupProductDO] = []
            list = result.flatMap({$0 as? GroupProductDO})
            onComplete(list)
            
        } catch {
            let fetchError = error as NSError
            onComplete([])
            print(fetchError)
        }
    }
    
    static func saveProducctWith(array: [JSON],_ onComplete:@escaping (()->Void)) {
        ProductManager.clearDataProduct {
            let container = CoreDataStack.sharedInstance.persistentContainer
            container.performBackgroundTask() { (context) in
                for jsonObject in array {
                    _ = ProductManager.createProductEntityFrom(dictionary:jsonObject,context)
                }
                do {
                    try context.save()
                    onComplete()
                } catch {
                    onComplete()
                }
            }
        }
    }
    
    static func saveGroupWith(array: [JSON],_ onComplete:@escaping (()->Void)) {
        ProductManager.clearDataGroupProduct {
            let container = CoreDataStack.sharedInstance.persistentContainer
            container.performBackgroundTask() { (context) in
                for jsonObject in array {
                    _ = ProductManager.createGroupEntityFrom(dictionary: jsonObject,context)
                }
                do {
                    try context.save()
                    onComplete()
                } catch {
                    onComplete()
                }
            }
        }
    }
    
    static func createProductEntityFrom(dictionary: JSON,_ context:NSManagedObjectContext) -> NSManagedObject? {
        if let object = NSEntityDescription.insertNewObject(forEntityName: "ProductDO", into: context) as? ProductDO {
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
            
            if let data = dictionary["cat_id"] as? String {
                object.cat_id = Int64(data)!
            } else if let data = dictionary["cat_id"] as? Int64 {
                object.cat_id = data
            }
            if let data = dictionary["series"] as? String {
                object.series = Int64(data)!
            } else if let data = dictionary["series"] as? Int64 {
                object.series = data
            }
            
            if let data = dictionary["sku"] as? String {
                object.sku = data
            } else if let data = dictionary["sku"] as? Int64 {
                object.sku = "\(data)"
            }
            
            if let data = dictionary["pv"] as? String {
                object.pv = Int64(data)!
            } else if let data = dictionary["pv"] as? Int64 {
                object.pv = data
            }
            if let data = dictionary["price"] as? String {
                object.price = Int64(data)!
            } else if let data = dictionary["price"] as? Int64 {
                object.price = data
            }
            if let data = dictionary["retail_price"] as? String {
                object.retail_price = Int64(data)!
            } else if let data = dictionary["retail_price"] as? Int64 {
                object.retail_price = data
            }
            if let data = dictionary["status"] as? String {
                object.status = Int64(data)!
            } else if let data = dictionary["status"] as? Int64 {
                object.status = data
            }
           
            if let data = dictionary["name"] as? String {
                object.name = data
            }
            if let data = dictionary["keyword"] as? String {
                object.keyword = data
            }
            if let data = dictionary["avatar"] as? String {
                object.avatar = data
            }
            
            if let data = dictionary["date_created"] as? NSDate {
                object.date_created = data
            }
            if let data = dictionary["updated"] as? NSDate {
                object.updated_ = data
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
    
    static func createGroupEntityFrom(dictionary: JSON,_ context:NSManagedObjectContext) -> NSManagedObject? {
        if let object = NSEntityDescription.insertNewObject(forEntityName: "GroupProductDO", into: context) as? GroupProductDO {
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
            
            if let data = dictionary["parent_id"] as? String {
                object.parent_id = Int64(data)!
            } else if let data = dictionary["parent_id"] as? Int64 {
                object.parent_id = data
            }
            if let data = dictionary["position"] as? String {
                object.position = Int64(data)!
            } else if let data = dictionary["position"] as? Int64 {
                object.position = data
            }
            
            if let data = dictionary["slug"] as? String {
                object.slug = data
            } else if let data = dictionary["slug"] as? Int64 {
                object.slug = "\(data)"
            }
            
            if let data = dictionary["viewed"] as? String {
                object.viewed = Int64(data)!
            } else if let data = dictionary["viewed"] as? Int64 {
                object.viewed = data
            }
            
            if let data = dictionary["status"] as? String {
                object.status = Int64(data)!
            } else if let data = dictionary["status"] as? Int64 {
                object.status = data
            }
            
            if let data = dictionary["name"] as? String {
                object.name = data
            }
            
            if let data = dictionary["sapo"] as? String {
                object.sapo = data
            }
            
            if let data = dictionary["keyword"] as? String {
                object.keyword = data
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
    
    static func clearDataProduct(_ complete:(()->Void)) {
        do {
            
            let context = CoreDataStack.sharedInstance.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ProductDO")
            fetchRequest.returnsObjectsAsFaults = false
            do {
                let objects  = try context.fetch(fetchRequest) as? [NSManagedObject]
                _ = objects.map {
                    $0.map({context.delete($0)})
                }
                
                complete()
            } catch let error {
                print("ERROR DELETING : \(error)")
                complete()
            }
        }
    }
    
    static func clearDataGroupProduct(_ complete:(()->Void)) {
        do {
            
            let context = CoreDataStack.sharedInstance.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "GroupProductDO")
            fetchRequest.returnsObjectsAsFaults = false
            do {
                let objects  = try context.fetch(fetchRequest) as? [NSManagedObject]
                _ = objects.map {
                    $0.map({context.delete($0)})
                }
                complete()
            } catch let error {
                print("ERROR DELETING : \(error)")
                complete()
            }
        }
    }
}
