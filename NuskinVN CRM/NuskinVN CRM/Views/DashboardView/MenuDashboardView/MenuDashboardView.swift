//
//  MenuDashboardView.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 10/2/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import UIKit

class MenuDashboardView: CViewSwitchLanguage {

    @IBOutlet var btnDay: UIButton!
    @IBOutlet var btnWeek: UIButton!
    @IBOutlet var btnMonth: UIButton!
    @IBOutlet var lblDay: UILabel!
    @IBOutlet var lblWeek: UILabel!
    @IBOutlet var lblMonth: UILabel!
    
    var onSelectFilter:((NSDate,NSDate,Bool)->Void)? /*fromDate, toDate, isGetAll*/
    
    var currentMonth:Int {
        let calendar = Calendar.autoupdatingCurrent
        let components = calendar.dateComponents([.month], from: Date())
        return components.month!
    }
    
    var currentYear:Int {
        let calendar = Calendar.autoupdatingCurrent
        let components = calendar.dateComponents([.year], from: Date())
        return components.year!
    }
    
    var listWeek:[JSON] {
        var data:[JSON] = [["id":"0","text":"all".localized()]]
        for i in 1 ..< 5 {
            data.append(["id":"\(i)","text":"\(i)".localized()])
        }
        return data
    }
    
    var listMonth:[JSON] {
        var data:[JSON] = [["id":"0","text":"all".localized()]]
        for i in 1 ..< 13 {
            data.append(["id":"\(i)","text":"\(i)".localized()])
        }
        return data
    }
    
    var listDay:[JSON] {
        var numDays = 32
        var startFrom = 1
        var mth: Int = currentMonth
        if self.month != "all".localized() {
            mth = Int(self.month)!
        }
        
        let dateComponents = DateComponents(year: currentYear, month: mth)
        let calendar = Calendar.current
        let date = calendar.date(from: dateComponents)!
        
        let range = calendar.range(of: .day, in: .month, for: date)!
        numDays = range.count + 1
        
        if self.week != "all".localized() {
            startFrom = (Int(self.week)!-1) * 7
            if startFrom == 0 {
                startFrom = 1
            }
            if Int(self.week) != 4 {
                numDays = (Int(self.week)!) * 7
            }
        }
        
        var data:[JSON] = [["id":"0","text":"all".localized()]]
        for i in startFrom ..< numDays {
            data.append(["id":"\(i)","text":"\(i)".localized()])
        }
        return data
    }
    
    var week:String = "all".localized()
    var day:String = "all".localized()//Date.init(timeIntervalSinceNow: 0).toString(dateFormat: "dd")
    var month:String = "all".localized()//Date.init(timeIntervalSinceNow: 0).toString(dateFormat: "MM")
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configView()
        configText()
    }
    
    override func reloadTexts() {
        configText()
    }
    
    // MARK: - event
    @IBAction func processButtonEvent(_ sender: UIButton) {
        var data:[JSON] = []
        if sender.isEqual(btnDay) {
            data = listDay
        } else if sender.isEqual(btnWeek) {
            data = listWeek
            self.btnDay.setTitle("all".localized(), for: .normal)
            self.day = "all".localized()
        } else if sender.isEqual(btnMonth) {
            data = listMonth
            self.btnDay.setTitle("all".localized(), for: .normal)
            self.day = "all".localized()
        }
        showPopupWithData(data:data, sender: sender) {[weak self] (item) in
            guard let _self = self else {return}
            if sender.isEqual(_self.btnDay) {
                _self.day = (item["text"] as! String)
            } else if sender.isEqual(_self.btnWeek) {
                _self.week = (item["text"] as! String)
            } else if sender.isEqual(_self.btnMonth) {
                _self.month = (item["text"] as! String)
            }
            _self.configText()
            _self.convertToDateAndInvolve()
        }
    }
    
    // MARK: - private
    func convertToDateAndInvolve() {
        var isLifeTime:Bool = true
        var fromDate:NSDate = Date.init(timeIntervalSinceNow: 0) as NSDate
        var toDate:NSDate = Date.init(timeIntervalSinceNow: 0) as NSDate
        
        if self.day != "all".localized() ||
            self.month != "all".localized() ||
            self.week != "all".localized() {
            isLifeTime = false
        }
        if !isLifeTime {
            
            var mth = currentMonth
            if self.month != "all".localized() {
                mth = Int(self.month)!
            }
            if self.week != "all".localized() && self.day == "all".localized(){
                if let frDateStr = listDay[1]["text"] as? String,
                    let toDateStr = listDay.last!["text"] as? String {
                    fromDate = "\(currentYear)-\(mth)-\(frDateStr) 00:00:00".toDate2() as NSDate
                    toDate = "\(currentYear)-\(mth)-\(toDateStr) 23:59:59".toDate2() as NSDate
                }
            } else {
                if self.day != "all".localized() {
                    fromDate = "\(currentYear)-\(mth)-\(self.day) 00:00:00".toDate2() as NSDate
                    toDate = "\(currentYear)-\(mth)-\(self.day) 23:59:59".toDate2() as NSDate
                } else {
                    if let frDateStr = listDay[1]["text"] as? String,
                        let toDateStr = listDay.last!["text"] as? String {
                        fromDate = "\(currentYear)-\(mth)-\(frDateStr) 00:00:00".toDate2() as NSDate
                        toDate = "\(currentYear)-\(mth)-\(toDateStr) 23:59:59".toDate2() as NSDate
                    }
                    
                }
            }
        }
        self.onSelectFilter?(fromDate, toDate, isLifeTime)
    }
    
    func showPopupWithData(data:[JSON],sender:UIButton,_ onSelectItem:@escaping ((JSON)->Void)) {
        let popupC = PopupController(nibName: "PopupController", bundle: Bundle.main)
        popupC.textAlignment = .center
        popupC.onSelectObject = {[weak self]
            item in
            guard let _ = self else {return}
            onSelectItem(item)
        }
        popupC.onDismiss = {[weak self] in
            guard let _ = self else {return}
            sender.imageView!.transform = sender.imageView!.transform.rotated(by: CGFloat(Double.pi))
        }
        var topVC = UIApplication.shared.keyWindow?.rootViewController
        while((topVC!.presentedViewController) != nil){
            topVC = topVC!.presentedViewController
        }
        topVC?.present(popupC, animated: false, completion: {[weak self] isDone in
            guard let _ = self else {return}
            sender.imageView!.transform = sender.imageView!.transform.rotated(by: CGFloat(Double.pi))
        })
        popupC.show(data, fromView: sender)
    }
    
    func configText() {
        btnDay.setTitle("\(day)", for: .normal)
        btnWeek.setTitle("\(week)", for: .normal)
        btnMonth.setTitle("\(month)", for: .normal)
        
        lblDay.text = "day".localized().capitalized
        lblMonth.text = "month".localized().capitalized
        lblWeek.text = "week".localized().capitalized
    }
    
    func configView() {
        btnDay.titleLabel?.font = UIFont(name: Theme.font.normal, size: Theme.fontSize.normal)
        btnWeek.titleLabel?.font = UIFont(name: Theme.font.normal, size: Theme.fontSize.normal)
        btnMonth.titleLabel?.font = UIFont(name: Theme.font.normal, size: Theme.fontSize.normal)
        
        btnDay.setTitleColor(UIColor(hex:Theme.colorDBTextNormal), for: .normal)
        btnWeek.setTitleColor(UIColor(hex:Theme.colorDBTextNormal), for: .normal)
        btnMonth.setTitleColor(UIColor(hex:Theme.colorDBTextNormal), for: .normal)
        
        btnDay.layer.borderWidth = 1.0
        btnDay.layer.masksToBounds = true
        btnDay.layer.cornerRadius = 5
        btnDay.layer.borderColor = UIColor(hex:Theme.colorDBBackgroundDashboard).cgColor
        
        btnWeek.layer.borderWidth = 1.0
        btnWeek.layer.masksToBounds = true
        btnWeek.layer.cornerRadius = 5
        btnWeek.layer.borderColor = UIColor(hex:Theme.colorDBBackgroundDashboard).cgColor
        
        btnMonth.layer.borderWidth = 1.0
        btnMonth.layer.masksToBounds = true
        btnMonth.layer.cornerRadius = 5
        btnMonth.layer.borderColor = UIColor(hex:Theme.colorDBBackgroundDashboard).cgColor
        
        btnDay.titleEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0)
        btnMonth.titleEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0)
        btnWeek.titleEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0)
        
        lblDay.font = UIFont(name: Theme.font.normal, size: Theme.fontSize.normal)
        lblWeek.font = UIFont(name: Theme.font.normal, size: Theme.fontSize.normal)
        lblMonth.font = UIFont(name: Theme.font.normal, size: Theme.fontSize.normal)
    }
}
