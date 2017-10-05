//
//  LocalService.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 9/21/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import Foundation
import SQLite

enum LocalServiceType: Int {
    case customer = 1
    case group
}

protocol LocalServiceDelegate:class {
    func localService(localService:LocalService,didReceiveData:Any, type:LocalServiceType)
    func localService(localService:LocalService,didFailed:Any, type:LocalServiceType)
}

class LocalService: NSObject {
    
    private static var sharedLocalService: LocalService = {
        let networkManager = LocalService(db: "crm")
        return networkManager
    }()
    
    // MARK: -
    weak var delegate_:LocalServiceDelegate?
    private var db: Connection!
    var listCustomer:Array<Any>?
    var listGroup:Array<Any>?
    
    // Initialization
    
     init(db: String) {
        let pathDB = Bundle.main.path(forResource: db, ofType: "db")!
        do {
            self.db = try Connection(pathDB)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    override init() {
        super.init()
        let pathDB = Bundle.main.path(forResource: "crm", ofType: "db")!
        do {
            self.db = try Connection(pathDB)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    // MARK: - Accessors
    
    class func shared() -> LocalService {
        return sharedLocalService
    }
    
    // MARK: - INTERFACE - Customer
    public func customSelectSQL(sql:String? = nil) {
        guard sql != nil else {
            return
        }
        do {
            var list:Array<Customer> = []
            for user in try db.prepare(sql!) {
                var customer = Customer(id: user[0] as! Int)
                customer.group = user[1] as? Int
                customer.status = user[12] as? Int
                customer.classify = user[6] as? Int
                customer.firstname = user[2] as? String
                customer.lastname = user[3] as? String
                customer.email = user[4] as? String
                customer.phone = user[5] as? String
                customer.birthday = user[7] as? String
                customer.social = user[8] as? String
                customer.company = user[9] as? String
                customer.address = user[10] as? String
                customer.properties = user[11] as? String
                list.append(customer)
            }
            listCustomer = list
            delegate_?.localService(localService: self, didReceiveData: list, type:.customer)
        } catch {
            print(error.localizedDescription)
            delegate_?.localService(localService: self, didFailed: error, type:.customer)
        }
    }
    
    func addCustomer(object:Customer) -> Bool{
        let customer = Table("customer")
        let group = Expression<Int?>("group")
        let status = Expression<Int?>("status")
        let classify = Expression<Int?>("classify")
        let firstname = Expression<String?>("firstname")
        let lastname = Expression<String?>("lastname")
        let email = Expression<String?>("email")
        let phone = Expression<String?>("phone")
        let birthday = Expression<String?>("birthday")
        let social = Expression<String?>("social")
        let company = Expression<String?>("company")
        let address = Expression<String?>("address")
        let properties = Expression<String?>("properties")
        
        let insert = customer.insert(group <- object.group,
                                     status <- object.status,
                                     classify <- object.classify,
                                     firstname <- object.firstname,
                                     lastname <- object.lastname,
                                     email <- object.email,
                                     phone <- object.phone,
                                     birthday <- object.birthday,
                                     social <- object.social,
                                     company <- object.company,
                                     address <- object.address,
                                     properties <- object.properties)
        do {
            try db.run(insert)
            // INSERT INTO "users" ("name", "email") VALUES ('Alice', 'alice@mac.com')
            return true
        } catch {
            print(error)
            return false
        }
    }
    
    func getCustomer(em:String? = nil, group:Int? = 0) -> Customer {
        
        let customer = Table("customer")
        let id = Expression<Int>("id")
        let group = Expression<Int?>("group")
        let status = Expression<Int?>("status")
        let classify = Expression<Int?>("classify")
        let firstname = Expression<String?>("firstname")
        let lastname = Expression<String?>("lastname")
        let email = Expression<String?>("email")
        let phone = Expression<String?>("phone")
        let birthday = Expression<String?>("birthday")
        let social = Expression<String?>("social")
        let company = Expression<String?>("company")
        let address = Expression<String?>("address")
        let properties = Expression<String?>("properties")

        var myFilter = Expression<Bool?>(value: true)
        if em != nil {
            myFilter = (email == em)
        }
        
        let select = customer.select(*).filter(myFilter).order(firstname.asc,firstname)
        do {
            
            for user in try db.prepare(select) {
                var customer = Customer(id: user[id])
                customer.group = user[group]
                customer.status = user[status]
                customer.classify = user[classify]
                customer.firstname = user[firstname]
                customer.lastname = user[lastname]
                customer.email = user[email]
                customer.phone = user[phone]
                customer.birthday = user[birthday]
                customer.social = user[social]
                customer.company = user[company]
                customer.address = user[address]
                customer.properties = user[properties]
                //String(describing: user[name]))
                // example get a row in mysql
                return customer
            }
        } catch {
            print(error.localizedDescription)
            
        }
        return Customer(id: 0)
    }
    
    func updateCustomer(object:Customer? = nil) {
        guard object == nil else { return }
        let customer = Table("customer")
        let id = Expression<Int>("id")
        let group = Expression<Int?>("group")
        let status = Expression<Int?>("status")
        let classify = Expression<Int?>("classify")
        let firstname = Expression<String?>("firstname")
        let lastname = Expression<String?>("lastname")
        let email = Expression<String?>("email")
        let phone = Expression<String?>("phone")
        let birthday = Expression<String?>("birthday")
        let social = Expression<String?>("social")
        let company = Expression<String?>("company")
        let address = Expression<String?>("address")
        let properties = Expression<String?>("properties")
        
        let alice = customer.filter(id == object!.id)
        
        do {
            try db.run(alice.update(group <- object?.group,
                                    status <- object?.status,
                                    classify <- object?.classify,
                                    firstname <- object?.firstname,
                                    lastname <- object?.lastname,
                                    email <- object?.email,
                                    phone <- object?.phone,
                                    birthday <- object?.birthday,
                                    social <- object?.social,
                                    company <- object?.company,
                                    address <- object?.address,
                                    properties <- object?.properties))
            // UPDATE "users" SET "email" = replace("email", 'mac.com', 'me.com')
            // WHERE ("id" = 1)
        } catch {
            print(error)
        }
    }
    
    func deleteCustomer(object:Customer? = nil) {
        guard object == nil else { return }
        let customer = Table("customer")
        let id = Expression<Int>("id")
        
        let alice = customer.filter(id == object!.id)
        
        do {
            try db.run(alice.delete())
        } catch {
            print(error)
        }
    }
    
    // MARK: - INTERFACE - Group
    func getAllGroup() {
        let group = Table("group")
        let id = Expression<Int>("id")
        let level = Expression<Int>("level")
        let name = Expression<String?>("name")
        let social = Expression<String?>("social")
        let color = Expression<String?>("color")
        
        var list:Array<GroupCustomer> = []
        do {
        for gr in try db.prepare(group) {
            var customer = GroupCustomer(id: gr[id])
            if let data = gr[name] {
                customer.name = data
            }
            if let data = gr[social] {
                customer.social = data
            }
            
            if let data = gr[color] {
                customer.color = data
            }
            
            customer.level = gr[level]
            list.append(customer)
            }
            
            delegate_?.localService(localService: self, didReceiveData: list, type:.group)
        } catch {
            print(error.localizedDescription)
            delegate_?.localService(localService: self, didFailed: error, type:.group)
        }
    }
    
    func addGroup(obj:GroupCustomer) -> Bool{
       
        let group = Table("group")
        
        let level = Expression<Int>("level")
        let name = Expression<String>("name")
//        let social = Expression<String?>("social")
        let color = Expression<String>("color")
        
        do {
            let insert = group.insert(name <- obj.name!, level <- obj.level!, color <- obj.color!)
            try db.run(insert)
            // INSERT INTO "users" ("name", "email") VALUES ('Alice', 'alice@mac.com')
        } catch {
            print(error)
            return false
        }
        return true
    }
    
    func updateGroup (object:GroupCustomer) {
        let group = Table("group")
        let id = Expression<Int>("id")
        let level = Expression<Int>("level")
        let name = Expression<String>("name")
        //        let social = Expression<String?>("social")
        let color = Expression<String>("color")
        
        let alice = group.filter(id == object.id)
        
        do {
            try db.run(alice.update(name <- object.name!, level <- object.level!, color <- object.color!))
        } catch {
            print(error)
        }
    }
    
    func deleteGroup(object:GroupCustomer) -> Bool{
        
        let group = Table("group")
        let id = Expression<Int>("id")
        
        let alice = group.filter(id == object.id)
        
        do {
            try db.run(alice.delete())
            return true
        } catch {
            print(error)
            return false
        }
    }
}
