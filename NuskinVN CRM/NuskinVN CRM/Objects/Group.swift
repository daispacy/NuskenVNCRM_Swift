//
//  Group.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 11/26/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import Foundation
import CoreData

struct Group {
   var date_created: NSDate?
   var distributor_id: Int64 = 0
   var group_name: String = ""
   var id: Int64 = 0
   var isTemp: Bool = false
   var min_pv: Int64 = 0
   var position: Int64 = 0
   var properties: String?
   var status: Int64 = 0
   var store_id: Int64 = 0
   var synced: Bool = true
   var local_id: Int64 = 0
    
    func numberCustomers(fromDate:NSDate? = nil, toDate:NSDate? = nil, isLifeTime:Bool = true)->Int64 {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CustomerDO")
        
        var predicate1 = NSPredicate(format: "1 > 0")
        if let user = UserManager.currentUser() {
            predicate1 = NSPredicate(format: "distributor_id IN %@", [user.id])
        }
        var predicate2 = NSPredicate(format: "1 > 0")
        let predicate3 = NSPredicate(format: "status == 1")
        if !isLifeTime {
            if let from = fromDate,
                let to = toDate {
                predicate2 = NSPredicate(format: "date_created >= %@ AND date_created <= %@",from,to)
            }
        }
        
        let predicate4 = NSPredicate(format: "(group_id IN %@ OR group_id IN %@)",[id],[local_id])
        
        let predicateCompound = NSCompoundPredicate.init(type: .and, subpredicates: [predicate1,predicate2,predicate3,predicate4])
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "fullname", ascending: true)]
        fetchRequest.predicate = predicateCompound
        
        do {
            let result = try CoreDataStack.sharedInstance.managedObjectContext.count(for:fetchRequest)
            return Int64(result)
            
        } catch {
            let fetchError = error as NSError
            print(fetchError)
            return 0
        }
    }
    
    func getListEmailCustomers() -> String {
        var emails = ""
        let list = customers().flatMap{$0.email}
        for item in list {
            if emails.characters.count > 0 {
                emails.append("; " + item)
            } else {
                emails.append(item)
            }
        }
        return emails
    }
    
    func customers(fromDate:NSDate? = nil, toDate:NSDate? = nil, isLifeTime:Bool = true)->[Customer] {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CustomerDO")
        var predicate1 = NSPredicate(format: "1 > 0")
        if let user = UserManager.currentUser() {
            predicate1 = NSPredicate(format: "distributor_id IN %@", [user.id])
        }
        var predicate2 = NSPredicate(format: "1 > 0")
        let predicate3 = NSPredicate(format: "status == 1")
        if !isLifeTime {
            if let from = fromDate,
                let to = toDate {
                predicate2 = NSPredicate(format: "date_created >= %@ AND date_created <= %@",from,to)
            }
        }
        
        let predicate4 = NSPredicate(format: "(group_id IN %@ OR group_id IN %@)",[id],[local_id])
        
        let predicateCompound = NSCompoundPredicate.init(type: .and, subpredicates: [predicate1,predicate2,predicate3,predicate4])
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "fullname", ascending: true)]
        fetchRequest.predicate = predicateCompound
        
        do {
            let result = try CoreDataStack.sharedInstance.managedObjectContext.fetch(fetchRequest)
            var list:[Customer] = []
            let listTemp = result.flatMap{$0 as? CustomerDO}
            list = listTemp.flatMap{Customer.parse($0.toDictionary)}
            if list.count > 0 {
                return list
            }
            
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
        return []
    }
    
    var toDictionary:[String:Any] {
        return [
            "group_name":group_name,
            "id":id,
            "min_pv":min_pv,
            "store_id":store_id,
            "distributor_id":distributor_id,
            "color":color,
            "position":position,
            "status":status,
            "synced":synced
        ]
    }
    
    var toDO:[String:Any] {
        return [
            "group_name":group_name,
            "id":id,
            "min_pv":min_pv,
            "store_id":store_id,
            "distributor_id":distributor_id,
            "position":position,
            "status":status,
            "synced":synced,
            "properties": properties ?? ""
        ]
    }
    
    
    mutating func setColor(_ color:String) {
        if let pro = properties {
            do {
                if let jsonData = pro.data(using: String.Encoding.utf8) {
                    if var pro:JSON = try JSONSerialization.jsonObject(with: jsonData, options: []) as? JSON {
                        pro["color"] = color
                        
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
                let jsonData = try JSONSerialization.data(withJSONObject: ["color":color])
                if let pro = String(data: jsonData, encoding: .utf8) {
                    properties = pro
                }
            }catch{}
        }
    }
    
    var color:String {
        var gcolor = ""
        if let properties = self.properties {
            if let data = properties.data(using: String.Encoding.utf8) {
                do {
                    if let pro:JSON = try JSONSerialization.jsonObject(with: data, options: []) as? JSON {
                        if let color = pro["color"] as? String {
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

extension Group {
    static func parse(_ dictionary:JSON) ->Group {
        
        var object = Group()
        
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
        
        if let data = dictionary["status"] as? String {
            object.status = Int64(data)!
        } else if let data = dictionary["status"] as? Int64 {
            object.status = data
        }
        
        if let data = dictionary["min_pv"] as? String {
            object.min_pv = Int64(data)!
        } else if let data = dictionary["min_pv"] as? Int64 {
            object.min_pv = data
        }
        
        if let data = dictionary["position"] as? String {
            object.position = Int64(data)!
        } else if let data = dictionary["position"] as? Int64 {
            object.position = data
        }
        
        if let data = dictionary["group_name"] as? String {
            object.group_name = data
        }
        
        if let data = dictionary["date_created"] as? NSDate {
            object.date_created = data
        }
        
        if let properties = dictionary["properties"] as? JSON {
            let jsonData = try! JSONSerialization.data(withJSONObject: properties)
            if let pro = String(data: jsonData, encoding: .utf8) {
                object.properties = pro
            }
        } else if let properties = dictionary["properties"] as? String {
            object.properties = properties
        }
        
        return object
    }
}
