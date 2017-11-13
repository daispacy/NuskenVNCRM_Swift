//
//  ProductManager.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 10/20/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import UIKit
import CoreData

class CustomerManager: NSObject {
    
    static func getReportCustomers(fromDate:NSDate? = nil,toDate:NSDate? = nil, isLifeTime:Bool = true,group:GroupDO? = nil,_ onComplete:@escaping (([CustomerDO])->Void)) {
        // Initialize Fetch Request
        let container = CoreDataStack.sharedInstance.persistentContainer
        container.performBackgroundTask() { (context) in
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CustomerDO")
            fetchRequest.returnsObjectsAsFaults = false
            var predicate1 = NSPredicate(format: "1 > 0")
            if let user = UserManager.currentUser() {
                predicate1 = NSPredicate(format: "distributor_id IN %@", [user.id])
            }
            let predicate3 = NSPredicate(format: "status == 1")
            
            var predicate2 = NSPredicate(format: "1 > 0")
            if !isLifeTime {
                if let from = fromDate,
                    let to = toDate {
                    predicate2 = NSPredicate(format: "date_created >= %@ AND date_created <= %@",from,to)
                }
            }
            var predicate4 = NSPredicate(format: "1 > 0")
            if let gr = group {
                if gr.id == 0 {
                    if let group_name = gr.group_name {
                        predicate4 = NSPredicate(format: "group_name == %@",group_name)
                    }
                } else {
                    predicate4 = NSPredicate(format: "(group_id IN %@ OR group_id IN %@)",[gr.id],[gr.local_id])
                }
            }
            let predicateCompound = NSCompoundPredicate.init(type: .and, subpredicates: [predicate1,predicate2,predicate3,predicate4])
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "fullname", ascending: true)]
            fetchRequest.predicate = predicateCompound
            do {
                let result = try context.fetch(fetchRequest)
                var list:[CustomerDO] = []
                list = result.flatMap({$0 as? CustomerDO})
                onComplete(list)
            } catch {
                let fetchError = error as NSError
                onComplete([])
                print(fetchError)
            }
        }
    }
    
    static func getAllCustomers(search:String? = nil,group:GroupDO? = nil,onComplete:(([CustomerDO])->Void)) {
        // Initialize Fetch Request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CustomerDO")
        fetchRequest.returnsObjectsAsFaults = false
        var predicate1 = NSPredicate(format: "1 > 0")
        if let user = UserManager.currentUser() {
            predicate1 = NSPredicate(format: "distributor_id IN %@", [user.id])
        }
        var predicate2 = NSPredicate(format: "1 > 0")
        var predicate4 = NSPredicate(format: "1 > 0")
        let predicate3 = NSPredicate(format: "status == 1")
        if let text = search {
            if text.characters.count > 0 {
                predicate2 = NSPredicate(format: "fullname contains[cd] %@",text)
            }
        }
        if let gr = group {
            if gr.id == 0 {
                if let group_name = gr.group_name {
                    predicate4 = NSPredicate(format: "group_name == %@",group_name)
                }
            } else {
                predicate4 = NSPredicate(format: "(group_id IN %@ OR group_id IN %@)",[gr.id],[gr.local_id])
            }
        }
        let predicateCompound = NSCompoundPredicate.init(type: .and, subpredicates: [predicate1,predicate2,predicate3,predicate4])
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "fullname", ascending: true)]
        fetchRequest.predicate = predicateCompound
        
        do {
            let result = try CoreDataStack.sharedInstance.persistentContainer.viewContext.fetch(fetchRequest)
            var list:[CustomerDO] = []
            list = result.flatMap({$0 as? CustomerDO})
            onComplete(list)
            
        } catch {
            let fetchError = error as NSError
            onComplete([])
            print(fetchError)
        }
    }
    
    static func getCustomersDontHaveOrder30Day (onComplete:(([CustomerDO])->Void)) {
        var list:[CustomerDO] = []
        CustomerManager.getAllCustomers { data in
            list = data.filter{$0.checkNotOrderOn30Day()}
        }
        onComplete(list)
    }
    
    static func getCustomersBirthday(onComplete:(([CustomerDO])->Void)) {
        // Initialize Fetch Request
        var data:[CustomerDO] = []
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CustomerDO")
        fetchRequest.returnsObjectsAsFaults = false
        var predicate1 = NSPredicate(format: "1 > 0")
        if let user = UserManager.currentUser() {
            predicate1 = NSPredicate(format: "distributor_id IN %@", [user.id])
        }
        let predicate3 = NSPredicate(format: "status == 1")
        let predicateCompound = NSCompoundPredicate.init(type: .and, subpredicates: [predicate1,predicate3])
//        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "birthday", ascending: true)]
        fetchRequest.predicate = predicateCompound
        
        do {
            let result = try CoreDataStack.sharedInstance.persistentContainer.viewContext.fetch(fetchRequest)
            var list:[CustomerDO] = []
            list = result.flatMap({$0 as? CustomerDO})
            data = list.filter {
                if let birthday = $0.birthday as Date?{
                    let calendar = Calendar.autoupdatingCurrent
                    let components = calendar.dateComponents([.month], from: Date())
                    let components1 = calendar.dateComponents([.month], from: birthday)
                    return components.month! == components1.month!
                }
                return false
            }
            data = data.sorted{ item1, item2 in
                if let birthday1 = item1.birthday as Date?,
                    let birthday2 = item2.birthday as Date?{
                    let calendar = Calendar.autoupdatingCurrent
                    let components = calendar.dateComponents([.day], from: birthday1)
                    let components1 = calendar.dateComponents([.day], from: birthday2)
                    
                    return components.day! <= components1.day!
                }
                return false
            }
            onComplete(data)
            
        } catch {
            let fetchError = error as NSError
            onComplete([])
            print(fetchError)
        }
    }
    
    static func getAllCustomersOrdered(search:String? = nil,group:GroupDO? = nil,onComplete:(([CustomerDO])->Void)) {
        // Initialize Fetch Request
        guard let user = UserManager.currentUser() else {onComplete([]); return }
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CustomerDO")
        fetchRequest.returnsObjectsAsFaults = false
        
        let predicate1 = NSPredicate(format: "distributor_id IN %@", [user.id])
        var predicate2 = NSPredicate(format: "1 > 0")
        var predicate4 = NSPredicate(format: "1 > 0")
        let predicate3 = NSPredicate(format: "status == 1")
        if let text = search {
            if text.characters.count > 0 {
                predicate2 = NSPredicate(format: "fullname contains[cd] %@",text)
            }
        }
        if let gr = group {
            if gr.id == 0 {
                if let group_name = gr.group_name {
                    predicate4 = NSPredicate(format: "group_name == %@",group_name)
                }
            } else {
                predicate4 = NSPredicate(format: "(group_id IN %@ OR group_id IN %@)",[gr.id],[gr.local_id])
            }
        }
        let predicateCompound = NSCompoundPredicate.init(type: .and, subpredicates: [predicate1,predicate2,predicate3,predicate4])
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "fullname", ascending: true)]
        fetchRequest.predicate = predicateCompound
        
        do {
            let result = try CoreDataStack.sharedInstance.persistentContainer.viewContext.fetch(fetchRequest)
            var list:[CustomerDO] = []
            list = result.flatMap({$0 as? CustomerDO})
            list = list.filter{$0.listOrders().count > 0}
            onComplete(list)
            
        } catch {
            let fetchError = error as NSError
            onComplete([])
            print(fetchError)
        }
    }
    
    static func getAllCustomersNotSynced(onComplete:@escaping (([CustomerDO])->Void)) {
        // Initialize Fetch Request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CustomerDO")
        fetchRequest.returnsObjectsAsFaults = false
        var predicate1 = NSPredicate(format: "1 > 0")
        if let user = UserManager.currentUser() {
            predicate1 = NSPredicate(format: "distributor_id IN %@", [user.id])
        }
        let predicate3 = NSPredicate(format: "synced == false")
    
        let predicateCompound = NSCompoundPredicate.init(type: .and, subpredicates: [predicate1,predicate3])
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "fullname", ascending: true)]
        fetchRequest.predicate = predicateCompound
        
        let container = CoreDataStack.sharedInstance.persistentContainer
        container.performBackgroundTask() { (context) in
            do {
                let result = try context.fetch(fetchRequest)
                var list:[CustomerDO] = []
                list = result.flatMap({$0 as? CustomerDO})
                onComplete(list)
                
            } catch {
                let fetchError = error as NSError
                onComplete([])
                print(fetchError)
            }
        }
    }
    
    static func markSynced(_ list:[Int64],_ done:@escaping (()->Void)) {
        let container = CoreDataStack.sharedInstance.persistentContainer
        container.performBackgroundTask() { (context) in
            let entity = NSEntityDescription.entity(forEntityName: "CustomerDO", in: context)
            let batchRequest = NSBatchUpdateRequest(entity: entity!)
            batchRequest.resultType = .statusOnlyResultType
            batchRequest.predicate = NSPredicate(format: "id IN %@ OR local_id IN %@",list.filter{$0 != 0},list.filter{$0 != 0});
            batchRequest.propertiesToUpdate = ["synced": true]
            do {
                try context.execute(batchRequest)
                done()
            } catch {
                done()
                print(error)
            }
            
            
        }
    }
    
    static func saveCustomerWith(array: [JSON],_ onComplete:@escaping (()->Void)) {
        let container = CoreDataStack.sharedInstance.persistentContainer
        container.performBackgroundTask() { (context) in
            for jsonObject in array {
                _ = CustomerManager.createCustomerEntityFrom(dictionary: jsonObject,context)
            }
            do {
                try context.save()
                onComplete()
            } catch {
                onComplete()
            }
        }
    }
    
    static func updateCustomerEntity(_ customer:NSManagedObject, onComplete:(()->Void)) {
        let context = CoreDataStack.sharedInstance.persistentContainer.viewContext
        do {
            try context.save()
            print("customer saved!")
        } catch let error as NSError  {
            print("Could not saved \(error), \(error.userInfo)")
        } catch {
            
        }
        onComplete()
    }
    
    static func invalidCustomerEntity(_ ids:[Int64]? = nil, onComplete:(()->Void)) {
        guard let listIDS = ids else { return }
        guard listIDS.count > 0 else { return }
        // Initialize Fetch Request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CustomerDO")
        fetchRequest.returnsObjectsAsFaults = false
        let predicate1 = NSPredicate(format: "id IN %@",[listIDS])
        fetchRequest.predicate = predicate1
        
        do {
            let result = try CoreDataStack.sharedInstance.persistentContainer.viewContext.fetch(fetchRequest)
            var list:[CustomerDO] = []
            list = result.flatMap({$0 as? CustomerDO})
            _ = list.map({
                $0.status = 0
                $0.synced = false
            })
            try! CoreDataStack.sharedInstance.persistentContainer.viewContext.save()
            onComplete()
            
        } catch {
            let fetchError = error as NSError
            onComplete()
            print(fetchError)
        }
    }
    
    static func createCustomerEntityFrom(dictionary: JSON,_ context:NSManagedObjectContext) -> NSManagedObject? {
        if let object = NSEntityDescription.insertNewObject(forEntityName: "CustomerDO", into: context) as? CustomerDO {
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
//            if let data = dictionary["skype"] as? String {
//                object.skype = data
//            }
//            if let data = dictionary["facebook"] as? String {
//                object.facebook = data
//            }
//            if let data = dictionary["viber"] as? String {
//                object.viber = data
//            }
//            if let data = dictionary["zalo"] as? String {
//                object.zalo = data
//            }

            if let data = dictionary["date_created"] as? String {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                if let myDate = dateFormatter.date(from: data) {
                    object.date_created = myDate as NSDate
                }
            }
            if let data = dictionary["last_login"] as? String {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                if let myDate = dateFormatter.date(from: data) {
                    object.last_login = myDate as NSDate
                }
            }
            
            if let properties = dictionary["properties"] as? JSON {
                let jsonData = try! JSONSerialization.data(withJSONObject: properties)
                if let pro = String(data: jsonData, encoding: .utf8) {
                    object.properties = pro
                }
                if let avatar = properties["avatar"] as? String {
                    object.avatar = avatar
                }
                if let data = properties["birthday"] as? String {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    if let myDate = dateFormatter.date(from: data) {
                        object.birthday = myDate as NSDate
                    }
                }
            }
            
            return object
        }
        return nil
    }
    
    static func clearAllDataSynced(_ onComplete:@escaping (()->Void)) {
        let container = CoreDataStack.sharedInstance.persistentContainer
        container.performBackgroundTask() { (context) in
            do {
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CustomerDO")
                fetchRequest.returnsObjectsAsFaults = false
                fetchRequest.predicate = NSPredicate(format: "synced == true")
                let objects  = try context.fetch(fetchRequest) as? [NSManagedObject]
                _ = objects.map {_ = $0.map({context.delete($0)})}
                try context.save()
                onComplete()
            } catch {
                onComplete()
            }
        }
    }
    
    static func clearData(_ fromList:[JSON], onComplete:(([JSON])->Void)) {
        do {
            var list:[JSON] = []
            let context = CoreDataStack.sharedInstance.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CustomerDO")
                    fetchRequest.returnsObjectsAsFaults = false
            do {
                let objects  = try context.fetch(fetchRequest) as? [NSManagedObject]
                _ = objects.map {
                    let obj = $0
                    _ = fromList.contains(where: { (item) -> Bool in
                        if let data = item["id"] as? String {
                            if let id = Int64(data) {
                                _ = obj.map{
                                    let customerDO = $0 as! CustomerDO
                                    if id == customerDO.id && customerDO.synced == true {
                                        list.append(item)
                                        context.delete($0)
                                    }
                                }
                            }
                        }
                        return false
                    })
                }
                CoreDataStack.sharedInstance.saveContext()
                list = fromList.filter {
                    if let dt = $0["id"] as? String {
                        if let hID = Int64(dt) {
                            if list.count == 0 {
                                return true
                            }
                            return list.contains(where: { (item) -> Bool in
                                if let data = item["id"] as? String {
                                    if let id = Int64(data) {
                                        if id == hID {
                                            return false
                                        }
                                    }
                                }
                                return true
                            })
                        }
                    }
                    return true
                }
                onComplete(list)
            } catch let error {
                print("ERROR DELETING : \(error)")
            }
        }
    }
}
