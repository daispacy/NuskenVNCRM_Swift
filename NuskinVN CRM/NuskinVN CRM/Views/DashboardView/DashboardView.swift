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
    var totalSummaryCustomerView:TotalSummaryView!
    var chartStatisticsOrder:ChartStatisticsOrder!
    var topProductView: TopProductView!
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
        // block summary
        totalSummaryView = Bundle.main.loadNibNamed(String(describing: TotalSummaryView.self), owner: self, options: nil)?.first as! TotalSummaryView
        totalSummaryView.configSummary(totalCustomer: "100", totalOrderComplete: "50", totalOrderUnComplete: "30")
        
        // block total
        totalSalesView = Bundle.main.loadNibNamed(String(describing: TotalSummaryView.self), owner: self, options: nil)!.last as! TotalSummaryView
        totalSalesView.loadTotalSales(total: "550.000.000")
        
        //block chart summary customer
        totalSummaryCustomerView = Bundle.main.loadNibNamed(String(describing: TotalSummaryView.self), owner: self, options: nil)!.last as! TotalSummaryView
        totalSummaryCustomerView.loadChartCustomer(dataChart: ["test"], totalOrdered: "100.000.000", totalNotOrderd: "50.000.000")
        
        //block chart order
        chartStatisticsOrder = Bundle.main.loadNibNamed(String(describing: ChartStatisticsOrder.self), owner: self, options: nil)!.first as! ChartStatisticsOrder

        //block top product
        topProductView = Bundle.main.loadNibNamed("TopProductView", owner: self, options: nil)!.first as! TopProductView
        
        //block customer ordered before 30 days
        birthdayCustomerListView = Bundle.main.loadNibNamed("BirthdayCustomerListView", owner: self, options: nil)!.first as! BirthdayCustomerListView
        
        // insert custom view into stack
        stackView.insertArrangedSubview(totalSummaryView, at: stackView.arrangedSubviews.count)
        stackView.insertArrangedSubview(totalSalesView, at: stackView.arrangedSubviews.count)
        stackView.insertArrangedSubview(totalSummaryCustomerView, at: stackView.arrangedSubviews.count)
        stackView.insertArrangedSubview(chartStatisticsOrder, at: stackView.arrangedSubviews.count)
        stackView.insertArrangedSubview(topProductView, at: stackView.arrangedSubviews.count)
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
