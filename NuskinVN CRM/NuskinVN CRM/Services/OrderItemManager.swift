//
//  ProductManager.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 10/20/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import UIKit
import CoreData

class OrderItemManager: NSObject {
    
    static func saveOrderItemWith(orerID:Int64? = 0, array: [JSON],_  onComplete:@escaping (()->Void)) {
        let container = CoreDataStack.sharedInstance.saveManagedObjectContext
        container.perform {
            for jsonObject in array {
                _ = OrderItemManager.createOrderItemEntityFrom(dictionary: jsonObject,container)
            }
            do {
                try container.save()
                onComplete()
            } catch {
                onComplete()
                fatalError("Failure to save context: \(error)")
            }
        }
    }
    
    static func getAllOrderItem(_ orderID:Int64 = 0, localID:Int64 = 0, onComplete:(([OrderItemDO])->Void)) {
        // Initialize Fetch Request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "OrderItemDO")
        
        var predicate3 = NSPredicate(format: "(1 > 0)")
        if orderID != 0 && localID != 0{
            predicate3 = NSPredicate(format: "(order_id IN %@ OR order_id IN %@)",[orderID],[localID])
        }
        let predicateCompound = NSCompoundPredicate.init(type: .and, subpredicates: [predicate3])
//        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "group_name", ascending: true)]
        fetchRequest.predicate = predicateCompound
        
        do {
            let result = try CoreDataStack.sharedInstance.saveManagedObjectContext.fetch(fetchRequest)
            var list:[OrderItemDO] = []
            list = result.flatMap({$0 as? OrderItemDO})
            onComplete(list)
            
        } catch {
            let fetchError = error as NSError
            onComplete([])
            print(fetchError)
        }
    }
    
    static func updateOrderItemEntity(_ group:NSManagedObject, onComplete:(()->Void)) {
        let context = CoreDataStack.sharedInstance.saveManagedObjectContext
        do {
            try context.save()
            print("order item saved!")
        } catch let error as NSError  {
            print("Could not saved \(error), \(error.userInfo)")
        } catch {
            
        }
        onComplete()
    }
    
    static func deleteOrderItemEntity(_ group:NSManagedObject, onComplete:(()->Void)) {
        let context = CoreDataStack.sharedInstance.saveManagedObjectContext
    
        do {
            context.delete(group)
            try context.save()
            print("order item deleted")
        } catch let error as NSError  {
            print("Could not deleted \(error), \(error.userInfo)")
        } catch {
            
        }
        onComplete()
    }
    
    static func createOrderItemEntityFrom(dictionary: JSON,_ context:NSManagedObjectContext){
        if let object = NSEntityDescription.insertNewObject(forEntityName: "OrderItemDO", into: context) as? OrderItemDO {
            
            object.synced = false
            
            if let data = dictionary["id"] as? String {
                object.id = Int64(data)!
            } else if let data = dictionary["id"] as? Int64 {
                object.id = data
            }
            
            if let data = dictionary["order_id"] as? String {
                object.order_id = Int64(data)!
            } else if let data = dictionary["order_id"] as? Int64 {
                object.order_id = data
            }
            
            if let data = dictionary["product_id"] as? String {
                object.product_id = Int64(data)!
            } else if let data = dictionary["product_id"] as? Int64 {
                object.product_id = data
            }
           
            if let data = dictionary["quantity"] as? String {
                object.quantity = Int64(data)!
            } else if let data = dictionary["quantity"] as? Int64 {
                object.quantity = data
            }
            
            if let data = dictionary["price"] as? String {
                object.price = Int64(data)!
            } else if let data = dictionary["price"] as? Int64 {
                object.price = data
            }
            do{try? context.save()}
        }
    }
    
    static func clearData(_ orderID:Int64? = 0, fromList:[JSON], onComplete:(([JSON]?)->Void)) {
        do {
            let context = CoreDataStack.sharedInstance.saveManagedObjectContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "OrderItemDO")
            
            fetchRequest.predicate = NSPredicate(format: "order_id IN %@",[orderID])
            do {
                let objects  = try context.fetch(fetchRequest) as? [NSManagedObject]
                _ = objects.map {_ = $0.map({context.delete($0)})}
                
                onComplete(fromList)
                
            } catch let error {
                print("ERROR DELETING : \(error)")
            }
        }
    }
    
    static func clearData(from:Int64? = 0, onComplete:(()->Void)) {
        do {
            let context = CoreDataStack.sharedInstance.saveManagedObjectContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "OrderItemDO")
            
            fetchRequest.predicate = NSPredicate(format: "order_id IN %@",[from])
            do {
                let objects  = try context.fetch(fetchRequest) as? [NSManagedObject]
                _ = objects.map {_ = $0.map({context.delete($0)})}
                
                onComplete()
                
            } catch let error {
                print("ERROR DELETING : \(error)")
            }
        }
    }
    
    static func resetData(_ onComplete:@escaping (()->Void)) {
        let container = CoreDataStack.sharedInstance.persistentContainer
        container.performBackgroundTask() { (context) in
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "OrderItemDO")
            
            
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
    
    static func resetData(from:[Int64], onComplete:(()->Void)) {
        if from.count == 0 {
            onComplete()
            return
        }
        do {
            let context = CoreDataStack.sharedInstance.saveManagedObjectContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "OrderItemDO")
            
            fetchRequest.predicate = NSPredicate(format: "order_id IN %@",from)
            do {
                let objects  = try context.fetch(fetchRequest) as? [NSManagedObject]
                _ = objects.map {_ = $0.map({context.delete($0)})}
                
                onComplete()
                
            } catch let error {
                onComplete()
                print("ERROR DELETING : \(error)")
            }
        }
    }
}
