//
//  OrderItemDO+CoreDataProperties.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 10/22/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//
//

import Foundation
import CoreData


extension OrderItemDO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<OrderItemDO> {
        return NSFetchRequest<OrderItemDO>(entityName: "OrderItemDO")
    }

    @NSManaged public var id: Int64
    @NSManaged public var name: String?
    @NSManaged public var order_id: Int64
    @NSManaged public var price: Int64
    @NSManaged public var product_id: Int64
    @NSManaged public var quantity: Int64
    @NSManaged public var synced: Bool

}
