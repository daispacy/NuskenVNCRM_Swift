//
//  CButton.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 9/22/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import UIKit

class CButton: UIButton {

    
    
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
        self.layer.cornerRadius = self.frame.size.height/2;
        self.clipsToBounds      = true;
    }
    
}
