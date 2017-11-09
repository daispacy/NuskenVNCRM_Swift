//
//  AppDelegate.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 9/20/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        UIApplication.shared.setMinimumBackgroundFetchInterval(60)
        
        // set default language
        AppConfig.language.setLanguage(language: "vi")
        
        // start get config
        SyncService.shared.getConfig()                
        
        // config navigation bar
        UINavigationBar.appearance().barTintColor = UIColor(hex:Theme.colorNavigationBar)
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName:UIColor.white,NSFontAttributeName:UIFont(name: Theme.font.normal, size: Theme.fontSize.normal)!]
        UINavigationBar.appearance().isTranslucent = false
        
        // config tabbar
        UITabBar.appearance().unselectedItemTintColor = UIColor.white
        UITabBar.appearance().tintColor = UIColor.white
        UITabBar.appearance().barTintColor = UIColor(hex:"0xe30b7a")
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName:UIColor.white,NSFontAttributeName:UIFont(name: Theme.font.normal, size: Theme.fontSize.small)!], for: UIControlState.selected)
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName:UIColor.white,NSFontAttributeName:UIFont(name: Theme.font.normal, size: Theme.fontSize.small)!], for: UIControlState.normal)
        UITabBar.appearance().isTranslucent = false
        
        window = UIWindow.init(frame: UIScreen.main.bounds)
        
        // set directory for coredata
        CoreDataStack.sharedInstance.applicationDocumentsDirectory()
        
        if let ww = window {
            
            if UserManager.currentUser() != nil && AppConfig.setting.isRememberUser(){
                AppConfig.navigation.gotoDashboardAfterSigninSuccess()
            } else {
                let vc:AuthenticViewController = AuthenticViewController.init(type: .AUTH_LOGIN)
                ww.rootViewController = vc
                ww.makeKeyAndVisible()
            }
        }
        
        return true
    }
    
    // MARK: Deeplinks
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return Deeplinker.handleDeeplink(url: url)
    }
    // MARK: Universal Links
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
            if let url = userActivity.webpageURL {
                return Deeplinker.handleDeeplink(url: url)
            }
        }
        return false
    }
    
    // Support for background fetch
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if (UIApplication.shared.applicationState == .active) {
            completionHandler(UIBackgroundFetchResult.noData)
            print("PREVENT SYNC BACKGROUND WHEN APP ACTIVE")
            return
        }
        print("start fecth")        
        LocalService.shared.startSyncDataBackground {
            completionHandler(UIBackgroundFetchResult.newData)
            print("end fecth")
        }
        completionHandler(UIBackgroundFetchResult.noData)
        
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        let aps = userInfo["aps"] as! [String: AnyObject]
        
        // 1
        if aps["content-available"] as? Int == 1 {
            print("start fecth from remote notification")
            LocalService.shared.startSyncDataBackground {
//                LocalNotification.dispatchlocalNotification(with: "Data", body: "sync_data".localized(), at: Date())
                completionHandler(.newData)
                print("end fecth from remote notification")
            }
        } else  {
            completionHandler(.newData)
        }
    }
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        
        let token = tokenParts.joined()
        if let user = UserManager.currentUser() {
            user.device_token = "\(token)"
            user.synced = false
            UserManager.save()
        }
    }
    
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        LocalService.shared.timerSyncToServer?.invalidate()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        if let _ = UserManager.currentUser() {
            LocalService.shared.startSyncData()
        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        // handle any deeplink
        Deeplinker.checkDeepLink()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        
        CoreDataStack.sharedInstance.saveContext()
    }
}

