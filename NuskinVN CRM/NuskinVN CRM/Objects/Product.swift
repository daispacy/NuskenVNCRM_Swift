//
//  Product.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 11/26/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import Foundation

struct Product {
   var avatar: String = ""
   var cat_id: Int64 = 0
    var parent_id: Int64 = 0
   var currency: Float = 0
   var date_created: NSDate?
   var description_: String = ""
    var sapo: String = ""
   var detail: String = ""
   var home: Int64 = 0
   var id: Int64 = 0
   var keyword: String = ""
   var market_price: Double = 0
   var name: String = ""
   var position: Int64 = 0
   var price: Int64 = 0
   var retail_price: Int64 = 0
   var properties: String?
   var pv: Int64 = 0
   var series: Int64 = 0
   var sku: String = ""
   var slug: String = ""
   var status: Int64 = 0
   var store_id: Int64 = 0
   var updated_: NSDate?
   var viewed: Int64 = 0
    
    var toDictionary:JSON {
        return ["id":id,
                "store_id":store_id,
                "cat_id":cat_id,
                "parent_id":parent_id,
                "position":position,
                "slug":slug,"viewed":viewed,
                "status":status,
                "name":name,
                "sapo":sapo,
                "keyword":keyword,
                "properties":properties ?? ""
            ]
    }
}

extension Product {
    static func parse (_ dictionary:JSON) -> Product {
        
        var object = Product()
        
        if let data = dictionary["id"] as? String {
            object.id = Int64(data)!
        } else if let data = dictionary["id"] as? Int64 {
            object.id = data
        }
        
        if let data = dictionary["store_id"] as? String {
            object.store_id = Int64(data)!
        } else if let data = dictionary["store_id"] as? Int64 {
            object.store_id = data
        }
        
        if let data = dictionary["cat_id"] as? String {
            object.cat_id = Int64(data)!
        } else if let data = dictionary["cat_id"] as? Int64 {
            object.cat_id = data
        }
        if let data = dictionary["series"] as? String {
            object.series = Int64(data)!
        } else if let data = dictionary["series"] as? Int64 {
            object.series = data
        }
        
        if let data = dictionary["sku"] as? String {
            object.sku = data
        } else if let data = dictionary["sku"] as? Int64 {
            object.sku = "\(data)"
        }
        
        if let data = dictionary["pv"] as? String {
            object.pv = Int64(data)!
        } else if let data = dictionary["pv"] as? Int64 {
            object.pv = data
        }
        if let data = dictionary["price"] as? String {
            object.price = Int64(data)!
        } else if let data = dictionary["price"] as? Int64 {
            object.price = data
        }
        if let data = dictionary["retail_price"] as? String {
            object.retail_price = Int64(data)!
        } else if let data = dictionary["retail_price"] as? Int64 {
            object.retail_price = data
        }
        if let data = dictionary["status"] as? String {
            object.status = Int64(data)!
        } else if let data = dictionary["status"] as? Int64 {
            object.status = data
        }
        
        if let data = dictionary["name"] as? String {
            object.name = data
        }
        if let data = dictionary["keyword"] as? String {
            object.keyword = data
        }
        if let data = dictionary["avatar"] as? String {
            object.avatar = data
        }
        
        if let properties = dictionary["properties"] as? JSON {
            let jsonData = try! JSONSerialization.data(withJSONObject: properties)
            if let pro = String(data: jsonData, encoding: .utf8) {
                object.properties = pro
            }
        } else if let properties = dictionary["properties"] as? String {
            object.properties = properties
        }
        
        return object
    }
}
