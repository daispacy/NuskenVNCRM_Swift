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

class LocalService: NSObject,LocalServiceDelegate {
    
    private static var sharedLocalService: LocalService = {
        let networkManager = LocalService(db: "crm")
        return networkManager
    }()
    
    // MARK: -
    weak var delegate_:LocalServiceDelegate?
    private var db: Connection!
    
    var isSync:Bool = false
    var timerSyncToServer:Timer?
    
    // Initialization
    
    init(db: String) {
        let pathDB = Bundle.main.path(forResource: db, ofType: "db")!
        print(pathDB)
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
    
    //start service
    func startSyncData() {
        // first
        self.syncToServer()
        
        // loop
        self.timerSyncToServer = Timer.scheduledTimer(timeInterval: 60*10, target: self, selector: #selector(self.syncToServer), userInfo: nil, repeats: true)
    }
    
    // MARK: - Accessors
    class func shared() -> LocalService {
        return sharedLocalService
    }
    
    // MARK: - Customer SQL
    func customerSQl(sql:String, onComplete:(()->Void)){
        if sql.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).characters.count > 0 {
            do {
                try self.db.run(sql)
                onComplete()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    // MARK: - INTERFACE - Customer
    public func getCustomerWithCustom(sql:String? = nil) {
        guard sql != nil else {
            return
        }
        do {
            var list:Array<Customer> = []
            for user in try db.prepare(sql!) {
                var customer = Customer(id: user[0] as! Int64, distributor_id:user[14] as! Int64, store_id:user[13] as! Int64)
                customer.group_id = user[1] as! Int64
                customer.status = user[11] as! Int64
                customer.type = user[5] as! Int64
                customer.fullname = user[2] as! String
                customer.email = user[3] as! String
                customer.tel = user[4] as! String
                customer.birthday = user[6] as! String
                customer.skype = user[7] as! String
                customer.company = user[8] as! String
                customer.address = user[9] as! String
                customer.properties = user[10] as? JSON
                customer.server_id = user[12] as! Int64
                customer.area_id = user[15] as! Int64
                customer.viber = user[16] as! String
                customer.zalo = user[17] as! String
                customer.city = user[18] as! String
                customer.country = user[19] as! String
                customer.gender = user[20] as! Int64
                customer.last_login = user[21] as! String
                customer.date_created = user[22] as! String
                customer.tempAvatar = user[23] as! String
                customer.facebook = user[24] as! String
                list.append(customer)
            }
            
            delegate_?.localService(localService: self, didReceiveData: list, type:.customer)
        } catch {
            print(error.localizedDescription)
            delegate_?.localService(localService: self, didFailed: error, type:.customer)
        }
    }
    
    func addCustomer(object:Customer) -> Bool{
        let customer = Table("customer")
        let group = Expression<Int64>("group_id")
        let server_id = Expression<Int64>("server_id")
        let store_id = Expression<Int64>("store_id")
        let distributor_id = Expression<Int64>("distributor_id")
        let status = Expression<Int64?>("status")
        let classify = Expression<Int64?>("type")
        let firstname = Expression<String?>("fullname")
        let email = Expression<String?>("email")
        let phone = Expression<String?>("tel")
        let birthday = Expression<String?>("birthday")
        let company = Expression<String?>("company")
        let address = Expression<String?>("address")
        let properties = Expression<String?>("properties")
        let viber = Expression<String?>("viber")
        let zalo = Expression<String?>("zalo")
        let skype = Expression<String?>("skype")
        let facebbook = Expression<String?>("facebook")
        let gender = Expression<Int64>("gender")
        let city = Expression<String?>("city")
        let country = Expression<String?>("country")
        let last_login = Expression<String?>("last_login")
        let date_created = Expression<String?>("date_created")
        let temp_avatar = Expression<String?>("temp_avatar")
        
        var pro:String = ""
        if object.properties != nil {
            pro.append(object.properties!.description)
        }
        
        let insert = customer.insert(group <- object.group_id,
                                     store_id <- object.store_id,
                                     distributor_id <- object.distributor_id,
                                     status <- object.status,
                                     classify <- object.type,
                                     firstname <- object.fullname,
                                     email <- object.email,
                                     phone <- object.tel,
                                     birthday <- object.birthday,
                                     company <- object.company,
                                     address <- object.address,
                                     properties <- pro,
                                     viber <- object.viber,
                                     zalo <- object.zalo,
                                     skype <- object.skype,
                                     gender <- object.gender,
                                     city <- object.city,
                                     country <- object.country,
                                     server_id <- object.server_id,
                                     facebbook <- object.facebook,
                                     last_login <- object.last_login,
                                     date_created <- object.date_created,
                                     temp_avatar <- object.tempAvatar)
        do {
            try db.run(insert)
            // INSERT INTO "users" ("name", "email") VALUES ('Alice', 'alice@mac.com')
            return true
        } catch {
            print(error)
            return false
        }
    }
    
    func updateCustomer(object:Customer) {
        
        let customer = Table("customer")
        let group = Expression<Int64>("group_id")
        let server_id = Expression<Int64>("server_id")
        let store_id = Expression<Int64>("store_id")
        let distributor_id = Expression<Int64>("distributor_id")
        let status = Expression<Int64?>("status")
        let classify = Expression<Int64?>("type")
        let firstname = Expression<String?>("fullname")
        let email = Expression<String?>("email")
        let phone = Expression<String?>("tel")
        let birthday = Expression<String?>("birthday")
        let company = Expression<String?>("company")
        let address = Expression<String?>("address")
        let properties = Expression<String?>("properties")
        let viber = Expression<String?>("viber")
        let zalo = Expression<String?>("zalo")
        let skype = Expression<String?>("skype")
        let facebbook = Expression<String?>("facebook")
        let gender = Expression<Int64>("gender")
        let city = Expression<String?>("city")
        let country = Expression<String?>("country")
        let last_login = Expression<String?>("last_login")
        let date_created = Expression<String?>("date_created")
        let temp_avatar = Expression<String?>("temp_avatar")
        
        var pro:String = ""
        if object.properties != nil {
            pro.append(object.properties!.description)
        }
        
        let alice = customer.filter(email == object.email)
        
        do {
            try db.run(alice.update(group <- object.group_id,
                                    store_id <- object.store_id,
                                    distributor_id <- object.distributor_id,
                                    status <- object.status,
                                    classify <- object.type,
                                    firstname <- object.fullname,
                                    email <- object.email,
                                    phone <- object.tel,
                                    birthday <- object.birthday,
                                    company <- object.company,
                                    address <- object.address,
                                    properties <- pro,
                                    viber <- object.viber,
                                    zalo <- object.zalo,
                                    skype <- object.skype,
                                    gender <- object.gender,
                                    city <- object.city,
                                    country <- object.country,
                                    server_id <- object.server_id,
                                    facebbook <- object.facebook,
                                    last_login <- object.last_login,
                                    date_created <- object.date_created,
                                    temp_avatar <- object.tempAvatar))
            // UPDATE "users" SET "email" = replace("email", 'mac.com', 'me.com')
            // WHERE ("id" = 1)
        } catch {
            print(error)
        }
    }
    
    func deleteCustomer(object:Customer? = nil) {
        guard object == nil else { return }
        let customer = Table("customer")
        let id = Expression<Int64>("id")
        
        let alice = customer.filter(id == object!.id)
        
        do {
            try db.run(alice.delete())
        } catch {
            print(error)
        }
    }
    
    // MARK: - INTERFACE - Group
    public func getGroupCustomerWithCustom(sql:String? = nil) {
        guard sql != nil else {
            return
        }
        do {
            var list:Array<GroupCustomer> = []
            for user in try db.prepare(sql!) {
                var customer = GroupCustomer(id: user[0] as! Int64, distributor_id: user[6] as! Int64, store_id: user[5] as! Int64)
                customer.name = user[1] as! String
                customer.server_id = user[4] as! Int64
                customer.color = user[2] as! String
                customer.position = user[3] as! Int64
                customer.status = user[7] as! Int64
                customer.synced = user[8] as! Int64
                list.append(customer)
            }
            delegate_?.localService(localService: self, didReceiveData: list, type:.group)
        } catch {
            print(error.localizedDescription)
            delegate_?.localService(localService: self, didFailed: error, type:.group)
        }
    }
    
    func getAllGroup() {
        let group = Table("group")
        let id = Expression<Int64>("id")
        let server_id = Expression<Int64>("server_id")
        let store_id = Expression<Int64>("store_id")
        let status = Expression<Int64>("status")
        let distributor_id = Expression<Int64>("distributor_id")
        let position = Expression<Int64>("position")
        let name = Expression<String?>("name")
        let color = Expression<String?>("color")
        let synced = Expression<Int64>("synced")
        let statusFilter:Int64 = 1
        var list:Array<GroupCustomer> = []
        
        do {
            for gr in try db.prepare(group.filter(status == statusFilter)) {
                var customer = GroupCustomer(id: gr[id], distributor_id:gr[distributor_id],store_id:gr[store_id])
                if let data = gr[name] {
                    customer.name = data
                }
                customer.synced = gr[synced]
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
        let server_id = Expression<Int64>("server_id")
        let store_id = Expression<Int64>("store_id")
        let distributor_id = Expression<Int64>("distributor_id")
        let position = Expression<Int64>("position")
        let name = Expression<String?>("name")
        let color = Expression<String?>("color")
        
        do {
            let insert = group.insert(name <- obj.name, position <- obj.position, color <- obj.color,store_id <- obj.store_id,server_id <- obj.server_id,distributor_id <- obj.distributor_id)
            try db.run(insert)
            // INSERT INTO "users" ("name", "email") VALUES ('Alice', 'alice@mac.com')
        } catch {
            print(error)
            return false
        }
        return true
    }
    
    func updateGroup (object:GroupCustomer) -> Bool{
        let group = Table("group")
        let id = Expression<Int64>("id")
        let server_id = Expression<Int64>("server_id")
        let status = Expression<Int64>("status")
        let level = Expression<Int64>("position")
        let name = Expression<String>("name")
        let color = Expression<String>("color")
        let synced = Expression<Int64>("synced")
        
        let alice = group.filter(id == object.id)
        
        do {
            try db.run(alice.update(name <- object.name, level <- object.position, color <- object.color, server_id <- object.server_id, status <- object.status, synced <- 0))
            return true
        } catch {
            print(error)
            return false
        }
    }
    
    func deleteGroup(object:GroupCustomer) -> Bool{
        
        let group = Table("group")
        let id = Expression<Int64>("id")
        
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

extension LocalService {
    // MARK: - Start sync with Server
    @objc fileprivate func syncToServer() {
        self.syncCustomerToServer()
        self.syncGroupCustomerToServer()
    }
    
    private func syncCustomerToServer() {
        print("start check/sync customer to server")
        let localService:LocalService = LocalService.init()
        localService.delegate_ = self as LocalServiceDelegate
        let sql:String = "select * from `customer` where `server_id` = '0'" // customer not synced
        localService.getCustomerWithCustom(sql: sql)
    }
    
    private func syncGroupCustomerToServer() {
        print("start check/sync group to server")
        let localService:LocalService = LocalService.init()
        localService.delegate_ = self as LocalServiceDelegate
        let sql:String = "select * from `group` where `synced` = '0'" // group not synced
        localService.getGroupCustomerWithCustom(sql: sql)
    }
}

extension LocalService {
    func localService(localService: LocalService, didReceiveData: Any, type: LocalServiceType) {
        switch type {
        case .customer:
            let list:[Customer] = didReceiveData as! [Customer]
            if list.count > 0 {
                var listCustomer:[[String:Any]] = []
                _ = list.map({
                    listCustomer.append($0.toDictionary)
                })
                print("Get local customer done... send to server")
            } else {
                print("Dont have new local customer... get customer from server")
            }
        case .group:
            let list:[GroupCustomer] = didReceiveData as! [GroupCustomer]
            if list.count > 0 {
                let listCustomer:[[String:Any]] = list.flatMap({$0.toDictionary})
                print("Get local group done... send to server")
                SyncService.shared().postAllGroupToServer(list: listCustomer, completion: { result in
                    switch result {
                    case .success(let data):
                        guard data.count > 0 else {
                            print("Dont have new group from server")
                            return
                        }
                        print("remove group synced")
                        localService.customerSQl(sql: "delete from `group` where `synced` = '1'", onComplete: {
                            print("start merge group to local DB")
                            let list:[GroupCustomer] = data
                            _ = list.map({
                                LocalService.shared().addGroup(obj: $0)
                            })
                        })
                    case.failure(_):
                        print("Error: cant get group from server")
                    }
                })
            } else {
                print("Dont have new local group... get group from server")
                SyncService.shared().getAllGroup(completion: { result in
                    switch result {
                    case .success(let data):
                        guard data.count > 0 else {
                            print("Dont have new group from server")
                            return
                        }
                        print("remove group synced")
                        localService.customerSQl(sql: "delete from `group` where `synced` = '1'", onComplete: {
                            print("start merge group to local DB")
                            let list:[GroupCustomer] = data
                            _ = list.map({
                                LocalService.shared().addGroup(obj: $0)
                            })
                        })
                    case .failure(_):
                        print("Error: cant get group from server")
                        break
                    }
                })
            }
        }
    }
    
    
    func localService(localService: LocalService, didFailed: Any, type: LocalServiceType) {
        
    }
}
