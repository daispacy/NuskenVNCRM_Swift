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
    private var leftButtonMenu:UIButton!
    private var rightButtonMenu:UIButton!

    var isSyncWithLoading:Bool = false
    
    // MARK: - INIT
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadAfterSynced(notification:)), name: Notification.Name("SyncData:Customer"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadAfterSynced(notification:)), name: Notification.Name("SyncData:Group"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadAfterSynced(notification:)), name: Notification.Name("SyncData:Order"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadAfterSynced(notification:)), name: Notification.Name("SyncData:OrderItem"), object: nil)
        
        
        configText()
        
        // Do any additional setup after loading the view.
        leftButtonMenu = UIButton(type: .custom)
        leftButtonMenu.setImage(UIImage(named: "menu_white_icon"), for: .normal)
        leftButtonMenu.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        leftButtonMenu.addTarget(self, action: #selector(self.menuPress(sender:)), for: .touchUpInside)
        let item1 = UIBarButtonItem(customView: leftButtonMenu)
//        self.navigationItem.leftBarButtonItem  = item1
        
        // Do any additional setup after loading the view.
        rightButtonMenu = UIButton(type: .custom)
        rightButtonMenu.setImage(UIImage(named: "menu_white_icon"), for: .normal)
        rightButtonMenu.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        rightButtonMenu.addTarget(self, action: #selector(self.menuPress(sender:)), for: .touchUpInside)
        let item2 = UIBarButtonItem(customView: rightButtonMenu)
        self.navigationItem.rightBarButtonItem  = item2
        
        // Do any additional setup after loading the view.
        tabBarController?.delegate = self
    }

    func firstSyncData() {
        
        let vc = SyncDataController(nibName: "SyncDataController", bundle: Bundle.main) as SyncDataController
        self.navigationController?.present(vc, animated: false, completion: {
            vc.startSync(true)
        })
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
                LocalService.shared.startSyncDataBackground()
            }
        }
//        SyncService.shared.getDashboard(completion: {[weak self] resut in
//            if let _self = self {
//                switch resut {
//                case .success(let resut):
//                    _self.reloadData(resut)
//                case .failure(_):
//                    print("failed get data for dashboard")
//                }
//            }
//        })
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
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "App:DeviceRotate"), object: nil)
        
        guard let view:UIView = objc_getAssociatedObject(self, &BlockCustomerView_associated) as? UIView else {
            return
        }
        
        if !(KxMenu.sharedMenu().menuView == nil) {

            if(KxMenu.sharedMenu().menuView.frame.origin.y > UIScreen.main.bounds.size.height - KxMenu.sharedMenu().menuView.frame.size.height) {
                KxMenu.sharedMenu().dismissMenu()
                return
            }
            
            if( view.isEqual(leftButtonMenu) == true) {
                Support.popup.showMenu(items: ["popup_menu_left_item".localized()],
                                      sender: self,
                                      view: leftButtonMenu,
                                      selector: #selector(self.menuItemLeftPress(menuItem:)))
            } else {
                Support.popup.showMenu(items: ["sync_data".localized(),
                                               "logout".localized()],
                                      sender: self,
                                      view: rightButtonMenu,
                                      selector: #selector(self.menuItemRightPress(menuItem:)))
            }
        }
    }
    
    override func configText() {
        self.title = "dashboard".localized().uppercased()
    }
    
    // MARK: - MENUBAR ENVENT
    @objc func menuPress(sender:UIButton) {
        
        if( sender.isEqual(leftButtonMenu) == true) {
            Support.popup.showMenu(items: ["popup_menu_left_item".localized()],
                                  sender: self,
                                  view: leftButtonMenu,
                                  selector: #selector(self.menuItemLeftPress(menuItem:)))
        } else {
            Support.popup.showMenu(items: ["sync_data".localized(),
                                           "logout".localized()],
                                  sender: self,
                                  view: rightButtonMenu,
                                  selector: #selector(self.menuItemRightPress(menuItem:)))
        }
        
        objc_setAssociatedObject(self, &BlockCustomerView_associated, sender, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    @objc fileprivate func menuItemLeftPress(menuItem:KxMenuItem) {
        
    }
    
    @objc fileprivate func menuItemRightPress(menuItem:KxMenuItem) {
        if menuItem.title == "logout".localized() {
            UserManager.reset()
            let vc:AuthenticViewController = AuthenticViewController.init(type: .AUTH_LOGIN)
            AppConfig.navigation.changeRootControllerTo(viewcontroller: vc, animated: false)
        } else if menuItem.title == "sync_data".localized() {
//            let vc = SyncDataController(nibName: "SyncDataController", bundle: Bundle.main) as SyncDataController
//            self.present(vc, animated: true, completion: {
//                vc.startSync()
//            })
            firstSyncData()
        }
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
