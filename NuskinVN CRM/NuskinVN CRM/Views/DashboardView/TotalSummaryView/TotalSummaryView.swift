//
//  TotalSummaryView.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 9/23/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import UIKit

class TotalSummaryView: CViewSwitchLanguage {
    
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
    @IBOutlet weak var stackViewMain: UIStackView!
    @IBOutlet weak var stackViewSub: UIStackView!
    @IBOutlet weak var vwStoreChart: UIView!
    
    @IBOutlet weak var lblCustomerRegister:UILabel!
    @IBOutlet weak var lblNumberCustomerRegister:UILabel!
    @IBOutlet weak var lblPotentialDistributors:UILabel!
    @IBOutlet weak var lblNumberPotentialDistributors:UILabel!
    @IBOutlet weak var lblOther:UILabel!
    @IBOutlet weak var lblNumberOther:UILabel!
    
    var chartStatisticsCustomer:ChartStatisticsCustomer!
    var lblTotalCustomer:UILabel!
    
    let paragraph: NSMutableParagraphStyle = {
        let para = NSMutableParagraphStyle()
        para.lineSpacing = 7
        para.alignment = .center
        return para
    }()
    
    
    let attributedStringUnitSales:NSMutableAttributedString =  {
        return NSMutableAttributedString(string: "currency_unit".localized().uppercased(), attributes: [NSFontAttributeName:UIFont(name: Theme.font.normal, size: Theme.fontSize.small)!,NSForegroundColorAttributeName:UIColor(hex:Theme.colorDBTextNormal)])
    }()
    
    let attributedStringUnitCustomer:NSMutableAttributedString =  {
        return NSMutableAttributedString(string: "human_unit".localized(), attributes: [NSFontAttributeName:UIFont(name: Theme.font.normal, size: Theme.fontSize.small)!,NSForegroundColorAttributeName:UIColor(hex:Theme.colorDBTextNormal)])
    }()
    
    let attributedStringTotalCustomer:NSMutableAttributedString =  {
        return NSMutableAttributedString(string: "total_customer".localized(), attributes: [NSFontAttributeName:UIFont(name: Theme.font.normal, size: Theme.fontSize.normal)!,NSForegroundColorAttributeName:UIColor(hex:Theme.colorDBTextNormal)])
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func reload(_ data: JSON) {
        super.reload(data)
    }
    
    override func reloadTexts() {
        // set text here
    }
    
    // MARK: - INTERFACE
    func configSummary(totalCustomer:String? = nil, totalOrderComplete:String? = nil, totalOrderUnComplete:String? = nil) {
        lblCustomer.text = "number_customer".localized()
        lblOrderComplete.text = "order_completed".localized()
        lblUnComplete.text = "order_uncompleted".localized()
        
        lblCustomer.font = UIFont(name: Theme.font.normal, size: Theme.fontSize.normal)!
        lblOrderComplete.font = UIFont(name: Theme.font.normal, size: Theme.fontSize.normal)!
        lblUnComplete.font = UIFont(name: Theme.font.normal, size: Theme.fontSize.normal)!
        
        lblCustomer.textColor = UIColor(hex:Theme.colorDBTextNormal)
        lblOrderComplete.textColor = UIColor(hex:Theme.colorDBTextNormal)
        lblUnComplete.textColor = UIColor(hex:Theme.colorDBTextNormal)
        
        lblNumberCustomer.font = UIFont(name: Theme.font.bold, size: Theme.fontSize.medium)!
        lblNumberOrdercomplete.font = UIFont(name: Theme.font.bold, size: Theme.fontSize.medium)!
        lblNumberOrderUncomplete.font = UIFont(name: Theme.font.bold, size: Theme.fontSize.medium)!
        
        lblNumberCustomer.textColor = UIColor(hex:Theme.colorDBTotalChartNormal)
        lblNumberOrdercomplete.textColor = UIColor(hex:Theme.colorDBTotalChartNormal)
        lblNumberOrderUncomplete.textColor = UIColor(hex:Theme.colorDBTotalChartNormal)
        
        lblNumberCustomer.text = totalCustomer?.toPrice()
        lblNumberOrdercomplete.text = totalOrderComplete?.toPrice()
        lblNumberOrderUncomplete.text = totalOrderUnComplete?.toPrice()
    }
    
    func loadChartCustomer(totalOrdered:String, totalNotOrderd:String) {
        
        lblTotalSales.removeFromSuperview()
        
        attributedStringUnitCustomer.addAttribute(NSParagraphStyleAttributeName, value: paragraph, range: NSRangeFromString(attributedStringUnitSales.string))
        
        //total ones
        let attributedStringTotalOne = NSMutableAttributedString(string:"\("customer_has_order".localized())\n", attributes: [NSFontAttributeName:UIFont(name: Theme.font.normal, size: Theme.fontSize.normal)!,NSForegroundColorAttributeName:UIColor(hex:Theme.colorDBTextNormal),NSParagraphStyleAttributeName:paragraph])
        let attributedStringNumberTotalOne = NSMutableAttributedString(string: "\(totalOrdered.toPrice())\n", attributes: [NSFontAttributeName:UIFont(name: Theme.font.bold, size: Theme.fontSize.medium)!,NSForegroundColorAttributeName:UIColor(hex:Theme.colorDBTotalChartNormal),NSParagraphStyleAttributeName:paragraph])
        let attributeStringForTotalOne = NSMutableAttributedString(attributedString: attributedStringTotalOne)
        attributeStringForTotalOne.append(attributedStringNumberTotalOne)
        attributeStringForTotalOne.append(attributedStringUnitCustomer)
        lblTotalSalesOne.attributedText = attributeStringForTotalOne
        
        //total two
        let attributedStringTotalTwo = NSMutableAttributedString(string:"\("customer_not_order_yet".localized())\n", attributes: [NSFontAttributeName:UIFont(name: Theme.font.normal, size: Theme.fontSize.normal)!,NSForegroundColorAttributeName:UIColor(hex:Theme.colorDBTextNormal),NSParagraphStyleAttributeName:paragraph])
        let attributedStringNumberTotalTwo = NSMutableAttributedString(string: "\(totalNotOrderd.toPrice())\n", attributes: [NSFontAttributeName:UIFont(name: Theme.font.bold, size: Theme.fontSize.medium)!,NSForegroundColorAttributeName:UIColor(hex:Theme.colorDBTotalChartNormal),NSParagraphStyleAttributeName:paragraph])
        let attributeStringForTotalTwo = NSMutableAttributedString(attributedString: attributedStringTotalTwo)
        attributeStringForTotalTwo.append(attributedStringNumberTotalTwo)
        attributeStringForTotalTwo.append(attributedStringUnitCustomer)
        lblTotalSalesTwo.attributedText = attributeStringForTotalTwo
        
        if chartStatisticsCustomer == nil {
            chartStatisticsCustomer = Bundle.main.loadNibNamed(String(describing: ChartStatisticsCustomer.self), owner: self, options: nil)!.first as! ChartStatisticsCustomer
            vwStoreChart.addSubview(chartStatisticsCustomer)
            chartStatisticsCustomer.translatesAutoresizingMaskIntoConstraints = false
            chartStatisticsCustomer.topAnchor.constraint(equalTo: vwStoreChart.topAnchor).isActive = true
            chartStatisticsCustomer.centerXAnchor.constraint(equalTo: vwStoreChart.centerXAnchor).isActive = true
            chartStatisticsCustomer.widthAnchor.constraint(equalToConstant: 300).isActive = true
            chartStatisticsCustomer.heightAnchor.constraint(equalToConstant: 300).isActive = true
            
            if lblTotalCustomer == nil {
                var test:String = "0"
                if let dt = self.data {
                    if let totalCustomers = dt["total_customers"] as? Int64{
                        test = "\(totalCustomers.toTextPrice())"
                    }
                }
                lblTotalCustomer = UILabel(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 10, height: 10)))
                lblTotalCustomer.numberOfLines = 0
                lblTotalCustomer.lineBreakMode = .byWordWrapping
                attributedStringTotalCustomer.addAttribute(NSParagraphStyleAttributeName, value: paragraph, range: NSRangeFromString(attributedStringUnitSales.string))
                attributedStringTotalCustomer.append(NSMutableAttributedString(string: "\n\(test)", attributes: [NSFontAttributeName:UIFont(name: Theme.font.bold, size: Theme.fontSize.larger)!,NSForegroundColorAttributeName:UIColor(hex:Theme.colorDBTotalChartNormal),NSParagraphStyleAttributeName:paragraph]))
                lblTotalCustomer.attributedText = attributedStringTotalCustomer
                chartStatisticsCustomer .addSubview(lblTotalCustomer)
                lblTotalCustomer.translatesAutoresizingMaskIntoConstraints = false
                lblTotalCustomer.centerXAnchor.constraint(equalTo: chartStatisticsCustomer.centerXAnchor).isActive = true
                lblTotalCustomer.centerYAnchor.constraint(equalTo: chartStatisticsCustomer.centerYAnchor).isActive = true
            }
            
            lblCustomerRegister.font = UIFont(name: Theme.font.normal, size: Theme.fontSize.small)!
            lblCustomerRegister.textColor = UIColor(hex:Theme.colorDBTextNormal)
            
            lblNumberCustomerRegister.font = UIFont(name: Theme.font.normal, size: Theme.fontSize.small)!
            lblNumberCustomerRegister.textColor = UIColor(hex:Theme.colorDBTextNormal)
            
            lblOther.font = UIFont(name: Theme.font.normal, size: Theme.fontSize.small)!
            lblOther.textColor = UIColor(hex:Theme.colorDBTextNormal)
            
            lblNumberOther.font = UIFont(name: Theme.font.normal, size: Theme.fontSize.small)!
            lblNumberOther.textColor = UIColor(hex:Theme.colorDBTextNormal)
            
            lblPotentialDistributors.font = UIFont(name: Theme.font.normal, size: Theme.fontSize.small)!
            lblPotentialDistributors.textColor = UIColor(hex:Theme.colorDBTextNormal)
            
            lblNumberPotentialDistributors.font = UIFont(name: Theme.font.normal, size: Theme.fontSize.small)!
            lblNumberPotentialDistributors.textColor = UIColor(hex:Theme.colorDBTextNormal)
            
            lblOther.text = "other".localized()
            
            
            if let dt = self.data {
                if let customers = dt["customers"] as? [JSON]{
                    var listGroup:[String] = []
                    var listValue:[Double] = []
                    var totalOther:Double = 0
                    var totalcustomerregister: Double = 0
                    var totaldistributor:Double = 0
                    _ = customers.map({
                        if let id = $0["id"] as? Int64{
                            if Int64(id) == 1 {
                                if let name = $0["name"] as? String{
                                    lblCustomerRegister.text = name
                                    listGroup.append(name)
                                }
                                if let total = $0["total"] as? Double{
                                    lblNumberCustomerRegister.text = "\(total.cleanValue)"
                                    totalcustomerregister = total
                                }
                            } else if Int64(id) == 2 {
                                if let name = $0["name"] as? String{
                                    lblPotentialDistributors.text = name
                                    listGroup.append(name)
                                }
                                if let total = $0["total"] as? Double{
                                    lblNumberPotentialDistributors.text = "\(total.cleanValue)"
                                    totaldistributor = total
                                }
                            } else {
                                if let total = $0["total"] as? Double{
                                    totalOther += total
                                }
                            }
                            
                        }
                    })
                    
                    listValue.append(totalcustomerregister)
                    listValue.append(totaldistributor)
                    listValue.append(totalOther)
                    
                    lblNumberOther.text = "\(totalOther.cleanValue)"
                    if listValue.count > 0 {
                        listGroup.append("other".localized())
                        
                        chartStatisticsCustomer.setChart(listGroup, values: listValue)
                    }
                }
            }
            
        }
    }
    
    func loadTotalSales(total:String) {
        if stackViewSub != nil {
            stackViewSub.removeFromSuperview()
        }
        if vwStoreChart != nil {
            vwStoreChart.removeFromSuperview()
        }
        self.layoutIfNeeded()
        self.setNeedsDisplay()
        
        attributedStringUnitSales.addAttribute(NSParagraphStyleAttributeName, value: paragraph, range: NSRangeFromString(attributedStringUnitSales.string))
        
        let size = "\(total)".size(attributes: [NSFontAttributeName:UIFont(name: Theme.font.bold, size: Theme.fontSize.larger)!,NSParagraphStyleAttributeName:paragraph])
        
        // total sales
        let attributedStringTotalSales = NSMutableAttributedString(string:"\("total_revenue".localized())\n", attributes: [NSFontAttributeName:UIFont(name: Theme.font.bold, size: Theme.fontSize.medium)!,NSForegroundColorAttributeName:UIColor(hex:Theme.colorDBTotalChartNormal),NSParagraphStyleAttributeName:paragraph])
        let attributedStringNumberTotalSales = NSMutableAttributedString(
            string: "\(total)\n",
            attributes: [NSFontAttributeName:UIFont(name: Theme.font.bold, size: Theme.fontSize.larger)!,
                         NSForegroundColorAttributeName:UIColor(_gradient: Theme.colorGradient, frame: CGRect(x: 0, y: 0, width: size.width + 5, height: size.height), isReverse: false),
                         NSParagraphStyleAttributeName:paragraph])
        
        let attributeStringForTotalSales = NSMutableAttributedString(attributedString: attributedStringTotalSales)
        attributeStringForTotalSales.append(attributedStringNumberTotalSales)
        attributeStringForTotalSales.append(attributedStringUnitSales)
        lblTotalSales.attributedText = attributeStringForTotalSales
    }
}
