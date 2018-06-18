//
//  GroupProductDO+CoreDataProperties.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 10/27/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//
//

import Foundation
import CoreData


extension GroupProductDO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<GroupProductDO> {
        return NSFetchRequest<GroupProductDO>(entityName: "GroupProductDO")
    }

    @NSManaged public var id: Int64
    @NSManaged public var parent_id: Int64
    @NSManaged public var store_id: Int64
    @NSManaged public var slug: String?
    @NSManaged public var name: String?
    @NSManaged public var keyword: String?
    @NSManaged public var sapo: String?
    @NSManaged public var position: Int64
    @NSManaged public var viewed: Int64
    @NSManaged public var properties: String?
    @NSManaged public var status: Int64

}
