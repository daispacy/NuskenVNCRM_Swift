//
//  GroupDO+CoreDataClass.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 10/24/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//
//

import Foundation
import CoreData

@objc(GroupDO)
public class GroupDO: NSManagedObject {

    //MARK: - Initialize
    convenience init(needSave: Bool,  context: NSManagedObjectContext?) {
        
        // Create the NSEntityDescription
        let entity = NSEntityDescription.entity(forEntityName: "GroupDO", in: context!)
        
        if(!needSave) {
            self.init(entity: entity!, insertInto: nil)
            isTemp = true
        } else {
            self.init(entity: entity!, insertInto: context)
        }
    }
    
    var toDictionary:[String:Any] {
        return [            
            "group_name":group_name ?? "",
            "id":id,
            "min_pv":min_pv,
            "store_id":store_id,
            "distributor_id":distributor_id,
            "position":position,
            "status":status,
            "synced":synced,
            "properties": properties ?? ""
        ]
    }
}
