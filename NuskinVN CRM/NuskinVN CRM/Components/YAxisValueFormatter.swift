//
//  YAxisValueFormatter.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 10/25/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import Foundation
import Charts
class YAxisValueFormatter: NSObject, IAxisValueFormatter {
    
    let numFormatter: NumberFormatter
    
    override init() {
        numFormatter = NumberFormatter()
        numFormatter.minimumFractionDigits = 1
        numFormatter.maximumFractionDigits = 1
        
        // if number is less than 1 add 0 before decimal
        numFormatter.minimumIntegerDigits = 1 // how many digits do want before decimal
        numFormatter.paddingPosition = .beforePrefix
        numFormatter.paddingCharacter = "0"
    }
    
    /// Called when a value from an axis is formatted before being drawn.
    ///
    /// For performance reasons, avoid excessive calculations and memory allocations inside this method.
    ///
    /// - returns: The customized label that is drawn on the axis.
    /// - parameter value:           the value that is currently being drawn
    /// - parameter axis:            the axis that the value belongs to
    ///
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return numFormatter.string(from: NSNumber(floatLiteral: value))!
    }
}

class ChartValueFormatter: NSObject, IValueFormatter {
    fileprivate var numberFormatter: NumberFormatter?
    fileprivate var showUnit:Bool = false
    
    convenience init(numberFormatter: NumberFormatter,_ showUnit:Bool? = nil) {
        self.init()
        self.numberFormatter = numberFormatter
        if let show = showUnit {
            self.showUnit = show
        }
    }
    
    func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
        guard let numberFormatter = numberFormatter
            else {
                return ""
        }
        
        return numberFormatter.string(for: value)!.replacingOccurrences(of: ",", with: ".")
    }
}

class PriceValueFormatter: NSObject, IValueFormatter {
    fileprivate var numberFormatter: NumberFormatter?
    fileprivate var showUnit:Bool = false
    
    convenience init(numberFormatter: NumberFormatter,_ showUnit:Bool? = nil) {
        self.init()
        self.numberFormatter = numberFormatter
        if let show = showUnit {
            self.showUnit = show
        }
    }
    
    func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
        guard let numberFormatter = numberFormatter
            else {
                return ""
        }
        if value >= 1000 && value < 1000000{
            return "~\(numberFormatter.string(for: round(value/1000))!.replacingOccurrences(of: ",", with: ".")) tỷ"
        } else if value > 1 && value < 1000 {
            return "\(numberFormatter.string(for: value)!.replacingOccurrences(of: ",", with: ".")) triệu"
        } else if value >= 1000000 {
            return "~\(numberFormatter.string(for: round(value/1000000))!.replacingOccurrences(of: ",", with: ".")) nghìn tỷ"
        }
        return numberFormatter.string(for: value)!.replacingOccurrences(of: ",", with: ".")
    }
}
