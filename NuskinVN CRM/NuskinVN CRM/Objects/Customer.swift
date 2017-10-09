//
//  Customer.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 9/21/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import UIKit

struct Customer {
    let id:Int
    
    var server_id:Int?
    var group_id:Int?
    var store_id:Int
    var distributor_id:Int
    var area_id:Int?
    var fullname:String?
    var email:String?
    var tel:String?
    var type:Int?
    var gender:Int?
    var birthday:String?
    var social:String?
    var company:String?
    var address:String?
    var skype:String?
    var viber:String?
    var zalo:String?
    var city:String?
    var country:String?
    var properties:String?
    var status:Int?
    
    init(id: Int, distributor_id:Int, store_id:Int) {
        self.id = id
        self.distributor_id = distributor_id
        self.store_id = store_id
    }
}
