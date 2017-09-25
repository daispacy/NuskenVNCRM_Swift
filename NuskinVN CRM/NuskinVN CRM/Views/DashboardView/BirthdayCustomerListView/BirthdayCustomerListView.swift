//
//  BirthdayCustomerListView.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 9/24/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import UIKit

var BlockCustomerView_associated: String = "BlockCustomerView"

protocol BirthdayCustomerListViewDelegate: class {
    func BirthdayCustomerListView(didSelect:BirthdayCustomerListView, customer:Customer)
}

protocol CustomerBlockViewDelegate: class {
    func CustomerBlockView(didSelect:CustomerBlockView,customer:Customer)
}

class CustomerBlockView: UIView {
    
    @IBOutlet var imgvAvatar: UIImageView!
    @IBOutlet var imgvStatus: UIImageView!
    @IBOutlet var lblName: UILabel!
    @IBOutlet var lblBirthday: UILabel!
    @IBOutlet var bottomLine: UIView!
    
    weak var delegate:CustomerBlockViewDelegate?
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
    
    // MARK: - INTERFACE
    func showInfoCustomer(customer:Customer?) {
        guard let data = customer else { return }
        
        object = data
        
        lblName.text = "\(data.firstname ?? "") \(data.lastname ?? "")"
        lblBirthday.text = data.birthday
        imgvAvatar.image = UIImage(named:"checkbox_check")
        imgvStatus.image = UIImage(named:"checkbox_uncheck")
    }
    
    func hideBottomLine(isHide:Bool) {
        if(isHide) {
            bottomLine.backgroundColor = UIColor.clear
        }
    }
    
    
    // MARK: - EVENT
    @objc private func openPopup() {
        
        delegate?.CustomerBlockView(didSelect: self,customer:object as! Customer)
    }
    
    // MARK: - PRIVATE
    private func configView() {
        lblName.textColor = UIColor(hex:Theme.colorDBTextNormal)
        lblBirthday.textColor = UIColor(hex:Theme.colorDBTextNormal)
        bottomLine.backgroundColor = UIColor(hex:Theme.colorDBBackgroundDashboard)
    }
}

class BirthdayCustomerListView: UIView, CustomerBlockViewDelegate {

    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var stackListCustomer: UIStackView!
    
    weak var delegate:BirthdayCustomerListViewDelegate?
    fileprivate var customerSelected:Customer?
    
    // MARK: - INIT
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configView()
        
        reloadListCustomer([Customer(id:10),
                            Customer(id:10),
                            Customer(id:10),
                            Customer(id:10),
                            Customer(id:10)])
    }

    // MARK: - INTERFACE
    func reloadListCustomer(_ listCustomers:Array<Any>?) {
        guard let data = listCustomers else { return }
        
        var i:Int = 0
        for item in data {
            let customerView = Bundle.main.loadNibNamed("CustomerBlockView", owner: self, options: nil)!.first as! CustomerBlockView
            customerView.delegate = self
            customerView.showInfoCustomer(customer: item as? Customer)
            
            customerView.hideBottomLine(isHide: i == data.count - 1)
            
            stackListCustomer.insertArrangedSubview(customerView, at: stackListCustomer.arrangedSubviews.count)
            i = i + 1
        }
    }
    
    // MARK: - PRIVATE
    private func configView() {
        lblTitle.text = "title_dashboard_birthday_customer".localized()
        lblTitle.textColor = UIColor(hex:Theme.colorDBTitleChart)
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
            
            Support.showPopupMenu(items: ["test test testse"], sender: self, view: view, selector: #selector(self.sendCongrabBirthday(menuItem:)),showArrow: true)
        }
    }
}

extension BirthdayCustomerListView {
    func CustomerBlockView(didSelect: CustomerBlockView, customer:Customer) {
        customerSelected = customer        
        
        Support.showPopupMenu(items: ["popup_menu_item_send_birthday".localized()],
                              sender: self,
                              view: didSelect,
                              selector: #selector(self.sendCongrabBirthday(menuItem:)),
                              showArrow: true)
        
        objc_setAssociatedObject(self, &BlockCustomerView_associated, didSelect, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    @objc fileprivate func sendCongrabBirthday(menuItem:KxMenuItem) {
        delegate?.BirthdayCustomerListView(didSelect: self, customer: customerSelected!)
    }
}
