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
                var customer = Customer(id: user[0] as! Int, distributor_id:user[1] as! Int, store_id:user[14] as! Int)
                customer.group_id = user[2] as? Int
                customer.status = user[12] as? Int
                customer.type = user[6] as? Int
                customer.fullname = user[3] as? String
                customer.email = user[4] as? String
                customer.tel = user[5] as? String
                customer.birthday = user[7] as? String
                customer.skype = user[8] as? String
                customer.company = user[9] as? String
                customer.address = user[10] as? String
                customer.properties = user[11] as? String
                customer.server_id = user[13] as? Int
                customer.area_id = user[15] as? Int
                customer.viber = user[16] as? String
                customer.zalo = user[17] as? String
                customer.city = user[18] as? String
                customer.country = user[19] as? String
                customer.gender = user[20] as? Int
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
        let group = Expression<Int>("group_id")
        let store_id = Expression<Int>("store_id")
        let distributor_id = Expression<Int>("distributor_id")
        let status = Expression<Int?>("status")
        let classify = Expression<Int?>("type")
        let firstname = Expression<String?>("fullname")
        let email = Expression<String?>("email")
        let phone = Expression<String?>("tel")
        let birthday = Expression<String?>("birthday")
        let social = Expression<String?>("social")
        let company = Expression<String?>("company")
        let address = Expression<String?>("address")
        let properties = Expression<String?>("properties")
        let viber = Expression<String?>("viber")
        let zalo = Expression<String?>("zalo")
        let skype = Expression<String?>("skype")
        let gender = Expression<Int>("gender")
        let city = Expression<String?>("city")
        let country = Expression<String?>("country")
        
        let insert = customer.insert(group <- object.group_id!,
                                     store_id <- object.store_id,
                                     distributor_id <- object.distributor_id,
                                     status <- object.status,
                                     classify <- object.type,
                                     firstname <- object.fullname,
                                     email <- object.email,
                                     phone <- object.tel,
                                     birthday <- object.birthday,
                                     social <- object.social,
                                     company <- object.company,
                                     address <- object.address,
                                     properties <- object.properties,
                                     viber <- object.viber,
                                     zalo <- object.zalo,
                                     skype <- object.skype,
                                     gender <- object.gender!,
                                     city <- object.city,
                                     country <- object.country)
        do {
            try db.run(insert)
            // INSERT INTO "users" ("name", "email") VALUES ('Alice', 'alice@mac.com')
            return true
        } catch {
            print(error)
            return false
        }
    }
    
//    func getCustomer(em:String? = nil, group:Int? = 0) -> Customer {
//
//        let customer = Table("customer")
//        let id = Expression<Int>("id")
//        let group = Expression<Int?>("group_id")
//        let status = Expression<Int?>("status")
//        let classify = Expression<Int?>("type")
//        let firstname = Expression<String?>("fullname")
//        let email = Expression<String?>("email")
//        let phone = Expression<String?>("tel")
//        let birthday = Expression<String?>("birthday")
//        let social = Expression<String?>("social")
//        let company = Expression<String?>("company")
//        let address = Expression<String?>("address")
//        let properties = Expression<String?>("properties")
//
//        var myFilter = Expression<Bool?>(value: true)
//        if em != nil {
//            myFilter = (email == em)
//        }
//
//        let select = customer.select(*).filter(myFilter).order(firstname.asc,firstname)
//        do {
//
//            for user in try db.prepare(select) {
//                var customer = Customer(id: user[id], distributor_id:user[distributor_id])
//                customer.group_id = user[group]
//                customer.status = user[status]
//                customer.type = user[classify]
//                customer.fullname = user[firstname]
//                customer.email = user[email]
//                customer.tel = user[phone]
//                customer.birthday = user[birthday]
//                customer.social = user[social]
//                customer.company = user[company]
//                customer.address = user[address]
//                customer.properties = user[properties]
//                //String(describing: user[name]))
//                // example get a row in mysql
//                return customer
//            }
//        } catch {
//            print(error.localizedDescription)
//
//        }
//        return Customer(id: 0)
//    }
    
    func updateCustomer(object:Customer? = nil) {
        guard object == nil else { return }
        let customer = Table("customer")
        let id = Expression<Int>("id")
        let group = Expression<Int?>("group_id")
        let status = Expression<Int?>("status")
        let classify = Expression<Int?>("type")
        let firstname = Expression<String?>("fullname")        
        let email = Expression<String?>("email")
        let phone = Expression<String?>("tel")
        let birthday = Expression<String?>("birthday")
        let social = Expression<String?>("social")
        let company = Expression<String?>("company")
        let address = Expression<String?>("address")
        let properties = Expression<String?>("properties")
        
        let alice = customer.filter(id == object!.id)
        
        do {
            try db.run(alice.update(group <- object?.group_id,
                                    status <- object?.status,
                                    classify <- object?.type,
                                    firstname <- object?.fullname,
                                    email <- object?.email,
                                    phone <- object?.tel,
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
        let server_id = Expression<Int>("server_id")
        let store_id = Expression<Int>("store_id")
        let distributor_id = Expression<Int>("distributor_id")
        let position = Expression<Int>("position")
        let name = Expression<String?>("name")
        let color = Expression<String?>("color")
        
        var list:Array<GroupCustomer> = []
        do {
        for gr in try db.prepare(group) {
            var customer = GroupCustomer(id: gr[id], distributor_id:gr[distributor_id],store_id:gr[store_id])
            if let data = gr[name] {
                customer.name = data
            }
           
            customer.server_id = gr[server_id]
            customer.store_id = gr[store_id]
            customer.distributor_id = gr[distributor_id]
            
            if let data = gr[color] {
                customer.color = data
            }
            
            customer.position = gr[position]
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
        
        let store_id = Expression<Int>("store_id")
        let distributor_id = Expression<Int>("distributor_id")
        let position = Expression<Int>("position")
        let name = Expression<String?>("name")
        let color = Expression<String?>("color")
        
        do {
            let insert = group.insert(name <- obj.name!, position <- obj.position!, color <- obj.color!,store_id <- obj.store_id,distributor_id <- obj.distributor_id)
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
            try db.run(alice.update(name <- object.name!, level <- object.position!, color <- object.color!))
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
