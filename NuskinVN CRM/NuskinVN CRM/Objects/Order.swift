//
//  Order.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 11/26/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import Foundation
import CoreData

struct Order {
    var id: Int64 = 0
    var local_id: Int64 = 0
    var store_id: Int64 = 0
    var customer_id: Int64 = 0
    var distributor_id: Int64 = 0
    var user_type: Int64 = 0
    var code: String = ""
    var name: String = ""
    var email: String = ""
    var address: String = ""
    var province: String = ""
    var tel: String = ""
    var cell: String = ""
    var date_created: NSDate?
    var last_updated: NSDate?
    var properties: String?
    var status: Int64 = 0
    var payment_status: Int64 = 0
    var validity: String = ""
    var total: Int64 = 0
    var number_domain: Int64 = 0
    var synced: Bool = true
    var payment_option: Int64 = 0
    var svd: String = ""
    var shipping_unit: Int64 = 0
    
    var toDO:[String:Any] {
        
        return [
            "code":code,
            "id":id,
            "local_id":local_id,
            "store_id":store_id,
            "distributor_id":distributor_id,
            "customer_id":customer_id,
            "status":status,
            "payment_status":payment_status,
            "payment_option":payment_option,
            "shipping_unit":shipping_unit,
            "properties": properties ?? "",
            "svd":svd,
            "email":email,
            "tel":tel,
            "cell":cell,
            "address":address,
            "date_created":date_created as Any,
            "last_updated":last_updated as Any,
            "synced":synced
        ]
    }
    
    var toDictionary:[String:Any] {
        
        var date_created_ = ""
        var last_updated_ = ""
        
        if let created = date_created as Date?{
            date_created_ = created.toString(dateFormat: "yyyy-MM-dd HH:mm:ss")
        }
        
        if let updated = last_updated as Date?{
            last_updated_ = updated.toString(dateFormat: "yyyy-MM-dd HH:mm:ss")
        }
        
        return [
            "code":code,
            "id":id,
            "local_id":local_id,
            "store_id":store_id,
            "distributor_id":distributor_id,
            "customer_id":customer_id,
            "status":status,
            "payment_status":payment_status,
            "payment_option":payment_option,
            "shipping_unit":shipping_unit,
            "transporter_other":transporter_other ?? "",
            "district":district,
            "city":city,
            "svd":svd,
            "email":email,
            "tel":tel,
            "cell":cell,
            "address":address,
            "date_created":date_created_,
            "last_updated":last_updated_,
            "order_items":orderItemsDictionary,
            "synced":synced
        ]
    }
    
    var totalPrice:Int64  {
        var total:Int64 = 0
        _ = orderItems().map({
            total += ($0.price * $0.quantity)
        })
        return total
    }
    
    var totalPV:Int64  {
        var total:Int64 = 0
        _ = orderItems().map({
            if let product = $0.product() {
                total += (product.pv * $0.quantity)
            }
        })
        return total
    }
    
    func customer() -> Customer? {
        if customer_id == 0 {
            return nil
        }
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CustomerDO")
        //            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "fullname", ascending: true)]
        if let user = UserManager.currentUser() {
            fetchRequest.predicate = NSPredicate(format: "(id IN %@ OR local_id IN %@) AND distributor_id IN %@", [customer_id],[customer_id],[user.id])
        }
        
        
        do {
            let result = try CoreDataStack.sharedInstance.saveManagedObjectContext.fetch(fetchRequest)
            var list:[Customer] = []
            let listTemp = result.flatMap({$0 as? CustomerDO})
            if listTemp.count > 0 {
                list = listTemp.flatMap{Customer.parse($0.toDictionary)}
                return list[0]
            }
            
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
        
        return nil
    }
    
    var orderItemsDictionary:[JSON] {
        let items = orderItems()
        var list:[JSON] = []
        list = items.flatMap({
            $0.toDictionary
        })
        return list
    }
    
    func numberOrderItems() -> Int64 {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "OrderItemDO")
        //            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "fullname", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "(order_id IN %@ OR order_id IN %@)", [id],[local_id])
        
        
        do {
            let result = try CoreDataStack.sharedInstance.saveManagedObjectContext.count(for:fetchRequest)
            return Int64(result)
            
            
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
        
        return 0
    }
    
    func orderItems() -> [OrderItem] {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "OrderItemDO")
        //            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "fullname", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "(order_id IN %@ OR order_id IN %@)", [id],[local_id])
        
        
        do {
            let result = try CoreDataStack.sharedInstance.saveManagedObjectContext.fetch(fetchRequest)
            var list:[OrderItem] = []
            let listTemp = result.flatMap({$0 as? OrderItemDO})
            list = listTemp.flatMap{OrderItem.parse($0.toDictionary)}
            return list
            
            
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
        
        return []
    }
    
    // MARK: - properties
    mutating func setOtherTransporter(_ color:String) {
        if let pro = properties {
            do {
                if let jsonData = pro.data(using: String.Encoding.utf8) {
                    if var pro:JSON = try JSONSerialization.jsonObject(with: jsonData, options: []) as? JSON {
                        pro["transporter_other"] = color
                        
                        do {
                            let jsonData = try JSONSerialization.data(withJSONObject: pro)
                            if let pro = String(data: jsonData, encoding: .utf8) {
                                properties = pro
                            }
                        }catch{}
                    }
                }
            }catch{}
        } else {
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: ["transporter_other":color])
                if let pro = String(data: jsonData, encoding: .utf8) {
                    properties = pro
                }
            }catch{}
        }
    }
    
    var transporter_other:String? {
        var gcolor:String?
        if let properties = self.properties {
            if let data = properties.data(using: String.Encoding.utf8) {
                do {
                    if let pro:JSON = try JSONSerialization.jsonObject(with: data, options: []) as? JSON {
                        if let color = pro["transporter_other"] as? String {
                            gcolor = color
                        }
                    }
                } catch {
                    print("warning parse properties Order: \(properties)")
                }
            }
        }
        return gcolor
    }
    
    
    mutating func setCity(_ color:String) {
        if let pro = properties {
            do {
                if let jsonData = pro.data(using: String.Encoding.utf8) {
                    if var pro:JSON = try JSONSerialization.jsonObject(with: jsonData, options: []) as? JSON {
                        pro["city"] = color
                        
                        do {
                            let jsonData = try JSONSerialization.data(withJSONObject: pro)
                            if let pro = String(data: jsonData, encoding: .utf8) {
                                properties = pro
                            }
                        }catch{}
                    }
                }
            }catch{}
        } else {
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: ["city":color])
                if let pro = String(data: jsonData, encoding: .utf8) {
                    properties = pro
                }
            }catch{}
        }
    }
    
    var city:String {
        var gcolor:String = ""
        if let properties = self.properties {
            if let data = properties.data(using: String.Encoding.utf8) {
                do {
                    if let pro:JSON = try JSONSerialization.jsonObject(with: data, options: []) as? JSON {
                        if let color = pro["city"] as? String {
                            gcolor = color
                        }
                    }
                } catch {
                    print("warning parse properties Order: \(properties)")
                }
            }
        }
        return gcolor
    }
    
    mutating func setDistrict(_ color:String) {
        if let pro = properties {
            do {
                if let jsonData = pro.data(using: String.Encoding.utf8) {
                    if var pro:JSON = try JSONSerialization.jsonObject(with: jsonData, options: []) as? JSON {
                        pro["district"] = color
                        
                        do {
                            let jsonData = try JSONSerialization.data(withJSONObject: pro)
                            if let pro = String(data: jsonData, encoding: .utf8) {
                                properties = pro
                            }
                        }catch{}
                    }
                }
            }catch{}
        } else {
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: ["district":color])
                if let pro = String(data: jsonData, encoding: .utf8) {
                    properties = pro
                }
            }catch{}
        }
    }
    
    var district:String {
        var gcolor:String = ""
        if let properties = self.properties {
            if let data = properties.data(using: String.Encoding.utf8) {
                do {
                    if let pro:JSON = try JSONSerialization.jsonObject(with: data, options: []) as? JSON {
                        if let color = pro["district"] as? String {
                            gcolor = color
                        }
                    }
                } catch {
                    print("warning parse properties Order: \(properties)")
                }
            }
        }
        return gcolor
    }
    
    // MARK: - validate
    func validateCode(code:String, oldCode:String,except:Bool)->Bool {
        guard let user = UserManager.currentUser() else { return false }
        if code.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines).characters.count == 0 {
            return true
        }
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "OrderDO")
        
        
        var predicate = NSPredicate(format: "code == %@ AND distributor_id == %d", code, user.id)
        if except {
            predicate = NSPredicate(format: "code == %@ AND code <> %@ AND distributor_id == %d", code,oldCode,user.id)
        }
        
        fetchRequest.predicate = predicate
        do {
            
            let results = try CoreDataStack.sharedInstance.saveManagedObjectContext.fetch(fetchRequest)
            
            return results.count == 0
            
        } catch let error as NSError {
            
            print(error)
            
        }
        return false
    }
    
    static func validateCode(code:String)->Bool {
        guard let user = UserManager.currentUser() else {
            return false
            
        }
        if code.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines).characters.count == 0 {
            return true
        }
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "OrderDO")
        
        
        let predicate = NSPredicate(format: "code == %@ AND distributor_id IN %@", code, [user.id])
        
        fetchRequest.predicate = predicate
        do {
            
            let results = try CoreDataStack.sharedInstance.saveManagedObjectContext.fetch(fetchRequest)
            
            return results.count == 0
            
        } catch let error as NSError {
            
            print(error)
            
        }
        return false
    }
}

extension Order {
    static func parse(dictionary:JSON) -> Order {
        var object = Order()
        
        object.synced = true
        
        if let data = dictionary["synced"] as? Bool {
            object.synced = data
        }
        
        if let data = dictionary["id"] as? String {
            object.id = Int64(data)!
        } else if let data = dictionary["id"] as? Int64 {
            object.id = data
        }
        
        if let data = dictionary["local_id"] as? String {
            object.local_id = Int64(data)!
        } else if let data = dictionary["local_id"] as? Int64 {
            object.local_id = data
        }
        
        if let data = dictionary["customer_id"] as? String {
            object.customer_id = Int64(data)!
        } else if let data = dictionary["customer_id"] as? Int64 {
            object.customer_id = data
        }
        
        if let data = dictionary["store_id"] as? String {
            object.store_id = Int64(data)!
        } else if let data = dictionary["store_id"] as? Int64 {
            object.store_id = data
        }
        
        if let data = dictionary["distributor_id"] as? String {
            object.distributor_id = Int64(data)!
        } else if let data = dictionary["distributor_id"] as? Int64 {
            object.distributor_id = data
        }
        
        if let data = dictionary["payment_option"] as? String {
            object.payment_option = Int64(data)!
        } else if let data = dictionary["payment_option"] as? Int64 {
            object.payment_option = data
        }
        
        if let data = dictionary["shipping_unit"] as? String {
            object.shipping_unit = Int64(data)!
        } else if let data = dictionary["shipping_unit"] as? Int64 {
            object.shipping_unit = data
        }
        
        if let data = dictionary["email"] as? String {
            object.email = data
        }
        if let data = dictionary["address"] as? String {
            object.address = data
        }
        if let data = dictionary["tel"] as? String {
            object.tel = data
        }
        if let data = dictionary["cell"] as? String {
            object.cell = data
        }
        
        if let data = dictionary["svd"] as? String {
            object.svd = data
        }
        if let data = dictionary["status"] as? String {
            object.status = Int64(data)!
        } else if let data = dictionary["status"] as? Int64 {
            object.status = data
        }
        
        if let data = dictionary["payment_status"] as? String {
            object.payment_status = Int64(data)!
        } else if let data = dictionary["payment_status"] as? Int64 {
            object.payment_status = data
        }
        
        if let data = dictionary["name"] as? String {
            object.name = data
        }
        if let data = dictionary["code"] as? String {
            object.code = data
        }
        
        if let data = dictionary["date_created"] as? String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            if let myDate = dateFormatter.date(from: data) {
                object.date_created = myDate as NSDate
            }
        } else if let data = dictionary["date_created"] as? NSDate{
            object.date_created = data
        }
        
        if let data = dictionary["last_updated"] as? String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            if let myDate = dateFormatter.date(from: data) {
                object.last_updated = myDate as NSDate
            }
        } else if let data = dictionary["last_updated"] as? NSDate{
            object.last_updated = data
        }
        
        if let properties = dictionary["properties"] as? JSON {
            let jsonData = try! JSONSerialization.data(withJSONObject: properties)
            if let pro = String(data: jsonData, encoding: .utf8) {
                object.properties = pro
            }
            if let add = properties["ship_address"] as? String {
                object.address = add
            }
            if let data = properties["payment_option"] as? String {
                object.payment_option = Int64(data)!
            } else if let data = properties["payment_option"] as? Int64 {
                object.payment_option = data
            }
            
            if let data = properties["shiping"] as? String {
                object.shipping_unit = Int64(data)!
            } else if let data = properties["shiping"] as? Int64 {
                object.shipping_unit = data
            }
            if let data = properties["svd"] as? String {
                object.svd = data
            }
            if let data = properties["svd"] as? String {
                object.svd = data
            }
            
            if let data = properties["city"] as? String {
                object.setCity(data)
            }
            
            if let data = properties["district"] as? String {
                object.setDistrict(data)
            }
            
            if let data = properties["transporter_other"] as? String {
                object.setOtherTransporter(data)
            }
        } else if let properties = dictionary["properties"] as? String{
            object.properties = properties
        }
        
        return object
    }
}
