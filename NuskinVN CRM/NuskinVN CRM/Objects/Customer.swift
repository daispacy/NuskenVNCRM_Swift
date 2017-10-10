//
//  Customer.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 9/21/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import UIKit

struct Customer {
    let id:Int64
    
    var server_id:Int64 = 0
    var username:String = ""
    var group_id:Int64 = 0
    var store_id:Int64 = 0
    var distributor_id:Int64 = 0
    var area_id:Int64 = 0
    var fullname:String = ""
    var email:String = ""
    var tel:String = ""
    var type:Int64  = 0
    var gender:Int64 = 0
    var birthday:String = ""
    var company:String = ""
    var address:String = ""
    var skype:String = ""
    var viber:String = ""
    var zalo:String = ""
    var facebook:String = ""
    var city:String = ""
    var country:String = ""
    var last_login:String = ""
    var date_created:String = ""
    var properties:JSON?
    var status:Int64 = 0
    
    init(id: Int64, distributor_id:Int64, store_id:Int64) {
        self.id = id
        self.distributor_id = distributor_id
        self.store_id = store_id
    }
    
    var toDictionary:[String:Any] {
        return [
            "server_id":server_id,
            "username":username,
            "group_id":group_id,
            "store_id":store_id,
            "distributor_id":distributor_id,
            "area_id":area_id,
            "fullname":fullname,
            "email":email,
            "tel":tel,
            "type":type,
            "gender":gender,
            "birthday":birthday,
            "company":company,
            "address":address,
            "skype":skype,
            "viber":viber,
            "zalo":zalo,
            "facebook":facebook,
            "city":city,
            "country":country,
            "last_login":last_login,
            "date_created":date_created,
            "status":status
        ]
    }
}

extension Customer {
    init?(json: JSON) {
        guard let email = json["email"] as? String,
            let username = json["username"] as? String else {
                return nil
        }
        self.id = 0
        if let id = json["id"] as? Int64 {
            self.server_id = id
        } else if let id = json["id"] as? String {
            self.server_id = Int64(id)!
        } else {
            return nil
        }
        
        if let id = json["distributor_id"] as? Int64 {
            self.distributor_id = id
        } else if let id = json["distributor_id"] as? String {
            self.distributor_id = Int64(id)!
        } else {
            return nil
        }
        
        if let id = json["store_id"] as? Int64 {
            self.store_id = id
        } else if let id = json["store_id"] as? String {
            self.store_id = Int64(id)!
        } else {
            return nil
        }
        
        if let id = json["area_id"] as? Int64 {
            self.area_id = id
        } else if let id = json["area_id"] as? String {
            self.area_id = Int64(id)!
        } else {
            return nil
        }
        
        if let id = json["type"] as? Int64 {
            self.type = id
        } else if let id = json["type"] as? String {
            self.type = Int64(id)!
        }
        
        if let id = json["status"] as? Int64 {
            self.status = id
        } else if let id = json["status"] as? String {
            self.status = Int64(id)!
        }
        
        if let id = json["gender"] as? Int64 {
            self.gender = id
        } else if let id = json["gender"] as? String {
            self.gender = Int64(id)!
        }
        
        self.username = username
        self.email = email
        
        if let properties = json["properties"] as? JSON {
            self.properties = properties
        }
        
        if let cell = json["date_created"] as? String {
            self.date_created = cell
        }
        if let cell = json["tel"] as? String {
            self.tel = cell
        }
        if let last_login = json["last_login"] as? String {
            self.last_login = last_login
        }
        
        if let dt = json["address"] as? String {
            self.address = dt
        }
        if let dt = json["fullname"] as? String {
            self.fullname = dt
        }
        if let dt = json["city"] as? String {
            self.city = dt
        }
        if let dt = json["country"] as? String {
            self.country = dt
        }
        if let dt = json["skype"] as? String {
            self.skype = dt
        }
        if let dt = json["viber"] as? String {
            self.viber = dt
        }
        if let dt = json["zalo"] as? String {
            self.zalo = dt
        }
        if let dt = json["facebook"] as? String {
            self.facebook = dt
        }
    }
}
