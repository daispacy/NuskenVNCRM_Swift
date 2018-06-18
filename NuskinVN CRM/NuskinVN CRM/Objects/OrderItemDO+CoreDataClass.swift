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
}
