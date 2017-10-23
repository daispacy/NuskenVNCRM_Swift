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
            total += ($0.product().pv * $0.quantity)
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
    
    func customer() -> CustomerDO {
        
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CustomerDO")
//            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "fullname", ascending: true)]
            fetchRequest.predicate = NSPredicate(format: "id IN %@ AND distributor_id IN %@", [customer_id],[UserManager.currentUser().id_card_no])
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
        
        return CustomerDO(needSave:false, context: CoreDataStack.sharedInstance.persistentContainer.viewContext)
    }
    
    func orderItems() -> [OrderItemDO] {
        
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "OrderItemDO")
            //            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "fullname", ascending: true)]
            fetchRequest.predicate = NSPredicate(format: "order_id IN %@", [id])
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
