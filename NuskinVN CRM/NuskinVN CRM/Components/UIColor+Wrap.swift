//
//  UIColor+Wrap.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 9/23/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(hex: String) {
        let scanner = Scanner(string: hex)
        scanner.scanLocation = 0
        
        var rgbValue: UInt64 = 0
        
        scanner.scanHexInt64(&rgbValue)
        
        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff
        
        self.init(
            red: CGFloat(r) / 0xff,
            green: CGFloat(g) / 0xff,
            blue: CGFloat(b) / 0xff, alpha: 1
        )
    }
    
    convenience init(_gradient colors:Array<UIColor> = [UIColor(hex:"0xe30b7a"),UIColor(hex:"0x349ad5")],
                     frame: CGRect,
                     isReverse:Bool = false,
                     startP:CGPoint? = nil,
                     endP:CGPoint? = nil) {
        
        // create the background layer that will hold the gradient
        let backgroundGradientLayer = CAGradientLayer()
        backgroundGradientLayer.frame = frame
        
        // we create an array of CG colors from out UIColor array
        var cgColors = colors.map({$0.cgColor})
        if(isReverse) {
            cgColors = colors.reversed().map({$0.cgColor})
        }
        
        backgroundGradientLayer.colors = cgColors
        if(isReverse) {
            backgroundGradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
            backgroundGradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        } else {
            backgroundGradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
            backgroundGradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        }
        
        if let sp = startP {
            backgroundGradientLayer.startPoint = sp
        }
        if let ep = endP {
            backgroundGradientLayer.endPoint = ep
        }
        
        UIGraphicsBeginImageContext(backgroundGradientLayer.bounds.size)
        backgroundGradientLayer.render(in: UIGraphicsGetCurrentContext()!)
        let backgroundColorImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        self.init(patternImage: backgroundColorImage!)
    }
}
