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
    var chartStatisticsSales:ChartStatisticsSales!
    var chartStatisticsOrder:ChartStatisticsOrder!
    var chartStatisticsCustomer:ChartStatisticsCustomer!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configView()
        
    }
    
    func configView () {
        totalSummaryView = Bundle.main.loadNibNamed(String(describing: TotalSummaryView.self), owner: self, options: nil)?.first as! TotalSummaryView
        totalSummaryView.configSummary(totalCustomer: "100", totalOrderComplete: "50", totalOrderUnComplete: "30")
        
        totalSalesView = Bundle.main.loadNibNamed(String(describing: TotalSummaryView.self), owner: self, options: nil)!.last as! TotalSummaryView
        totalSalesView.configSales(total: "100", totalOne: "50", totalTwo: "30")
        
        chartStatisticsSales = Bundle.main.loadNibNamed(String(describing: ChartStatisticsSales.self), owner: self, options: nil)!.first as! ChartStatisticsSales
        
        chartStatisticsOrder = Bundle.main.loadNibNamed(String(describing: ChartStatisticsOrder.self), owner: self, options: nil)!.first as! ChartStatisticsOrder
        
        chartStatisticsCustomer = Bundle.main.loadNibNamed(String(describing: ChartStatisticsCustomer.self), owner: self, options: nil)!.first as! ChartStatisticsCustomer
        
        stackView.insertArrangedSubview(totalSummaryView, at: stackView.arrangedSubviews.count)
        stackView.insertArrangedSubview(totalSalesView, at: stackView.arrangedSubviews.count)
        stackView.insertArrangedSubview(chartStatisticsSales, at: stackView.arrangedSubviews.count)
        stackView.insertArrangedSubview(chartStatisticsCustomer, at: stackView.arrangedSubviews.count)
        stackView.insertArrangedSubview(chartStatisticsOrder, at: stackView.arrangedSubviews.count)
    }
}
