//
//  Date+Wrap.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 10/18/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import Foundation

extension Date {
    func convertDateFormat(from: String, to: String, dateString: String?) -> String? {
        let fromDateFormatter = DateFormatter()
        fromDateFormatter.dateFormat = from
        var formattedDateString: String? = nil
        if dateString != nil {
            let formattedDate = fromDateFormatter.date(from: dateString!)
            if formattedDate != nil {
                let toDateFormatter = DateFormatter()
                toDateFormatter.dateFormat = to
                formattedDateString = toDateFormatter.string(from: formattedDate!)
            }
        }
        return formattedDateString
    }
    
    func toString( dateFormat format  : String ) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
    
    func addedBy(minutes:Int) -> Date {
        return Calendar.current.date(byAdding: .minute, value: minutes, to: self)!
    }
    
    var currentMonth:String {
        let calendar = Calendar.autoupdatingCurrent
        let components = calendar.dateComponents([.month], from: self)
        return "\(components.month!)"
    }
    
    var currentYear:String {
        let calendar = Calendar.autoupdatingCurrent
        let components = calendar.dateComponents([.year], from: self)
        return "\(components.year!)"
    }
    
    var listDay:[String] {
        
        let calendar = Calendar.current
        var numDays = 32
        let startFrom = 1
        
        let range = calendar.range(of: .day, in: .month, for: self)!
        numDays = range.count + 1
        
        var data:[String] = []
        for i in startFrom ..< numDays {
            data.append("\(i)".localized())
        }
        return data
    }
}
