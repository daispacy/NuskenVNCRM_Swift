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
    case order
}

let path = NSSearchPathForDirectoriesInDomains(
    .documentDirectory, .userDomainMask, true
    ).first!

final class LocalService: NSObject {
    
    static let shared = LocalService()
    
    // MARK: -
    var db: Connection!
    
    var isMoveDB:Bool = false
    var isSync:Bool = false
    var timerSyncToServer:Timer?
    
    // Initialization
    private override init() {
        super.init()
        
        do {
            self.db = try Connection("\(prepareDatabaseFile())")
            self.db.busyTimeout = 30
//            db.busyHandler({ tries in
//                if tries >= 9999 {
//                    return false
//                }
//                return true
//            })
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func prepareDatabaseFile() -> String {
        let fileName: String = AppConfig.db.name
        
        let fileManager:FileManager = FileManager.default
        let directory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let documentUrl = directory.appendingPathComponent(fileName)
        let bundleUrl = Bundle.main.resourceURL?.appendingPathComponent("crm.sqlite")
        
        // here check if file already exists on simulator
        if fileManager.fileExists(atPath: (documentUrl.path)) {
                print("DB exists! \(documentUrl.path)")
            return documentUrl.path
        } else if fileManager.fileExists(atPath: (bundleUrl?.path)!) {
            print("document file does not exist, copy from bundle!")
            do {
                try fileManager.copyItem(at:bundleUrl!, to:documentUrl)
            } catch let error as NSError {
                print("Couldn't copy file to final location! Error:\(error.description)")
            }
        }
        return documentUrl.path
    }
    
    
    //start service
    func startSyncData() {
        // first
        self.syncToServer()
        
        if let bool = self.timerSyncToServer?.isValid {
            if bool {self.timerSyncToServer?.invalidate()}
        }
        
        // loop
        self.timerSyncToServer = Timer.scheduledTimer(timeInterval: 60*3, target: self, selector: #selector(self.syncToServer), userInfo: nil, repeats: true)
    }
    
    // MARK: - Accessors
//    class func shared() -> LocalService {
//        return sharedLocalService
//    }
    
    // MARK: - Customer SQL
    func customSQl(sql:String, onComplete:(()->Void)){
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
    public func getCustomerWithCustom(sql:String, onComplete:(([Customer]) -> Void)) {
       
        do {
            var list:Array<Customer> = []
            for user in try db.prepare(sql) {
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
                customer.synced = user[25] as! Int64
                list.append(customer)
            }
            onComplete(list)
        } catch {
            print(error.localizedDescription)
            onComplete([])
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
        let synced = Expression<Int64?>("synced")
        
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
                                     temp_avatar <- object.tempAvatar,
                                     synced <- object.synced)
        do {
            try db.run(insert)
            // INSERT INTO "users" ("name", "email") VALUES ('Alice', 'alice@mac.com')
            return true
        } catch {
            print(error)
            return false
        }
    }
    
    func updateCustomer(object:Customer) ->Bool{
        
        let customer = Table("customer")
        let id = Expression<Int64>("id")
        let group = Expression<Int64>("group_id")
        let server_id = Expression<Int64>("server_id")
        let store_id = Expression<Int64>("store_id")
        let distributor_id = Expression<Int64>("distributor_id")
        let status = Expression<Int64?>("status")
        let classify = Expression<Int64?>("type")
        let firstname = Expression<String?>("fullname")
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
        let synced = Expression<Int64?>("synced")
        
        var pro:String = ""
        if object.properties != nil {
            pro.append(object.properties!.description)
        }
        
        let alice = customer.filter(id == object.id)
        
        do {
            try db.run(alice.update(group <- object.group_id,
                                    id <- object.id,
                                    store_id <- object.store_id,
                                    distributor_id <- object.distributor_id,
                                    status <- object.status,
                                    classify <- object.type,
                                    firstname <- object.fullname,
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
                                    temp_avatar <- object.tempAvatar,
                                    synced <- 0))
            // UPDATE "users" SET "email" = replace("email", 'mac.com', 'me.com')
            // WHERE ("id" = 1)
            return true
        } catch {
            print(error)
            return false
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
    
    func countLocalData(sql:String) -> Int64{
        do {
            return try db.scalar(sql) as! Int64
        } catch {
            print(error)
            return 0
        }
    }
    
    func getCustomerFromID(customerID:Int64 = 0) -> Customer{
        do {
            var list:Array<Customer> = []
            for user in try db.prepare("select * from `customer` where `id` = '\(customerID)' OR `server_id` = '\(customerID)'") {
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
                customer.synced = user[25] as! Int64
                list.append(customer)
            }
            
            if list.count > 0 {
                return list.first!
            }
        } catch {
            print(error.localizedDescription)
            return Customer(id: 0, distributor_id: 0, store_id: 0)
        }
        return Customer(id: 0, distributor_id: 0, store_id: 0)
    }
    
    // MARK: - INTERFACE - Group
    public func getGroupCustomerWithCustom(sql:String? = nil, onComplete:(([GroupCustomer])->Void)) {
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
            onComplete(list)
        } catch {
            print(error.localizedDescription)
            onComplete([])
        }
    }
    
    func getAllGroup(onComplete:([GroupCustomer])->Void) {
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
            
            onComplete(list)
        } catch {
            print(error.localizedDescription)
            onComplete([])
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
        let synced = Expression<Int64?>("synced")
        
        do {
            let insert = group.insert(name <- obj.name, position <- obj.position, color <- obj.color,store_id <- obj.store_id,server_id <- obj.server_id,distributor_id <- obj.distributor_id, synced <- obj.synced)
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
    
    func getNameGroupFromID(sql:String) -> String{
        do {
            if let string =  try db.scalar(sql) as? String {
                return string
            }
            return ""
        } catch {
            print(error)
            return ""
        }
    }
    
    // MARK: - product
    func addProduct(obj:Product, onComplete:((Int64)->Void)){
        
        let group = Table("product")
        let country_id = Expression<Int64>("server_id")
        let name = Expression<String?>("name")
        
        do {
            let insert = group.insert(name <- obj.name, country_id <- obj.server_id)
            let rowID = try db.run(insert)
            // INSERT INTO "users" ("name", "email") VALUES ('Alice', 'alice@mac.com')
            onComplete(rowID)
        } catch {
            print(error)
            onComplete(0)
        }
    }
    
    func updateProduct (object:Product) -> Bool{
        let group = Table("product")
        let id = Expression<Int64>("id")
        let country_id = Expression<Int64>("server_id")
        let name = Expression<String?>("name")
        let synced = Expression<Int64>("synced")
        
        let alice = group.filter(id == object.id)
        
        do {
            try db.run(alice.update(name <- object.name, country_id <- object.server_id, synced <- 0))
            return true
        } catch {
            print(error)
            return false
        }
    }
    
    func getAllProduct(complete:([Product])->Void){
        
        var list:Array<Product> = []
        let stringSQL = "select * from `product`"
        do {
            for gr in try db.prepare(stringSQL) {
                
                var customer = Product()
                customer.id = gr[0] as! Int64
                customer.server_id = gr[1] as! Int64
                customer.synced = gr[3] as! Int64
                customer.name = gr[2] as! String
                
                list.append(customer)
            }
            complete(list)
        } catch {
            print(error.localizedDescription)
            complete([])
        }
    }
    
    func getAllProduct(orderID:Int64 = 0) -> [Product]{
        
        var list:Array<Product> = []
        let stringSQL = "select `product`.id, `product`.name, `product`.server_id, `product`.synced, `order_product`.price, `order_product`.`quantity` from `product`  join `order_product` on `order_product`.product_id = `product`.id where `order_product`.order_id = \(orderID)"
//        if orderID > 0 {
//            stringSQL.append(" where `id` in (select product_id from `order_product` where `order_id` = '\(orderID)')")
//        }
        do {
            for gr in try db.prepare(stringSQL) {
                
                var customer = Product()
                customer.id = gr[0] as! Int64
                customer.server_id = gr[2] as! Int64
                customer.synced = gr[3] as! Int64
                customer.name = gr[1] as! String
                customer.price = gr[4] as! Int64
                customer.quantity = gr[5] as! Int64
                
                list.append(customer)
            }
            return list
        } catch {
            print(error.localizedDescription)
            return []
        }        
    }
    
    // MARK: - order
    func addOrder(obj:Order,onComplete:(()->Void)){
        
        let group = Table("order")
        let server_id = Expression<Int64>("server_id")
        let store_id = Expression<Int64>("store_id")
        let user_id = Expression<Int64>("user_id")
        let customer_id = Expression<Int64>("customer_id")
        let order_code = Expression<String?>("order_code")
        let email = Expression<String?>("address")
        let tel = Expression<String?>("tel")
        let address = Expression<String?>("address")
        let date_created = Expression<String?>("date_created")
        let last_updated = Expression<String?>("last_updated")
        let status = Expression<Int64>("status")
        let payment_status = Expression<Int64>("payment_status")
        let payment_method = Expression<String?>("payment_method")
        let shipping_unit = Expression<String?>("shipping_unit")
        let transporter_id = Expression<String?>("transporter_id")
        let note = Expression<String?>("note")
        let synced = Expression<Int64>("synced")
        
        //order_product table
        let order_product = Table("order_product")
        let order_id = Expression<Int64>("order_id")
        let product_id = Expression<Int64>("product_id")
        let price = Expression<Int64>("price")
        let quantity = Expression<Int64>("quantity")
        
        do {
            try db.transaction {
                let insert = group.insert(server_id <- obj.server_id,
                                          store_id <- obj.store_id,
                                          user_id <- obj.user_id,
                                          customer_id <- obj.customer_id,
                                          order_code <- obj.order_code,
                                          email <- obj.email,
                                          tel <- obj.tel,
                                          address <- obj.address,
                                          date_created <- obj.date_created,
                                          last_updated <- obj.last_updated,
                                          status <- obj.status,
                                          payment_status <- obj.payment_status,
                                          payment_method <- obj.payment_method,
                                          shipping_unit <- obj.shipping_unit,
                                          transporter_id <- obj.transporter_id,
                                          note <- obj.note,
                                          synced <- 0
                )
                let orderID = try db.run(insert)
                _ = obj.tempProducts.map({
                    let product = $0
                    if $0.id > 0 {
                        if LocalService.shared.updateProduct(object: $0) {
                            do {
                                try db.run(order_product.insert(product_id <- $0.id, order_id <- orderID, price <- $0.price, quantity <- $0.quantity))
                            } catch {
                                onComplete()
                            }
                        }
                    } else {
                        LocalService.shared.addProduct(obj: $0, onComplete: {
                            productID in
                            if productID > 0 {
                                do {
                                    try db.run(order_product.insert(product_id <- productID, order_id <- orderID, price <- product.price, quantity <- product.quantity))
                                } catch {
                                    onComplete()
                                }
                            }
                        })
                        
                    }
                })
            }
            onComplete()
            // INSERT INTO "users" ("name", "email") VALUES ('Alice', 'alice@mac.com')
        } catch {
            print(error)
            onComplete()
        }
    }
    
    func updateOrder(obj:Order,onComplete:(()->Void)){
        
        let group = Table("order")
        let id = Expression<Int64>("id")
        let server_id = Expression<Int64>("server_id")
        let store_id = Expression<Int64>("store_id")
        let user_id = Expression<Int64>("user_id")
        let customer_id = Expression<Int64>("customer_id")
        let order_code = Expression<String?>("order_code")
        let email = Expression<String?>("address")
        let tel = Expression<String?>("tel")
        let address = Expression<String?>("address")
        let date_created = Expression<String?>("date_created")
        let last_updated = Expression<String?>("last_updated")
        let status = Expression<Int64>("status")
        let payment_status = Expression<Int64>("payment_status")
        let payment_method = Expression<String?>("payment_method")
        let shipping_unit = Expression<String?>("shipping_unit")
        let transporter_id = Expression<String?>("transporter_id")
        let note = Expression<String?>("note")
        let synced = Expression<Int64>("synced")
        
        //order_product table
        let order_product = Table("order_product")
        let order_id = Expression<Int64>("order_id")
        let product_id = Expression<Int64>("product_id")
        let price = Expression<Int64>("price")
        let quantity = Expression<Int64>("quantity")
        
        let alice = group.filter(id == obj.id)
        do {
            try db.transaction {
                let insert = alice.update(server_id <- obj.server_id,
                                          store_id <- obj.store_id,
                                          user_id <- obj.user_id,
                                          customer_id <- obj.customer_id,
                                          order_code <- obj.order_code,
                                          email <- obj.email,
                                          tel <- obj.tel,
                                          address <- obj.address,
                                          date_created <- obj.date_created,
                                          last_updated <- obj.last_updated,
                                          status <- obj.status,
                                          payment_status <- obj.payment_status,
                                          payment_method <- obj.payment_method,
                                          shipping_unit <- obj.shipping_unit,
                                          transporter_id <- obj.transporter_id,
                                          note <- obj.note,
                                          synced <- 0
                )
                try db.run(insert)
                LocalService.shared.customSQl(sql: "delete from `order_product` where order_id = \(obj.id)", onComplete: {
                    _ = obj.tempProducts.map({
                        let product = $0
                        if $0.id > 0 {
                            if LocalService.shared.updateProduct(object: $0) {
                                do {
                                    try db.run(order_product.insert(product_id <- $0.id, order_id <- obj.id, price <- $0.price, quantity <- $0.quantity))
                                } catch {
                                    onComplete()
                                }
                            }
                        } else {
                            LocalService.shared.addProduct(obj: $0, onComplete: {
                                productID in
                                if productID > 0 {
                                    do {
                                        try db.run(order_product.insert(product_id <- productID, order_id <- obj.id, price <- product.price, quantity <- product.quantity))
                                    } catch {
                                        onComplete()
                                    }
                                }
                            })
                            
                        }
                    })
                })
            }
            onComplete()
            // INSERT INTO "users" ("name", "email") VALUES ('Alice', 'alice@mac.com')
        } catch {
            print(error)
            onComplete()
        }
    }
    
    func getAllOrder(_ customerID:Int64 = 0, onComplete:(([Order])->Void)) {
        let group = Table("order")
        let id = Expression<Int64>("id")
        let server_id = Expression<Int64>("server_id")
        let store_id = Expression<Int64>("store_id")
        let user_id = Expression<Int64>("user_id")
        let customer_id = Expression<Int64>("customer_id")
        let order_code = Expression<String?>("order_code")
        let email = Expression<String?>("address")
        let tel = Expression<String?>("tel")
        let address = Expression<String?>("address")
        let date_created = Expression<String?>("date_created")
        let last_updated = Expression<String?>("last_updated")
        let status = Expression<Int64>("status")
        let payment_status = Expression<Int64>("payment_status")
        let payment_method = Expression<String?>("payment_method")
        let shipping_unit = Expression<String?>("shipping_unit")
        let synced = Expression<Int64>("synced")
        let transporter_id = Expression<String?>("transporter_id")
        let note = Expression<String?>("note")
        var list:Array<Order> = []
        
        // Start with "true" expression (matches all records):
        var myFilter = Expression<Bool>(value: true)
        if customerID > 0 {
            myFilter = myFilter && (customer_id == customerID)
        }
        
        do {
            for gr in try db.prepare(group.filter(myFilter)) {
                var customer = Order()
                customer.id = gr[id]
                if let data = gr[order_code] {
                    customer.order_code = data
                }
                customer.synced = gr[synced]
                customer.server_id = gr[server_id]
                customer.store_id = gr[store_id]
                customer.user_id = gr[user_id]
                customer.customer_id = gr[customer_id]
                customer.status = gr[status]
                customer.payment_status = gr[payment_status]
                
                if let data = gr[order_code] {
                    customer.order_code = data
                }
                
                if let data = gr[email] {
                    customer.email = data
                }
                
                if let data = gr[tel] {
                    customer.tel = data
                }
                
                if let data = gr[address] {
                    customer.address = data
                }
                
                if let data = gr[date_created] {
                    customer.date_created = data
                }
                
                if let data = gr[last_updated] {
                    customer.last_updated = data
                }
                
                if let data = gr[address] {
                    customer.address = data
                }
                
                if let data = gr[payment_method] {
                    customer.payment_method = data
                }
                
                if let data = gr[shipping_unit] {
                    customer.shipping_unit = data
                }
                if let data = gr[transporter_id] {
                    customer.transporter_id = data
                }
                if let data = gr[note] {
                    customer.note = data
                }
                
                list.append(customer)
            }
            onComplete(list)
        } catch {
            print(error.localizedDescription)
            onComplete([])
        }
    }
    
    // MARK: - interface city
    func addCity(obj:City){
        
        let group = Table("city")
        let id = Expression<Int64>("id")
        let country_id = Expression<Int64>("country_id")
        let name = Expression<String?>("name")
        
        do {
            let insert = group.insert(name <- obj.name, country_id <- obj.country_id,id <- obj.id)
            try db.run(insert)
            // INSERT INTO "users" ("name", "email") VALUES ('Alice', 'alice@mac.com')
        } catch {
            print(error)
        }
    }
    
    func getAllCity(complete:([City])->Void){
        
        let listT = NSKeyedUnarchiver.unarchiveObject(with:UserDefaults.standard.value(forKey: "App:ListCity") as! Data) as! [JSON]
        let listCountry:[City] = listT.flatMap({City(json:$0)})
        if listCountry.count > 0 {
            complete(listCountry)
            return
        }
        
        let group = Table("city")
        let id = Expression<Int64>("id")
        let country_id = Expression<Int64>("country_id")
        let name = Expression<String?>("name")
        
        var list:Array<City> = []
        
        do {
            for gr in try db.prepare(group.order(name.asc,name)) {
                var customer = City()
                customer.id = gr[id]
                customer.country_id = gr[country_id]
                if let name = gr[name] {
                    customer.name = name
                }
                list.append(customer)
            }
            complete(list)
        } catch {
            print(error.localizedDescription)
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
        let sql:String = "select * from `customer` where `synced` = '0'" // customer not synced
        LocalService.shared.getCustomerWithCustom(sql: sql, onComplete: {
            list in
            if list.count > 0 {
                var listCustomer:[[String:Any]] = []
                _ = list.map({
                    listCustomer.append($0.toDictionary)
                })
                print("Get local customer done... send to server")
                SyncService.shared.postAllCustomerToServer(list: listCustomer, completion: { result in
                    switch result {
                    case .success(let data):
                        guard data.count > 0 else {
                            print("Dont have new customer from server")
                            return
                        }
                        
                        print("start merge customer to local DB")
                        do {
                            try LocalService.shared.db.transaction {
                                let list:[Customer] = data
                                _ = list.map({
                                    LocalService.shared.customSQl(sql: "delete from `customer` where `email` = '\($0.email)'", onComplete: {
                                        print("remove customer synced")
                                    })
                                    _ = LocalService.shared.addCustomer(object: $0)
                                })
                            }
                        }catch{
                            
                        }
                        NotificationCenter.default.post(name:Notification.Name("SyncData:Customer"),object:nil)
                    case.failure(_):
                        print("Error: cant get group from server 1")
                    }
                })
            } else {
                print("Dont have new local customer... get customer from server")
                SyncService.shared.getCustomers(completion: { result in
                    switch result {
                    case .success(let data):
                        guard data.count > 0 else {
                            print("Dont have new customer from server")
                            return
                        }
                        
                        print("start merge customer to local DB 2")
                        do{
                            try LocalService.shared.db.transaction {
                                let list:[Customer] = data
                                _ = list.map({
                                    LocalService.shared.customSQl(sql: "delete from `customer` where `email` = '\($0.email)'", onComplete: {
                                        print("remove customer synced 2")
                                    })
                                    _ = LocalService.shared.addCustomer(object: $0)
                                })
                            }
                        } catch {
                            
                        }
                        NotificationCenter.default.post(name:Notification.Name("SyncData:Customer"),object:nil)
                    case .failure(_):
                        print("Error: cant get customer from server 2")
                        break
                    }
                })
            }
        })
    }
    
    private func syncGroupCustomerToServer() {
        print("start check/sync group to server")
        let sql:String = "select * from `group` where `synced` = '0'" // group not synced
        LocalService.shared.getGroupCustomerWithCustom(sql: sql, onComplete: {
            list in
            if list.count > 0 {
                let listCustomer:[[String:Any]] = list.flatMap({$0.toDictionary})
                print("Get local group done... send to server")
                SyncService.shared.postAllGroupToServer(list: listCustomer, completion: { result in
                    switch result {
                    case .success(let data):
                        guard data.count > 0 else {
                            print("Dont have new group from server 1")
                            return
                        }
                        print("remove group synced")
                        do{
                            try LocalService.shared.db.transaction {
                                LocalService.shared.customSQl(sql: "delete from `group`", onComplete: {
                                    print("start merge group to local DB")
                                    let list:[GroupCustomer] = data
                                    _ = list.map({
                                        LocalService.shared.addGroup(obj: $0)
                                    })
                                    NotificationCenter.default.post(name:Notification.Name("SyncData:Group"),object:nil)
                                })
                            }
                        } catch {
                            
                        }
                    case.failure(_):
                        print("Error: cant get group from server 1")
                    }
                })
            } else {
                print("Dont have new local group... get group from server")
                SyncService.shared.getAllGroup(completion: { result in
                    switch result {
                    case .success(let data):
                        guard data.count > 0 else {
                            print("Dont have new group from server 2")
                            return
                        }
                        print("remove group synced")
                       
                        do{
                            try LocalService.shared.db.transaction {
                                LocalService.shared.customSQl(sql: "delete from `group`", onComplete: {
                                    print("start merge group to local DB")
                                    let list:[GroupCustomer] = data
                                    _ = list.map({
                                        LocalService.shared.addGroup(obj: $0)
                                    })
                                    NotificationCenter.default.post(name:Notification.Name("SyncData:Group"),object:nil)
                                })
                            }
                        }catch {
                            
                        }
                        
                    case .failure(_):
                        print("Error: cant get group from server 2")
                        break
                    }
                })
            }
        })
    }
}
