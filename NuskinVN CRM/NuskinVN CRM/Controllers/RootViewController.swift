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
    var onReloadData:(()->Void)?
    let disposeBag:DisposeBag = DisposeBag()
    var leftButtonMenu:UIButton!
    var rightButtonMenu:UIButton!
    var isTabbarShow:Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _ = onDidLoad?()
        self.navigationController?.hidesBottomBarWhenPushed = true
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

    func refreshAvatar() {
        _ = rightButtonMenu.subviews.map({ (view) in
            if view.tag == 1111 {
                view.removeFromSuperview()
            }
        })
        let imageView:UIImageView = UIImageView(image: UIImage(named: "menu_profile_white_76"))
        imageView.tag = 1111
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 15
        if let user = UserManager.currentUser() {
            if let avaStr = user.avatar {
                if let urlAvatar = user.urlAvatar {
                    rightButtonMenu.imageView!.layer.cornerRadius = 15;
                    if avaStr.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines).characters.count > 0 {
                        if avaStr.contains(".jpg") || avaStr.contains(".png"){
                            imageView.loadImageUsingCacheWithURLString(urlAvatar, placeHolder: nil)
                        } else {
                            if let dataDecoded : Data = Data(base64Encoded: avaStr, options: .ignoreUnknownCharacters) {
                                let decodedimage = UIImage(data: dataDecoded)
                                imageView.image = decodedimage
                            }
                        }
                    }
                } else {
                    if let dataDecoded : Data = Data(base64Encoded: avaStr, options: .ignoreUnknownCharacters) {
                        let decodedimage = UIImage(data: dataDecoded)
                        imageView.image = decodedimage
                    }
                }
            }
        }
        rightButtonMenu.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(equalToConstant: 30).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        imageView.centerXAnchor.constraint(equalTo: rightButtonMenu.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: rightButtonMenu.centerYAnchor).isActive = true
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
                                               "support".localized(),
                                               "logout".localized()],
                                       sender: self,
                                       view: leftButtonMenu,
                                       selector: #selector(self.menuItemLeftPress(menuItem:)))
            } else {
                let vc = UserProfileController(nibName: "UserProfileController", bundle: Bundle.main)
                let nv = UINavigationController(rootViewController: vc)
                Support.topVC?.present(nv, animated: true, completion: {
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
        Support.topVC?.present(vc, animated: false, completion: {
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
            let imageView:UIImageView = UIImageView(image: UIImage(named: "menu_profile_white_76"))
            imageView.tag = 1111
            imageView.contentMode = .scaleAspectFill
            imageView.layer.masksToBounds = true
            imageView.layer.cornerRadius = 15
            if let user = UserManager.currentUser() {
                if let avaStr = user.avatar {
                    if let urlAvatar = user.urlAvatar {                        
                        if avaStr.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines).characters.count > 0 {
                            if avaStr.contains(".jpg") || avaStr.contains(".png"){
                                imageView.loadImageUsingCacheWithURLString(urlAvatar, placeHolder: nil)
                            } else {
                                if let dataDecoded : Data = Data(base64Encoded: avaStr, options: .ignoreUnknownCharacters) {
                                    let decodedimage = UIImage(data: dataDecoded)
                                    imageView.image = decodedimage
                                }
                            }
                        }
                    } else {
                        if let dataDecoded : Data = Data(base64Encoded: avaStr, options: .ignoreUnknownCharacters) {
                            let decodedimage = UIImage(data: dataDecoded)
                            imageView.image = decodedimage
                        }
                    }
                }
            }
            rightButtonMenu.addSubview(imageView)
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.widthAnchor.constraint(equalToConstant: 30).isActive = true
            imageView.heightAnchor.constraint(equalToConstant: 30).isActive = true
            imageView.centerXAnchor.constraint(equalTo: rightButtonMenu.centerXAnchor).isActive = true
            imageView.centerYAnchor.constraint(equalTo: rightButtonMenu.centerYAnchor).isActive = true
            
            rightButtonMenu.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            rightButtonMenu.addTarget(self, action: #selector(self.menuPress(sender:)), for: .touchUpInside)
            let item2 = UIBarButtonItem(customView: rightButtonMenu)
            self.navigationItem.rightBarButtonItem  = item2
        }
    }
    
    @objc func menuPress(sender:UIButton) {
        
        if( sender.isEqual(leftButtonMenu) == true) {
            Support.popup.showMenu(items: ["sync_data".localized(),
                                           "support".localized(),
                                           "logout".localized()],
                                   sender: self,
                                   view: sender,
                                   selector: #selector(self.menuItemLeftPress(menuItem:)))
        } else {
            let vc = UserProfileController(nibName: "UserProfileController", bundle: Bundle.main)
            let nv = UINavigationController(rootViewController: vc)
            Support.topVC?.present(nv, animated: true, completion: {[weak self] in
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
                _self.refreshAvatar()
            }
        }
        
        objc_setAssociatedObject(self, &BlockCustomerView_associated, sender, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    @objc fileprivate func menuItemLeftPress(menuItem:KxMenuItem) {
        if menuItem.title == "logout".localized() {
            LocalService.shared.timerSyncToServer?.invalidate()
            UserManager.reset()
            let vc:AuthenticViewController = AuthenticViewController.init(type: .AUTH_LOGIN)
            AppConfig.navigation.changeRootControllerTo(viewcontroller: vc, animated: false)
        } else if menuItem.title == "sync_data".localized() {
            //            let vc = SyncDataController(nibName: "SyncDataController", bundle: Bundle.main) as SyncDataController
            //            self.present(vc, animated: true, completion: {
            //                vc.startSync()
            //            })
            firstSyncData()
        } else if menuItem.title == "support".localized() {
            let vc1 = EmailController(nibName: "EmailController", bundle: Bundle.main)
            Support.topVC!.present(vc1, animated: true, completion: {
                vc1.show(from: "", to: "48hrs_reply_vietnam@nuskin.com")
            })
        }
    }
    
    @objc fileprivate func menuItemRightPress(menuItem:KxMenuItem) {
        
    }
    
    func showTabbar(_ isShow:Bool = true) {
        if isTabbarShow == isShow {return}
        isTabbarShow = isShow
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
