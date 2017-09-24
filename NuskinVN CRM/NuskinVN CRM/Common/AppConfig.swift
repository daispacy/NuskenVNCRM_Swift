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
        let currentLanguage = AppConfig.getCurrentLanguage
        if(currentLanguage != language) {
            Localize.setCurrentLanguage(language)
            UserDefaults.standard.set(language, forKey: "AppConfig:Language")
            UserDefaults.standard.synchronize()
        }
    }
}
