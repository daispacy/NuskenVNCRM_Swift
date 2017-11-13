//
//  LocalService.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 9/21/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import Foundation
import SystemConfiguration
import CoreData

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
        print("START SERVICE SYNC DATA")
        // first
//        self.syncToServer()
        
        if let bool = self.timerSyncToServer?.isValid {
            if bool {self.timerSyncToServer?.invalidate()}
        }
        
        // loop
        self.timerSyncToServer = Timer.scheduledTimer(timeInterval: 60*2, target: self, selector: #selector(self.syncToServer), userInfo: nil, repeats: true)
    }
    
    func startSyncDataBackground(onComplete:(()->Void)? = nil) {
        if let bool = LocalService.shared.isShouldSyncData?() {
            if bool == false {
                onComplete?()
                print("APP IN STATE BUSY, SO WILL SYNCED LATER")
                NotificationCenter.default.post(name:Notification.Name("SyncData:APPBUSY"),object:nil)
                NotificationCenter.default.post(name:Notification.Name("SyncData:FOREOUTSYNC"),object:nil)
                return
            }
        }
            self.syncUser{
                self.syncMasterData{self.syncGroups {self.syncCustomers {SyncService.shared.syncProducts{_ in self.syncOrders{self.syncOrdersItems {
                                        DispatchQueue.main.async {
                                            print("SYNC DATA COMPLETE")
                                            onComplete?()
                                            DispatchQueue.main.async {
                                                NotificationCenter.default.post(name:Notification.Name("SyncData:AllDone"),object:nil)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
    }
    
    @objc private func syncToServer() {
        
        if let bool = LocalService.shared.isShouldSyncData?() {
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
        
        self.startSyncDataBackground(onComplete: nil)
        
        /*
        return
        
        // user
        self.syncUser()
        
        //master data
        self.syncMasterData()
        
        // groups
        self.syncGroups()
        
        // customers
        self.syncCustomers()
        
        // products
        SyncService.shared.syncProducts(completion: {_ in
            NotificationCenter.default.post(name:Notification.Name("SyncData:Group&Product"),object:nil)
        })
        
        // orders
        self.syncOrders()
        
        // order items
        self.syncOrdersItems()
 */
        
    }
    
    private func syncMasterData(_ onComplete:(()->Void)? = nil) {
        SyncService.shared.getMasterData { _ in
            onComplete?()
        }
    }
    
    private func syncUser(_ onComplete:(()->Void)? = nil) {
        guard let _ = UserManager.currentUser() else { onComplete?(); return }
//        if user.synced == false {
            SyncService.shared.syncUser({ _ in
                onComplete?()
            })
//        }
    }
    
    private func syncOrdersItems(_ onComplete:(()->Void)? = nil) {
            print("*******\nSTART SYNC ORDERITEMS\n*******")
        
        DispatchQueue.main.async {
            NotificationCenter.default.post(name:Notification.Name("SyncData:StartOrderItem"),object:nil)
        }
        
        SyncService.shared.getOrderItems(completion: { (result) in
            switch result {
            case .success(let data):
                if let bool = LocalService.shared.isShouldSyncData?() {
                    if bool == false {
                        onComplete?()
                        print("APP IN STATE BUSY, SO WILL SYNCED LATER")
                        NotificationCenter.default.post(name:Notification.Name("SyncData:APPBUSY"),object:nil)
                        NotificationCenter.default.post(name:Notification.Name("SyncData:FOREOUTSYNC"),object:nil)
                        return
                    }
                }
                OrderItemManager.resetData {
                    if data.count > 0 {
                        print("SAVE ORDERITEM TO CORE DATA")
                        OrderItemManager.saveOrderItemWith(array:data) {
                            onComplete?()
                            DispatchQueue.main.async {
                                NotificationCenter.default.post(name:Notification.Name("SyncData:OrderItem"),object:nil)
                            }
                        }
                    } else {
                        onComplete?()
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name:Notification.Name("SyncData:OrderItem"),object:nil)
                        }
                    }
                }
                
            case .failure(_):
                onComplete?()
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name:Notification.Name("SyncData:FOREOUTSYNC"),object:nil)
                }
                print("Error: cant get orderitem from server 2")
                break
            }
        })
    }
    
    private func syncOrders(_ onComplete:(()->Void)? = nil) {
        
        OrderManager.getAllOrdersNotSynced { list in
            let listDictionaryOrders:[JSON] = list.flatMap({$0.toDictionary})
            print("*******\nSTART SYNC ORDERS: \(listDictionaryOrders.count)\n*******")
            DispatchQueue.main.async {
                NotificationCenter.default.post(name:Notification.Name("SyncData:StartOrder"),object:nil)
            }
            
            print(listDictionaryOrders)
            SyncService.shared.postAllOrdersToServer(list: listDictionaryOrders, completion: { (result) in
                switch result {
                case .success(let data):
                    // change state to synced true
                    if let bool = LocalService.shared.isShouldSyncData?() {
                        if bool == false {
                            onComplete?()
                            print("APP IN STATE BUSY, SO WILL SYNCED LATER")
                            NotificationCenter.default.post(name:Notification.Name("SyncData:APPBUSY"),object:nil)
                            NotificationCenter.default.post(name:Notification.Name("SyncData:FOREOUTSYNC"),object:nil)
                            return
                        }
                    }
                    var list1:[Int64] = [0]
                    if listDictionaryOrders.count > 0 {
                        list1.append(contentsOf: listDictionaryOrders.flatMap{$0["id"] as? Int64})
                        list1.append(contentsOf: listDictionaryOrders.flatMap{$0["local_id"] as? Int64})
                    }
                    OrderManager.markSynced(list1, {
                        OrderManager.clearAllDataSynced {
                            if data.count > 0 {
                                print("SAVE ORDER TO CORE DATA")
                                OrderManager.saveOrderWith(array:data) {
                                    onComplete?()
                                    DispatchQueue.main.async {
                                        NotificationCenter.default.post(name:Notification.Name("SyncData:Order"),object:nil)
                                    }
                                }
                            } else {
                                onComplete?()
                            }
                        }
                    })
                   
                case .failure(_):
                    onComplete?()
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name:Notification.Name("SyncData:FOREOUTSYNC"),object:nil)
                    }
                    print("Error: cant get order from server 2")
                    break
                }
            })
        }
    }
    
    private func syncCustomers(_ onComplete:(()->Void)? = nil) {
        CustomerManager.getAllCustomersNotSynced { list in
            let listDictionaryCustomer:[JSON] = list.flatMap({$0.toDictionary})
            DispatchQueue.main.async {
                NotificationCenter.default.post(name:Notification.Name("SyncData:StartCustomer"),object:nil)
            }
            print("*******\nSTART SYNC CUSTOMERS: \(listDictionaryCustomer.count)\n*******")
            SyncService.shared.postAllCustomerToServer(list:listDictionaryCustomer, completion: { (result) in
                switch result {
                case .success(let data):
                    if let bool = LocalService.shared.isShouldSyncData?() {
                        if bool == false {
                            onComplete?()
                            print("APP IN STATE BUSY, SO WILL SYNCED LATER")
                            NotificationCenter.default.post(name:Notification.Name("SyncData:APPBUSY"),object:nil)
                            NotificationCenter.default.post(name:Notification.Name("SyncData:FOREOUTSYNC"),object:nil)
                            return
                        }
                    }
                    // change state to synced true
                    var list1:[Int64] = [0]
                    if listDictionaryCustomer.count > 0 {
                         list1.append(contentsOf: listDictionaryCustomer.flatMap{$0["id"] as? Int64})
                        list1.append(contentsOf: listDictionaryCustomer.flatMap{$0["local_id"] as? Int64})
                    }
                    CustomerManager.markSynced(list1, {
                        CustomerManager.clearAllDataSynced {
                            if data.count > 0 {
                                print("SAVE CUSTOMER TO CORE DATA")
                                CustomerManager.saveCustomerWith(array: data) {
                                    onComplete?()
                                    DispatchQueue.main.async {
                                        NotificationCenter.default.post(name:Notification.Name("SyncData:Customer"),object:nil)
                                    }
                                }
                            } else {
                                onComplete?()
                                DispatchQueue.main.async {
                                    NotificationCenter.default.post(name:Notification.Name("SyncData:Customer"),object:nil)
                                }
                            }
                        }
                    })
                case .failure(_):
                    onComplete?()
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name:Notification.Name("SyncData:FOREOUTSYNC"),object:nil)
                    }
                    print("Error: cant get group from server 2")
                    break
                }
                
            })
        }
    }
    
    private func syncGroups(_ onComplete:(()->Void)? = nil) {
        GroupManager.getAllGroupSynced(onComplete: { (list) in
            let listDictionaryGroup:[JSON] = list.flatMap({$0.toDictionary})
            DispatchQueue.main.async {
                NotificationCenter.default.post(name:Notification.Name("SyncData:StartGroup"),object:nil)
            }
            print("*******\nSTART SYNC GROUPS: \(listDictionaryGroup.count)\n*******")
            SyncService.shared.postAllGroupToServer(list: listDictionaryGroup, completion: { result in
                switch result {
                case .success(let data):
                    guard data.count > 0 else {
                        onComplete?()
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name:Notification.Name("SyncData:Group"),object:nil)
                        }
                        print("Dont have new group from server")
                        return
                    }

                    switch result {
                    case .success(let data):
                        if let bool = LocalService.shared.isShouldSyncData?() {
                            if bool == false {
                                onComplete?()
                                print("APP IN STATE BUSY, SO WILL SYNCED LATER")
                                NotificationCenter.default.post(name:Notification.Name("SyncData:APPBUSY"),object:nil)
                                NotificationCenter.default.post(name:Notification.Name("SyncData:FOREOUTSYNC"),object:nil)
                                return
                            }
                        }
                        
                        var list1:[Int64] = [0]
                        if listDictionaryGroup.count > 0 {
                            list1.append(contentsOf: listDictionaryGroup.flatMap{$0["id"] as? Int64})
                            list1.append(contentsOf: listDictionaryGroup.flatMap{$0["local_id"] as? Int64})
                        }
                        GroupManager.markSynced(list1, {
                            print("SAVE GROUP TO CORE DATA")
                            GroupManager.clearAllDataSynced {
                                if data.count > 0 {
                                    GroupManager.saveGroupWith(array: data) {
                                        DispatchQueue.main.async {
                                            NotificationCenter.default.post(name:Notification.Name("SyncData:Group"),object:nil)
                                        }
                                        onComplete?()
                                    }
                                } else {
                                    onComplete?()
                                    DispatchQueue.main.async {
                                        NotificationCenter.default.post(name:Notification.Name("SyncData:Group"),object:nil)
                                    }
                                }
                            }
                        })
                    case .failure(_):
                        onComplete?()
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name:Notification.Name("SyncData:FOREOUTSYNC"),object:nil)
                        }
                        print("Error: cant get group from server 2")
                        break
                    }
                case.failure(_):
                    onComplete?()
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name:Notification.Name("SyncData:FOREOUTSYNC"),object:nil)
                    }
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
