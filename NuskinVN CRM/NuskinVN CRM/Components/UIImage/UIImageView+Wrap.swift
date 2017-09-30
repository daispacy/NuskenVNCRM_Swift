//
//  UIImageView+Wrap.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 9/27/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import Foundation
import UIKit

class CImageView: UIImageView {
    
    var paddingRightView:CGFloat = {
        return CGFloat(5)
    }()
    
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
        cornerLayer.strokeColor = UIColor.white.withAlphaComponent(0.4).cgColor
        cornerLayer.fillColor = nil;
        self.layer.addSublayer(cornerLayer)
        
        self.layer.cornerRadius = paddingRightView;
        self.clipsToBounds      = false;
    }
}
