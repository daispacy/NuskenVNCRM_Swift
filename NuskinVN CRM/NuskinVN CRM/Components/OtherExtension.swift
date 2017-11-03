//
//  OtherExtension.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 11/3/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import Foundation
import UIKit

class CButtonWithImageRight1: UIButton {
    override func layoutSubviews() {
        super.layoutSubviews()
        imageEdgeInsets = UIEdgeInsetsMake(0, frame.size.width-5, 0, 25)
        titleEdgeInsets = UIEdgeInsetsMake(0, -15, 0, 0)
    }
}

class CButtonWithImageRight2: UIButton {
    override func layoutSubviews() {
        super.layoutSubviews()
        imageEdgeInsets = UIEdgeInsetsMake(0, frame.size.width - 10, 0, 20)
        titleEdgeInsets = UIEdgeInsetsMake(0, -13, 0, 0)
    }
}

extension UIImagePickerController {
    open override func viewDidLoad() {
        super.viewDidLoad()
        // prevent sync data while working with order
        print("REMOVE LOOP SYNC WHEN UIImagePickerController OPENED")
        LocalService.shared.timerSyncToServer?.invalidate()
    }
}