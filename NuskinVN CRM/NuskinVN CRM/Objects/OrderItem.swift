//
//  OrderItem.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 11/26/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import Foundation
import CoreData

struct OrderItem {
   var id: Int64 = 0
   var name: String = ""
   var order_id: Int64 = 0
   var price: Int64 = 0
   var product_id: Int64 = 0
   var quantity: Int64 = 0
   var synced: Bool = true
    
    
    func product() -> Product? {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ProductDO")
        fetchRequest.predicate = NSPredicate(format: "id IN %@", [product_id])
        
        
        do {
            let result = try CoreDataStack.sharedInstance.managedObjectContext.fetch(fetchRequest)
            var list:[Product] = []
            let temp = result.flatMap({$0 as? ProductDO})
            list = temp.flatMap{Product.parse($0.toDictionary)}
            if list.count > 0 {
                return list.first!
            }
            
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
        
        return nil
    }
    
    var toDictionary:[String:Any] {
        return [
            "id":id,
            "name":name,
            "order_id":order_id,
            "product_id":product_id,
            "price":price,
            "quantity":quantity
        ]
    }
}

extension OrderItem {
    static func parse(_ dictionary:JSON) -> OrderItem{
        var object = OrderItem()
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
        
        if let data = dictionary["synced"] as? Bool {
            object.synced = data
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
        
        return object
    }
}
