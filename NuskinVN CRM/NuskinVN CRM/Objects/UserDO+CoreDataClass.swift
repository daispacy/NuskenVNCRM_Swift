//
//  UserDO+CoreDataClass.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 10/28/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//
//

import Foundation
import CoreData

@objc(UserDO)
public class UserDO: NSManagedObject {
    var toDictionary:[String:Any] {
        return [
            "store_id": store_id,
            "type": type,
            "fullname": fullname ?? "",
            "address": address ?? "",
            "email": email ?? "",
            "tel": tel ?? ""
        ]
    }
}
