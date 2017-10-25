//
//  DashboardView.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 9/22/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import UIKit
import CoreData

protocol DashboardViewDelegate: class {
    
}

class DashboardView: CViewSwitchLanguage, BirthdayCustomerListViewDelegate {

    
    @IBOutlet var stackView: UIStackView!
    @IBOutlet var scrollView: UIScrollView!
    
    weak var delegate_: DashboardViewDelegate?
    
    //custom view
    var menuDashboard:MenuDashboardView!
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
        
        // block menu
//        menuDashboard = Bundle.main.loadNibNamed("MenuDashboardView", owner: self, options: nil)?.first as! MenuDashboardView
        
        // block summary
        totalSummaryView = Bundle.main.loadNibNamed(String(describing: TotalSummaryView.self), owner: self, options: nil)?.first as! TotalSummaryView
        
        // block total
        totalSalesView = Bundle.main.loadNibNamed(String(describing: TotalSummaryView.self), owner: self, options: nil)!.last as! TotalSummaryView
        
        //block chart summary customer
        totalSummaryCustomerView = Bundle.main.loadNibNamed(String(describing: TotalSummaryView.self), owner: self, options: nil)!.last as! TotalSummaryView
        
        //block chart order
        chartStatisticsOrder = Bundle.main.loadNibNamed(String(describing: ChartStatisticsOrder.self), owner: self, options: nil)!.first as! ChartStatisticsOrder

        //block top product
//        topProductView = Bundle.main.loadNibNamed("TopProductView", owner: self, options: nil)!.first as! TopProductView
        
        //block customer ordered before 30 days
//        birthdayCustomerListView = Bundle.main.loadNibNamed("BirthdayCustomerListView", owner: self, options: nil)!.first as! BirthdayCustomerListView
        
        // insert custom view into stack
//        stackView.insertArrangedSubview(menuDashboard, at: stackView.arrangedSubviews.count)
        
//        stackView.insertArrangedSubview(topProductView, at: stackView.arrangedSubviews.count)
//        stackView.insertArrangedSubview(birthdayCustomerListView, at: stackView.arrangedSubviews.count)
    }
    
    override func reload(_ data:JSON) {
        
        if let totalCustomer = data["total_customers"],
            let totalOrderComplete = data["total_orders_processed"],
            let totalOrderUncomplete = data["total_orders_not_processed"] {
            stackView.insertArrangedSubview(totalSummaryView, at: stackView.arrangedSubviews.count)
            totalSummaryView.configSummary(totalCustomer: "\(totalCustomer)", totalOrderComplete: "\(totalOrderComplete)", totalOrderUnComplete: "\(totalOrderUncomplete)")
        } else {
            totalSummaryView.removeFromSuperview()
        }
        
        if let data = data["total_orders_amount"] as? Int64{
            stackView.insertArrangedSubview(totalSalesView, at: stackView.arrangedSubviews.count)
            totalSalesView.loadTotalSales(total: "\(data.toTextPrice())")
        } else {
            totalSalesView.removeFromSuperview()
        }
        
        
        if let data2 = data["total_customers_ordered"],
            let data3 = data["total_customers_not_ordered"],
            let listGroupCustomers = data["customers"] as? [JSON]{
            if listGroupCustomers.count > 0 {
                totalSummaryCustomerView.reload(data)
                stackView.insertArrangedSubview(totalSummaryCustomerView, at: stackView.arrangedSubviews.count)
                totalSummaryCustomerView.loadChartCustomer(totalOrdered: "\(data2)", totalNotOrderd: "\(data3)")
            }
        } else {
            totalSummaryCustomerView.removeFromSuperview()
        }
        
        
        if let data2 = data["total_orders_processed"],
            let data3 = data["total_orders_not_processed"]{
            chartStatisticsOrder.reload(data)
            stackView.insertArrangedSubview(chartStatisticsOrder, at: stackView.arrangedSubviews.count)
            chartStatisticsOrder.setChart(["",""], values: [Double(data2 as! String)!,Double(data3 as! String)!])
        } else {
            chartStatisticsOrder.removeFromSuperview()
        }
        
    }
    
    override func reloadTexts() {
        // set text here
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
