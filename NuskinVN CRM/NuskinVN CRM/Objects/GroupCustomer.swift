//
//  GroupCustomer.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 9/21/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import UIKit

struct GroupCustomer {
    let id:Int
    var name:String?
    var social:String?
    
    
    init(id: Int, dictionary:[String:Any]? = nil) {
        self.id = id
        if((dictionary) != nil) {
            self.social = dictionary!["social"] as? String ?? ""
            
        }
    }
}

