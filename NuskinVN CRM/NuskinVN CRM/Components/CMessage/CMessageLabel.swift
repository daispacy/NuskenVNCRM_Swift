//
//  CMessageLabel.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 9/22/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import UIKit

class CMessageLabel: UILabel {

    func setMessage(msg:String!, icon:String) {
        let attachment = NSTextAttachment()
        attachment.image = Support.imageWithIconFont(code: icon, size: 12)
        attachment.bounds = CGRect(x: 0, y:0, width: 12, height: 12)
        let attachmentStr = NSAttributedString(attachment: attachment)
        let myString = NSMutableAttributedString(string: "")
        myString.append(attachmentStr)
        let myString1 = NSMutableAttributedString(string: "  " + msg)
        myString.append(myString1)
        self.attributedText = myString
    }

}
