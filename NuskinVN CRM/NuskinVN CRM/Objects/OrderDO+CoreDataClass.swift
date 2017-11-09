//
//  OrderDO+CoreDataClass.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 10/22/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//
//

import Foundation
import CoreData

@objc(OrderDO)
public class OrderDO: NSManagedObject {
    
    var customerManage:CustomerDO?
    var orderItemsManager:[OrderItemDO] = []
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
    
    //MARK: - Initialize
    convenience init(needSave: Bool,  context: NSManagedObjectContext?) {
        
        // Create the NSEntityDescription
        let entity = NSEntityDescription.entity(forEntityName: "OrderDO", in: context!)
        
        if(!needSave) {
            self.init(entity: entity!, insertInto: nil)
        } else {
            self.init(entity: entity!, insertInto: context)
        }
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
            "code":code ?? "",
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
            "svd":svd ?? "",
            "email":email ?? "",
            "tel":tel ?? "",
            "cell":cell ?? "",
            "address":address ?? "",
            "date_created":date_created_,
            "last_updated":last_updated_,
            "order_items":orderItemsDictionary
        ]
    }

    func customer() -> CustomerDO? {
        if customer_id == 0 {
            return nil
        }
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CustomerDO")
//            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "fullname", ascending: true)]
        if let user = UserManager.currentUser() {
            fetchRequest.predicate = NSPredicate(format: "(id IN %@ OR local_id IN %@) AND distributor_id IN %@", [customer_id],[customer_id],[user.id])
        }
            fetchRequest.returnsObjectsAsFaults = false
            
            do {
                let result = try CoreDataStack.sharedInstance.persistentContainer.viewContext.fetch(fetchRequest)
                var list:[CustomerDO] = []
                list = result.flatMap({$0 as? CustomerDO})
                if list.count > 0 {
                    customerManage = list[0]
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
    
    func orderItems() -> [OrderItemDO] {
        
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "OrderItemDO")
            //            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "fullname", ascending: true)]
            fetchRequest.predicate = NSPredicate(format: "(order_id IN %@ OR order_id IN %@)", [id],[local_id])
            fetchRequest.returnsObjectsAsFaults = false
            
            do {
                let result = try CoreDataStack.sharedInstance.persistentContainer.viewContext.fetch(fetchRequest)
                var list:[OrderItemDO] = []
                list = result.flatMap({$0 as? OrderItemDO})
                orderItemsManager = list
                return list
                
                
            } catch {
                let fetchError = error as NSError
                print(fetchError)
            }
        
        return []
    }
    
    // MARK: - properties
    func setOtherTransporter(_ color:String) {
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
    
    
    func setCity(_ color:String) {
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
    
    func setDistrict(_ color:String) {
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
        fetchRequest.returnsObjectsAsFaults = false
        
        var predicate = NSPredicate(format: "code == %@ AND distributor_id == %d", code, user.id)
        if except {
            predicate = NSPredicate(format: "code == %@ AND code <> %@ AND distributor_id == %d", code,oldCode,user.id)
        }
        
        fetchRequest.predicate = predicate
        do {
            
            let results = try CoreDataStack.sharedInstance.persistentContainer.viewContext.fetch(fetchRequest)
            
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
        fetchRequest.returnsObjectsAsFaults = false
        
        let predicate = NSPredicate(format: "code == %@ AND distributor_id IN %@", code, [user.id])
        
        fetchRequest.predicate = predicate
        do {
            
            let results = try CoreDataStack.sharedInstance.persistentContainer.viewContext.fetch(fetchRequest)
            
            return results.count == 0
            
        } catch let error as NSError {
            
            print(error)
            
        }
        return false
    }
}
