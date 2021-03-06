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
    @IBOutlet weak var indicatorLoading: UIActivityIndicatorView!
    
    var onSelectFilter:((NSDate,NSDate,Bool)->Void)? /*fromDate, toDate, isGetAll*/
    var involkeFunctionView:((Customer,Bool)->Void)?
    var gotoOrderList:((Int64)->Void)?
    var gotoOrderListByCustomerID:(([Int64])->Void)?
    
    //custom view
    var menuDashboard:MenuDashboardView = Bundle.main.loadNibNamed("MenuDashboardView", owner: self, options: nil)?.first as! MenuDashboardView
    var totalSummaryView:TotalSummaryView!
    var totalSalesView:TotalSummaryView!
    var totalSummaryCustomerView:TotalSummaryView!
    var chartStatisticsOrder:ChartStatisticsOrder!
    var chartStatisticsOrder1:ChartStatisticsPie!
    var chartQuarter:ChartStatisticsCombined!
    var topProductView: TopProductView!
    var birthdayCustomerListView:BirthdayCustomerListView = Bundle.main.loadNibNamed("BirthdayCustomerListView", owner: self, options: nil)!.first as! BirthdayCustomerListView
    var birthdayDontOrder30:BirthdayCustomerListView = Bundle.main.loadNibNamed("BirthdayCustomerListView", owner: self, options: nil)!.first as! BirthdayCustomerListView
    
    var maxTopProduct:Int = 10
    var fromDate:NSDate? = nil
    var toDate:NSDate? = nil
    var isLifeTime: Bool = true
    
    // MARK: - INIT
    override func awakeFromNib() {
        super.awakeFromNib()
        NotificationCenter.default.addObserver(self, selector: #selector(DashboardView.reloadWhenDetectRotation), name: NSNotification.Name(rawValue: "App:DeviceRotate"), object: nil)
        configView()
        
        // block menu
        menuDashboard.onSelectFilter = {[weak self] from,to,lifetime in
            guard let _self = self else {return}
            _self.fromDate = from
            _self.toDate = to
            _self.isLifeTime = lifetime
            _self.onSelectFilter?(from,to,lifetime)
        }
        
        // next tutorial from menu dashboard
        menuDashboard.getNextTutorial = {[weak self] in
            guard let _self = self else {return}
            _self.startTutorial()
        }
        
        // menu
        stackView.insertArrangedSubview(menuDashboard, at: 0)
        menuDashboard.updateControlsYear(nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "App:DeviceRotation"), object: self)
    }
    
    // MARK: - private
    func configView () {
        
        // block summary
        totalSummaryView = Bundle.main.loadNibNamed(String(describing: TotalSummaryView.self), owner: self, options: nil)?.first as! TotalSummaryView
        totalSummaryView.gotoOrderList = {[weak self] status in
            guard let _self = self else {return}
            _self.gotoOrderList?(status)
        }
        
        // block total
        totalSalesView = Bundle.main.loadNibNamed(String(describing: TotalSummaryView.self), owner: self, options: nil)!.last as! TotalSummaryView
        
        //block chart summary customer
        totalSummaryCustomerView = Bundle.main.loadNibNamed(String(describing: TotalSummaryView.self), owner: self, options: nil)!.last as! TotalSummaryView
        
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
    }
    
    // MARK: - interface
    override func reload(_ data:JSON) {
                
        if stackView.arrangedSubviews.count > 0 {
            _ = stackView.arrangedSubviews.map({
                if !$0.isEqual(menuDashboard) && !$0.isEqual(indicatorLoading){
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
            
            totalSummaryView.getNextTutorial = {[weak self] in
                guard let _self = self else {return}
                _self.startTutorial()
            }
            
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
                
                totalSummaryCustomerView.presentCustomerList = { isOrdered in
                    if let topVC = Support.topVC {
                        let vc = CustomerStatusController(nibName: "CustomerStatusController", bundle: Bundle.main)
                        let nv = UINavigationController(rootViewController: vc)
                        topVC.present(nv, animated: true, completion: { isDone in
                            vc.load(isOrdered)
                        })
                        vc.onGotoOrderList = {[weak self] listIDs in
                            guard let _self = self else {return}
                            _self.gotoOrderListByCustomerID?(listIDs)
                        }
                    }
                }
                
                totalSummaryCustomerView.getNextTutorial = {[weak self] in
                    guard let _self = self else {return}
                    _self.startTutorial()
                }
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
            chartStatisticsOrder1.setChart(["money_collected".localized(),"no_charge".localized()], values: [Double(data3 as! String)!,Double(data2 as! String)!])
        } else {
            chartStatisticsOrder1.removeFromSuperview()
        }

        //block quarter of year for status order
        stackView.insertArrangedSubview(chartQuarter, at: stackView.arrangedSubviews.count)
        chartQuarter.loadData(self.fromDate!,self.toDate!,self.isLifeTime)
        
        // top 10 product
        if let data2 = data["top_ten_product"] as? [JSON]{
            stackView.insertArrangedSubview(topProductView, at: stackView.arrangedSubviews.count)
            topProductView.maxTopProduct = self.maxTopProduct
            topProductView.loadData(data: data2)
            topProductView.getNextTutorial = {[weak self] in
                guard let _self = self else {return}
                _self.startTutorial()
            }
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
        birthdayDontOrder30.getNextTutorial = {[weak self] in
            guard let _self = self else {return}
            _self.startTutorial()
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
        birthdayCustomerListView.getNextTutorial = {[weak self] in
            guard let _self = self else {return}
            _self.startTutorial()
        }
    }
    
    func loading(_ isLoading:Bool = false) {
        if indicatorLoading == nil {
//            onAwake = {[weak self] in
//                guard let _self = self else {return}
//                if isLoading {
//                    _self.indicatorLoading.startAnimating()
//                } else {
//                    _self.indicatorLoading.stopAnimating()
//                }
//
//            }
        } else {
            if isLoading {
                indicatorLoading.startAnimating()
            } else {
                indicatorLoading.stopAnimating()
            }
        }
        
    }
    
    func startTutorial(_ onComplete:(()->Void)? = nil) {
        onComplete?()
        return
        if !AppConfig.setting.isShowTutorial(with: MENU_DASHBOARD_SCENE) {
            menuDashboard.startTutorial(1)
        } else if !AppConfig.setting.isShowTutorial(with: REPORT_STATUS_ORDER_SCENE) {
            totalSummaryView.startTutorial(1)
        } else if !AppConfig.setting.isShowTutorial(with: REPORT_CUSTOMER_ORDER_SCENE) {
            let center = totalSummaryCustomerView.getWindowCenter(to: totalSummaryCustomerView.superview!)
            let point = CGPoint(x:0, y: center.y)
            self.scrollView.setContentOffset(point, animated: true)
            Timer.scheduledTimer(withTimeInterval: 0.6, repeats: false, block: {[weak self] (timer) in
                timer.invalidate()
                guard let _self = self else {return}
                _self.totalSummaryCustomerView.startTutorial(4)
            })
        } else if !AppConfig.setting.isShowTutorial(with: REPORT_PRODUCT_SCENE) && topProductView.superview != nil{
            let center = topProductView.getWindowTop(to: topProductView.superview!)
            let point = CGPoint(x:0, y: center.y)
            self.scrollView.setContentOffset(point, animated: true)
            Timer.scheduledTimer(withTimeInterval: 0.6, repeats: false, block: {[weak self] (timer) in
                timer.invalidate()
                guard let _self = self else {return}
                _self.topProductView.startTutorial(1)
            })
        } else if !AppConfig.setting.isShowTutorial(with: REMINDER_CUSTOMER_SCENE) && birthdayCustomerListView.superview != nil{
            let center = birthdayCustomerListView.getWindowTop(to: birthdayCustomerListView.superview!)
            let point = CGPoint(x:0, y: center.y)
            self.scrollView.setContentOffset(point, animated: true)
            Timer.scheduledTimer(withTimeInterval: 0.4, repeats: false, block: {[weak self] (timer) in
                timer.invalidate()
                guard let _self = self else {return}
                _self.birthdayCustomerListView.startTutorial(1)
            })
        } else if !AppConfig.setting.isShowTutorial(with: CONGRAT_CUSTOMER_SCENE) && birthdayDontOrder30.superview != nil{
            let center = birthdayDontOrder30.getWindowTop(to: birthdayDontOrder30.superview!)
            let point = CGPoint(x:0, y: center.y)
            self.scrollView.setContentOffset(point, animated: true)
            Timer.scheduledTimer(withTimeInterval: 0.4, repeats: false, block: {[weak self] (timer) in
                timer.invalidate()
                guard let _self = self else {return}
                _self.birthdayDontOrder30.startTutorial(2)
            })
        } else {
            onComplete?()
        }
        
    }
    
    override func reloadTexts() {
        // set text here
    }
    
    func reloadWhenDetectRotation () {
        
    }
}
