//
//  UserDO+CoreDataProperties.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 10/28/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//
//

import Foundation
import CoreData


extension UserDO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserDO> {
        return NSFetchRequest<UserDO>(entityName: "UserDO")
    }

    @NSManaged public var address: String?
    @NSManaged public var cell: String?
    @NSManaged public var date_created: NSDate?
    @NSManaged public var email: String?
    @NSManaged public var fullname: String?
    @NSManaged public var id_card_no: Int64
    @NSManaged public var id: Int64
    @NSManaged public var last_login: NSDate?
    @NSManaged public var properties: String?
    @NSManaged public var status: Int64
    @NSManaged public var store_id: Int64
    @NSManaged public var tel: String?
    @NSManaged public var type: Int64
    @NSManaged public var username: String?
    @NSManaged public var avatar: String?
    @NSManaged public var device_token: String?
    @NSManaged public var synced: Bool

}
