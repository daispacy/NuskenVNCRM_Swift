//
//  City.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 10/11/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import Foundation

struct City {
    var id:Int64 = 0
    var name:String = ""
    var country_id:Int64 = 0
}

extension City {
    init(json:JSON) {
        if let id = json["id"] as? Int64 {
            self.id = id
        } else if let id = json["id"] as? String {
            self.id = Int64(id)!
        }
        
        if let id = json["name"] as? String {
            self.name = id
        }
        
        if let id = json["provinceid"] as? Int64 {
            self.country_id = id
        } else if let id = json["provinceid"] as? String {
            self.country_id = Int64(id)!
        }
    }
}
