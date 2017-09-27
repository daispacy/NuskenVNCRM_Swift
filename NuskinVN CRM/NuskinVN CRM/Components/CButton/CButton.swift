//
//  CButton.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 9/22/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import UIKit

class CButton: UIButton {
    
    var paddingRightView:CGFloat = {
        return CGFloat(5)
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        config()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        config()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.masksToBounds = false
        
        
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
        cornerLayer.strokeColor = UIColor.white.withAlphaComponent(0.5).cgColor
        cornerLayer.fillColor = nil;
        self.layer.addSublayer(cornerLayer)
    }
    
    func config()  {
        
        //        self.layer.borderWidth = 1.0;
        //        self.layer.borderColor = self.backgroundColor?.cgColor;
        self.layer.cornerRadius = paddingRightView;
        self.clipsToBounds      = true;
    }
    
}

class CButtonWithImage: UIButton {
    var paddingRightView:CGFloat = {
        return CGFloat(3)
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let imV = imageView {
            imV.layer.masksToBounds = false
            if let subs = imV.layer.sublayers {
                for la in subs.reversed() {
                    if la .isKind(of: CAShapeLayer.self) {
                        la.removeFromSuperlayer()
                    }
                }
            }
            let cornerPath:UIBezierPath = UIBezierPath()
            cornerPath.move(to: CGPoint(x: imV.bounds.maxX + paddingRightView, y: imV.bounds.maxY/2 ))
            cornerPath.addLine(to: CGPoint(x: imV.bounds.maxX + paddingRightView, y: imV.bounds.maxY))
            cornerPath.addArc(withCenter: CGPoint(x: imV.bounds.maxX, y: imV.bounds.maxY), radius: paddingRightView, startAngle: 0.0, endAngle: CGFloat(Double.pi/2), clockwise: true)
            cornerPath.addLine(to: CGPoint(x: paddingRightView*3, y: imV.bounds.maxY + paddingRightView))
            
            let cornerLayer:CAShapeLayer = CAShapeLayer()
            cornerLayer.lineWidth = 1.0
            cornerLayer.position = CGPoint(x:-2.5,y:-2)
            cornerLayer.path = cornerPath.cgPath
            cornerLayer.strokeColor = UIColor.white.withAlphaComponent(0.5).cgColor
            cornerLayer.fillColor = nil;
            imV.layer.addSublayer(cornerLayer)
        }
    }
}
