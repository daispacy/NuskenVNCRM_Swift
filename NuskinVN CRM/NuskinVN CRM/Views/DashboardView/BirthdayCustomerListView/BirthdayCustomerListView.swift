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
    
    @IBOutlet var imgvAvatar: CImageViewRoundGradient!
    @IBOutlet var vwStatus: UIView!
    @IBOutlet var lblName: UILabel!
    @IBOutlet var lblBirthday: UILabel!
    @IBOutlet var bottomLine: UIView!
    @IBOutlet var lblStatus: UILabel!
    @IBOutlet var stackContainer: UIStackView!
    @IBOutlet var btnCheckCongrat: UIButton!
    @IBOutlet var vwCongrat: UIView!
    
    var tapOpenPopup:UITapGestureRecognizer?
    var involkeFunctionView:((CustomerDO,UIView)->Void)?
    var needReloadData:(()->Void)?
    var object:CustomerDO?
    
    var isShowNotOrder30:Bool = false,forceRemoveButtonCheck:Bool = false
    
    // MARK: - INIT
   
    override func awakeFromNib() {
        super.awakeFromNib()
        
        reloadTexts()
        configView()
        
        tapOpenPopup = UITapGestureRecognizer(target: self, action: #selector(self.openPopup))
        self.addGestureRecognizer(tapOpenPopup!)
    }
    
    deinit {
         self.removeGestureRecognizer(tapOpenPopup!)
    }
    
    override func reloadTexts() {
        // set text here
        btnCheckCongrat.setTitle(!isShowNotOrder30 ? "mark_send".localized() : "mark_prompt".localized(), for: .normal)
        
        layoutIfNeeded()
        setNeedsDisplay()
    }
    
    // MARK: - INTERFACE
    func showInfoCustomer(customer:CustomerDO?,_ is30:Bool = false, forceRemoveButtonCheck:Bool = false) {
        isShowNotOrder30 = is30
        guard let data = customer else { return }
        
        if forceRemoveButtonCheck {
            vwCongrat.removeFromSuperview()
        }
        
        object = data
       
        if let name = data.fullname {
            lblName.text = name
        } else {
            lblName.text = ""
        }
        
        if !isShowNotOrder30 {
            if let birthday = data.birthday as Date?{
                lblBirthday.text = birthday.toString(dateFormat: "dd/MM/yyyy")
            } else {
                lblBirthday.text = ""
            }
            if(data.isCongratBirthday) {
                vwStatus.backgroundColor = UIColor(hex:"0x009688")
                lblStatus.text = "congrated".localized()
                vwCongrat.removeFromSuperview()
            } else {
                vwStatus.backgroundColor = UIColor(hex:"0xf44336")
                lblStatus.text = "not_congrated".localized()
            }
        } else {
            
            lblBirthday.text = data.lastDateOrder()
            if(data.isRemind) {
                vwStatus.backgroundColor = UIColor(hex:"0x009688")
                lblStatus.text = "prompt".localized()
                vwCongrat.removeFromSuperview()
            } else {
                vwStatus.backgroundColor = UIColor(hex:"0xf44336")
                lblStatus.text = "not_prompt".localized()
            }
        }
        
        reloadTexts()
        
        lblStatus.textColor = vwStatus.backgroundColor
        
        if let avaStr = data.avatar {
            if let urlAvatar = data.urlAvatar {
                if avaStr.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines).characters.count > 0 {
                    if avaStr.contains(".jpg") || avaStr.contains(".png"){
                        imgvAvatar.loadImageUsingCacheWithURLString(urlAvatar, placeHolder: nil)
                    } else {
                        if let dataDecoded : Data = Data(base64Encoded: avaStr, options: .ignoreUnknownCharacters) {
                            let decodedimage = UIImage(data: dataDecoded)
                            imgvAvatar.image = decodedimage
                        }
                    }
                }
            } else {
                if let dataDecoded : Data = Data(base64Encoded: avaStr, options: .ignoreUnknownCharacters) {
                    let decodedimage = UIImage(data: dataDecoded)
                    imgvAvatar.image = decodedimage
                }
            }
        }
        
    }
    
    func hideBottomLine(isHide:Bool) {
        if(isHide) {
            bottomLine.backgroundColor = UIColor.clear
        }
    }
    
    // MARK: - EVENT
    @objc private func openPopup() {
        guard let dt = object else { return }
        
        // check if reminder is dont add function view
        if !isShowNotOrder30 {
            if dt.isCongratBirthday {return}
        } else {
            if dt.isRemind {return}
        }
        
        self.involkeFunctionView?(dt,self)
    }
    
    @IBAction func markCongrat(_ sender: Any) {
        guard let data = object else { return }
        guard let birth = data.birthday else {return}
        if !isShowNotOrder30 {
            BirthdayManager.saveBirthday(array: [["customer_id":data.id,"customer_local_id":data.local_id,"birthday":birth]])
        } else {
            NotOrder30DOManager.saveRemind(array: [["customer_id":data.id,"customer_local_id":data.local_id,"date_remind":birth]])
        }
        self.needReloadData?()
    }
    
    
    
    // MARK: - PRIVATE
    private func configView() {
        lblName.textColor = UIColor(hex:Theme.colorDBTextNormal)
        lblName.font = UIFont(name: Theme.font.bold, size: Theme.fontSize.normal)
        
        lblStatus.font = UIFont(name: Theme.font.normal, size: Theme.fontSize.small)
        
        lblBirthday.textColor = UIColor(hex:Theme.colorDBTextNormal)
        lblBirthday.font = UIFont(name: Theme.font.normal, size: Theme.fontSize.normal)
        
        bottomLine.backgroundColor = UIColor(hex:Theme.colorDBBackgroundDashboard)
        
        btnCheckCongrat.tintColor = UIColor(hex:"0x349ad5")
        btnCheckCongrat.titleLabel?.font = UIFont(name: Theme.font.bold, size: Theme.fontSize.small)
        btnCheckCongrat.setTitleColor(UIColor(_gradient: Theme.colorGradient, frame: btnCheckCongrat.titleLabel!.frame, isReverse: false), for: .normal)
    }
}

class BirthdayCustomerListView: CViewSwitchLanguage {

    @IBOutlet var lblTitle: CLabelGradient!
    @IBOutlet var stackListCustomer: UIStackView!
    
    fileprivate var customerSelected:CustomerDO?
    
    var involkeFunctionView:((CustomerDO,UIView)->Void)?
    var needReloadData:(()->Void)?
    
    var isShowNotOrder30:Bool = false,forceRemoveButtonCheck:Bool = false
    
    // MARK: - INIT
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configView()                
    }

    func reloadData(_ is30:Bool = false, forceRemoveButtonCheck:Bool = false) {
        isShowNotOrder30 = is30
        self.forceRemoveButtonCheck = forceRemoveButtonCheck
        lblTitle.text = !isShowNotOrder30 ? "list_customer_have_birthday_in_month".localized().uppercased() : "unlisted_customer_list_for_30_days".localized().uppercased()
        _ = stackListCustomer.arrangedSubviews.map{$0.removeFromSuperview()}
        if !is30 {
            CustomerManager.getCustomersBirthday {[weak self] (list) in
                guard let _self = self else {return}
                _self.reloadListCustomer(list)
            }
        } else {
            CustomerManager.getCustomersDontHaveOrder30Day{[weak self] (list) in
                guard let _self = self else {return}
                _self.reloadListCustomer(list)
            }
        }
    }
    
    // MARK: - INTERFACE
    func reloadListCustomer(_ listCustomers:[CustomerDO]?) {
        guard let data = listCustomers else { return }
        
        if data.count == 0 {
            self.removeFromSuperview()
            return
        }
        
        var i:Int = 0
        for item in data {
            let customerView = Bundle.main.loadNibNamed("CustomerBlockView", owner: self, options: nil)!.first as! CustomerBlockView
            customerView.showInfoCustomer(customer: item,isShowNotOrder30,forceRemoveButtonCheck: self.forceRemoveButtonCheck)
            customerView.involkeFunctionView = {[weak self] customer, sender in
                guard let _self = self else {return}
                _self.involkeFunctionView?(customer,sender)
            }
            customerView.needReloadData = {[weak self] in
                guard let _self = self else {return}
                _self.needReloadData?()
            }
            customerView.hideBottomLine(isHide: i == data.count - 1)
            
            stackListCustomer.insertArrangedSubview(customerView, at: stackListCustomer.arrangedSubviews.count)
            i = i + 1
        }
    }
    
    // MARK: - PRIVATE
    private func configView() {
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
