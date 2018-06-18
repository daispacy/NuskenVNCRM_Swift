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
            "tel": tel ?? "",
            "avatar": avatar ?? ""
        ]
    }
    
    var urlAvatar:String? {
        if let properties = self.properties {
            if let data = properties.data(using: String.Encoding.utf8) {
                do {
                    if let pro:JSON = try JSONSerialization.jsonObject(with: data, options: []) as? JSON {
                        if let color = pro["avatar"] as? String {
                            if color.contains("\(username ?? "")") {
                                return "\(Server.domainImage.rawValue)/upload/1/customers/\(color.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)"
                            } else {
                                return "\(Server.domainImage.rawValue)/upload/1/customers/a_\(color.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)"
                            }
                        }
                    }
                } catch {
                    print("warning parse properties User: \(properties)")
                }
            }
        }
        return nil
    }
}
