//
//  DashboardCustomerController.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 11/8/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import UIKit

class DashboardCustomerController: UIViewController {

    @IBOutlet var stackView: UIStackView!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var btnClose: UIButton!
    @IBOutlet var lblNam: UILabel!
    //custom view
    var menuDashboard:MenuDashboardView = Bundle.main.loadNibNamed("MenuDashboardView", owner: self, options: nil)?.first as! MenuDashboardView
    var totalSummaryView:TotalSummaryView!
    var totalSalesView:TotalSummaryView!
    var totalPVView:TotalSummaryView!
    var chartStatisticsOrder:ChartStatisticsOrder!
    var chartStatisticsOrder1:ChartStatisticsPie!
    var chartQuarter:ChartStatisticsCombined!
    var topProductView: TopProductView!
    
    // properties
    var fromDate:NSDate? = nil
    var toDate:NSDate? = nil
    var isLifeTime: Bool = true
    var maxTopProduct:Int = 10
    
    var customer:CustomerDO?
    
    // MARK: - INIT
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        self.providesPresentationContextTransitionStyle = true
        self.definesPresentationContext = true
        self.modalPresentationStyle=UIModalPresentationStyle.overCurrentContext
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // block menu
        let height:NSLayoutConstraint = menuDashboard.heightAnchor.constraint(equalToConstant: 130)
        height.priority = 750
        menuDashboard.addConstraint(height)
        menuDashboard.onSelectFilter = {[weak self] from,to,lifetime in
            guard let _self = self else {return}
            _self.fromDate = from
            _self.toDate = to
            _self.isLifeTime = lifetime
            _self.getReport()
        }
        
        // menu
        stackView.insertArrangedSubview(menuDashboard, at: stackView.arrangedSubviews.count)
        
        menuDashboard.updateControlsYear(nil)
    }
    
    // MARK: - event
    @IBAction func closeEvent(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - private
    func getReport() {
        guard let cus = self.customer else {self.dismiss(animated: true, completion: nil); return}
        if let name = cus.fullname {
            lblNam.text = name.uppercased()
        } else {
            lblNam.text = ""
        }
        
        UserManager.getDataCustomerDashboard(self.fromDate, toDate: self.toDate, isLifeTime: self.isLifeTime, customer: cus) {[weak self] data in
            guard let _self = self else {return}
            DispatchQueue.main.async {
                _self.reload(data)
            }
        }
    }
    
    func configView () {
        
        // block summary
        totalSummaryView = Bundle.main.loadNibNamed(String(describing: TotalSummaryView.self), owner: self, options: nil)?.first as! TotalSummaryView
        
        // block total
        totalSalesView = Bundle.main.loadNibNamed(String(describing: TotalSummaryView.self), owner: self, options: nil)!.last as! TotalSummaryView
        
        // block total PV
        totalPVView = Bundle.main.loadNibNamed(String(describing: TotalSummaryView.self), owner: self, options: nil)!.last as! TotalSummaryView
        
        //block chart order
        chartStatisticsOrder = Bundle.main.loadNibNamed(String(describing: ChartStatisticsOrder.self), owner: self, options: nil)!.first as! ChartStatisticsOrder
        
        //block chart order
        chartStatisticsOrder1 = Bundle.main.loadNibNamed(String(describing: ChartStatisticsPie.self), owner: self, options: nil)!.first as! ChartStatisticsPie
        
        //block chart quarter
        chartQuarter = Bundle.main.loadNibNamed(String(describing: ChartStatisticsCombined.self), owner: self, options: nil)!.first as! ChartStatisticsCombined
        
        //block top product
        topProductView = Bundle.main.loadNibNamed("TopProductView", owner: self, options: nil)!.first as! TopProductView
        topProductView.onMoreProduct = {[weak self] in
            guard let _self = self else {return}
            _self.maxTopProduct += 10
            _self.topProductView.maxTopProduct = _self.maxTopProduct
            _self.topProductView.reloadData()
        }
        
        lblNam.textColor = UIColor.white
        lblNam.font = UIFont(name: Theme.font.bold, size: Theme.fontSize.medium)
    }
    
    // MARK: - interface
    func reload(_ data:JSON) {
        
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
        
        if let data = data["total_pv_amount"] as? Int64{
            stackView.insertArrangedSubview(totalPVView, at: stackView.arrangedSubviews.count)
            totalPVView.loadTotalPV(total: "\(data.toTextPrice())")
        } else {
            totalPVView.removeFromSuperview()
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
        
        //block quarter of year for status order
        stackView.insertArrangedSubview(chartQuarter, at: stackView.arrangedSubviews.count)
        chartQuarter.loadData(self.fromDate!,self.toDate!,self.isLifeTime,self.customer)
        
        // top 10 product
        if let data2 = data["top_ten_product"] as? [JSON]{
            stackView.insertArrangedSubview(topProductView, at: stackView.arrangedSubviews.count)
            topProductView.maxTopProduct = self.maxTopProduct
            topProductView.loadData(data: data2)
        } else {
            topProductView.removeFromSuperview()
        }
        
        // top 10 product
        if let data2 = data["top_ten_product"] as? [JSON]{
            stackView.insertArrangedSubview(topProductView, at: stackView.arrangedSubviews.count)
            topProductView.loadData(data: data2)
        } else {
            topProductView.removeFromSuperview()
        }
    }
}
