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
        return CGFloat(10)
    }()
    
    var paddingRightView:CGFloat = {
        return CGFloat(5)
    }()
    
    var alphaLayer:CGFloat = {
        return CGFloat(0.4)
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configTextField(isBorder:false)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let subs = layer.sublayers {
            for la in subs.reversed() {
                if la .isKind(of: CAShapeLayer.self) {
                    la.removeFromSuperlayer()
                }
            }
        }
        let cornerPath:UIBezierPath = UIBezierPath()
        cornerPath.move(to: CGPoint(x: self.bounds.maxX + paddingRightView, y: paddingRightView ))
        cornerPath.addLine(to: CGPoint(x: self.bounds.maxX + paddingRightView, y: self.bounds.maxY))
        cornerPath.addArc(withCenter: CGPoint(x: self.bounds.maxX, y: self.bounds.maxY), radius: paddingRightView, startAngle: 0.0, endAngle: CGFloat(Double.pi/2), clockwise: true)
        cornerPath.addLine(to: CGPoint(x: paddingRightView, y: self.bounds.maxY + paddingRightView))
        
        let cornerLayer:CAShapeLayer = CAShapeLayer()
        cornerLayer.lineWidth = 1.0
        cornerLayer.position = CGPoint(x:-2,y:-2)
        cornerLayer.path = cornerPath.cgPath
        cornerLayer.strokeColor = UIColor.white.withAlphaComponent(alphaLayer).cgColor
        cornerLayer.fillColor = nil;
        self.layer.addSublayer(cornerLayer)
        
        let backgroundPath:UIBezierPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: paddingRightView)
        let backgroundLayer:CAShapeLayer = CAShapeLayer()
        backgroundLayer.lineWidth = 1.0
        backgroundLayer.frame = self.bounds
        backgroundLayer.path = backgroundPath.cgPath
        backgroundLayer.fillColor = UIColor.white.withAlphaComponent(alphaLayer).cgColor;
        self.layer.addSublayer(backgroundLayer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        configTextField(isBorder:false)
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
    
    func configTextField(isSecurity:Bool? = false, isBorder:Bool? = true) {
        
        self.clipsToBounds = false
//        backgroundColor = UIColor.white
        self.setValue(UIColor.white.withAlphaComponent(0.6), forKeyPath: "_placeholderLabel.textColor")
        self.tintColor = UIColor.white
        
        self.isSecureTextEntry = isSecurity!
        
        if(isBorder)! {
            
            self.layer.borderWidth = 1.0;
            self.layer.borderColor = UIColor.white.withAlphaComponent(alphaLayer).cgColor;
            self.layer.cornerRadius = paddingRightView;
        }
    }
}
