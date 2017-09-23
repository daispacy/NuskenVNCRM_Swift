//
//  TotalSummaryView.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 9/23/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import UIKit

class TotalSummaryView: UIView {

    // summary
    @IBOutlet var lblCustomer: UILabel!
    @IBOutlet var lblOrderComplete: UILabel!
    @IBOutlet var lblUnComplete: UILabel!
    @IBOutlet var lblNumberCustomer: UILabel!
    @IBOutlet var lblNumberOrdercomplete: UILabel!
    @IBOutlet var lblNumberOrderUncomplete: UILabel!
    
    //sales
    @IBOutlet  var lineHorizontal: UIView!
    @IBOutlet  var lineVertical: UIView!
    @IBOutlet  var lblTotalSales: UILabel!
    @IBOutlet  var lblTotalSalesOne: UILabel!
    @IBOutlet  var lblTotalSalesTwo: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    // MARK: - INTERFACE
    func configSummary(totalCustomer:String? = nil, totalOrderComplete:String? = nil, totalOrderUnComplete:String? = nil) {
        lblCustomer.text = "total_customer".localized()
        lblOrderComplete.text = "total_order_completed".localized()
        lblUnComplete.text = "total_order_uncompleted".localized()
        
        lblNumberCustomer.text = totalCustomer
        lblNumberOrdercomplete.text = totalOrderComplete
        lblNumberOrderUncomplete.text = totalOrderUnComplete
    }
    
    func configSales(total:String? = nil, totalOne:String? = nil, totalTwo:String? = nil) {
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = 7
        paragraph.alignment = .center
        
        // total sales
        let attributedStringTotalSales = NSMutableAttributedString(string:"\("total_sales".localized())\n", attributes: [NSFontAttributeName:UIFont.boldSystemFont(ofSize: 18),NSParagraphStyleAttributeName:paragraph])
        let attributedStringNumberTotalSales = NSMutableAttributedString(string: "\(total!)\n", attributes: [NSFontAttributeName:UIFont.boldSystemFont(ofSize: 30),NSForegroundColorAttributeName:UIColor.green,NSParagraphStyleAttributeName:paragraph])
        let attributedStringUnitSales = NSMutableAttributedString(string: "currency_unit".localized(), attributes: [NSFontAttributeName:UIFont.systemFont(ofSize: 12),NSParagraphStyleAttributeName:paragraph])
        
        let attributeStringForTotalSales = NSMutableAttributedString(attributedString: attributedStringTotalSales)
        attributeStringForTotalSales.append(attributedStringNumberTotalSales)
        attributeStringForTotalSales.append(attributedStringUnitSales)
        lblTotalSales.attributedText = attributeStringForTotalSales
        
        //total ones
        let attributedStringTotalOne = NSMutableAttributedString(string:"\("sales_month".localized())\n", attributes: [NSFontAttributeName:UIFont.boldSystemFont(ofSize: 12),NSParagraphStyleAttributeName:paragraph])
        let attributedStringNumberTotalOne = NSMutableAttributedString(string: "\(totalOne!)\n", attributes: [NSFontAttributeName:UIFont.boldSystemFont(ofSize: 18),NSForegroundColorAttributeName:UIColor.darkGray,NSParagraphStyleAttributeName:paragraph])
        let attributeStringForTotalOne = NSMutableAttributedString(attributedString: attributedStringTotalOne)
        attributeStringForTotalOne.append(attributedStringNumberTotalOne)
        attributeStringForTotalOne.append(attributedStringUnitSales)
        lblTotalSalesOne.attributedText = attributeStringForTotalOne
   
        //total two
        let attributedStringTotalTwo = NSMutableAttributedString(string:"\("sales_month".localized())\n", attributes: [NSFontAttributeName:UIFont.boldSystemFont(ofSize: 12),NSParagraphStyleAttributeName:paragraph])
        let attributedStringNumberTotalTwo = NSMutableAttributedString(string: "\(totalOne!)\n", attributes: [NSFontAttributeName:UIFont.boldSystemFont(ofSize: 18),NSForegroundColorAttributeName:UIColor.darkGray,NSParagraphStyleAttributeName:paragraph])
        let attributeStringForTotalTwo = NSMutableAttributedString(attributedString: attributedStringTotalTwo)
        attributeStringForTotalTwo.append(attributedStringNumberTotalTwo)
        attributeStringForTotalTwo.append(attributedStringUnitSales)
        lblTotalSalesTwo.attributedText = attributeStringForTotalTwo
    }
    
    
}
