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
        calendar?.timeZone = .current
        var DateArray = self.components(separatedBy: "-")
        if DateArray.count == 0 {
            DateArray = self.components(separatedBy: "/")
        }
        let components = NSDateComponents()
        components.year = Int(DateArray[2])!
        components.month = Int(DateArray[1])!
        components.day = Int(DateArray[0])! + 1
        components.timeZone = TimeZone(abbreviation: "GMT+0:00")
        let date = calendar?.date(from: components as DateComponents)
        
        return date!
    }
    
    func toDate3()-> Date
    {
        let calendar = NSCalendar(identifier: NSCalendar.Identifier.gregorian)
        calendar?.timeZone = .current
        var DateArray = self.components(separatedBy: "/")
        
        let components = NSDateComponents()
        components.year = Int(DateArray[1])!
        components.month = Int(DateArray[0])!
//        components.day = Int(DateArray[0])! + 1
        components.timeZone = TimeZone(abbreviation: "GMT+0:00")
        let date = calendar?.date(from: components as DateComponents)
        
        return date!
    }
    
    func toDate2() -> Date{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.date(from: self) ?? Date.init(timeIntervalSinceNow: 0)
    }
    
    func toPrice() -> String {
        if !self.isNumber() { return self }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSize = 3
        return  formatter.string(from: NSNumber(value: Int64(self.replacingOccurrences(of: ".", with: ""))!))!.replacingOccurrences(of: ",", with: ".")
    }
    
    func isNumber() -> Bool {
        let numberCharacters = CharacterSet.decimalDigits.inverted
        return !self.replacingOccurrences(of: ".", with: "").isEmpty && self.replacingOccurrences(of: ".", with: "").rangeOfCharacter(from: numberCharacters) == nil
    }
}

extension Int64 {
    func toTextPrice() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        if let result =  formatter.string(from: NSNumber(value: self)) {
            return result.replacingOccurrences(of: ",", with: ".")
        } else {
            return "\(self)"
        }
    }
}

extension Double {
    
    func toTextPrice() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        if let result =  formatter.string(from: NSNumber(value: self)) {
            return result.replacingOccurrences(of: ",", with: ".")
        } else {
            return "\(self)"
        }
    }
    
    var cleanValue: String
    {
        return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
}

extension Float
{
    var cleanValue: String
    {
        return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
}
