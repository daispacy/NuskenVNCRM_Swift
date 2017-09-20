//
//  LocalService.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 9/21/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import UIKit
import SQLite

class LocalService {
    
    private static var sharedLocalService: LocalService = {
        let networkManager = LocalService(db: "crm")
        return networkManager
    }()
    
    // MARK: -
    
    private let db: Connection!
    var listCustomer:Array<Any>?
    var listGroup:Array<Any>?
    
    // Initialization
    
    private init(db: String) {
        let pathDB = Bundle.main.path(forResource: db, ofType: "db")!
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
    
    // MARK: - PRIVATE - Customer
    public func getAllCustomers() {
        let customer = Table("customer")
        let id = Expression<Int64>("id")
        let name = Expression<String?>("name")
        let email = Expression<String?>("email")
        
        do {
        for user in try db.prepare(customer) {
            print("id: \(user[id]), name: \(String(describing: user[name])), email: \(String(describing: user[email]))")
            // id: 1, name: Optional("Alice"), email: alice@mac.com
        }
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    private func addCustomer(object:Any? = nil) {
        guard object == nil else { return }
        let customer = Table("customer")
        let name = Expression<String?>("name")
        let email = Expression<String>("email")
        
        let insert = customer.insert(name <- "Alice", email <- "alice@mac.com")
        do {
            try db.run(insert)
            // INSERT INTO "users" ("name", "email") VALUES ('Alice', 'alice@mac.com')
        } catch {
            print(error)
        }
    }
    
    private func updateCustomer(object:Any? = nil) {
        guard object == nil else { return }
        let customer = Table("customer")
        let id = Expression<Int64>("id")
        let name = Expression<String?>("name")
        let email = Expression<String?>("email")
        
        let alice = customer.filter(id == rowid)
        
        do {
            try db.run(alice.update(email <- email.replace("mac.com", with: "me.com"),email <- email.replace("mac.com", with: "me.com")))
            // UPDATE "users" SET "email" = replace("email", 'mac.com', 'me.com')
            // WHERE ("id" = 1)
        } catch {
            print(error)
        }
        
        // update list customer
        getAllCustomers()
    }
    
    private func deleteCustomer(object:Any? = nil) {
        guard object == nil else { return }
        let customer = Table("customer")
        let id = Expression<Int64>("id")
        let name = Expression<String?>("name")
        let email = Expression<String>("email")
        
        let alice = customer.filter(id == rowid)
        
        do {
            try db.run(alice.delete())
        } catch {
            print(error)
        }
        
        // update list customer
        getAllCustomers()
    }
    
    // MARK: - PRIVATE - Group
    private func getAllGroup() {
        let group = Table("group")
        let id = Expression<Int64>("id")
        let name = Expression<String?>("name")
        
        for user in try! db.prepare(group) {
            print("id: \(user[id]), name: \(String(describing: user[name]))")
            // id: 1, name: Optional("Alice"), email: alice@mac.com
        }
    }
    
    private func addGroup(name:String? = nil) {
        guard name == nil else { return }
        let group = Table("group")
        let name = Expression<String?>("name")
        
        let insert = group.insert(name <- "Alice")
        do {
            try db.run(insert)
            // INSERT INTO "users" ("name", "email") VALUES ('Alice', 'alice@mac.com')
        } catch {
            print(error)
        }
        
        getAllGroup()
    }
    
    private func updateGroup (object:Any? = nil) {
        guard object == nil else { return }
        let group = Table("group")
        let id = Expression<Int64>("id")
        let name = Expression<String?>("name")
        
        let alice = group.filter(id == rowid)
        
        do {
            try db.run(alice.update(name <- name.replace("mac.com", with: "me.com")))
            // UPDATE "users" SET "email" = replace("email", 'mac.com', 'me.com')
            // WHERE ("id" = 1)
        } catch {
            print(error)
        }
        
        // update list group
        getAllGroup()
    }
    
    private func deleteGroup(object:Any? = nil) {
        guard object == nil else { return }
        let group = Table("group")
        let id = Expression<Int64>("id")
        
        let alice = group.filter(id == rowid)
        
        do {
            try db.run(alice.delete())
        } catch {
            print(error)
        }
        
        // update list group
        getAllGroup()
    }
}
