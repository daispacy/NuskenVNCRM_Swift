//
//  User.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 10/9/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import UIKit

struct User {

    private static var initUser: User = {
        if let data = UserDefaults.standard.value(forKey: "App:CurrentUser") {
            if let user = NSKeyedUnarchiver.unarchiveObject(with:data as! Data) as? JSON{
                let currentUser = User(json:user)!
                return currentUser
            } else {
                return User(json: ["id":0,"store_id":0, "email":"","username": ""])!
            }
        }
        return User(json: ["id":0,"store_id":0, "email":"","username": ""])!
        
    }()
    
    static func currentUser() -> User {
        return initUser
    }

    let store_id: Int
    
    let id: Int
    
    let username: String
    
    let email: String
    
    var fullname: String? = nil
    
    var password: String? = nil
    
    var type: Int? = 0
    
    var address: String? = nil
    
    var status: Int? = 0
    
    var properties: JSON? = nil
    
    var tel: String? = nil
    
    var last_login: String? = nil
    
    var cell: String? = nil
    
    static func isValid() -> Bool {
        if currentUser().email.characters.count == 0 || currentUser().id == 0 {
            return false
        }
        return AppConfig.setting.isRememberUser() == true
    }
    
    static func setCurrentUser(user:JSON) {
        UserDefaults.standard.setValue(NSKeyedArchiver.archivedData(withRootObject: user), forKey: "App:CurrentUser")
        UserDefaults.standard.synchronize()
    }
}

extension User {
    init?(json: JSON) {
        guard let email = json["email"] as? String,
            let username = json["username"] as? String else {
                return nil
        }
        
        if let id = json["id"] as? Int {
            self.id = id
        } else if let id = json["id"] as? String {
            self.id = Int(id)!
        } else {
            return nil
        }
        
        if let id = json["store_id"] as? Int {
            self.store_id = id
        } else if let id = json["store_id"] as? String {
            self.store_id = Int(id)!
        } else {
            return nil
        }
        
        if let id = json["type"] as? Int {
            self.type = id
        } else if let id = json["type"] as? String {
            self.type = Int(id)!
        }
        
        if let id = json["status"] as? Int {
            self.status = id
        } else if let id = json["status"] as? String {
            self.status = Int(id)!
        }
        
        self.username = username
        self.email = email
        
        if let properties = json["properties"] as? JSON {
            self.properties = properties
        }
        
        if let cell = json["cell"] as? String {
            self.cell = cell
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
        if let dt = json["password"] as? String {
            self.password = dt
        }
    }
}
