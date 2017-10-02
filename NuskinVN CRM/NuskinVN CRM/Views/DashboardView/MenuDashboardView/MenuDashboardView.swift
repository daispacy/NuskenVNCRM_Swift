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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configView()
        configText()
    }
    
    override func reloadTexts() {
        configText()
    }
    
    @IBAction func processButtonEvent(_ sender: UIButton) {
        let popupC = PopupController(nibName: "PopupController", bundle: Bundle.main)
        popupC.onSelect = {
            item, index in
            print("\(item) \(index)")
        }
        popupC.onDismiss = {
            sender.imageView!.transform = sender.imageView!.transform.rotated(by: CGFloat(Double.pi))
        }
        var topVC = UIApplication.shared.keyWindow?.rootViewController
        while((topVC!.presentedViewController) != nil){
            topVC = topVC!.presentedViewController
        }
        topVC?.present(popupC, animated: false, completion: {isDone in
            sender.imageView!.transform = sender.imageView!.transform.rotated(by: CGFloat(Double.pi))            
        })
        popupC.show(data: ["item 1","item 2","item 1","item 2","item 1","item 2","item 1","item 2","item 1","item 2"], fromView: sender)
    }
    
    
    func configText() {
        btnDay.setTitle("\("day".localized())", for: .normal)
        btnWeek.setTitle("\("week".localized())", for: .normal)
        btnMonth.setTitle("\("month".localized())", for: .normal)
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
    }
}
