//
//  GroupCustomer.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 9/21/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import UIKit

enum GroupLevel: Int64 {
    case ten = 1
    case nine
    case seven
    case three
    case one
}

struct GroupCustomer {
    let id:Int64
    var store_id:Int64 = 0
    var distributor_id:Int64 = 0
    var server_id:Int64 = 0
    var name:String = ""
    var color: String = "gradient"
    var position: Int64 = 0
    var status: Int64 = 1
    var synced: Int64 = 0
    
    
    init(id: Int64, distributor_id:Int64,store_id:Int64) {
        self.id = id
        self.distributor_id = distributor_id
        self.store_id = store_id
    }
    
    func validAddNewGroup()->Bool {
        if name.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).characters.count > 0 && position != 0 {
            return true
        }
        
        return false
    }
    
    var toDictionary:[String:Any] {
        return [
            "server_id":server_id,
            "name":name,
            "id":id,
            "store_id":store_id,
            "distributor_id":distributor_id,
            "color":color,
            "position":position,
            "status":status,
            "synced":synced
            ]
    }
    
    var numberCustomer: Int64  {
        var sql:String = "SELECT count(*) FROM customer where `status` = '1' and `group_id` = '\(self.id)'"
        if self.server_id > 0 {
            sql = "SELECT count(*) FROM customer where `status` = '1' and `group_id` = '\(self.server_id)'"
        }
        return LocalService.shared().countLocalData(sql: sql)
    }
}

extension GroupCustomer {
    init?(json: JSON) {
        guard let name = json["group_name"] as? String else {
                return nil
        }
        self.name = name
        self.id = 0
        self.synced = 1
        
        if let id = json["store_id"] as? Int64 {
            self.store_id = id
        } else if let id = json["store_id"] as? String {
            self.store_id = Int64(id)!
        } else {
            return nil
        }
        
        if let id = json["id"] as? Int64 {
            self.server_id = id
        } else if let id = json["id"] as? String {
            self.server_id = Int64(id)!
        }
        
        if let id = json["status"] as? Int64 {
            self.status = id
        } else if let id = json["status"] as? String {
            self.status = Int64(id)!
        }
        
        if let id = json["distributor_id"] as? Int64 {
            self.distributor_id = id
        } else if let id = json["distributor_id"] as? String {
            self.distributor_id = Int64(id)!
        }
        
        if let id = json["position"] as? Int64 {
            self.position = id
        } else if let id = json["position"] as? String {
            self.position = Int64(id)!
        }
        
        if let properties = json["color"] as? String {
            self.color = properties
        }
    }
}
