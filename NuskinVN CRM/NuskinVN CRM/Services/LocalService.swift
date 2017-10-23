//
//  LocalService.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 9/21/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import Foundation
import SQLite
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
    
    // MARK: -
    var db: Connection!
    
    var isMoveDB:Bool = false
    var isSync:Bool = false
    var timerSyncToServer:Timer?
    
    // Initialization
    private override init() {
        super.init()
    }
    
    //start service
    func startSyncData() {
        
        if UserManager.currentUser().id_card_no == 0 {
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
    
    @objc private func syncToServer() {
        
        if !Support.connectivity.isConnectedToInternet() {
            // Device doesn't have internet connection
            print("Internet Offline")
            return
        }
            
        // groups
        self.syncGroups()
        
        // customers
        self.syncCustomers()
        
        //products
        SyncService.shared.syncProducts(completion: {_ in })
        
    }
    
    private func syncCustomers() {
        CustomerManager.getAllCustomersNotSynced { list in
            let listDictionaryCustomer:[JSON] = list.flatMap({$0.toDictionary})
            
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
                            
                            NotificationCenter.default.post(name:Notification.Name("SyncData:Customer"),object:nil)
                        }
                    case .failure(_):
                        print("Error: cant get group from server 2")
                        break
                    }
                case.failure(_):
                    print("Error: cant get group from server 1")
                }
            })
        }
    }
    
    private func syncGroups() {
        GroupManager.getAllGroupSynced(onComplete: { (list) in
            let listDictionaryGroup:[JSON] = list.flatMap({$0.toDictionary})
            
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

                            NotificationCenter.default.post(name:Notification.Name("SyncData:Group"),object:nil)
                        }
                    case .failure(_):
                        print("Error: cant get group from server 2")
                        break
                    }
                case.failure(_):
                    print("Error: cant get group from server 1")
                }
            })
        })
    }
    
    func getAllCity(complete:([City])->Void){
        
        let listT = NSKeyedUnarchiver.unarchiveObject(with:UserDefaults.standard.value(forKey: "App:ListCity") as! Data) as! [JSON]
        let listCountry:[City] = listT.flatMap({City(json:$0)})
        if listCountry.count > 0 {
            complete(listCountry)
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
