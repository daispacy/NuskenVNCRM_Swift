//
//  DashboardViewController.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 9/22/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import UIKit

class DashboardViewController: RootViewController, DashboardViewDelegate, UITabBarControllerDelegate {
    
    private var dashboardView:DashboardView!

    var isSyncWithLoading:Bool = false
    
    // MARK: - INIT
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadAfterSynced(notification:)), name: Notification.Name("SyncData:Customer"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadAfterSynced(notification:)), name: Notification.Name("SyncData:Group"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadAfterSynced(notification:)), name: Notification.Name("SyncData:Order"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadAfterSynced(notification:)), name: Notification.Name("SyncData:OrderItem"), object: nil)
        
        
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
        UserManager.getDataDashboard {[weak self] data in
            if let _self = self {
                _self.reloadData(data)
            }
        }
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
        
        UserManager.getDataDashboard {[weak self] data in
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
        dashboardView.delegate_ = self
        self.view = dashboardView
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
        } else {
            if tabBarItem.tag == 10 {
                AppConfig.navigation.changeController(to: CustomerListController(nibName: "CustomerListController", bundle: Bundle.main), on: tabBarController, index: 0)
            }
        }
        return true
    }
}
