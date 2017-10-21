//
//  CustomerDO+CoreDataProperties.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 10/20/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//
//

import Foundation
import CoreData


extension CustomerDO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CustomerDO> {
        return NSFetchRequest<CustomerDO>(entityName: "CustomerDO")
    }

    @NSManaged public var address: String?
    @NSManaged public var area_id: Int64
    @NSManaged public var city: String?
    @NSManaged public var county: String?
    @NSManaged public var date_created: NSDate?
    @NSManaged public var distributor_id: Int64
    @NSManaged public var email: String?
    @NSManaged public var facebook: String?
    @NSManaged public var fullname: String?
    @NSManaged public var gender: Int64
    @NSManaged public var group_id: Int64
    @NSManaged public var id: Int64
    @NSManaged public var last_login: NSDate?
    @NSManaged public var password: String?
    @NSManaged public var properties: String?
    @NSManaged public var skype: String?
    @NSManaged public var status: Int64
    @NSManaged public var store_id: Int64
    @NSManaged public var tel: String?
    @NSManaged public var type: Int64
    @NSManaged public var username: String?
    @NSManaged public var viber: String?
    @NSManaged public var zalo: String?
    @NSManaged public var group_name: String?
    @NSManaged public var synced: Bool
    @NSManaged public var avatar: String?
    @NSManaged public var group: NSSet?

}
