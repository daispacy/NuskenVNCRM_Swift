//
//  ProductDO+CoreDataClass.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 10/22/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//
//

import Foundation
import CoreData

@objc(ProductDO)
public class ProductDO: NSManagedObject {
    //MARK: - Initialize
    convenience init(needSave: Bool,  context: NSManagedObjectContext?) {
        
        // Create the NSEntityDescription
        let entity = NSEntityDescription.entity(forEntityName: "ProductDO", in: context!)
        
        if(!needSave) {
            self.init(entity: entity!, insertInto: nil)
        } else {
            self.init(entity: entity!, insertInto: context)
        }
    }
    
    var toDictionary:[String:Any] {
        
        return [
            "id":id,
            "store_id":store_id,
            "cat_id":cat_id,
            "series":series,
            "sku":sku ?? "",
            "pv":pv,
            "price":price,
            "retail_price":retail_price,
            "status":status,
            "name":name ?? "",
            "avatar":avatar ?? "",
            "date_created":date_created as Any,
            "updated":updated_ as Any,
            "properties":properties ?? ""
        ]
    }
}
