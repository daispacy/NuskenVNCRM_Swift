//
//  LocalService.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 9/21/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import Foundation
import SQLite

protocol LocalServiceDelegate:class {
    func localService(localService:LocalService,didReceiveData:Any)
    func localService(localService:LocalService,didFailed:Any)
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
                customer.firstname = String(describing:user[2])
                customer.lastname = String(describing:user[3])
                customer.email = String(describing:user[4])
                customer.phone = String(describing:user[5])
                customer.birthday = String(describing:user[7])
                customer.social = String(describing:user[8])
                customer.company = String(describing:user[9])
                customer.address = String(describing:user[10])
                customer.properties = String(describing:user[11])
                list.append(customer)
            }
            listCustomer = list
            delegate_?.localService(localService: self, didReceiveData: list)
        } catch {
            print(error.localizedDescription)
            delegate_?.localService(localService: self, didFailed: error)
        }
    }
    
    func addCustomer(object:Customer? = nil) {
        guard object == nil else { return }
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
        
        let insert = customer.insert(group <- object?.group,
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
                                     properties <- object?.properties)
        do {
            try db.run(insert)
            // INSERT INTO "users" ("name", "email") VALUES ('Alice', 'alice@mac.com')
        } catch {
            print(error)
        }
    }
    
    func getCustomer(em:String? = nil) -> Customer {
        
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
                customer.firstname = String(describing:user[firstname])
                customer.lastname = String(describing:user[lastname])
                customer.email = String(describing:user[email])
                customer.phone = String(describing:user[phone])
                customer.birthday = String(describing:user[birthday])
                customer.social = String(describing:user[social])
                customer.company = String(describing:user[company])
                customer.address = String(describing:user[address])
                customer.properties = String(describing:user[properties])
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
            
            delegate_?.localService(localService: self, didReceiveData: list)
        } catch {
            print(error.localizedDescription)
            delegate_?.localService(localService: self, didFailed: error)
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
    
    func updateGroup (object:GroupCustomer? = nil) {
        guard object == nil else { return }
        let group = Table("group")
        let id = Expression<Int>("id")
        let name = Expression<String?>("name")
        let social = Expression<String?>("social")
        
        let alice = group.filter(id == object!.id)
        
        do {
            try db.run(alice.update(name <- object!.name, social <- object!.social))
        } catch {
            print(error)
        }
    }
    
    func deleteGroup(object:GroupCustomer? = nil) {
        guard object == nil else { return }
        let group = Table("group")
        let id = Expression<Int>("id")
        
        let alice = group.filter(id == object!.id)
        
        do {
            try db.run(alice.delete())
        } catch {
            print(error)
        }
    }
}
