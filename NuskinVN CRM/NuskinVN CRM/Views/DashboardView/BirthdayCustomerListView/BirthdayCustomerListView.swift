//
//  BirthdayCustomerListView.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 9/24/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import UIKit
import CoreData

var BlockCustomerView_associated: String = "BlockCustomerView"


class CustomerBlockView: CViewSwitchLanguage {
    
    @IBOutlet var imgvAvatar: UIImageView!
    @IBOutlet var vwStatus: UIView!
    @IBOutlet var lblName: UILabel!
    @IBOutlet var lblBirthday: UILabel!
    @IBOutlet var bottomLine: UIView!
    @IBOutlet var lblStatus: UILabel!
    
    var tapOpenPopup:UITapGestureRecognizer?
    var object:Any?
    
    // MARK: - INIT
   
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configView()
        
        tapOpenPopup = UITapGestureRecognizer(target: self, action: #selector(self.openPopup))
        self.addGestureRecognizer(tapOpenPopup!)
    }
    
    deinit {
         self.removeGestureRecognizer(tapOpenPopup!)
    }
    
    override func reloadTexts() {
        // set text here
    }
    
    // MARK: - INTERFACE
    func showInfoCustomer(customer:CustomerDO?) {
        guard let data = customer else { return }
        
        object = data
       
        lblName.text = "\(data.fullname)"
        
//        lblBirthday.text = data.birthday
//        imgvAvatar.image = UIImage(named:"checkbox_check")
        
        if(data.status == 1) {
            vwStatus.backgroundColor = UIColor(hex:"0x009688")
            lblStatus.text = "reminded".localized()
        } else {
            vwStatus.backgroundColor = UIColor(hex:"0xf44336")
            lblStatus.text = "not_prompted".localized()
        }
        lblStatus.textColor = vwStatus.backgroundColor
        
    }
    
    func hideBottomLine(isHide:Bool) {
        if(isHide) {
            bottomLine.backgroundColor = UIColor.clear
        }
    }
    
    
    // MARK: - EVENT
    @objc private func openPopup() {
        
    }
    
    // MARK: - PRIVATE
    private func configView() {
        lblName.textColor = UIColor(hex:Theme.colorDBTextNormal)
        lblName.font = UIFont(name: Theme.font.normal, size: Theme.fontSize.normal)
        
        lblStatus.font = UIFont(name: Theme.font.normal, size: Theme.fontSize.small)
        
        lblBirthday.textColor = UIColor(hex:Theme.colorDBTextNormal)
        lblBirthday.font = UIFont(name: Theme.font.normal, size: Theme.fontSize.normal)
        
        bottomLine.backgroundColor = UIColor(hex:Theme.colorDBBackgroundDashboard)
    }
}

class BirthdayCustomerListView: UIView {

    @IBOutlet var lblTitle: CLabelGradient!
    @IBOutlet var stackListCustomer: UIStackView!
    
    fileprivate var customerSelected:CustomerDO?
    
    // MARK: - INIT
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configView()
    }

    // MARK: - INTERFACE
    func reloadListCustomer(_ listCustomers:[CustomerDO]?) {
        guard let data = listCustomers else { return }
        
        var i:Int = 0
        for item in data {
            let customerView = Bundle.main.loadNibNamed("CustomerBlockView", owner: self, options: nil)!.first as! CustomerBlockView
            customerView.showInfoCustomer(customer: item)
            
            customerView.hideBottomLine(isHide: i == data.count - 1)
            
            stackListCustomer.insertArrangedSubview(customerView, at: stackListCustomer.arrangedSubviews.count)
            i = i + 1
        }
    }
    
    // MARK: - PRIVATE
    private func configView() {
        lblTitle.text = "unlisted_customer_list_for_30_days".localized().uppercased()
        lblTitle.font = UIFont(name: Theme.font.bold, size: Theme.fontSize.medium)
        
    }
    
    func refreshPopupMenu() {
        if !(KxMenu.sharedMenu().menuView == nil) {
            guard let view:UIView = objc_getAssociatedObject(self, &BlockCustomerView_associated) as? UIView else {
                return
            }
            
            if(KxMenu.sharedMenu().menuView.frame.origin.y > UIScreen.main.bounds.size.height - KxMenu.sharedMenu().menuView.frame.size.height) {
                KxMenu.sharedMenu().dismissMenu()
                return
            }
            
            Support.popup.showMenu(items: ["test test testse"], sender: self, view: view, selector: #selector(self.sendCongrabBirthday(menuItem:)),showArrow: true)
        }
    }
}

extension BirthdayCustomerListView {
    func CustomerBlockView(didSelect: CustomerBlockView, customer:CustomerDO) {
        customerSelected = customer        
        
        Support.popup.showMenu(items: ["popup_menu_item_send_birthday".localized()],
                              sender: self,
                              view: didSelect,
                              selector: #selector(self.sendCongrabBirthday(menuItem:)),
                              showArrow: true)
        
        objc_setAssociatedObject(self, &BlockCustomerView_associated, didSelect, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    @objc fileprivate func sendCongrabBirthday(menuItem:KxMenuItem) {
       
    }
}
