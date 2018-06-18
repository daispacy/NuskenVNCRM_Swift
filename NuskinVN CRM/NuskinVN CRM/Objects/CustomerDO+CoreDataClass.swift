//
//  CustomerDO+CoreDataClass.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 10/20/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//
//

import Foundation
import CoreData

@objc(CustomerDO)
public class CustomerDO: NSManagedObject {

    var isTemp = false
    
    //MARK: - Initialize
    convenience init(needSave: Bool,  context: NSManagedObjectContext?) {
        
        // Create the NSEntityDescription
        let entity = NSEntityDescription.entity(forEntityName: "OrderDO", in: context!)
        
        if(!needSave) {
            self.init(entity: entity!, insertInto: nil)
            isTemp = true
        } else {
            self.init(entity: entity!, insertInto: context)
        }
    }
    
    var toDictionary:[String:Any] {
        
        var proper:JSON = [:]
        if let properties = self.properties {
            if let data = properties.data(using: String.Encoding.utf8) {
                do {
                    if let pro:JSON = try JSONSerialization.jsonObject(with: data, options: []) as? JSON {
                        proper = pro
                    }
                } catch {
                    print("warning parse properties CUSTOMER: \(properties)")
                }
            }
        }
        
        var date_created_ = ""
        var last_updated_ = ""
        var birthday_ = ""
        
        if let created = date_created as Date?{
            date_created_ = created.toString(dateFormat: "yyyy-MM-dd HH:mm:ss")
        }
        
        if let updated = last_login as Date?{
            last_updated_ = updated.toString(dateFormat: "yyyy-MM-dd HH:mm:ss")
        }
        
        if let updated = birthday as Date?{
            birthday_ = updated.toString(dateFormat: "yyyy-MM-dd")
        }
        
        return [
            "id": id,
            "store_id": store_id,
            "distributor_id": distributor_id,
            "area_id": area_id,
            "type": type,
            "city_id": city_id,
            "district_id": district_id,
            "username": username ?? "",
            "password": password ?? "",
            "fullname": fullname ?? "",
            "gender": gender,
            "address": address ?? "",
            "email": email ?? "",
            "city": city ?? "",
            "county": county ?? "",
            "tel": tel ?? "",
            "avatar": avatar ?? "",
            "group_id": group_id,
            "properties": proper,
            "date_created": date_created_,
            "last_login": last_updated_,
            "birthday": birthday_,
            "status": status,
            "synced":synced
        ]
    }
}
