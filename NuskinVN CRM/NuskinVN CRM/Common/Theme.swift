//
//  Theme.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 9/24/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import UIKit

class Theme: NSObject {
    
    static var colorGradient:Array<UIColor> {
        return [UIColor(hex:"0xe30b7a"),UIColor(hex:"0x349ad5")]
    }
    
    // MARK: - COMMON
    static var colorNavigationBar:String {
        return "0x018AAF"
    }
    static var colorBottomBar:String {
        return "0x018AAF"
    }
    static var colorTitleBar:String {
        return "0xffffff"
    }
    
    // MARK: ALERT
    static var colorAlertButtonTitleColor:String {
        return "0xffffff"
    }
    static var colorAlertButtonBackgroundColor:String {
        return "0x018AAF"
    }
    static var colorAlertTextNormal:String {
        return "0x323232"
    }
    static var colorAlertTextBold:String {
        return "0x333333"
    }
    
    // MARK: - COLOR DASHBOARD
    static var colorDBTitleChart:String {
        return "0x333333"
    }
    static var colorDBChartNonProcess:String {
        return "0xFFEB3C"
    }
    static var colorDBChartProcess:String {
        return "0x018AAF"
    }
    static var colorDBNumberTotalSales:String {
        return "0x018AAF"
    }
    
    static var colorDBTextHighlight:String {
        return "0xffffff"
    }
    static var colorDBTextNormal:String {
        return "0x323232"
    }
    static var colorDBButtonChartTextSelected:String {
        return "0xffffff"
    }
    static var colorDBButtonChartTextNormal:String {
        return "0x323232"
    }
    static var colorDBButtonChartNormal:String {
        return "0xD4D8DB"
    }
    static var colorDBButtonChartSelected:String {
        return "0x018AAF"
    }
    static var colorDBBackgroundDashboard:String {
        return "0xD4D8DB"
    }
    static var colorDBTotalChartNormal:String {
        return "0x333333"
    }
    
    // MARK: - COLOR AUTHENTIC
    static var colorATTextColor:String {
        return "0xffffff"
    }
    static var colorATBorderColor:String {
        return "0xffffff"
    }
    static var colorATButtonBackgroundColor:String {
        return "0xffffff"
    }
    static var colorATButtonTitleColor:String {
        return "0x018AAF"
    }
    
    // MARK: - MANAGE COLOR
    class color: NSObject {
        // MARK: - COLOR GROUP - LIST CUSTOMER
        class customer: color {
            static var titleGroup: String {
                return "0x333333"
            }
            
            static var subGroup:String {
                return "0x323232"
            }
        }
    }
    
    // MARK: - FONT
    class font: NSObject {
        static var bold:String {
            return "Roboto-Medium"
        }
        
        static var boldItalic:String {
            return "Roboto-MediumItalic"
        }
               
        static var normal:String {
            return "Roboto-Light"
        }
        
        static var normalItalic:String {
            return "Roboto-LightItalic"
        }
    }
    
    // MARK: - fontSize
    class fontSize: NSObject {
        
        static var small:CGFloat {
            return 14
        }
        
        static var normal:CGFloat {
            return 17
        }
        
        static var medium:CGFloat {
            return 21
        }
        
        static var larger:CGFloat {
            return 30
        }
    }
}
