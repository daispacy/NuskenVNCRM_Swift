//
//  Customer.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 11/26/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import Foundation
import CoreData

struct Customer {
     var address: String = ""
     var local_id: Int64 = 0
     var area_id: Int64 = 0
     var city: String = ""
     var county: String = ""
     var date_created: NSDate?
     var distributor_id: Int64 = 0
     var email: String = ""
     var fullname: String = ""
     var gender: Int64 = 0
     var group_id: Int64 = 0
     var id: Int64 = 0
     var last_login: NSDate?
     var birthday: NSDate?
     var password: String = ""
     var properties: String?
     var status: Int64 = 0
     var store_id: Int64 = 0
     var tel: String = ""
     var type: Int64 = 0
     var city_id: Int64 = 0
     var district_id: Int64 = 0
     var username: String = ""
     var group_name: String = ""
     var synced: Bool = false
     var avatar: String = ""
    
    var toDictionary:[String:Any] {
        
        var proper:JSON = [:]
        if let properties = self.properties {
            if let data = properties.data(using: String.Encoding.utf8) {
                do {
                    if let pro:JSON = try JSONSerialization.jsonObject(with: data, options: []) as? JSON {
                        proper = pro
                    }
                } catch {
                    print("warning parse properties CUSTOMER: \(properties)")
                }
            }
        }
        
        var date_created_ = ""
        var last_updated_ = ""
        var birthday_ = ""
        
        if let created = date_created as Date?{
            date_created_ = created.toString(dateFormat: "yyyy-MM-dd HH:mm:ss")
        }
        
        if let updated = last_login as Date?{
            last_updated_ = updated.toString(dateFormat: "yyyy-MM-dd HH:mm:ss")
        }
        
        if let updated = birthday as Date?{
            birthday_ = updated.toString(dateFormat: "yyyy-MM-dd")
        }
        
        return [
            "id": id,
            "store_id": store_id,
            "distributor_id": distributor_id,
            "area_id": area_id,
            "type": type,
            "city_id": city_id,
            "district_id": district_id,
            "username": username,
            "password": password,
            "fullname": fullname,
            "gender": gender,
            "address": address,
            "email": email,
            "city": city,
            "county": county,
            "tel": tel,
            "skype": skype,
            "facebook": facebook,
            "viber": viber,
            "zalo": zalo,
            "avatar": avatar,
            "group_id": group_id,
            "properties": proper,
            "date_created": date_created_,
            "last_login": last_updated_,
            "birthday": birthday_,
            "status": status,
            "synced":synced
        ]
    }
    
    var toDO:[String:Any] {
        
        return [
            "id": id,
            "store_id": store_id,
            "distributor_id": distributor_id,
            "area_id": area_id,
            "type": type,
            "city_id": city_id,
            "district_id": district_id,
            "username": username,
            "password": password,
            "fullname": fullname,
            "gender": gender,
            "address": address,
            "email": email,
            "city": city,
            "county": county,
            "tel": tel,
            "avatar": avatar,
            "group_id": group_id,
            "properties": properties ?? "",
            "date_created": date_created as Any,
            "last_login": last_login as Any,
            "birthday": birthday as Any,
            "status": status,
            "synced":synced
        ]
    }
    
    var isCongratBirthday:Bool {
        let list = [local_id,id].filter{$0 != 0}
        return !BirthdayManager.checkBirthday(list)
    }
    
    var isRemind:Bool {
        let list = [local_id,id].filter{$0 != 0}
        return NotOrder30DOManager.checkRemind(list)
    }
    
    static func isExist(email:String, oldEmail:String,except:Bool) -> Bool{
        guard let user = UserManager.currentUser() else { return true }
        if email.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines).characters.count == 0 {
            return false
        }
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CustomerDO")
        
        
        var predicate = NSPredicate(format: "email == %@ AND distributor_id == %d", email, user.id)
        if except {
            predicate = NSPredicate(format: "email == %@ AND email <> %@ AND distributor_id == %d", email,oldEmail,user.id)
        }
        
        fetchRequest.predicate = predicate
        do {
            
            let results = try CoreDataStack.sharedInstance.saveManagedObjectContext.fetch(fetchRequest)
            
            return results.count != 0
            
        } catch let error as NSError {
            
            print(error)
            
        }
        return true
    }
    
    func checkNotOrderOn30Day() -> Bool {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "OrderDO")
        
        var predicate = NSPredicate(format: "1 > 0")
        if let user = UserManager.currentUser() {
            predicate = NSPredicate(format: "customer_id in %@ AND distributor_id IN %@ AND date_created > %@", [id,local_id].filter{$0 != 0},[user.id],Date(timeIntervalSinceNow: -2592000) as NSDate)
        }
        
        fetchRequest.predicate = predicate
        
        do {
            
            let results = try CoreDataStack.sharedInstance.saveManagedObjectContext.fetch(fetchRequest) as! [OrderDO]
            return results.count > 0
            
        } catch {
            return true
        }
    }
    
    func lastDateOrder() -> String {
        if getNumberOrders() > 0 {
            if let order = listOrders().first {
                if let date = order.date_created {
                    return (date as Date).toString(dateFormat: "dd/MM/yyyy\nHH:mm:ss")
                }
            }
        }
        return ""
    }
    
    func getNumberOrders() -> Int64 {
        
        //        if let list = listlistOrdersManager {
        //            return list
        //        }
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "OrderDO")
        
        var predicate = NSPredicate(format: "1 > 0")
        if let user = UserManager.currentUser() {
            predicate = NSPredicate(format: "(customer_id in %@ OR customer_id in %@) AND distributor_id IN %@", [id],[local_id],[user.id])
        }
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date_created", ascending: false)]
        fetchRequest.predicate = predicate
        
        do {
            let results = try? CoreDataStack.sharedInstance.saveManagedObjectContext.count(for: fetchRequest)
            if results != nil {
                return Int64(results!)
            }
        }
        
        return 0
    }
    
    func listOrders() -> [OrderDO] {
        
        //        if let list = listlistOrdersManager {
        //            return list
        //        }
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "OrderDO")
        
        var predicate = NSPredicate(format: "1 > 0")
        if let user = UserManager.currentUser() {
            predicate = NSPredicate(format: "(customer_id in %@ OR customer_id in %@) AND distributor_id IN %@", [id],[local_id],[user.id])
        }
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date_created", ascending: false)]
        fetchRequest.predicate = predicate
        
        do {
            
            let results = try CoreDataStack.sharedInstance.saveManagedObjectContext.fetch(fetchRequest) as! [OrderDO]
            return results
            
        } catch let error as NSError {
            
            print(error)
            
        }
        
        return []
    }
    
    func listGroups() -> [Group] {
        //        if let group = listGroupsManager {
        //            return group
        //        }
        let fetchRequestGroupDO = NSFetchRequest<NSFetchRequestResult>(entityName: "GroupDO")
        fetchRequestGroupDO.returnsObjectsAsFaults = false
        let predicate = NSPredicate(format: "(id in %@ OR local_id in %@)", [group_id],[group_id])
        
        fetchRequestGroupDO.predicate = predicate
        
        do {
            
            let results = try CoreDataStack.sharedInstance.saveManagedObjectContext.fetch(fetchRequestGroupDO) as! [GroupDO]
            return results.flatMap({Group.parse($0.toDictionary)})
            
        } catch let error as NSError {
            
            print(error)
            
        }
        
        return []
    }
    
    var urlAvatar:String? {
        if let properties = self.properties {
            if let data = properties.data(using: String.Encoding.utf8) {
                do {
                    if let pro:JSON = try JSONSerialization.jsonObject(with: data, options: []) as? JSON {
                        if let color = pro["avatar"] as? String {
                            if color.contains("@") {
                                return "\(Server.domainImage.rawValue)/upload/1/customers/\(color.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)"
                            } else {
                                return "\(Server.domainImage.rawValue)/upload/1/customers/a_\(color.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)"
                            }
                        }
                    }
                } catch {
                    print("warning parse properties customer: \(properties)")
                }
            }
        }
        return nil
    }
    
    mutating func setSkype(_ color:String) {
        if let pro = properties {
            do {
                if let jsonData = pro.data(using: String.Encoding.utf8) {
                    if var pro:JSON = try JSONSerialization.jsonObject(with: jsonData, options: []) as? JSON {
                        pro["skype"] = color
                        
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
                let jsonData = try JSONSerialization.data(withJSONObject: ["skype":color])
                if let pro = String(data: jsonData, encoding: .utf8) {
                    properties = pro
                }
            }catch{}
        }
    }
    
    var skype:String {
        var gcolor = ""
        if let properties = self.properties {
            if let data = properties.data(using: String.Encoding.utf8) {
                do {
                    if let pro:JSON = try JSONSerialization.jsonObject(with: data, options: []) as? JSON {
                        if let color = pro["skype"] as? String {
                            gcolor = color
                        }
                    }
                } catch {
                    print("warning parse properties GROUP: \(properties)")
                }
            }
        }
        return gcolor
    }
    
    mutating func setZalo(_ color:String) {
        if let pro = properties {
            do {
                if let jsonData = pro.data(using: String.Encoding.utf8) {
                    if var pro:JSON = try JSONSerialization.jsonObject(with: jsonData, options: []) as? JSON {
                        pro["zalo"] = color
                        
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
                let jsonData = try JSONSerialization.data(withJSONObject: ["zalo":color])
                if let pro = String(data: jsonData, encoding: .utf8) {
                    properties = pro
                }
            }catch{}
        }
    }
    
    var zalo:String {
        var gcolor = ""
        if let properties = self.properties {
            if let data = properties.data(using: String.Encoding.utf8) {
                do {
                    if let pro:JSON = try JSONSerialization.jsonObject(with: data, options: []) as? JSON {
                        if let color = pro["zalo"] as? String {
                            gcolor = color
                        }
                    }
                } catch {
                    print("warning parse properties GROUP: \(properties)")
                }
            }
        }
        return gcolor
    }
    
    mutating func setViber(_ color:String) {
        if let pro = properties {
            do {
                if let jsonData = pro.data(using: String.Encoding.utf8) {
                    if var pro:JSON = try JSONSerialization.jsonObject(with: jsonData, options: []) as? JSON {
                        pro["viber"] = color
                        
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
                let jsonData = try JSONSerialization.data(withJSONObject: ["viber":color])
                if let pro = String(data: jsonData, encoding: .utf8) {
                    properties = pro
                }
            }catch{}
        }
    }
    
    var viber:String {
        var gcolor = ""
        if let properties = self.properties {
            if let data = properties.data(using: String.Encoding.utf8) {
                do {
                    if let pro:JSON = try JSONSerialization.jsonObject(with: data, options: []) as? JSON {
                        if let color = pro["viber"] as? String {
                            gcolor = color
                        }
                    }
                } catch {
                    print("warning parse properties GROUP: \(properties)")
                }
            }
        }
        return gcolor
    }
    
    mutating func setFacebook(_ color:String) {
        if let pro = properties {
            do {
                if let jsonData = pro.data(using: String.Encoding.utf8) {
                    if var pro:JSON = try JSONSerialization.jsonObject(with: jsonData, options: []) as? JSON {
                        pro["facebook"] = color
                        
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
                let jsonData = try JSONSerialization.data(withJSONObject: ["facebook":color])
                if let pro = String(data: jsonData, encoding: .utf8) {
                    properties = pro
                }
            }catch{}
        }
    }
    
    var facebook:String {
        var gcolor = ""
        if let properties = self.properties {
            if let data = properties.data(using: String.Encoding.utf8) {
                do {
                    if let pro:JSON = try JSONSerialization.jsonObject(with: data, options: []) as? JSON {
                        if let color = pro["facebook"] as? String {
                            gcolor = color
                        }
                    }
                } catch {
                    print("warning parse properties GROUP: \(properties)")
                }
            }
        }
        return gcolor
    }
}

extension Customer {
    
    static func parse(_ dictionary:JSON) ->Customer{
        var object = Customer()
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
        if let data = dictionary["area_id"] as? String {
            object.area_id = Int64(data)!
        } else if let data = dictionary["area_id"] as? Int64 {
            object.area_id = data
        }
        if let data = dictionary["type"] as? String {
            object.type = Int64(data)!
        } else if let data = dictionary["type"] as? Int64 {
            object.type = data
        }
        if let data = dictionary["gender"] as? String {
            object.gender = Int64(data)!
        } else if let data = dictionary["gender"] as? Int64 {
            object.gender = data
        }
        if let data = dictionary["status"] as? String {
            object.status = Int64(data)!
        } else if let data = dictionary["status"] as? Int64 {
            object.status = data
        }
        if let data = dictionary["group_id"] as? String {
            object.group_id = Int64(data)!
        } else if let data = dictionary["group_id"] as? Int64 {
            object.group_id = data
        }
        
        if let data = dictionary["username"] as? String {
            object.username = data
        }
        if let data = dictionary["password"] as? String {
            object.password = data
        }
        if let data = dictionary["fullname"] as? String {
            object.fullname = data
        }
        
        if let data = dictionary["address"] as? String {
            object.address = data
        }
        if let data = dictionary["email"] as? String {
            object.email = data
        }
        if let data = dictionary["city"] as? String {
            object.city = data
        }
        if let data = dictionary["county"] as? String {
            object.county = data
        }
        if let data = dictionary["tel"] as? String {
            object.tel = data
        }
        
        if let data = dictionary["date_created"] as? String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            if let myDate = dateFormatter.date(from: data) {
                object.date_created = myDate as NSDate
            }
        } else if let data = dictionary["date_created"] as? NSDate {
            object.date_created = data
        }
        
        if let data = dictionary["last_login"] as? String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            if let myDate = dateFormatter.date(from: data) {
                object.last_login = myDate as NSDate
            }
        } else if let data = dictionary["last_login"] as? NSDate {
            object.last_login = data
        }
        
        if let avatar = dictionary["avatar"] as? String {
            object.avatar = avatar
        }
        
        if let data = dictionary["birthday"] as? String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            if let myDate = dateFormatter.date(from: data) {
                object.birthday = myDate as NSDate
            }
        } else if let data = dictionary["birthday"] as? NSDate {
            object.birthday = data
        }
        
        if let properties = dictionary["properties"] as? JSON {
            let jsonData = try! JSONSerialization.data(withJSONObject: properties)
            if let pro = String(data: jsonData, encoding: .utf8) {
                object.properties = pro
            }
            if let avatar = properties["avatar"] as? String {
                if object.avatar.characters.count == 0 {
                    object.avatar = avatar
                }
            }
            if let data = properties["birthday"] as? String {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                if let myDate = dateFormatter.date(from: data) {
                    object.birthday = myDate as NSDate
                }
            }
        } else if let properties = dictionary["properties"] as? String{
            object.properties = properties
        }
        
        return object
    }
}
