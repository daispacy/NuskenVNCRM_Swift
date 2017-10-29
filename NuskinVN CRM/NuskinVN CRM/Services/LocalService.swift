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
        DispatchQueue.global(qos: .background).async {
            self.syncUser()
            self.syncMasterData()
            self.syncGroups {
                self.syncCustomers {
                    self.syncOrders {
                        self.syncOrdersItems {
                            DispatchQueue.main.async {
                                onComplete?()
                            }
                        }
                    }
                }
            }
        }
    }
    
    @objc private func syncToServer() {
        DispatchQueue.global(qos: .background).async {
            // user
            self.syncUser()
            
            //master data
            self.syncMasterData()
            
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
            SyncService.shared.syncProducts(completion: {_ in
                NotificationCenter.default.post(name:Notification.Name("SyncData:Group&Product"),object:nil)
            })
            
            // orders
            self.syncOrders()
            
            // order items
            self.syncOrdersItems()
        }
    }
    
    private func syncMasterData() {
        SyncService.shared.getMasterData { _ in
            
        }
    }
    
    private func syncUser() {
        guard let _ = UserManager.currentUser() else { return }
//        if user.synced == false {
            SyncService.shared.syncUser({ _ in
                
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
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name:Notification.Name("SyncData:OrderItem"),object:nil)
                        }
                    }
                case .failure(_):
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name:Notification.Name("SyncData:FOREOUTSYNC"),object:nil)
                    }
                    print("Error: cant get orderitem from server 2")
                    break
                }
            case.failure(_):
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name:Notification.Name("SyncData:FOREOUTSYNC"),object:nil)
                }
                print("Error: cant get orderitem from server 1")
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
                            DispatchQueue.main.async {
                                NotificationCenter.default.post(name:Notification.Name("SyncData:Order"),object:nil)
                            }
                        }
                    case .failure(_):
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name:Notification.Name("SyncData:FOREOUTSYNC"),object:nil)
                        }
                        print("Error: cant get order from server 2")
                        break
                    }
                case.failure(_):
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name:Notification.Name("SyncData:FOREOUTSYNC"),object:nil)
                    }
                    print("Error: cant get order from server 1")
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
                            DispatchQueue.main.async {
                                NotificationCenter.default.post(name:Notification.Name("SyncData:Customer"),object:nil)
                            }
                        }
                    case .failure(_):
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name:Notification.Name("SyncData:FOREOUTSYNC"),object:nil)
                        }
                        print("Error: cant get group from server 2")
                        break
                    }
                case.failure(_):
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name:Notification.Name("SyncData:FOREOUTSYNC"),object:nil)
                    }
                    print("Error: cant get group from server 1")
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
                            DispatchQueue.main.async {
                                NotificationCenter.default.post(name:Notification.Name("SyncData:Group"),object:nil)
                            }
                        }
                    case .failure(_):
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name:Notification.Name("SyncData:FOREOUTSYNC"),object:nil)
                        }
                        print("Error: cant get group from server 2")
                        break
                    }
                case.failure(_):
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
