//
//  GroupCustomer.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 9/21/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import UIKit

enum GroupLevel: Int {
    case ten = 1
    case nine
    case seven
    case three
    case one
}

struct GroupCustomer {
    let id:Int
    var name:String?
    var social:String?
    var color: String?
    var level: Int?
    var numberCustomer: Int?
    
    
    init(id: Int) {
        self.id = id
    }
    
    func validAddNewGroup()->Bool {
        guard name != nil else {
            return false
        }
        if name!.characters.count > 0 && level != nil {
            return true
        }
        
        return false
    }
}

