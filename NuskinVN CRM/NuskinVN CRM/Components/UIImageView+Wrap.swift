//
//  UIImageView+Wrap.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 9/27/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import Foundation
import UIKit

let imageCache = NSCache<NSString, UIImage>()

private var KeepTap:String = "KeepTap"
private var KeepTapEvent:String = "KeepTapEvent"

extension UIImageView {
    
    func loadImageUsingCacheWithURLString(_ URLString: String, size:CGSize?, placeHolder: UIImage?) {
        
        self.image = nil
        if let cachedImage = imageCache.object(forKey: NSString(string: URLString)) {
            self.image = cachedImage
            return
        }
        
        if let url = URL(string: URLString) {
            URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
                
                //print("RESPONSE FROM API: \(response)")
                if error != nil {
                    if let er = error {
                        print("ERROR LOADING IMAGES FROM URL: \(er)")
                    }
                    DispatchQueue.main.async {
                        self.image = placeHolder
                    }
                    return
                }
                DispatchQueue.main.async {
                    if let data = data {
                        if let downloadedImage = UIImage(data: data) {
                            if let s = size {
                                let img = downloadedImage.resizeImageWith(newSize: s)
                                imageCache.setObject(img, forKey: NSString(string: URLString))
                                self.image = img
                            } else {
                                self.image = downloadedImage
                                imageCache.setObject(downloadedImage, forKey: NSString(string: URLString))
                            }
                        }
                    }
                }
            }).resume()
        }
    }
    
    var singleTap:UITapGestureRecognizer {
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(self.tapDetected(_:)))
        singleTap.numberOfTapsRequired = 1 // you can change this value
        return singleTap
    }
    
    func addEvent(_ event:(()->Void)) {
        if objc_getAssociatedObject(self, &KeepTap) != nil {return}
        
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(singleTap)
        objc_setAssociatedObject(self, &KeepTap, singleTap, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        objc_setAssociatedObject(self, &KeepTapEvent, event, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    func removeEvent() {
        if let tap = objc_getAssociatedObject(self, &KeepTap) as? UITapGestureRecognizer {
            self.removeGestureRecognizer(tap)
        }
    }
    
    //Action
    func tapDetected(_ sender:UITapGestureRecognizer) {
        print("Imageview Clicked")
        if let event = objc_getAssociatedObject(self, &KeepTapEvent) as? (()->Void) {
            event()
        }
    }
}

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

class CImageViewRoundGradient: UIImageView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = frame.size.width/2
        layer.masksToBounds = true        
    }
}
