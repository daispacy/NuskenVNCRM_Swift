//
//  ProductDO+CoreDataProperties.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 10/22/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//
//

import Foundation
import CoreData


extension ProductDO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ProductDO> {
        return NSFetchRequest<ProductDO>(entityName: "ProductDO")
    }

    @NSManaged public var avatar: String?
    @NSManaged public var cat_id: Int64
    @NSManaged public var currency: Float
    @NSManaged public var date_created: NSDate?
    @NSManaged public var description_: String?
    @NSManaged public var detail: String?
    @NSManaged public var home: Int64
    @NSManaged public var id: Int64
    @NSManaged public var keyword: String?
    @NSManaged public var market_price: Double
    @NSManaged public var name: String?
    @NSManaged public var position: Int64
    @NSManaged public var price: Int64
    @NSManaged public var properties: String?
    @NSManaged public var pv: Int64
    @NSManaged public var series: Int64
    @NSManaged public var sku: String?
    @NSManaged public var slug: String?
    @NSManaged public var status: Int64
    @NSManaged public var store_id: Int64
    @NSManaged public var updated_: NSDate?
    @NSManaged public var viewed: Int64

}
