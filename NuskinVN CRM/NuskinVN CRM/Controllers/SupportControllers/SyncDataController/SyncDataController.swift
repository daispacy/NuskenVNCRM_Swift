//
//  SyncDataController.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 10/25/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import UIKit
import CoreData

class SyncDataController: RootViewController {

    @IBOutlet var sccrollView: UIScrollView!
    @IBOutlet var indicator: UIActivityIndicatorView!
    @IBOutlet var lblStatus: UILabel!
    @IBOutlet var btnQuit: UIButton!
    @IBOutlet var lblLoading: UILabel!
    @IBOutlet var indicatorLoading: UIActivityIndicatorView!
    
    
    var timer:Timer?
    var didAppBusy:Bool = false
    var didSyncedOrder:Bool = false
    var didSyncedOrderItem:Bool = false
    var didSyncedCustomer:Bool = false
    var didSyncedGroup:Bool = false
    var isRoot = false
    var isLoading:Bool = false
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.providesPresentationContextTransitionStyle = true
        self.definesPresentationContext = true
        self.modalPresentationStyle=UIModalPresentationStyle.overCurrentContext
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        LocalService.shared.isShouldSyncData = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        if self.isModalInPopover{
        
//        }
        
        LocalService.shared.isShouldSyncData = {
            return true
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.forceQuit(notification:)), name: Notification.Name("SyncData:FOREOUTSYNC"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.willSyncedCustomer(notification:)), name: Notification.Name("SyncData:StartCustomer"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.willSyncedGroup(notification:)), name: Notification.Name("SyncData:StartGroup"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.willSyncedOrder(notification:)), name: Notification.Name("SyncData:StartOrder"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.willSyncedOrderItem(notification:)), name: Notification.Name("SyncData:StartOrderItem"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.didSyncedCustomer(notification:)), name: Notification.Name("SyncData:Customer"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.didSyncedGroup(notification:)), name: Notification.Name("SyncData:Group"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.didSyncedOrder(notification:)), name: Notification.Name("SyncData:Order"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.didSyncedOrderItem(notification:)), name: Notification.Name("SyncData:OrderItem"), object: nil)
        
        btnQuit.setTitle("close".localized().uppercased(), for: .normal)
        btnQuit.titleLabel?.font = UIFont(name: Theme.font.bold, size: Theme.fontSize.medium)
        lblStatus.text = "syncing".localized() + "\n"
        lblStatus.font = UIFont(name: Theme.font.normal, size: Theme.fontSize.normal)
        lblStatus.textColor = UIColor.white
        lblLoading.text = "syncing".localized()
        lblLoading.font = UIFont(name: Theme.font.normal, size: Theme.fontSize.normal)
        lblLoading.textColor = UIColor(hex:Theme.colorDBTextNormal)
        indicator.startAnimating()
        indicatorLoading.startAnimating()
        
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        if let window = appdelegate.window {
            if let root = window.rootViewController {
                if root.isEqual(self) {
                    isRoot = true
                    startSync()
                }
            }
        }
    }
    
    // MARK: - interface
    func startSync(_ isLoading:Bool? = false) {
        LocalService.shared.startSyncData()
        if let bool = isLoading {
            self.isLoading = bool
            if bool {
                
                btnQuit.isHidden = true
                self.sccrollView.isHidden = true
            }
        }
    }
    
    // MARK: - private
    func willSyncedGroup(notification:Notification) {
        didSyncedGroup = false
        indicator.startAnimating()
        lblStatus.text?.append("start_sync_group".localized() + "\n")
    }
    func willSyncedCustomer(notification:Notification) {
        didSyncedCustomer = false
        indicator.startAnimating()
        lblStatus.text?.append("start_sync_customer".localized() + "\n")
    }
    func willSyncedOrder(notification:Notification) {
        didSyncedOrder = false
        indicator.startAnimating()
        lblStatus.text?.append("start_sync_order".localized() + "\n")
    }
    func willSyncedOrderItem(notification:Notification) {
        didSyncedOrderItem = false
        indicator.startAnimating()
        lblStatus.text?.append("start_sync_order_items".localized() + "\n")
    }
    
    func didSyncedGroup(notification:Notification) {
        didSyncedGroup = true
        lblStatus.text?.append("start_sync_group".localized() + "..............OK\n")
        updateStatus()
    }
    func didSyncedCustomer(notification:Notification) {
        didSyncedCustomer = true
        lblStatus.text?.append("start_sync_customer".localized() + "............OK\n")
        updateStatus()
    }
    func didSyncedOrder(notification:Notification) {
        didSyncedOrder = true
        lblStatus.text?.append("start_sync_order".localized() + "..................OK\n")
        updateStatus()
    }
    func didSyncedOrderItem(notification:Notification) {
        didSyncedOrderItem = true
        lblStatus.text?.append("start_sync_order_items".localized() + ".................OK\n")
        updateStatus()
    }
    func appBusy(notification:Notification) {
        didAppBusy = true
        updateStatus()
    }
    func forceQuit(notification:Notification) {
        dismiss(animated: false, completion: nil)
    }
    private func updateStatus() {
        
        if self.isLoading {
            if didSyncedOrder &&
                didSyncedCustomer &&
                didSyncedGroup &&
                didSyncedOrderItem {
                dismiss(animated: false, completion: nil)
            }
            return
        }
        
        var y:CGFloat = 0
        if self.sccrollView.contentSize.height > self.view.frame.maxY - 115{
            y = self.sccrollView.contentSize.height - CGFloat(self.view.frame.maxY - 115)
        }
        sccrollView.setContentOffset(CGPoint(x:0, y:y), animated: true)
        if didAppBusy  {
            indicator.stopAnimating()
            lblStatus.text = "app_is_busy_try_again_later".localized().uppercased()
            return
        }
        if (didSyncedOrder && didSyncedCustomer && didSyncedGroup && didSyncedOrderItem) {
            indicator.stopAnimating()
            let date = Date.init(timeIntervalSinceNow: 0)
            lblStatus.text?.append("----------\("complete".localized().uppercased()): \(date.toString(dateFormat: "yyyy-MM-dd HH:mm:ss"))----------\n\n")
            if self.isRoot {
                timer = Timer.scheduledTimer(timeInterval:1, target: self, selector: #selector(self.gotoNext), userInfo: nil, repeats: true)
            }
        }
    }
    
    @objc func gotoNext() {
        self.timer?.invalidate()
        AppConfig.navigation.gotoDashboardAfterSigninSuccess()
    }
    
    @IBAction func quit(_ sender: Any) {
        if self.isRoot {
            self.timer?.invalidate()
            AppConfig.navigation.gotoDashboardAfterSigninSuccess()
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        print("dealloc SyncDataController")
    }
}
