//
//  CButton.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 9/22/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import UIKit

class CButtonChart: UIButton {

    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        config()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        config()
    }
    
    func config()  {
        
//        self.layer.borderWidth = 1.0;
//        self.layer.borderColor = self.backgroundColor?.cgColor;
        self.backgroundColor = UIColor(hex:Theme.colorDBButtonChartNormal)
        setBackgroundImage(UIImage(color:UIColor(hex:Theme.colorDBButtonChartNormal)), for: .normal)
        setBackgroundImage(UIImage(color:UIColor(hex:Theme.colorDBButtonChartSelected)), for: .selected)
        setTitleColor(UIColor(hex:Theme.colorDBButtonChartTextNormal), for: .normal)
        setTitleColor(UIColor(hex:Theme.colorDBButtonChartTextSelected), for: .selected)
        
        titleLabel?.font = UIFont.systemFont(ofSize: 14)
        titleLabel?.adjustsFontSizeToFitWidth = true
        
        self.layer.cornerRadius = (frame.size.height/2) * (60/100);
        self.clipsToBounds      = true;
        
        titleEdgeInsets.left = 10
        titleEdgeInsets.right = 10
    }
}
