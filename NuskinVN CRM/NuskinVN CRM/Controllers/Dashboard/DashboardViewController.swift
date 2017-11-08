//
//  DashboardViewController.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 9/22/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import UIKit

class DashboardViewController: RootViewController, UITabBarControllerDelegate {
    
    private var dashboardView:DashboardView!

    var isSyncWithLoading:Bool = false
    
    var fromDate:NSDate? = nil
    var toDate:NSDate? = nil
    var isLifeTime: Bool = true
    
    // MARK: - INIT
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadAfterSynced(notification:)), name: Notification.Name("SyncData:AllDone"), object: nil)
        
        configText()
        
        // add menu from root
        addDefaultMenu()
        
        // Do any additional setup after loading the view.
        tabBarController?.delegate = self
    }
        
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func reloadAfterSynced(notification:Notification) {
        
        self.getDataForDashboard(fromDate: fromDate, toDate: toDate, isLifeTime: isLifeTime)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let itemTabbar = UITabBarItem(title: "title_tabbar_button_customer".localized().uppercased(), image: UIImage(named: "tabbar_customer"), selectedImage: UIImage(named: "tabbar_customer")?.withRenderingMode(.alwaysOriginal))
        itemTabbar.tag = 10
        tabBarItem  = itemTabbar
        if isSyncWithLoading {
            isSyncWithLoading = false
            firstSyncData()
        }
        
        if let timer = LocalService.shared.timerSyncToServer {
            if !timer.isValid {
                LocalService.shared.startSyncData()
            }
        }
        
        self.getDataForDashboard()        
    }
    
    func getDataForDashboard(fromDate:NSDate? = nil, toDate:NSDate? = nil, isLifeTime:Bool = true) {
//        print("\(fromDate) - \(toDate) - \(isLifeTime)")
        UserManager.getDataDashboard(fromDate, toDate: toDate, isLifeTime: isLifeTime) {[weak self] data in
            if let _self = self {
                _self.reloadData(data)
            }
        }
    }
    
    func reloadData(_ data:JSON) {
        dashboardView.reload(data)
    }
    
    override func loadView() {
        dashboardView = Bundle.main.loadNibNamed(String(describing: DashboardView.self), owner: self, options: nil)?.first as! DashboardView
        self.view = dashboardView
        dashboardView.onSelectFilter = {[weak self] from, to, lifetime in
            guard let _self = self else {return}
            _self.fromDate = from
            _self.toDate = to
            _self.isLifeTime = lifetime
            _self.getDataForDashboard(fromDate: from, toDate: to,isLifeTime: lifetime)
        }
        
        let topVC = Support.topVC!
        dashboardView.involkeFunctionView = {[weak self] customer,is30 in
            guard let _self = self else {return}
            guard let user = UserManager.currentUser() else {return}
            
            let vc = PopupCustomerFunctionController(nibName: "PopupCustomerFunctionController", bundle: Bundle.main)
            
            _self.preventSyncData()
            topVC.present(vc, animated: false, completion: {
                // load customer, is30: mean display text for block customer have order higher 30 day
                vc.show(customer, is30:is30)
            })
            
            // listern user choose function email
            vc.involkeEmailView = { customer in
                let vc1 = EmailController(nibName: "EmailController", bundle: Bundle.main)
                _self.preventSyncData()
                topVC.present(vc1, animated: true, completion: {
                    vc1.show(from: user.email!, to: customer.email!)
                })
                vc1.onDismissComplete = {[weak self] in
                    guard let _ = self else {return}
                    print("REMOVE PREVENT SYNC DATA")
                    LocalService.shared.isShouldSyncData = nil
                }
            }
            
            // remove prevent sync when this controller has deinit
            vc.ondeinitial = {[weak self] in
                guard let _ = self else {return}
                print("REMOVE PREVENT SYNC DATA")
                LocalService.shared.isShouldSyncData = nil
            }
            
            // reload data when user mark
            vc.needReloadData = {[weak self] in
                guard let _self = self else {return}                
                if is30 {
                    _self.dashboardView.birthdayDontOrder30.reloadData(true, forceRemoveButtonCheck: true)
                } else {
                    _self.dashboardView.birthdayCustomerListView.reloadData(false, forceRemoveButtonCheck: true)
                }
            }
            
        }
    }        
    
    override func configText() {
        self.title = "dashboard".localized().uppercased()
    }        
}

extension DashboardViewController {

    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        if tabBarController.tabBar.selectedItem?.tag == 1 {
            let itemTabbar = UITabBarItem(title: "dashboard".localized().uppercased(), image: UIImage(named: "tabbar_dashboard"), selectedImage: UIImage(named: "tabbar_dashboard")?.withRenderingMode(.alwaysOriginal))
            itemTabbar.tag = 9
            tabBarItem  = itemTabbar
            let nv = self.tabBarController?.viewControllers![1] as! UINavigationController            
            nv.popToRootViewController(animated: true)
        } else {
            if tabBarItem.tag == 10 {
                AppConfig.navigation.changeController(to: CustomerListController(nibName: "CustomerListController", bundle: Bundle.main), on: tabBarController, index: 0)
            }
        }
        return true
    }
}
