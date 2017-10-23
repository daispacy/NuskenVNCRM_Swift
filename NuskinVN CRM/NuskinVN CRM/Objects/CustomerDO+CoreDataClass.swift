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
    let fetchRequestGroupDO = NSFetchRequest<NSFetchRequestResult>(entityName: "GroupDO")
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
    
    var toDictionary:[String:Any] {
        
        var proper:JSON = [:]
        if let properties = self.properties {
            if let data = properties.data(using: String.Encoding.utf8) {
                do {
                    if let pro:JSON = try JSONSerialization.jsonObject(with: data, options: []) as? JSON {
                        proper = pro
                    }
                } catch {
                    print("warning parse properties GROUP: \(properties)")
                }
            }
        }
        
        return [
            "id": id,
            "store_id": store_id,
            "distributor_id": distributor_id,
            "area_id": area_id,
            "type": type,
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
            "date_created": date_created ?? "",
            "last_login": last_login ?? "",
            "status": status,
            "synced":synced
        ]
    }
    
    static func isExist(email:String,except:Bool) -> Bool{
        
        if email.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines).characters.count == 0 {
            return false
        }
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CustomerDO")
        fetchRequest.returnsObjectsAsFaults = false
        
        var predicate = NSPredicate(format: "email == %@", email)
        if except {
            predicate = NSPredicate(format: "email == %@ AND email <> %@", email,email)
        }
        
        fetchRequest.predicate = predicate
        do {
            
            let results = try CoreDataStack.sharedInstance.persistentContainer.viewContext.fetch(fetchRequest)
            
            return results.count == 0
            
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
    
    var isShouldOpenFunctionView:Bool {
        return zalo.characters.count > 0 && facebook.characters.count > 0 && viber.characters.count > 0 && skype.characters.count > 0
    }
    
    func listOrders() -> [OrderDO] {
        
//        if let list = listlistOrdersManager {
//            return list
//        }
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "OrderDO")
        fetchRequest.returnsObjectsAsFaults = false
        let predicate = NSPredicate(format: "customer_id in %@ AND distributor_id IN %@", [id],[UserManager.currentUser().id_card_no])
        
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
        
            fetchRequestGroupDO.returnsObjectsAsFaults = false
            let predicate = NSPredicate(format: "id in %@", [group_id])
            
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
    
}
