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
        
        if !Support.connectivity.isConnectedToInternet() {
            // Device doesn't have internet connection
            print("Internet Offline")
            onComplete?()
            NotificationCenter.default.post(name:Notification.Name("SyncData:FOREOUTSYNC"),object:nil)
            return
        }
        
        SyncService.shared.syncProducts {_ in print("SYNC products COMPLETED".uppercased())
            DispatchQueue.main.async {
                NotificationCenter.default.post(name:Notification.Name("SyncData:Product"),object:nil)
            }
            self.syncUser{print("SYNC MASTERDATA COMPLETED".uppercased())}
            self.syncMasterData{print("SYNC master data COMPLETED".uppercased())}
            self.syncGroups {print("SYNC groups COMPLETED".uppercased())
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name:Notification.Name("SyncData:Group"),object:nil)
                }
            }
            
            self.syncCustomers {print("SYNC customer COMPLETED".uppercased())
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name:Notification.Name("SyncData:Customer"),object:nil)
                }
            }
            
            self.syncOrders{print("SYNC orders COMPLETED".uppercased())
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name:Notification.Name("SyncData:Order"),object:nil)
                }
            }
            
            self.syncOrdersItems {print("SYNC orderitems COMPLETED".uppercased())
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name:Notification.Name("SyncData:OrderItem"),object:nil)
                }
            }
            
            //        DispatchQueue.main.async {
            //            print("\n ====> SYNC DATA COMPLETE")
            onComplete?()
            //            DispatchQueue.main.async {
            //                NotificationCenter.default.post(name:Notification.Name("SyncData:AllDone"),object:nil)
            //            }
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
    
    func syncMasterData(_ onComplete:(()->Void)? = nil) {
        SyncService.shared.getMasterData { _ in
            DispatchQueue.main.async {
                NotificationCenter.default.post(name:Notification.Name("SyncData:MasterData"),object:nil)
                onComplete?()
            }
        }
    }
    
    func syncUser(_ onComplete:(()->Void)? = nil) {
        
        guard let _ = UserManager.currentUser() else { onComplete?(); return }
        SyncService.shared.syncUser({ _ in
            DispatchQueue.main.async {
                NotificationCenter.default.post(name:Notification.Name("SyncData:Customer"),object:nil)
                onComplete?()
            }
        })
    }
    
    func syncOrdersItems(_ onComplete:(()->Void)? = nil) {
        print("*******\nSTART SYNC ORDERITEMS\n*******")
        
        //        DispatchQueue.main.async {
        //            NotificationCenter.default.post(name:Notification.Name("SyncData:StartOrderItem"),object:nil)
        //        }
        
        SyncService.shared.getOrderItems(completion: { (result) in
            switch result {
            case .success(let data):
                if let bool = LocalService.shared.isShouldSyncData?() {
                    if bool == false {
                        onComplete?()
                        print("APP IN STATE BUSY, SO WILL SYNCED LATER")
                        //                        NotificationCenter.default.post(name:Notification.Name("SyncData:APPBUSY"),object:nil)
                        //                        NotificationCenter.default.post(name:Notification.Name("SyncData:FOREOUTSYNC"),object:nil)
                        return
                    }
                }
                OrderItemManager.resetData {
                    if data.count > 0 {
                        print("SAVE ORDERITEM TO CORE DATA")
                        OrderItemManager.saveOrderItemWith(array:data) {
                            onComplete?()
                            //                            DispatchQueue.main.async {
                            //                                NotificationCenter.default.post(name:Notification.Name("SyncData:OrderItem"),object:nil)
                            //                            }
                        }
                    } else {
                        onComplete?()
                        //                        DispatchQueue.main.async {
                        //                            NotificationCenter.default.post(name:Notification.Name("SyncData:OrderItem"),object:nil)
                        //                        }
                    }
                }
                
            case .failure(_):
                onComplete?()
                //                DispatchQueue.main.async {
                //                    NotificationCenter.default.post(name:Notification.Name("SyncData:FOREOUTSYNC"),object:nil)
                //                }
                print("Error: cant get orderitem from server 2")
                break
            }
        })
    }
    
    func syncOrders(_ one:Bool = false,_ onComplete:(()->Void)? = nil) {
        
        OrderManager.getAllOrdersNotSynced { list in
            let listDictionaryOrders:[JSON] = list.flatMap({$0.toDictionary})
            print("*******\nSTART SYNC ORDERS: \(listDictionaryOrders)\n*******")
            //            DispatchQueue.main.async {
            //                NotificationCenter.default.post(name:Notification.Name("SyncData:StartOrder"),object:nil)
            //            }
            
            if one {
                SyncService.shared.postOrdersAndOrderItemsTypeOne(list: listDictionaryOrders, completion: { (result) in
                    switch result {
                    case .success(let data):
                        print("*******\n GOT ORDERS: \(data)\n*******")
                        // change state to synced true
                        if let bool = LocalService.shared.isShouldSyncData?() {
                            if bool == false {
                                onComplete?()
                                DispatchQueue.main.async {
                                    NotificationCenter.default.post(name:Notification.Name("SyncData:OrderOne"),object:nil)
                                }
                                print("APP IN STATE BUSY, SO WILL SYNCED LATER")
                                //                                NotificationCenter.default.post(name:Notification.Name("SyncData:APPBUSY"),object:nil)
                                return
                            }
                        }
                        var list1:[Int64] = [0]
                        if listDictionaryOrders.count > 0 {
                            list1.append(contentsOf: listDictionaryOrders.flatMap{$0["id"] as? Int64})
                            list1.append(contentsOf: listDictionaryOrders.flatMap{$0["local_id"] as? Int64})
                        }
                        if let orders = data["orders"] as? [JSON],
                            let orderitems = data["orderitems"] as? [JSON] {
                            OrderManager.markSynced(list1, {
                                OrderManager.update(orders, {
                                    OrderItemManager.resetData(from: list1) {
                                        if orderitems.count > 0 {
                                            print("SAVE ORDERITEM TO CORE DATA")
                                            OrderItemManager.saveOrderItemWith(array:orderitems) {
                                                onComplete?()
                                                print("SAVE ORDERS AND REFERENCE TO CORE DATA")
                                                DispatchQueue.main.async {
                                                    NotificationCenter.default.post(name:Notification.Name("SyncData:OrderOne"),object:nil)
                                                }
                                                //                                                DispatchQueue.main.async {
                                                //                                                    NotificationCenter.default.post(name:Notification.Name("SyncData:OrderItem"),object:nil)
                                                //                                                }
                                            }
                                        } else {
                                            print("NO ORDERITEM on SERVER TO CORE DATA".uppercased())
                                            onComplete?()
                                            DispatchQueue.main.async {
                                                NotificationCenter.default.post(name:Notification.Name("SyncData:OrderOne"),object:nil)
                                            }
                                            //                                            DispatchQueue.main.async {
                                            //                                                NotificationCenter.default.post(name:Notification.Name("SyncData:OrderItem"),object:nil)
                                            //                                            }
                                        }
                                    }
                                })
                            })
                        } else {
                            print("warning no data to parse when sync one Orders and ordertiems".uppercased())
                            onComplete?()
                            DispatchQueue.main.async {
                                NotificationCenter.default.post(name:Notification.Name("SyncData:OrderOne"),object:nil)
                            }
                        }
                        
                    case .failure(_):
                        onComplete?()
                        print("Error: cant get order from server 2")
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name:Notification.Name("SyncData:OrderOne"),object:nil)
                        }
                        break
                    }
                })
                return
            }
            
            SyncService.shared.postAllOrdersToServer(list: listDictionaryOrders, completion: { (result) in
                switch result {
                case .success(let data):
                    // change state to synced true
                    if let bool = LocalService.shared.isShouldSyncData?() {
                        if bool == false {
                            onComplete?()
                            print("APP IN STATE BUSY, SO WILL SYNCED LATER")
                            //                            NotificationCenter.default.post(name:Notification.Name("SyncData:APPBUSY"),object:nil)
                            //                            NotificationCenter.default.post(name:Notification.Name("SyncData:FOREOUTSYNC"),object:nil)
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
                                    //                                    DispatchQueue.main.async {
                                    //                                        NotificationCenter.default.post(name:Notification.Name("SyncData:Order"),object:nil)
                                    //                                    }
                                }
                            } else {
                                onComplete?()
                            }
                        }
                    })
                    
                case .failure(_):
                    onComplete?()
                    //                    DispatchQueue.main.async {
                    ////                        NotificationCenter.default.post(name:Notification.Name("SyncData:FOREOUTSYNC"),object:nil)
                    //                    }
                    print("Error: cant get order from server 2")
                    break
                }
            })
        }
    }
    
    func syncCustomers(_ one:Bool = false,_ onComplete:(()->Void)? = nil) {
        CustomerManager.getAllCustomersNotSynced { list in
            let listDictionaryCustomer:[JSON] = list.flatMap({$0.toDictionary})
            //            DispatchQueue.main.async {
            //                NotificationCenter.default.post(name:Notification.Name("SyncData:StartCustomer"),object:nil)
            //            }
            print("*******\nSTART SYNC CUSTOMERS: \(listDictionaryCustomer.count)\n*******")
            if one == true {
                SyncService.shared.postCustomersTypeOne(list:listDictionaryCustomer, completion: { (result) in
                    switch result {
                    case .success(let data):
                        if let bool = LocalService.shared.isShouldSyncData?() {
                            if bool == false {
                                onComplete?()
                                print("APP IN STATE BUSY, SO WILL SYNCED LATER")
                                //                                NotificationCenter.default.post(name:Notification.Name("SyncData:APPBUSY"),object:nil)
                                //                                NotificationCenter.default.post(name:Notification.Name("SyncData:FOREOUTSYNC"),object:nil)
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
                            CustomerManager.update(data, {
                                print("UPDATE CUSTOMER \(data) TO CORE DATA")
                                onComplete?()
                                //                                DispatchQueue.main.async {
                                //                                    NotificationCenter.default.post(name:Notification.Name("SyncData:Customer"),object:nil)
                                //                                }
                            })
                        })
                    case .failure(_):
                        onComplete?()
                        //                        DispatchQueue.main.async {
                        //                            NotificationCenter.default.post(name:Notification.Name("SyncData:FOREOUTSYNC"),object:nil)
                        //                        }
                        print("Error: cant get customer from server 2")
                        break
                    }
                    
                })
                return
            }
            SyncService.shared.postAllCustomerToServer(list:listDictionaryCustomer, completion: { (result) in
                switch result {
                case .success(let data):
                    if let bool = LocalService.shared.isShouldSyncData?() {
                        if bool == false {
                            onComplete?()
                            print("APP IN STATE BUSY, SO WILL SYNCED LATER")
                            NotificationCenter.default.post(name:Notification.Name("SyncData:APPBUSY"),object:nil)
                            //                            NotificationCenter.default.post(name:Notification.Name("SyncData:FOREOUTSYNC"),object:nil)
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
                        //                        NotificationCenter.default.post(name:Notification.Name("SyncData:FOREOUTSYNC"),object:nil)
                    }
                    print("Error: cant get customer from server 2")
                    break
                }
                
            })
        }
    }
    
    private func syncGroups(_ onComplete:(()->Void)? = nil) {
        GroupManager.getAllGroupSynced(onComplete: { (list) in
            let listDictionaryGroup:[JSON] = list.flatMap({$0.toDictionary})
            //            DispatchQueue.main.async {
            //                NotificationCenter.default.post(name:Notification.Name("SyncData:StartGroup"),object:nil)
            //            }
            print("*******\nSTART SYNC GROUPS: \(listDictionaryGroup)\n*******")
            SyncService.shared.postAllGroupToServer(list: listDictionaryGroup, completion: { result in
                
                switch result {
                case .success(let data):
                    if let bool = LocalService.shared.isShouldSyncData?() {
                        if bool == false {
                            onComplete?()
                            print("APP IN STATE BUSY, SO WILL SYNCED LATER")
                            //                            NotificationCenter.default.post(name:Notification.Name("SyncData:APPBUSY"),object:nil)
                            //                                NotificationCenter.default.post(name:Notification.Name("SyncData:FOREOUTSYNC"),object:nil)
                            return
                        }
                    }
                    
                    guard data.count > 0 else {
                        onComplete?()
                        //                        DispatchQueue.main.async {
                        //                            NotificationCenter.default.post(name:Notification.Name("SyncData:Group"),object:nil)
                        //                        }
                        print("Dont have new group from server")
                        return
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
                                    //                                    DispatchQueue.main.async {
                                    //                                        NotificationCenter.default.post(name:Notification.Name("SyncData:Group"),object:nil)
                                    //                                    }
                                    onComplete?()
                                }
                            } else {
                                onComplete?()
                                //                                DispatchQueue.main.async {
                                //                                    NotificationCenter.default.post(name:Notification.Name("SyncData:Group"),object:nil)
                                //                                }
                            }
                        }
                    })
                case .failure(_):
                    onComplete?()
                    //                    DispatchQueue.main.async {
                    //                            NotificationCenter.default.post(name:Notification.Name("SyncData:FOREOUTSYNC"),object:nil)
                    //                    }
                    print("Error: cant get group from server 2")
                    break
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
