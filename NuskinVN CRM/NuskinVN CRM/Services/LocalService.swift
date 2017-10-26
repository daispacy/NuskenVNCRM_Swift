//
//  LocalService.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 9/21/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import Foundation
import SystemConfiguration

enum LocalServiceType: Int {
    case customer = 1
    case group
    case order
}

let path = NSSearchPathForDirectoriesInDomains(
    .documentDirectory, .userDomainMask, true
    ).first!

final class LocalService: NSObject {
    
    static let shared = LocalService()
    
    var isMoveDB:Bool = false
    var isShouldSyncData:(()->Bool)?
    var timerSyncToServer:Timer?
    
    // Initialization
    private override init() {
        super.init()
    }
    
    //start service
    func startSyncData() {
        
        if UserManager.currentUser() == nil {
            print("Please login before use SYNC")
            return
        }
        
        // first
        self.syncToServer()
        
        if let bool = self.timerSyncToServer?.isValid {
            if bool {self.timerSyncToServer?.invalidate()}
        }
        
        // loop
        self.timerSyncToServer = Timer.scheduledTimer(timeInterval: 60*1, target: self, selector: #selector(self.syncToServer), userInfo: nil, repeats: true)
    }
    
    func startSyncDataBackground(onComplete:(()->Void)? = nil) {
        self.syncGroups {
            self.syncCustomers {
                self.syncOrders {
                    self.syncOrdersItems {
                        onComplete?()
                    }
                }
            }
        }
    }
    
    @objc private func syncToServer() {
        
        if let bool = self.isShouldSyncData?() {
            if bool == false {
                print("APP IN STATE BUSY, SO WILL SYNCED LATER")
                NotificationCenter.default.post(name:Notification.Name("SyncData:APPBUSY"),object:nil)
                NotificationCenter.default.post(name:Notification.Name("SyncData:FOREOUTSYNC"),object:nil)
                return
            }
        }
        
        if !Support.connectivity.isConnectedToInternet() {
            // Device doesn't have internet connection
            print("Internet Offline")
            NotificationCenter.default.post(name:Notification.Name("SyncData:FOREOUTSYNC"),object:nil)
            return
        }
            
        // groups
        self.syncGroups()
        
        // customers
        self.syncCustomers()
        
        // products
        SyncService.shared.syncProducts(completion: {_ in })
        
        // orders
        self.syncOrders()
        
        // order items
        self.syncOrdersItems()
    }
    
    private func syncOrdersItems(_ onComplete:(()->Void)? = nil) {
            print("*******\nSTART SYNC ORDERITEMS\n*******")
        
        NotificationCenter.default.post(name:Notification.Name("SyncData:StartOrderItem"),object:nil)
        
        SyncService.shared.getOrderItems(completion: { (result) in
            switch result {
            case .success(let data):
                guard data.count > 0 else {
                    print("Dont have new orderitems from server")
                    return
                }
                
                switch result {
                case .success(let data):
                    if data.count > 0 {
                        print("SAVE ORDERITEM TO CORE DATA")
                        OrderItemManager.resetData {
                            OrderItemManager.saveOrderItemWith(array:data)
                        }
                        onComplete?()
                        NotificationCenter.default.post(name:Notification.Name("SyncData:OrderItem"),object:nil)
                    }
                case .failure(_):
                    NotificationCenter.default.post(name:Notification.Name("SyncData:FOREOUTSYNC"),object:nil)
                    print("Error: cant get orderitem from server 2")
                    break
                }
            case.failure(_):
                NotificationCenter.default.post(name:Notification.Name("SyncData:FOREOUTSYNC"),object:nil)
                print("Error: cant get orderitem from server 1")
            }
        })
    }
    
    private func syncOrders(_ onComplete:(()->Void)? = nil) {
        
        OrderManager.getAllOrdersNotSynced { list in
            let listDictionaryOrders:[JSON] = list.flatMap({$0.toDictionary})
            print("*******\nSTART SYNC ORDERS: \(listDictionaryOrders.count)\n*******")
            NotificationCenter.default.post(name:Notification.Name("SyncData:StartOrder"),object:nil)
            
            print(listDictionaryOrders)
            SyncService.shared.postAllOrdersToServer(list: listDictionaryOrders, completion: { (result) in
                switch result {
                case .success(let data):
                    guard data.count > 0 else {
                        print("Dont have new orders from server")
                        return
                    }
                    
                    switch result {
                    case .success(let data):
                        // change state to synced true
                        _ = list.map({
                            let group = $0
                            group.synced = true
                            do{try CoreDataStack.sharedInstance.persistentContainer.viewContext.save()}catch{}
                            
                        })
                        if data.count > 0 {
                            print("SAVE ORDER TO CORE DATA")
                            OrderManager.clearAllDataSynced {
                                OrderManager.saveOrderWith(array:data)
                            }
                            onComplete?()
                            NotificationCenter.default.post(name:Notification.Name("SyncData:Order"),object:nil)
                        }
                    case .failure(_):
                        NotificationCenter.default.post(name:Notification.Name("SyncData:FOREOUTSYNC"),object:nil)
                        print("Error: cant get order from server 2")
                        break
                    }
                case.failure(_):
                    NotificationCenter.default.post(name:Notification.Name("SyncData:FOREOUTSYNC"),object:nil)
                    print("Error: cant get order from server 1")
                }
            })
        }
    }
    
    private func syncCustomers(_ onComplete:(()->Void)? = nil) {
        CustomerManager.getAllCustomersNotSynced { list in
            let listDictionaryCustomer:[JSON] = list.flatMap({$0.toDictionary})
            NotificationCenter.default.post(name:Notification.Name("SyncData:StartCustomer"),object:nil)
            print("*******\nSTART SYNC CUSTOMERS: \(listDictionaryCustomer.count)\n*******")
            SyncService.shared.postAllCustomerToServer(list: listDictionaryCustomer, completion: { (result) in
                switch result {
                case .success(let data):
                    guard data.count > 0 else {
                        print("Dont have new customers from server")
                        return
                    }
                    
                    switch result {
                    case .success(let data):
                        // change state to synced true
                        _ = list.map({
                            let group = $0
                            group.synced = true
                            do{try CoreDataStack.sharedInstance.persistentContainer.viewContext.save()}catch{}
                            
                            
                        })
                        if data.count > 0 {
                            print("SAVE CUSTOMER TO CORE DATA")
                            CustomerManager.clearAllDataSynced {
                                CustomerManager.saveCustomerWith(array: data)
                            }
                            onComplete?()
                            NotificationCenter.default.post(name:Notification.Name("SyncData:Customer"),object:nil)
                        }
                    case .failure(_):
                        NotificationCenter.default.post(name:Notification.Name("SyncData:FOREOUTSYNC"),object:nil)
                        print("Error: cant get group from server 2")
                        break
                    }
                case.failure(_):
                    NotificationCenter.default.post(name:Notification.Name("SyncData:FOREOUTSYNC"),object:nil)
                    print("Error: cant get group from server 1")
                }
            })
        }
    }
    
    private func syncGroups(_ onComplete:(()->Void)? = nil) {
        GroupManager.getAllGroupSynced(onComplete: { (list) in
            let listDictionaryGroup:[JSON] = list.flatMap({$0.toDictionary})
            NotificationCenter.default.post(name:Notification.Name("SyncData:StartGroup"),object:nil)
            print("*******\nSTART SYNC GROUPS: \(listDictionaryGroup.count)\n*******")
            SyncService.shared.postAllGroupToServer(list: listDictionaryGroup, completion: { result in
                switch result {
                case .success(let data):
                    guard data.count > 0 else {
                        print("Dont have new group from server")
                        return
                    }

                    switch result {
                    case .success(let data):
                        _ = list.map({
                            let group = $0
                            group.synced = true
                            do{try CoreDataStack.sharedInstance.persistentContainer.viewContext.save()}catch{}
                        })
                        if data.count > 0 {
                            print("SAVE GROUP TO CORE DATA")
                            GroupManager.clearAllDataSynced {
                                GroupManager.saveGroupWith(array: data)
                            }
                            onComplete?()
                            NotificationCenter.default.post(name:Notification.Name("SyncData:Group"),object:nil)
                        }
                    case .failure(_):
                        NotificationCenter.default.post(name:Notification.Name("SyncData:FOREOUTSYNC"),object:nil)
                        print("Error: cant get group from server 2")
                        break
                    }
                case.failure(_):
                    NotificationCenter.default.post(name:Notification.Name("SyncData:FOREOUTSYNC"),object:nil)
                    print("Error: cant get group from server 1")
                }
            })
        })
    }
    
    func getAllCity(complete:([City])->Void){
        
        let listT = NSKeyedUnarchiver.unarchiveObject(with:UserDefaults.standard.value(forKey: "App:ListCity") as! Data) as! [JSON]
        let listCountry:[City] = listT.flatMap({City(json:$0)})
        let list = listCountry.sorted { (item1, item2) -> Bool in
            return item1.name.localizedCaseInsensitiveCompare(item2.name) == ComparisonResult.orderedAscending
        }
        if listCountry.count > 0 {
            complete(list)
            return
        }
    }
}

extension LocalService {
    // MARK: - Start sync with Server
    @objc fileprivate func syncToServer1() {
//        self.syncCustomerToServer()
//        self.syncGroupCustomerToServer()
    }
    
//    private func syncGroupCustomerToServer() {
//        print("start check/sync group to server")
//        let sql:String = "select * from `group` where `synced` = '0'" // group not synced
//        LocalService.shared.getGroupCustomerWithCustom(sql: sql, onComplete: {
//            list in
//            if list.count > 0 {
//                let listCustomer:[[String:Any]] = list.flatMap({$0.toDictionary})
//                print("Get local group done... send to server")
//                SyncService.shared.postAllGroupToServer(list: listCustomer, completion: { result in
//                    switch result {
//                    case .success(let data):
//                        guard data.count > 0 else {
//                            print("Dont have new group from server 1")
//                            return
//                        }
//                        print("remove group synced")
//                        do{
//                            try LocalService.shared.db.transaction {
//                                LocalService.shared.customSQl(sql: "delete from `group`", onComplete: {
//                                    print("start merge group to local DB")
//                                    let list:[GroupCustomer] = data
//                                    _ = list.map({
//                                        LocalService.shared.addGroup(obj: $0)
//                                    })
//                                    NotificationCenter.default.post(name:Notification.Name("SyncData:Group"),object:nil)
//                                })
//                            }
//                        } catch {
//
//                        }
//                    case.failure(_):
//                        print("Error: cant get group from server 1")
//                    }
//                })
//            } else {
//                print("Dont have new local group... get group from server")
//                SyncService.shared.getAllGroup(completion: { result in
//                    switch result {
//                    case .success(let data):
//                        guard data.count > 0 else {
//                            print("Dont have new group from server 2")
//                            return
//                        }
//                        print("remove group synced")
//
//                        do{
//                            try LocalService.shared.db.transaction {
//                                LocalService.shared.customSQl(sql: "delete from `group`", onComplete: {
//                                    print("start merge group to local DB")
//                                    let list:[GroupCustomer] = data
//                                    _ = list.map({
//                                        LocalService.shared.addGroup(obj: $0)
//                                    })
//                                    NotificationCenter.default.post(name:Notification.Name("SyncData:Group"),object:nil)
//                                })
//                            }
//                        }catch {
//
//                        }
//
//                    case .failure(_):
//                        print("Error: cant get group from server 2")
//                        break
//                    }
//                })
//            }
//        })
//    }
}
