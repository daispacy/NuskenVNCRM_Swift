//
//  CLabel.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 9/30/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import UIKit

class CLabelGradient: UILabel {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        textColor = UIColor(_gradient: Theme.colorGradient, frame: CGRect(origin: CGPoint.zero, size: CGSize(width: frame.size.width, height: superview!.frame.maxY)), isReverse: false)
    }
}
