//
//  String+wrap.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 10/11/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import Foundation
extension String {
    func toDate()-> Date
    {
        let calendar = NSCalendar(identifier: NSCalendar.Identifier.gregorian)
        let DateArray = self.components(separatedBy: "/")
        let components = NSDateComponents()
        components.year = Int(DateArray[2])!
        components.month = Int(DateArray[1])!
        components.day = Int(DateArray[0])! + 1
        let date = calendar?.date(from: components as DateComponents)
        
        return date!
    }
}
