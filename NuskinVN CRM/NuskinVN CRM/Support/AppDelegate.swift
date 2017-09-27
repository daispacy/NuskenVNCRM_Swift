//
//  AppDelegate.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 9/20/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        AppConfig.setLanguage(language: AppConfig.getCurrentLanguage)
        
        UINavigationBar.appearance().barTintColor = UIColor(hex:Theme.colorNavigationBar)
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName:UIColor.white]
        
        UITabBar.appearance().backgroundColor = UIColor(hex:Theme.colorBottomBar)
        UITabBar.appearance().tintColor = UIColor(hex:Theme.colorBottomBar)
//        UITabBar.appearance().
        
        window = UIWindow.init(frame: UIScreen.main.bounds)
        
        if let ww = window {
            
            let isLogin:Bool = false
            if !isLogin {
                let vc:AuthenticViewController = AuthenticViewController.init(type: .AUTH_LOGIN)
                ww.rootViewController = vc
                
            } else {
                
                let vc:UITabBarController = UITabBarController.init()
                let uinaviVC = UINavigationController.init(rootViewController: DashboardViewController())
                let uinaviVC2 = UINavigationController.init(rootViewController: OrderManagerViewController())
                vc.setViewControllers([uinaviVC,uinaviVC2], animated: true)
                
                let itemTabbar = UITabBarItem(title: "title_tabar_button_order".localized(), image: UIImage(named: "menu_white_icon"), selectedImage: UIImage(named: "menu_white_icon"))
                uinaviVC2.tabBarItem  = itemTabbar
                
                ww.rootViewController = vc
            }
            ww.makeKeyAndVisible()
        }
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.        
    }
}

