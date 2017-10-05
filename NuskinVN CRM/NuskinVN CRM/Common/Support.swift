//
//  Support.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 9/22/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import UIKit
import FontAwesomeKit

class Support: NSObject {
    
    // MARK: - validate
    class validate: Support {
        
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
    
    // MARK: - popup
    class popup: NSObject {
        static func showMenu(items:[String],
                             sender:Any,
                             view:UIView,
                             selector:Selector,
                             showArrow:Bool? = false) {
            
            let sArrow = showArrow!
            var arrowSize:CGFloat = 4
            var showShadow:Bool = false
            
            if(sArrow) {
                arrowSize = 9
                showShadow = true
                
            }
            
            var menuArray:[KxMenuItem] = []
            
            for item in items {
                menuArray .append(KxMenuItem(title: item, image: nil, target: sender as AnyObject, action: selector))
            }
            
            let options = OptionalConfiguration(
                
                font: UIFont.boldSystemFont(ofSize: 16),
                
                arrowSize: arrowSize,
                
                marginXSpacing: 7,
                
                marginYSpacing: 7,
                
                intervalSpacing: 15,
                
                menuCornerRadius: 6,
                
                maskToBackground: false,
                
                shadowOfMenu: showShadow,
                
                hasSeperatorLine: true,
                
                seperatorLineHasInsets: false,
                
                textColor: Color(R: 255,G: 255, B: 255),
                
                menuBackgroundColor: Color(R: 227.0/255.0,G: 11.0/255.0, B: 122.0/255.0),
                
                menuBackgroundColor1: Color(R: 52.0/255.0,G: 154.0/255.0, B: 213.0/255.0)
                
            )
            
            let rect = view.superview!.convert(view.frame.origin, to: nil)
            
            KxMenu.showMenuInView(view: UIApplication.shared.keyWindow!, fromRect: CGRect(origin: CGPoint(x:rect.x , y: rect.y), size: CGSize(width: view.frame.size.width, height:view.frame.size.height)), menuItems: menuArray, withOptions: options)
            KxMenu.sharedMenu().menuView.target = sender
        }
        
        static func showAlert(message:String,buttons:Array<String> ,vc:UIViewController, onAction:@escaping ((Int)-> Void)) {
            let test = CustomAlertController(nibName: "CustomAlertController", bundle: Bundle.main)
            vc.present(test, animated: false, completion: {done in
                test.message(message: message, buttons: buttons, select: {
                    i in
                    onAction(i)
                })
            })
        }
    }
    
    // MARK: - Image
    class image: Support {
        static func iconFont(code:String,size:CGFloat,color:String? = "0xffffff") -> UIImage? {
            
            if let checkIcon = FAKFontAwesome.init(code: code, size: size) {
                if let cl = color {
                    checkIcon.addAttribute(NSForegroundColorAttributeName, value: UIColor(hex:cl))
                }
                return checkIcon.image(with: CGSize(width:size,height:size))
            }
            
            return nil
        }
    }
}

extension UIDevice {
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }
}
