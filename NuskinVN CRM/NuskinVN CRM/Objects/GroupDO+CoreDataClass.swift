//
//  GroupDO+CoreDataClass.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 10/24/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//
//

import Foundation
import CoreData

@objc(GroupDO)
public class GroupDO: NSManagedObject {

    //MARK: - Initialize
    convenience init(needSave: Bool,  context: NSManagedObjectContext?) {
        
        // Create the NSEntityDescription
        let entity = NSEntityDescription.entity(forEntityName: "GroupDO", in: context!)
        
        if(!needSave) {
            self.init(entity: entity!, insertInto: nil)
            isTemp = true
        } else {
            self.init(entity: entity!, insertInto: context)
        }
    }
    
    func customers(fromDate:NSDate? = nil, toDate:NSDate? = nil, isLifeTime:Bool = true)->[CustomerDO] {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CustomerDO")
        fetchRequest.returnsObjectsAsFaults = false
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
            let result = try CoreDataStack.sharedInstance.persistentContainer.viewContext.fetch(fetchRequest)
            var list:[CustomerDO] = []
            list = result.flatMap({$0 as? CustomerDO})
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
            "name":group_name ?? "",
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
    
    
    func setColor(_ color:String) {
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
