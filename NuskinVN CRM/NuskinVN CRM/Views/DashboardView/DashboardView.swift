//
//  DashboardView.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 9/22/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import UIKit
import CoreData

class DashboardView: CViewSwitchLanguage {

    
    @IBOutlet var stackView: UIStackView!
    @IBOutlet var scrollView: UIScrollView!
    
    var onSelectFilter:((NSDate,NSDate,Bool)->Void)? /*fromDate, toDate, isGetAll*/
    var involkeFunctionView:((CustomerDO,Bool)->Void)?
    
    //custom view
    var menuDashboard:MenuDashboardView = Bundle.main.loadNibNamed("MenuDashboardView", owner: self, options: nil)?.first as! MenuDashboardView
    var totalSummaryView:TotalSummaryView!
    var totalSalesView:TotalSummaryView!
    var totalSummaryCustomerView:TotalSummaryView!
    var chartStatisticsOrder:ChartStatisticsOrder!
    var chartStatisticsOrder1:ChartStatisticsOrder!
    var topProductView: TopProductView!
    var birthdayCustomerListView:BirthdayCustomerListView = Bundle.main.loadNibNamed("BirthdayCustomerListView", owner: self, options: nil)!.first as! BirthdayCustomerListView
    var birthdayDontOrder30:BirthdayCustomerListView = Bundle.main.loadNibNamed("BirthdayCustomerListView", owner: self, options: nil)!.first as! BirthdayCustomerListView
    
    // MARK: - INIT
    override func awakeFromNib() {
        super.awakeFromNib()
        NotificationCenter.default.addObserver(self, selector: #selector(DashboardView.reloadWhenDetectRotation), name: NSNotification.Name(rawValue: "App:DeviceRotate"), object: nil)
        configView()
        
        // block menu
        menuDashboard.onSelectFilter = {[weak self] from,to,lifetime in
            guard let _self = self else {return}
            _self.onSelectFilter?(from,to,lifetime)
        }
        
        // menu
        stackView.insertArrangedSubview(menuDashboard, at: stackView.arrangedSubviews.count)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "App:DeviceRotation"), object: self)
    }
    
    // MARK: - INTERFACE
    func configView () {
        
        
        
        // block summary
        totalSummaryView = Bundle.main.loadNibNamed(String(describing: TotalSummaryView.self), owner: self, options: nil)?.first as! TotalSummaryView
        
        // block total
        totalSalesView = Bundle.main.loadNibNamed(String(describing: TotalSummaryView.self), owner: self, options: nil)!.last as! TotalSummaryView
        
        //block chart summary customer
        totalSummaryCustomerView = Bundle.main.loadNibNamed(String(describing: TotalSummaryView.self), owner: self, options: nil)!.last as! TotalSummaryView
        
        //block chart order
        chartStatisticsOrder = Bundle.main.loadNibNamed(String(describing: ChartStatisticsOrder.self), owner: self, options: nil)!.first as! ChartStatisticsOrder
        
        //block chart order
        chartStatisticsOrder1 = Bundle.main.loadNibNamed(String(describing: ChartStatisticsOrder.self), owner: self, options: nil)!.first as! ChartStatisticsOrder

        //block top product
        topProductView = Bundle.main.loadNibNamed("TopProductView", owner: self, options: nil)!.first as! TopProductView
        
//        stackView.insertArrangedSubview(topProductView, at: stackView.arrangedSubviews.count)
//        stackView.insertArrangedSubview(birthdayCustomerListView, at: stackView.arrangedSubviews.count)
    }
    
    override func reload(_ data:JSON) {
        
        if stackView.arrangedSubviews.count > 0 {
            _ = stackView.arrangedSubviews.map({
                if !$0.isEqual(menuDashboard) {
                    $0.removeFromSuperview()
                }
            })
            configView()
        }
        
        if let totalCustomer = data["total_orders_invalid"],
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
            let data3 = data["total_orders_not_processed"],
            let totalCustomer = data["total_orders_invalid"]{
            chartStatisticsOrder.reload(data)
            stackView.insertArrangedSubview(chartStatisticsOrder, at: stackView.arrangedSubviews.count)
            chartStatisticsOrder.setTitleOption(one: "process".localized(), two: "unprocess".localized(), three: "invalid".localized())
            chartStatisticsOrder.setChart(["",""], values: [Double(data2 as! String)!,Double(data3 as! String)!,Double(totalCustomer as! String)!])
        } else {
            chartStatisticsOrder.removeFromSuperview()
        }

        if let data2 = data["total_orders_no_charge"],
            let data3 = data["total_orders_money_collected"]{
            chartStatisticsOrder1.reload(data)
            stackView.insertArrangedSubview(chartStatisticsOrder1, at: stackView.arrangedSubviews.count)
            chartStatisticsOrder1.setTitleOption(one: "money_collected".localized(), two: "no_charge".localized())
            chartStatisticsOrder1.setChart(["",""], values: [Double(data3 as! String)!,Double(data2 as! String)!])
        } else {
            chartStatisticsOrder1.removeFromSuperview()
        }
        
        // top 10 product
        if let data2 = data["top_ten_product"] as? [JSON]{
            stackView.insertArrangedSubview(topProductView, at: stackView.arrangedSubviews.count)
            topProductView.loadData(data: data2)
        } else {
            topProductView.removeFromSuperview()
        }
        
        // block customer ordered before 30 days
        stackView.insertArrangedSubview(birthdayDontOrder30, at: stackView.arrangedSubviews.count)
        birthdayDontOrder30.reloadData(true,forceRemoveButtonCheck: true)
        birthdayDontOrder30.involkeFunctionView = {[weak self] customer, sender in
            guard let _self = self else {return}
            _self.involkeFunctionView?(customer,true)
        }
        birthdayDontOrder30.needReloadData = {[weak self] in
            guard let _self = self else {return}
            _self.birthdayDontOrder30.reloadData(true,forceRemoveButtonCheck: true)
        }
        
        // block customer have birthday today
        stackView.insertArrangedSubview(birthdayCustomerListView, at: stackView.arrangedSubviews.count)
        birthdayCustomerListView.reloadData(false,forceRemoveButtonCheck: true)
        birthdayCustomerListView.involkeFunctionView = {[weak self] customer, sender in
            guard let _self = self else {return}
            _self.involkeFunctionView?(customer,false)
        }
        birthdayCustomerListView.needReloadData = {[weak self] in
            guard let _self = self else {return}
            _self.birthdayCustomerListView.reloadData(false,forceRemoveButtonCheck: true)
        }
    }
    
    override func reloadTexts() {
        // set text here
    }
    
    func reloadWhenDetectRotation () {
        
    }
}
