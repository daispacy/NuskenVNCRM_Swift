//
//  DashboardViewController.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 9/22/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import UIKit

class DashboardViewController: RootViewController, UITabBarControllerDelegate {
    
    fileprivate var dashboardView:DashboardView!

    var isSyncWithLoading:Bool = false
    
    var fromDate:NSDate? = nil
    var toDate:NSDate? = nil
    var isLifeTime: Bool = true
    var isStartingTutorial:Bool = false // prevent reload data when tutorial
    
    // MARK: - INIT
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configText()
        
        // add menu from root
        addDefaultMenu()

        // Do any additional setup after loading the view.
        tabBarController?.delegate = self
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func reloadAfterSynced(notification:Notification) {
        if let tabbarController = self.tabBarController {
            if let vc = tabbarController.selectedViewController as? UINavigationController{
                if let vChild = vc.viewControllers.first {
                    if vChild.isEqual(self) {
                        if !self.isStartingTutorial {
                            self.getDataForDashboard(fromDate: fromDate, toDate: toDate, isLifeTime: isLifeTime)
                        }
                    }
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let itemTabbar = UITabBarItem(title: "title_tabbar_button_customer".localized().uppercased(), image: UIImage(named: "tabbar_customer"), selectedImage: UIImage(named: "tabbar_customer")?.withRenderingMode(.alwaysOriginal))
        itemTabbar.tag = 10
        tabBarItem  = itemTabbar
        
        dashboardView.scrollView.setContentOffset(CGPoint.zero, animated: true)
        
//        if isSyncWithLoading {
//            isSyncWithLoading = false
////            firstSyncData()
//            if !Support.connectivity.isConnectedToInternet() {
//                self.getDataForDashboard(fromDate: fromDate, toDate: toDate, isLifeTime: isLifeTime)
//            }
//        } else {
//        if shouldReloadDashboardData {
//            self.getDataForDashboard(fromDate: fromDate, toDate: toDate, isLifeTime: isLifeTime)
//        }
//        }
        
//        if let timer = LocalService.shared.timerSyncToServer {
//            if !timer.isValid {
//                LocalService.shared.startSyncData()
//            }
//        }
        self.getDataForDashboard(fromDate: fromDate, toDate: toDate, isLifeTime: isLifeTime)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        if shouldReloadDashboardData {
//
//        }
    }
    
    // MARK: - private
    func getDataForDashboard(fromDate:NSDate? = nil, toDate:NSDate? = nil, isLifeTime:Bool = true) {
//        print("\(fromDate) - \(toDate) - \(isLifeTime)")
        dashboardView.loading(true)
        UserManager.getDataDashboard(fromDate, toDate: toDate, isLifeTime: isLifeTime) {[weak self] data in
            if let _self = self {
                DispatchQueue.main.async {
                    _self.dashboardView.loading(false)
                    _self.reloadData(data)
                    
                    if _self.isStartingTutorial {return}
                    
                    if !AppConfig.setting.isShowTutorial(with: DASHBOARD_CONTROLLER_SCENE) {
                        _self.startTutorial(1)
                    } else {
                        _self.checkNextTutorial()
                    }
                }
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
        
        dashboardView.gotoOrderList = {[weak self] status in
            guard let _self = self else {return}
            let itemTabbar = UITabBarItem(title: "title_tabbar_button_dashboard".localized().uppercased(), image: UIImage(named: "tabbar_customer"), selectedImage: UIImage(named: "tabbar_dashboard")?.withRenderingMode(.alwaysOriginal))
            itemTabbar.tag = 9
            _self.tabBarItem  = itemTabbar
            let nv = _self.tabBarController?.viewControllers![1] as! UINavigationController
            let vc = nv.viewControllers[0] as! OrderListController
            vc.isGotoFromCustomerList = true
            vc.customer_id = []
            vc.status = status
            if let from = _self.fromDate, let to = _self.toDate {
                vc.fromDate = from
                vc.toDate = to
                vc.isLifeTime = _self.isLifeTime
                vc.menuDashboard.setDate(_self.dashboardView.menuDashboard.year,_self.dashboardView.menuDashboard.month, _self.dashboardView.menuDashboard.week, _self.dashboardView.menuDashboard.day)
            }
            _self.tabBarController?.selectedIndex = 1
        }
        
        dashboardView.gotoOrderListByCustomerID = {[weak self] listIDs in
            guard let _self = self else {return}
            let itemTabbar = UITabBarItem(title: "title_tabbar_button_dashboard".localized().uppercased(), image: UIImage(named: "tabbar_dashboard"), selectedImage: UIImage(named: "tabbar_dashboard")?.withRenderingMode(.alwaysOriginal))
            itemTabbar.tag = 9
            _self.tabBarItem  = itemTabbar
            let nv = _self.tabBarController?.viewControllers![1] as! UINavigationController
            let vc = nv.viewControllers[0] as! OrderListController
            vc.isGotoFromCustomerList = true
            vc.customer_id = listIDs
            _self.tabBarController?.selectedIndex = 1
        }
        
        let topVC = Support.topVC!
        dashboardView.involkeFunctionView = {[weak self] customer,is30 in
            guard let _self = self else {return}
            guard let user = UserManager.currentUser() else {return}
            
            let vc = PopupCustomerFunctionController(nibName: "PopupCustomerFunctionController", bundle: Bundle.main)
            let nv = UINavigationController(rootViewController: vc)
            vc.navigationController?.setNavigationBarHidden(true, animated: false)
            _self.preventSyncData()
            topVC.present(nv, animated: false, completion: {
                // load customer, is30: mean display text for block customer have order higher 30 day
                vc.show(customer, is30:is30)
            })
            
            // listern user choose function email
            vc.involkeEmailView = { customer in
                let vc1 = EmailController(nibName: "EmailController", bundle: Bundle.main)
                _self.preventSyncData()
                let nv = UINavigationController(rootViewController: vc1)
                vc1.navigationController?.setNavigationBarHidden(true, animated: false)
                topVC.present(nv, animated: true, completion: {
                    vc1.show(from: user.email!, to: customer.email)
                })
                vc1.onDismissComplete = {[weak self] in
                    guard let _ = self else {return}
                    print("REMOVE PREVENT SYNC DATA")
                    LocalService.shared.isShouldSyncData = nil
                }
            }
            
            vc.gotoOrderList = {customer in
                let itemTabbar = UITabBarItem(title: "title_tabbar_button_dashboard".localized().uppercased(), image: UIImage(named: "tabbar_customer"), selectedImage: UIImage(named: "tabbar_dashboard")?.withRenderingMode(.alwaysOriginal))
                itemTabbar.tag = 9
                _self.tabBarItem  = itemTabbar
                let nv = _self.tabBarController?.viewControllers![1] as! UINavigationController
                let vc = nv.viewControllers[0] as! OrderListController
                vc.isGotoFromCustomerList = true
                vc.customer_id = [customer.id,customer.local_id]
                _self.tabBarController?.selectedIndex = 1
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

// MARK: - Tabbar Delegate
extension DashboardViewController {

    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        if tabBarController.tabBar.selectedItem?.tag == 1 {
            let itemTabbar = UITabBarItem(title: "dashboard".localized().uppercased(), image: UIImage(named: "tabbar_dashboard"), selectedImage: UIImage(named: "tabbar_dashboard")?.withRenderingMode(.alwaysOriginal))
            itemTabbar.tag = 9
            tabBarItem  = itemTabbar
            if let nv = self.tabBarController?.viewControllers?[1] as? UINavigationController{
                nv.setViewControllers([OrderListController(nibName: "OrderListController", bundle: Bundle.main)], animated: false)
            }
        } else {
            if tabBarItem.tag == 10 {
                AppConfig.navigation.changeController(to: CustomerListController(nibName: "CustomerListController", bundle: Bundle.main), on: tabBarController, index: 0)
            }
        }
        return true
    }
}

// MARK: - ShowCase
extension DashboardViewController: MaterialShowcaseDelegate {
    
    func checkNextTutorial() {
        dashboardView.startTutorial {[weak self] in
            guard let _self = self else {return}
            _self.isStartingTutorial = false
        }
    }
    
    // MARK: - init showcase
    func startTutorial(_ step:Int = 1) {
        return
        // showcase
        isStartingTutorial = true
        configShowcase(MaterialShowcase(), step) { showcase, shouldShow in
            if shouldShow {
                showcase.delegate = self
                showcase.show(completion: nil)
            }
        }
    }
    
    func configShowcase(_ showcase:MaterialShowcase,_ step:Int = 1,_ shouldShow:((MaterialShowcase,Bool)->Void)) {
        if step == 1 {
            showcase.setTargetView(tabBar: self.tabBarController!.tabBar, itemIndex: 0)
            showcase.primaryText = ""
            showcase.identifier = TABBAR_BUTTON_CUSTOMER
            showcase.secondaryText = "click_here_go_to_view_customers".localized()
            shouldShow(showcase,true)
        } else if step == 2 {
            showcase.setTargetView(tabBar: self.tabBarController!.tabBar, itemIndex: 1)
            showcase.primaryText = ""
            showcase.identifier = TABBAR_BUTTON_ORDER
            showcase.secondaryText = "click_here_go_to_view_orders".localized()
            shouldShow(showcase,true)
        } else if step == 3 {
            showcase.setTargetView(barButtonItem: self.navigationItem.leftBarButtonItem!)
            showcase.primaryText = ""
            showcase.identifier = NAVIGATION_BUTTON_MENU
            showcase.secondaryText = "click_here_open_menu".localized()
            shouldShow(showcase,true)
        } else if step == 4 {
            showcase.setTargetView(barButtonItem: self.navigationItem.rightBarButtonItems!.last!)
            showcase.primaryText = ""
            showcase.identifier = NAVIGATION_BUTTON_NEWS
            showcase.secondaryText = "click_here_open_news".localized()
            shouldShow(showcase,true)
        } else if step == 5 {
            showcase.setTargetView(barButtonItem: self.navigationItem.rightBarButtonItems!.first!)
            showcase.primaryText = ""
            showcase.identifier = NAVIGATION_BUTTON_PROFILE
            showcase.secondaryText = "click_here_open_profile".localized()
            shouldShow(showcase,true)
        } else {
            shouldShow(showcase,false)
            if step > 5 {
                AppConfig.setting.setFinishShowcase(key: DASHBOARD_CONTROLLER_SCENE)
                checkNextTutorial()
            }
        }
    }
    
    // MARK: - showcase delegate
//    func showCaseWillDismiss(showcase: MaterialShowcase) {
//        print("Showcase \(showcase.identifier) will dismiss.")
//    }
    func showCaseDidDismiss(showcase: MaterialShowcase) {
        if let step = showcase.identifier {
            if let s = Int(step) {
                let ss = s + 1
                startTutorial(ss)
            }
        }
        
    }
}
