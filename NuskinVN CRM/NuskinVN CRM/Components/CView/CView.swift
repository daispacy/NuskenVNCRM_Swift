//
//  CView.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 9/30/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import Foundation
import UIKit
import Localize_Swift

enum ViewBorderType {
    case left
    case right
    case top
    case bottom
}

class CViewBorder:UIView {
    var type: [ViewBorderType] = [.left, .right, .bottom, .top]
    var color:String = "0x382a2a"
    init(frame: CGRect,_ type:[ViewBorderType],_ color:String? = nil) {
        super.init(frame: frame)
        self.type = type
        if let cl = color {
            self.color = cl
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundColor = UIColor.clear
        layer.masksToBounds = false
        
        if self.bounds.width <= 0 || self.bounds.height <= 0 {
            return
        }
        if let subs = layer.sublayers {
            for la in subs.reversed() {
                if la .isKind(of: CAShapeLayer.self) {
                    la.removeFromSuperlayer()
                }
            }
        }
        
        for t in self.type {
            if t == .left {
                let leftPath:UIBezierPath = UIBezierPath()
                leftPath.move(to: CGPoint(x: 0, y: 0 ))
                leftPath.addLine(to: CGPoint(x: 0, y: self.bounds.maxY))
                
                let leftLayer:CAShapeLayer = CAShapeLayer()
                leftLayer.lineWidth = 1.0
                leftLayer.position = CGPoint(x:0,y:0)
                leftLayer.path = leftPath.cgPath
                leftLayer.strokeColor = UIColor(hex:self.color).cgColor
                leftLayer.fillColor = nil;
                self.layer.addSublayer(leftLayer)
            }
            
            if t == .right {
                let leftPath:UIBezierPath = UIBezierPath()
                leftPath.move(to: CGPoint(x: self.bounds.maxX, y: 0 ))
                leftPath.addLine(to: CGPoint(x: self.bounds.maxX, y: self.bounds.maxY))
                
                let leftLayer:CAShapeLayer = CAShapeLayer()
                leftLayer.lineWidth = 1.0
                leftLayer.position = CGPoint(x:0,y:0)
                leftLayer.path = leftPath.cgPath
                leftLayer.strokeColor = UIColor(hex:self.color).cgColor
                leftLayer.fillColor = nil;
                self.layer.addSublayer(leftLayer)
            }
            
            if t == .bottom {
                let bottomPath:UIBezierPath = UIBezierPath()
                bottomPath.move(to: CGPoint(x: 0, y: self.bounds.maxY))
                bottomPath.addLine(to: CGPoint(x: self.bounds.maxX, y: self.bounds.maxY))
                
                let BottomLayer:CAShapeLayer = CAShapeLayer()
                BottomLayer.lineWidth = 1.0
                BottomLayer.position = CGPoint(x:0,y:0)
                BottomLayer.path = bottomPath.cgPath
                BottomLayer.strokeColor = UIColor(hex:self.color).cgColor
                BottomLayer.fillColor = nil;
                self.layer.addSublayer(BottomLayer)
            }
            
            if t == .top {
                let bottomPath:UIBezierPath = UIBezierPath()
                bottomPath.move(to: CGPoint(x: 0, y: 0))
                bottomPath.addLine(to: CGPoint(x: self.bounds.maxX, y: 0))
                
                let BottomLayer:CAShapeLayer = CAShapeLayer()
                BottomLayer.lineWidth = 1.0
                BottomLayer.position = CGPoint(x:0,y:0)
                BottomLayer.path = bottomPath.cgPath
                BottomLayer.strokeColor = UIColor(hex:self.color).cgColor
                BottomLayer.fillColor = nil;
                self.layer.addSublayer(BottomLayer)
            }
        }
    }
}

class CView:UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        configView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configView()
    }
    
    func configView() {
        self.layer.cornerRadius = 4;
        self.clipsToBounds = false;
    }
}

class CViewSwitchLanguage:UIView, ReloadedUIView {
    
    var data:JSON?
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        registerSwitchLanguage()
    }
    
    deinit {
        afterDeinit()
    }
    
    func reload(_ data:JSON) {
        self.data = data
    }
    
    func registerSwitchLanguage() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadTexts), name: NSNotification.Name( LCLLanguageChangeNotification), object: nil)
    }
    
    func afterDeinit() {
        NotificationCenter.default.removeObserver(self)
//        print("remove LCLLanguageChangeNotification")
    }
    
    func reloadTexts() {
        // override
        fatalError("Override this method")
    }
}
