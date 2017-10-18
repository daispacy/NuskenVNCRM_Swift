//
//  Product.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 10/17/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import Foundation

struct Product {
    var id:Int64 = 0
    var server_id:Int64 = 0
    var name:String = ""
    var tempName:String = ""
    var synced:Int64 = 0
    var price:Int64 = 0
    var quantity:Int64 = 0
    
    func isValid(exceptMe:Bool = false) ->Bool{
        var sql:String = "SELECT count(*) FROM `product` where `name` = '\(self.name)'"
        if exceptMe {
            sql.append(" AND id <> '\(id)'")
        }
        let count:Int64 = LocalService.shared.countLocalData(sql: sql)
        return count <= 0
    }
}

extension Product {
    init(json:JSON) {
        
        self.synced = 1
        
        if let id = json["id"] as? Int64 {
            self.id = id
        } else if let id = json["id"] as? String {
            self.id = Int64(id)!
        }
        
        if let id = json["server_id"] as? Int64 {
            self.server_id = id
        } else if let id = json["server_id"] as? String {
            self.server_id = Int64(id)!
        }
        
        if let id = json["name"] as? String {
            self.name = id
        }
    }
}