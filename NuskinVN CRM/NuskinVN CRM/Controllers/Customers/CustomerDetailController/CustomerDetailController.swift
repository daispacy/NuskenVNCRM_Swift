//
//  CustomerDetailController.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 10/6/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import UIKit

class CustomerDetailController: RootViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}

class CButtonWithImageRight1: UIButton {
    override func layoutSubviews() {
        super.layoutSubviews()
        imageEdgeInsets = UIEdgeInsetsMake(0, frame.size.width, 0, 40)
    }
}
