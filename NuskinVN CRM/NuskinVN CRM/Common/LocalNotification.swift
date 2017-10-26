//
//  LocalNotification.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 10/26/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import UIKit
import UserNotifications

class LocalNotification: NSObject {
    
    class func registerForLocalNotification(on application:UIApplication) {
        // Override point for customization after application launch.
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            // Enable or disable features based on authorization.
            if((error == nil)) {
                print("Request authorization failed!")
            }
            else {
                print("Request authorization succeeded!")
            }
        }
    }
    
    class func dispatchlocalNotification(with title: String, body: String, userInfo: [AnyHashable: Any]? = nil, at date:Date) {
        
        // Swift
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default()
        content.categoryIdentifier = "notify-test"
        
        let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest.init(identifier: "notify-test", content: content, trigger: trigger)
        
        let center = UNUserNotificationCenter.current()
        center.add(request)
        
        print("WILL DISPATCH LOCAL NOTIFICATION AT ", date)
        
    }
}
