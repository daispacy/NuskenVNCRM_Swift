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

class DashboardView: UIView, BirthdayCustomerListViewDelegate {

    
    @IBOutlet var stackView: UIStackView!
    @IBOutlet var scrollView: UIScrollView!
    
    weak var delegate_: DashboardViewDelegate?
    
    //custom view
    var totalSummaryView:TotalSummaryView!
    var totalSalesView:TotalSummaryView!
    var chartStatisticsSales:ChartStatisticsSales!
    var chartStatisticsOrder:ChartStatisticsOrder!
    var chartStatisticsCustomer:ChartStatisticsCustomer!
    var birthdayCustomerListView:BirthdayCustomerListView!
    
    // MARK: - INIT
    override func awakeFromNib() {
        super.awakeFromNib()
        NotificationCenter.default.addObserver(self, selector: #selector(DashboardView.reloadWhenDetectRotation), name: NSNotification.Name(rawValue: "App:DeviceRotate"), object: nil)
        configView()
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "App:DeviceRotation"), object: self)
    }
    
    // MARK: - INTERFACE
    func configView () {
        totalSummaryView = Bundle.main.loadNibNamed(String(describing: TotalSummaryView.self), owner: self, options: nil)?.first as! TotalSummaryView
        totalSummaryView.configSummary(totalCustomer: "100", totalOrderComplete: "50", totalOrderUnComplete: "30")
        
        totalSalesView = Bundle.main.loadNibNamed(String(describing: TotalSummaryView.self), owner: self, options: nil)!.last as! TotalSummaryView
        totalSalesView.configSales(total: "100", totalOne: "50", totalTwo: "30")
        
        chartStatisticsSales = Bundle.main.loadNibNamed(String(describing: ChartStatisticsSales.self), owner: self, options: nil)!.first as! ChartStatisticsSales
        
        chartStatisticsOrder = Bundle.main.loadNibNamed(String(describing: ChartStatisticsOrder.self), owner: self, options: nil)!.first as! ChartStatisticsOrder
        
        chartStatisticsCustomer = Bundle.main.loadNibNamed(String(describing: ChartStatisticsCustomer.self), owner: self, options: nil)!.first as! ChartStatisticsCustomer
        
        birthdayCustomerListView = Bundle.main.loadNibNamed("BirthdayCustomerListView", owner: self, options: nil)!.first as! BirthdayCustomerListView
        
        stackView.insertArrangedSubview(totalSummaryView, at: stackView.arrangedSubviews.count)
        stackView.insertArrangedSubview(totalSalesView, at: stackView.arrangedSubviews.count)
        stackView.insertArrangedSubview(chartStatisticsSales, at: stackView.arrangedSubviews.count)
        stackView.insertArrangedSubview(chartStatisticsCustomer, at: stackView.arrangedSubviews.count)
        stackView.insertArrangedSubview(chartStatisticsOrder, at: stackView.arrangedSubviews.count)
        stackView.insertArrangedSubview(birthdayCustomerListView, at: stackView.arrangedSubviews.count)
    }
    
    func reloadWhenDetectRotation () {
        if let view = birthdayCustomerListView {
            view.refreshPopupMenu()
        }
    }
}

extension DashboardView {
    func BirthdayCustomerListView(didSelect: BirthdayCustomerListView, customer: Customer) {
        
    }
}
