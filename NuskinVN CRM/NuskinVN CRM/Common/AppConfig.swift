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
            UserDefaults.standard.synchronize()
        }
        static func isRememberUser() -> Bool {
            if let remember =  UserDefaults.standard.value(forKey: "App:RememberUser") as? Bool {
                return remember
            }
            return false
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
                UserDefaults.standard.synchronize()
            }
        }
    }
    
    // MARK: - navigation
    class navigation: AppConfig {
        static func gotoDashboardAfterSigninSuccess() {
            
            let vc:UITabBarController = UITabBarController.init()
            
            let uinaviVC1 = UINavigationController.init(rootViewController: DashboardViewController())
            let uinaviVC2 = UINavigationController.init(rootViewController: OrderManagerViewController())
            
            vc.setViewControllers([uinaviVC1,uinaviVC2], animated: true)
            
            let itemTabbar2 = UITabBarItem(title: "title_tabbar_button_order".localized(), image: UIImage(named: "tabbar_order"), selectedImage: nil)
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
}
