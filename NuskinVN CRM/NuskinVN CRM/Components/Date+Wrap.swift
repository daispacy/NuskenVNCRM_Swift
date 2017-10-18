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
}
