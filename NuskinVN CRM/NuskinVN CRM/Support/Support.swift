//
//  Support.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 9/22/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import UIKit

class Support: NSObject {
    
    static func isValidEmailAddress(emailAddressString: String) -> Bool {
        var returnValue = true
        let emailRegEx = "[A-Z0-9a-z.-_]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,3}"
        
        do {
            let regex = try NSRegularExpression(pattern: emailRegEx)
            let nsString = emailAddressString as NSString
            let results = regex.matches(in: emailAddressString, range: NSRange(location: 0, length: nsString.length))
            
            if results.count == 0
            {
                returnValue = false
            }
            
        } catch let error as NSError {
            print("invalid regex: \(error.localizedDescription)")
            returnValue = false
        }
        
        return  returnValue
    }
    
    static func isValidPassword(password: String) -> Bool {
        var returnValue = true
        if(password.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines).characters.count < 6) {
            returnValue = false
        }
        
        return  returnValue
    }
    
    static func isValidVNID(vnid: String) -> Bool {
        var returnValue = false
        
        if(vnid.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines).characters.count > 3) {
            let index = vnid.index(vnid.startIndex, offsetBy: 2)
            let preffix = vnid.substring(to: index)
            if(preffix == "VN") {
                returnValue = true
            }
        }
        
        return  returnValue
    }
}
