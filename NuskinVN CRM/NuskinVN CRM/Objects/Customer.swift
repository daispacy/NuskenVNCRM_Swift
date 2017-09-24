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
    
    var group:Int?
    var firstname:String?
    var lastname:String?
    var email:String?
    var phone:String?
    var classify:Int?
    var birthday:String?
    var social:String?
    var company:String?
    var address:String?
    var properties:String?
    var status:Int?
    
    init(id: Int, dictionary:[String:Any]? = nil) {
        self.id = id
        firstname = "pham quoc dai quoc dai"
        lastname = "quoc dai"
        birthday = "22/02/1989"
        if((dictionary) != nil) {
            self.group = dictionary!["group"] as? Int ?? 0
            self.classify = dictionary!["classify"] as? Int ?? 0
            self.status = dictionary!["status"] as? Int ?? 0
            self.firstname = dictionary!["firstname"] as? String ?? ""
            self.lastname = dictionary!["lastname"] as? String ?? ""
            self.email = dictionary!["email"] as? String ?? ""
            self.phone = dictionary!["phone"] as? String ?? ""
            self.birthday = dictionary!["birthday"] as? String ?? ""
            self.social = dictionary!["social"] as? String ?? ""
            self.company = dictionary!["company"] as? String ?? ""
            self.address = dictionary!["address"] as? String ?? ""
            self.properties = dictionary!["properties"] as? String ?? ""
        }
    }
}
