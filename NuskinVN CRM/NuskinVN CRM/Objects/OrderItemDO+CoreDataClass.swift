//
//  OrderItemDO+CoreDataClass.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 10/22/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//
//

import Foundation
import CoreData

@objc(OrderItemDO)
public class OrderItemDO: NSManagedObject {

    var productManage:ProductDO?
    
    var toDictionary:[String:Any] {
        return [
            "id":id,
            "name":name ?? "",
            "order_id":order_id,
            "product_id":product_id,
            "price":price,
            "quantity":quantity
        ]
    }
    
    func product() -> ProductDO? {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ProductDO")
        fetchRequest.predicate = NSPredicate(format: "id IN %@", [product_id])
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let result = try CoreDataStack.sharedInstance.persistentContainer.viewContext.fetch(fetchRequest)
            var list:[ProductDO] = []
            list = result.flatMap({$0 as? ProductDO})
            if list.count > 0 {
                productManage = list[0]
                return list[0]
            }
            
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
        
        return nil
    }
}
