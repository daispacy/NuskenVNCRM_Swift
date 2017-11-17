//
//  CustomerDO+CoreDataClass.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 10/20/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//
//

import Foundation
import CoreData

@objc(CustomerDO)
public class CustomerDO: NSManagedObject {

    var isTemp = false
    var listGroupsManager:[GroupDO]?
    var listlistOrdersManager:[OrderDO]?
    
    //MARK: - Initialize
    convenience init(needSave: Bool,  context: NSManagedObjectContext?) {
        
        // Create the NSEntityDescription
        let entity = NSEntityDescription.entity(forEntityName: "OrderDO", in: context!)
        
        if(!needSave) {
            self.init(entity: entity!, insertInto: nil)
            isTemp = true
        } else {
            self.init(entity: entity!, insertInto: context)
        }
    }
    
    var isCongratBirthday:Bool {
        let list = [local_id,id].filter{$0 != 0}
        return !BirthdayManager.checkBirthday(list)
    }
    
    var isRemind:Bool {
        let list = [local_id,id].filter{$0 != 0}
        return NotOrder30DOManager.checkRemind(list)
    }
    
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
            "username": username ?? "",
            "password": password ?? "",
            "fullname": fullname ?? "",
            "gender": gender,
            "address": address ?? "",
            "email": email ?? "",
            "city": city ?? "",
            "county": county ?? "",
            "tel": tel ?? "",
            "skype": skype,
            "facebook": facebook,
            "viber": viber,
            "zalo": zalo,
            "avatar": avatar ?? "",
            "group_id": group_id,
            "properties": proper,
            "date_created": date_created_,
            "last_login": last_updated_,
            "birthday": birthday_,
            "status": status,
            "synced":synced
        ]
    }
    
    static func isExist(email:String, oldEmail:String,except:Bool) -> Bool{
        guard let user = UserManager.currentUser() else { return true }
        if email.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines).characters.count == 0 {
            return false
        }
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CustomerDO")
        fetchRequest.returnsObjectsAsFaults = false
        
        var predicate = NSPredicate(format: "email == %@ AND distributor_id == %d", email, user.id)
        if except {
            predicate = NSPredicate(format: "email == %@ AND email <> %@ AND distributor_id == %d", email,oldEmail,user.id)
        }
        
        fetchRequest.predicate = predicate
        do {
            
            let results = try CoreDataStack.sharedInstance.persistentContainer.viewContext.fetch(fetchRequest)
            
            return results.count != 0
            
        } catch let error as NSError {
            
            print(error)
            
        }
        return true
    }
    
    func setSkype(_ color:String) {
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
    
    func setZalo(_ color:String) {
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
    
    func setViber(_ color:String) {
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
    
    func setFacebook(_ color:String) {
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
    
    func checkNotOrderOn30Day() -> Bool {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "OrderDO")
        fetchRequest.returnsObjectsAsFaults = false
        var predicate = NSPredicate(format: "1 > 0")
        if let user = UserManager.currentUser() {
            predicate = NSPredicate(format: "customer_id in %@ AND distributor_id IN %@ AND date_created > %@", [id,local_id].filter{$0 != 0},[user.id],Date(timeIntervalSinceNow: -2592000) as NSDate)
        }
        
        fetchRequest.predicate = predicate
        
        do {
            
            let results = try CoreDataStack.sharedInstance.persistentContainer.viewContext.fetch(fetchRequest) as! [OrderDO]
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
        fetchRequest.returnsObjectsAsFaults = false
        var predicate = NSPredicate(format: "1 > 0")
        if let user = UserManager.currentUser() {
            predicate = NSPredicate(format: "(customer_id in %@ OR customer_id in %@) AND distributor_id IN %@", [id],[local_id],[user.id])
        }
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date_created", ascending: false)]
        fetchRequest.predicate = predicate
        
        do {
            let results = try? CoreDataStack.sharedInstance.persistentContainer.viewContext.count(for: fetchRequest)
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
        fetchRequest.returnsObjectsAsFaults = false
        var predicate = NSPredicate(format: "1 > 0")
        if let user = UserManager.currentUser() {
            predicate = NSPredicate(format: "(customer_id in %@ OR customer_id in %@) AND distributor_id IN %@", [id],[local_id],[user.id])
        }
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date_created", ascending: false)]
        fetchRequest.predicate = predicate
        
        do {
            
            let results = try CoreDataStack.sharedInstance.persistentContainer.viewContext.fetch(fetchRequest) as! [OrderDO]
            listlistOrdersManager = results
            return results
            
        } catch let error as NSError {
            
            print(error)
            
        }
        
        return []
    }
    
    func listGroups() -> [GroupDO] {
//        if let group = listGroupsManager {
//            return group
//        }
            let fetchRequestGroupDO = NSFetchRequest<NSFetchRequestResult>(entityName: "GroupDO")
            fetchRequestGroupDO.returnsObjectsAsFaults = false
            let predicate = NSPredicate(format: "(id in %@ OR local_id in %@)", [group_id],[group_id])
            
            fetchRequestGroupDO.predicate = predicate
            
            do {
                
                let results = try CoreDataStack.sharedInstance.persistentContainer.viewContext.fetch(fetchRequestGroupDO) as! [GroupDO]
                listGroupsManager = results
                return results
                
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
}
