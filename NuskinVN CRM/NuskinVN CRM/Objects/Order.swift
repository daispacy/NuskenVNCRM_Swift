//
//  Order.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 10/17/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import Foundation

struct Order {
    var id:Int64 = 0
    var server_id:Int64 = 0
    var store_id:Int64 = 0
    var user_id:Int64 = 0
    var customer_id:Int64 = 0
    var order_code:String = ""
    var email:String = ""
    var address:String = ""
    var tel:String = ""
    var date_created:String = ""
    var last_updated:String = ""
    var status:Int64 = 0
    var payment_status:Int64 = 0
    var payment_method:String = ""
    var shipping_unit:String = "" // transporter
    var transporter_id:String = ""
    var note:String = ""
    var synced:Int64 = 0
    
    var tempProducts:[Product] = []
    
    
    var customer:Customer {
        return LocalService.shared.getCustomerFromID(customerID: customer_id)
    }
    
    var products: [Product] {
        return LocalService.shared.getAllProduct(orderID: id)
    }
    
    var total:Int64 {
        if products.count > 0 {
            var t:Int64 = 0
            _ = products.map({
                t += $0.price
            })
            return t
        }
        return 0
    }
}

extension Order {
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
        
        if let id = json["store_id"] as? Int64 {
            self.store_id = id
        } else if let id = json["store_id"] as? String {
            self.store_id = Int64(id)!
        }
        
        if let id = json["user_id"] as? Int64 {
            self.user_id = id
        } else if let id = json["user_id"] as? String {
            self.user_id = Int64(id)!
        }
        
        if let id = json["customer_id"] as? Int64 {
            self.customer_id = id
        } else if let id = json["customer_id"] as? String {
            self.customer_id = Int64(id)!
        }
        
        if let id = json["order_code"] as? String {
            self.order_code = id
        }
        
        if let id = json["email"] as? String {
            self.email = id
        }
        
        if let id = json["address"] as? String {
            self.address = id
        }
        
        if let id = json["tel"] as? String {
            self.tel = id
        }
        if let id = json["date_created"] as? String {
            self.date_created = id
        }
        if let id = json["last_updated"] as? String {
            self.last_updated = id
        }
        if let id = json["status"] as? Int64 {
            self.status = id
        } else if let id = json["status"] as? String {
            self.status = Int64(id)!
        }
        if let id = json["payment_status"] as? Int64 {
            self.payment_status = id
        } else if let id = json["payment_status"] as? String {
            self.payment_status = Int64(id)!
        }
        if let id = json["payment_method"] as? String {
            self.payment_method = id
        }
        if let id = json["shipping_unit"] as? String {
            self.shipping_unit = id
        }
        if let id = json["transporter_id"] as? String {
            self.transporter_id = id
        }
        if let id = json["note"] as? String {
            self.note = id
        }
    }
}
