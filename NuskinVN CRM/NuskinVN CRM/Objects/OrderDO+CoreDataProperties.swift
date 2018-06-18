//
//  OrderDO+CoreDataProperties.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 10/22/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//
//

import Foundation
import CoreData


extension OrderDO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<OrderDO> {
        return NSFetchRequest<OrderDO>(entityName: "OrderDO")
    }

    @NSManaged public var id: Int64
    @NSManaged public var local_id: Int64
    @NSManaged public var store_id: Int64
    @NSManaged public var customer_id: Int64
    @NSManaged public var distributor_id: Int64
    @NSManaged public var user_type: Int64
    @NSManaged public var code: String?
    @NSManaged public var name: String?
    @NSManaged public var email: String?
    @NSManaged public var address: String?
    @NSManaged public var province: String?
    @NSManaged public var tel: String?
    @NSManaged public var cell: String?
    @NSManaged public var rname: String?
    @NSManaged public var raddress: String?
    @NSManaged public var rprovince: String?
    @NSManaged public var rtell: String?
    @NSManaged public var rcell: String?
    @NSManaged public var rdate: NSDate?
    @NSManaged public var rnote: String?
    @NSManaged public var date_created: NSDate?
    @NSManaged public var last_updated: NSDate?
    @NSManaged public var properties: String?
    @NSManaged public var status: Int64
    @NSManaged public var payment_status: Int64
    @NSManaged public var validity: String?
    @NSManaged public var total: Int64
    @NSManaged public var number_domain: Int64
    @NSManaged public var synced: Bool
    @NSManaged public var payment_option: Int64
    @NSManaged public var svd: String?
    @NSManaged public var shipping_unit: Int64

}
