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
}
