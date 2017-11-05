//
//  AppConfig.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 9/20/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import UIKit
import Localize_Swift

class AppConfig: NSObject {
    
    // MARK: - Other
    class setting: AppConfig {
        static func setRememerID(isRemember:Bool) {
            UserDefaults.standard.setValue(isRemember, forKey: "App:RememberUser")
            
        }
        static func isRememberUser() -> Bool {
            if let remember =  UserDefaults.standard.value(forKey: "App:RememberUser") as? Bool {
                return remember
            }
            return false
        }
    }
    
    // MARK: - deeplink
    class deeplink:AppConfig {
        static func setZalo(str:String) {
            UserDefaults.standard.setValue(str, forKey: "AppDeepLink:Zalo")
            
        }
        static func zalo() -> String {
            if let str = UserDefaults.standard.value(forKey: "AppDeepLink:Zalo") {
                return str as! String
            }
            return ""
        }
        
        static func setViber(str:String) {
            UserDefaults.standard.setValue(str, forKey: "AppDeepLink:Viber")
            
        }
        static func viber() -> String {
            if let str = UserDefaults.standard.value(forKey: "AppDeepLink:Viber") {
                return str as! String
            }
            return ""
        }
        
        static func setSkype(str:String) {
            UserDefaults.standard.setValue(str, forKey: "AppDeepLink:Skype")
            
        }
        static func skype() -> String {
            if let str = UserDefaults.standard.value(forKey: "AppDeepLink:Skype") {
                return str as! String
            }
            return ""
        }
        
        static func setFacebook(str:String) {
            UserDefaults.standard.setValue(str, forKey: "AppDeepLink:Facebook")
            
        }
        static func facebook() -> String {
            if let str = UserDefaults.standard.value(forKey: "AppDeepLink:Facebook") {
                return str as! String
            }
            return ""
        }
        
        static func setFacebookGroup(str:String) {
            UserDefaults.standard.setValue(str, forKey: "AppDeepLink:FacebookGroup")
            
        }
        static func facebookGroup() -> String {
            if let str = UserDefaults.standard.value(forKey: "AppDeepLink:FacebookGroup") {
                return str as! String
            }
            return ""
        }
        
        static func setFacebookLinkItunes(str:String) {
            UserDefaults.standard.setValue(str, forKey: "AppDeepLink:FacebookLinkItunes")
            
        }
        static func facebookLinkItunes() -> String {
            if let str = UserDefaults.standard.value(forKey: "AppDeepLink:FacebookLinkItunes") {
                return str as! String
            }
            return ""
        }
        
        static func setViberLinkItunes(str:String) {
            UserDefaults.standard.setValue(str, forKey: "AppDeepLink:ViberLinkItunes")
            
        }
        static func viberLinkItunes() -> String {
            if let str = UserDefaults.standard.value(forKey: "AppDeepLink:ViberLinkItunes") {
                return str as! String
            }
            return ""
        }
        
        static func setZaloLinkItunes(str:String) {
            UserDefaults.standard.setValue(str, forKey: "AppDeepLink:ZaloLinkItunes")
            
        }
        static func zaloLinkItunes() -> String {
            if let str = UserDefaults.standard.value(forKey: "AppDeepLink:ZaloLinkItunes") {
                return str as! String
            }
            return ""
        }
        
        static func setSkypeLinkItunes(str:String) {
            UserDefaults.standard.setValue(str, forKey: "AppDeepLink:SkypeLinkItunes")
            
        }
        static func skypeLinkItunes() -> String {
            if let str = UserDefaults.standard.value(forKey: "AppDeepLink:SkypeLinkItunes") {
                return str as! String
            }
            return ""
        }
    }
    
    // MARK: - language
    class language: AppConfig {
        static var getCurrentLanguage: String {
            if(UserDefaults.standard.string(forKey: "AppConfig:Language") != nil) {
                return UserDefaults.standard.string(forKey: "AppConfig:Language")!
            } else {
                return "en"
            }
        }
        
        static func setLanguage(language:String) {
            let availableLanguages = Localize.availableLanguages()
            if(!availableLanguages.contains(language)) {
                return;
            }
            let currentLanguage = AppConfig.language.getCurrentLanguage
            if(currentLanguage != language) {
                Localize.setCurrentLanguage(language)
                UserDefaults.standard.set(language, forKey: "AppConfig:Language")
                
            }
        }
    }
    
    // MARK: - navigation
    class navigation: AppConfig {
        static func gotoDashboardAfterSigninSuccess() {
            
            LocalNotification.registerForLocalNotification(on: UIApplication.shared)
            
            //start service if signin Success
            LocalService.shared.startSyncData()
            
            let vc:UITabBarController = UITabBarController.init()
            let dashboardC:DashboardViewController =  DashboardViewController()
            dashboardC.isSyncWithLoading = true
            let uinaviVC1 = UINavigationController.init(rootViewController:dashboardC)
            let uinaviVC2 = UINavigationController.init(rootViewController: OrderListController(nibName: "OrderListController", bundle: Bundle.main))
            
            vc.setViewControllers([uinaviVC1,uinaviVC2], animated: true)
            
            let itemTabbar2 = UITabBarItem(title: "title_tabbar_button_order".localized().uppercased(), image: UIImage(named: "tabbar_order"), selectedImage: nil)
            itemTabbar2.tag = 1
            
            uinaviVC2.tabBarItem  = itemTabbar2
           
            AppConfig.navigation.changeRootControllerTo(viewcontroller: vc)
        }
        
        static func changeRootControllerTo(viewcontroller:UIViewController, animated:Bool? = false) {
            let appdelegate = UIApplication.shared.delegate as! AppDelegate
            
            var duration:Double  = 0
            if let animate = animated {
                if animate {duration = 0.3}
            }
        
            if let window = appdelegate.window {
                UIView.transition(with: window, duration: duration, options: .transitionCrossDissolve, animations: {
                    window.rootViewController = viewcontroller
                    appdelegate.window!.makeKeyAndVisible()
                }, completion:nil)
            }
        }
        
        static func changeController(to:UIViewController, on:UITabBarController, index:Int) {
            if let listNaviControllers = on.viewControllers {
                if let navi = listNaviControllers[index] as? UINavigationController {
                    navi.setViewControllers([to], animated: false)
                }
            }
        }
    }
    
    // MARK: - order
    class order: AppConfig {
        static let listStatus:[JSON] = MasterDataManager.getData("ORDER_STATUS").flatMap({["id":$0.data_value,"name":$0.data_name?.localized() ?? ""]})
        
        static let listPaymentStatus:[JSON] = MasterDataManager.getData("PAYMENT_STATUS").flatMap({["id":$0.data_value,"name":$0.data_name?.localized() ?? ""]})
        
        static let listPaymentMethod:[JSON] = MasterDataManager.getData("PAYMENT_TYPE").flatMap({["id":$0.data_value,"name":$0.data_name?.localized() ?? ""]})
        
        static let listTranspoter:[JSON] = MasterDataManager.getData("SHIPPER").flatMap({["id":$0.data_value,"name":$0.data_name?.localized() ?? ""]})
    }
}
