//
//  DashboardView.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 9/22/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import UIKit

protocol DashboardViewDelegate: class {
    
}

class DashboardView: UIView {

    
    @IBOutlet var stackView: UIStackView!
    
    weak var delegate_: DashboardViewDelegate?
    
    //custom view
    var totalSummaryView:TotalSummaryView!
    var totalSalesView:TotalSummaryView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configView()
        
    }
    
    func configView () {
        totalSummaryView = Bundle.main.loadNibNamed(String(describing: TotalSummaryView.self), owner: self, options: nil)?.first as! TotalSummaryView
        totalSummaryView.configSummary(totalCustomer: "100", totalOrderComplete: "50", totalOrderUnComplete: "30")
        
        totalSalesView = Bundle.main.loadNibNamed(String(describing: TotalSummaryView.self), owner: self, options: nil)!.last as! TotalSummaryView
        totalSalesView.configSales(total: "100", totalOne: "50", totalTwo: "30")
        
        
        stackView.insertArrangedSubview(totalSummaryView, at: stackView.arrangedSubviews.count)
        stackView.insertArrangedSubview(totalSalesView, at: stackView.arrangedSubviews.count)
    }
}
