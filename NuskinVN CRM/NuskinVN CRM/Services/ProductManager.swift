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
    
    static func getAllProducts(search:String? = nil, onComplete:(([ProductDO])->Void)) {
        // Initialize Fetch Request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ProductDO")
        fetchRequest.returnsObjectsAsFaults = false
        var predicate2 = NSPredicate(format: "1 > 0")
        let predicate3 = NSPredicate(format: "status == 1")
        if let text = search {
            if text.characters.count > 0 {
                predicate2 = NSPredicate(format: "name contains[cd] %@ OR keyword contains[cd] %@",text,text)
            }
        }
        
        let predicateCompound = NSCompoundPredicate.init(type: .and, subpredicates: [predicate2,predicate3])
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "price", ascending: true),NSSortDescriptor(key: "retail_price", ascending: true)]
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
    
    static func saveProducctWith(array: [JSON]) {
        ProductManager.clearData(array,onComplete: { array in
            if array.count > 0 {
                _ = array.map{ProductManager.createProductEntityFrom(dictionary: $0)}
            }
            do {
                try CoreDataStack.sharedInstance.persistentContainer.viewContext.save()
            } catch let error {
                print(error)
            }
        })
    }
    
    static func updateProductEntity(_ product:NSManagedObject, onComplete:(()->Void)) {
        let context = CoreDataStack.sharedInstance.persistentContainer.viewContext
        do {
            try context.save()
            print("product saved!")
        } catch let error as NSError  {
            print("Could not saved \(error), \(error.userInfo)")
        } catch {
            
        }
        onComplete()
    }
    
    static func createProductEntityFrom(dictionary: JSON) -> NSManagedObject? {
        let context = CoreDataStack.sharedInstance.persistentContainer.viewContext
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
    
    static func clearData(_ fromList:[JSON], onComplete:(([JSON])->Void)) {
        do {
            var list:[JSON] = []
            let context = CoreDataStack.sharedInstance.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ProductDO")
            fetchRequest.returnsObjectsAsFaults = false
            do {
                let objects  = try context.fetch(fetchRequest) as? [NSManagedObject]
                _ = objects.map {
                    let obj = $0
                    _ = fromList.contains(where: { (item) -> Bool in
                        if let data = item["id"] as? String {
                            if let id = Int64(data) {
                                _ = obj.map{
                                    let productDO = $0 as! ProductDO
                                    if id == productDO.id {
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
