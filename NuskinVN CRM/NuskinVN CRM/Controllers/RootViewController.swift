//
//  RootViewController.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 9/20/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import UIKit
import CoreData
import Localize_Swift
import RxSwift
import RxCocoa

class RootViewController: UIViewController {
    
    var onDidLoad:(()->Bool)?
    let disposeBag:DisposeBag = DisposeBag()
    var leftButtonMenu:UIButton!
    var rightButtonMenu:UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _ = onDidLoad?()
    }
    
    
    // Add an observer for LCLLanguageChangeNotification on viewWillAppear. This is posted whenever a language changes and allows the viewcontroller to make the necessary UI updated. Very useful for places in your app when a language change might happen.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        NotificationCenter.default.addObserver(self, selector: #selector(configText), name: NSNotification.Name( LCLLanguageChangeNotification), object: nil)
    }
    
    // Remove the LCLLanguageChangeNotification on viewWillDisappear
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        NotificationCenter.default.removeObserver(self)
        if LocalService.shared.isShouldSyncData != nil{
            print("REMOVE CHECK PREVENT SYNC")
            LocalService.shared.isShouldSyncData = nil
        }
    }
    
    func configText() {
        
    }
    
    deinit {
        print("\(String(describing: self.self)) dealloc")
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
                Support.popup.showMenu(items: ["sync_data".localized(),
                                               "logout".localized()],
                                       sender: self,
                                       view: leftButtonMenu,
                                       selector: #selector(self.menuItemLeftPress(menuItem:)))
            } else {
                let vc = UserProfileController(nibName: "UserProfileController", bundle: Bundle.main)
                self.navigationController?.present(vc, animated: true, completion: {
                    vc.onDidRotate = {
                        [weak self] in
                        guard let _self = self else {return}
                        _self.showTabbar(false)
                    }
                    vc.onDismissComplete = {[weak self] in
                        guard let _self = self else {return}
                        _self.showTabbar(true)
                    }
                })
            }
        }
    }
    
    func preventSyncData() {
        // prevent sync data while working with order
        print("REGISTER PREVENT SYNC")
        LocalService.shared.isShouldSyncData = {[weak self] in
            if let _ = self {
                return false
            }
            return true
        }
    }
    
    func firstSyncData() {
        
        let vc = SyncDataController(nibName: "SyncDataController", bundle: Bundle.main) as SyncDataController
        self.navigationController?.present(vc, animated: false, completion: {
            vc.startSync(true)
        })
    }
    
    func addDefaultMenu (_ onlyLeft:Bool = false) {
        // Do any additional setup after loading the view.
        leftButtonMenu = UIButton(type: .custom)
        leftButtonMenu.setImage(UIImage(named: "menu_white_icon"), for: .normal)
        leftButtonMenu.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        leftButtonMenu.addTarget(self, action: #selector(self.menuPress(sender:)), for: .touchUpInside)
        let item1 = UIBarButtonItem(customView: leftButtonMenu)
        self.navigationItem.leftBarButtonItem  = item1
        
        if !onlyLeft {
            // Do any additional setup after loading the view.
            rightButtonMenu = UIButton(type: .custom)
            rightButtonMenu.setImage(UIImage(named: "menu_profile_white_76"), for: .normal)
            rightButtonMenu.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            rightButtonMenu.addTarget(self, action: #selector(self.menuPress(sender:)), for: .touchUpInside)
            let item2 = UIBarButtonItem(customView: rightButtonMenu)
            self.navigationItem.rightBarButtonItem  = item2
        }
    }
    
    @objc func menuPress(sender:UIButton) {
        
        if( sender.isEqual(leftButtonMenu) == true) {
            Support.popup.showMenu(items: ["sync_data".localized(),
                                           "logout".localized()],
                                   sender: self,
                                   view: sender,
                                   selector: #selector(self.menuItemLeftPress(menuItem:)))
        } else {
            let vc = UserProfileController(nibName: "UserProfileController", bundle: Bundle.main)
            self.navigationController?.present(vc, animated: true, completion: {[weak self] in
                guard let _self = self else {return}
                _self.showTabbar(false)
                vc.onDidRotate = {
                    [weak self] in
                    guard let _self = self else {return}
                    _self.showTabbar(false)
                }
            })
            vc.onDismissComplete = {[weak self] in
                guard let _self = self else {return}
                _self.showTabbar(true)
            }
        }
        
        objc_setAssociatedObject(self, &BlockCustomerView_associated, sender, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    @objc fileprivate func menuItemLeftPress(menuItem:KxMenuItem) {
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
    
    @objc fileprivate func menuItemRightPress(menuItem:KxMenuItem) {
        
    }
    
    func showTabbar(_ isShow:Bool = true) {
        guard let _tabbaController = self.tabBarController else { return }
        let frame = _tabbaController.tabBar.frame;
        let height = frame.size.height;
        let offsetY = isShow ? 0-height : height;
        
        // zero duration means no animation
        let duration = 0.3;
        UIView.animate(withDuration: duration) {
            
            _tabbaController.tabBar.frame = frame.offsetBy(dx:0,dy:offsetY)
        }
    }
}
