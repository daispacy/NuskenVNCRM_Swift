//
//  CInput.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 9/22/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import UIKit
import QuartzCore

class CInput: UITextField {
    
    var paddingText:CGFloat = {
        return CGFloat(40)
    }()
    
    var paddingRightView:CGFloat = {
        return CGFloat(10)
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configTextField(isBorder:true)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        configTextField(isBorder:true)
    }
 
    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.leftViewRect(forBounds: bounds)
        rect.origin.x = paddingRightView
        
        return rect
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        var rect =  bounds
        rect.origin.x = paddingText
        if(self.rightView != nil) {
            rect.size.width = rect.size.width - self.rightView!.frame.size.width - paddingText/2
        } else {
            rect.size.width = rect.size.width - paddingText - paddingText/2
        }
        
        return rect
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return textRect(forBounds:bounds)
    }
    
    func configTextField(imageName:String? = "checkbox_uncheck",isSecurity:Bool? = false, isBorder:Bool? = false) {
        if(imageName != nil) {
            self.leftViewMode = .always
            self.leftView = UIImageView.init(image: UIImage(named:imageName!))
            self.clipsToBounds = true
        }
        
        self.isSecureTextEntry = isSecurity!
        
        if(isBorder)! {
            
            self.layer.borderWidth = 1.0;
            self.layer.borderColor = UIColor.gray.cgColor;
            self.layer.cornerRadius = self.frame.size.height/2;
            self.clipsToBounds      = true;
        }
    }
}
