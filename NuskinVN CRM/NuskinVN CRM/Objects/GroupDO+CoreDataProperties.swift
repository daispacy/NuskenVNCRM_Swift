//
//  GroupDO+CoreDataProperties.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 10/24/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//
//

import Foundation
import CoreData


extension GroupDO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<GroupDO> {
        return NSFetchRequest<GroupDO>(entityName: "GroupDO")
    }

    @NSManaged public var date_created: NSDate?
    @NSManaged public var distributor_id: Int64
    @NSManaged public var group_name: String?
    @NSManaged public var id: Int64
    @NSManaged public var isTemp: Bool
    @NSManaged public var min_pv: Int64
    @NSManaged public var position: Int64
    @NSManaged public var properties: String?
    @NSManaged public var status: Int64
    @NSManaged public var store_id: Int64
    @NSManaged public var synced: Bool
    @NSManaged public var local_id: Int64

}
