//
//  LaunchController.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 11/28/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import UIKit

class LaunchController: UIViewController {

    var didAppBusy:Bool = false
    var didSyncedProduct:Bool = false
    var didSyncedMasterData:Bool = false
    var didSyncedOrder:Bool = false
    var didSyncedOrderItem:Bool = false
    var didSyncedCustomer:Bool = false
    var didSyncedGroup:Bool = false
    var isRoot = false
    var isLoading:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.startLoading(activityIndicatorStyle: .whiteLarge)
        
        if !Support.connectivity.isConnectedToInternet() {
            AppConfig.navigation.gotoDashboardAfterSigninSuccess()
            return
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.forceQuit(notification:)), name: Notification.Name("SyncData:FOREOUTSYNC"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.didSyncedMasterData(notification:)), name: Notification.Name("SyncData:MasterData"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.didSyncedProduct(notification:)), name: Notification.Name("SyncData:Product"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.didSyncedCustomer(notification:)), name: Notification.Name("SyncData:Customer"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.didSyncedGroup(notification:)), name: Notification.Name("SyncData:Group"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.didSyncedOrder(notification:)), name: Notification.Name("SyncData:Order"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.didSyncedOrderItem(notification:)), name: Notification.Name("SyncData:OrderItem"), object: nil)
        
        LocalService.shared.startSyncDataBackground()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - private
    func willSyncedGroup(notification:Notification) {
        didSyncedGroup = false
    }
    func willSyncedCustomer(notification:Notification) {
        didSyncedCustomer = false
    }
    func willSyncedOrder(notification:Notification) {
        didSyncedOrder = false
    }
    func willSyncedOrderItem(notification:Notification) {
        didSyncedOrderItem = false
    }
    
    func didSyncedGroup(notification:Notification) {
        didSyncedGroup = true
        updateStatus()
    }
    func didSyncedCustomer(notification:Notification) {
        didSyncedCustomer = true
        updateStatus()
    }
    func didSyncedOrder(notification:Notification) {
        didSyncedOrder = true
        updateStatus()
    }
    func didSyncedOrderItem(notification:Notification) {
        didSyncedOrderItem = true
        updateStatus()
    }
    func didSyncedMasterData(notification:Notification) {
        didSyncedMasterData = true
        updateStatus()
    }
    func didSyncedProduct (notification:Notification) {
        didSyncedProduct = true
        updateStatus()
    }
    func appBusy(notification:Notification) {
        didAppBusy = true
        updateStatus()
    }
    
    func forceQuit(notification:Notification) {
        self.view.stopLoading()
        AppConfig.navigation.gotoDashboardAfterSigninSuccess()
    }
    
    private func updateStatus() {
        
            if didSyncedOrder &&
                didSyncedCustomer &&
                didSyncedGroup &&
                didSyncedOrderItem &&
                didSyncedMasterData &&
                didSyncedProduct {
                self.view.stopLoading()
                AppConfig.navigation.gotoDashboardAfterSigninSuccess()
            }
            return
    }
    
}
