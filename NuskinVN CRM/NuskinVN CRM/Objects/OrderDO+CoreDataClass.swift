//
//  OrderDO+CoreDataClass.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 10/22/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//
//

import Foundation
import CoreData

@objc(OrderDO)
public class OrderDO: NSManagedObject {
    
    //MARK: - Initialize
    convenience init(needSave: Bool,  context: NSManagedObjectContext?) {
        
        // Create the NSEntityDescription
        let entity = NSEntityDescription.entity(forEntityName: "OrderDO", in: context!)
        
        if(!needSave) {
            self.init(entity: entity!, insertInto: nil)
        } else {
            self.init(entity: entity!, insertInto: context)
        }
    }
    
    var toDictionary:[String:Any] {
        
        return [
            "code":code ?? "",
            "id":id,
            "local_id":local_id,
            "store_id":store_id,
            "distributor_id":distributor_id,
            "customer_id":customer_id,
            "status":status,
            "payment_status":payment_status,
            "payment_option":payment_option,
            "shipping_unit":shipping_unit,
            "svd":svd ?? "",
            "email":email ?? "",
            "tel":tel ?? "",
            "cell":cell ?? "",
            "address":address ?? "",
            "date_created":date_created as Any,
            "last_updated":last_updated as Any,
            "properties":properties ?? "",
            "synced":synced
        ]
    }
}
