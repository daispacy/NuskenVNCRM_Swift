//
//  OrderListCell.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 10/17/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class OrderListCell: UITableViewCell {

    
    @IBOutlet var bottomLine: UIView!
    @IBOutlet var vwBtnCheck: UIView!
    @IBOutlet var btnCheck: UIButton!

    @IBOutlet var lblNameCustomer: UILabel!
    @IBOutlet var lblDateCreated: UILabel!
    @IBOutlet var lblCode: UILabel!
    @IBOutlet var lblGoal: UILabel!
    @IBOutlet var lblTotalPrice: UILabel!
    @IBOutlet var lblStatus: UILabel!
    @IBOutlet var lblPaymentStatus: UILabel!
    @IBOutlet var vwStatus: UIView!
    
    var isEdit:Bool = false
    var object:Order!
    var isSelect:Bool = false
    var isChecked:Bool = false
    var disposeBag = DisposeBag()
    
    var onSelectOrder:((Order, Bool) -> Void)?
    var onEditOrder:((Order) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
//        lblStatus.text = "loading".localized()
        self.layoutIfNeeded()
        self.setNeedsDisplay()
        
        isSelect = false
        isEdit = false
        
        let bgColorView = UIView()
        let btLine = UIView()
        bgColorView.addSubview(btLine)
        btLine.backgroundColor = UIColor(hex:"0xEBEBF1")
        btLine.translatesAutoresizingMaskIntoConstraints = false
        btLine.heightAnchor.constraint(equalToConstant: 1).isActive = true
        btLine.leadingAnchor.constraint(equalTo: bgColorView.leadingAnchor, constant: 40).isActive = true
        btLine.trailingAnchor.constraint(equalTo: bgColorView.trailingAnchor, constant: 0).isActive = true
        btLine.bottomAnchor.constraint(equalTo: bgColorView.bottomAnchor, constant: 0).isActive = true
        bgColorView.backgroundColor = UIColor.clear
        selectedBackgroundView = bgColorView
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    // MARK: - interface
    func show(_ order:Order, isEdit:Bool,isSelect:Bool, isChecked:Bool) {
        object = order
        self.isEdit = isEdit
        self.isSelect = isSelect
        self.isChecked = isChecked
        configText()
        configView()
        
        if let customer = order.customer() {
            lblNameCustomer.text = customer.fullname
        }else {
            lblNameCustomer.text = "unknown".localized()
        }
        lblTotalPrice.text = "\(order.totalPrice.toTextPrice()) \("price_unit".localized())"
        lblGoal.text = "\(order.totalPV.toTextPrice()) \("pv".localized().uppercased())"
        
        if let date = order.date_created {
            let date_created = date as Date
            lblDateCreated.text = date_created.toString(dateFormat: "dd-MM-yyyy")
        }
        
        lblCode.text = order.code
        
        if let user = UserManager.currentUser() {
            if user.username == "phamdaiit" {
                lblCode.text = lblCode.text?.appending(" [\(order.synced)]")
            }
        }
        
        _ = AppConfig.order.listStatus().map({[weak self] item in
            if let _self = self {
                if order.status == item["id"] as! Int64 {
                    _self.lblStatus.text = item["name"] as? String
                }
            }
        })
        
        _ = AppConfig.order.listPaymentStatus().map({[weak self] item in
            if let _self = self {
                if order.payment_status == item["id"] as! Int64 {
                    _self.lblPaymentStatus.text = item["name"] as? String
                }
            }
        })
        
        switch order.status {
        case 0: // invalid
            lblStatus.textColor = UIColor(hex:"0xff1744")
        case 1: // process
            lblStatus.textColor = UIColor(hex:"0x38a4dd")
        case 3: // unprocess
            lblStatus.textColor = UIColor(hex:"0xffab00")
        default:
            lblStatus.textColor = UIColor.clear
        }

        switch order.payment_status {
        case 2: // unpaid
            lblPaymentStatus.textColor = UIColor(hex:"0xff1744")
        case 1: // paid
            lblPaymentStatus.textColor = UIColor(hex:"0x38a4dd")
        default:
            lblStatus.textColor = UIColor.clear
        }
    }
    
    func setSelect() {
        btnCheck.isSelected = !btnCheck.isSelected
        self.isChecked = btnCheck.isSelected
        onSelectOrder?(object,btnCheck.isSelected)
    }
    
    // MARK: - private
    func configView() {
        if let imageCheck = Support.image.iconFont(code: "\u{f14a}", size: 24, color:"0x71757A") {
            btnCheck.setImage(imageCheck, for: .selected)
        }
        if let imageUnCheck = Support.image.iconFont(code: "\u{f096}", size: 24, color:"0x71757A") {
            btnCheck.setImage(imageUnCheck, for: .normal)
        }
        
        vwBtnCheck.isHidden = !isEdit
        btnCheck.isSelected = isChecked

        configLabel(lbl: lblCode)        
        configLabel(lbl: lblNameCustomer, isTitle: true)
        configLabel(lbl: lblTotalPrice)
//        configLabel(lbl: lblStatus)
        
        lblDateCreated.font = UIFont(name: Theme.font.normal, size: Theme.fontSize.normal)
        lblDateCreated.textColor = UIColor(hex:Theme.color.customer.titleGroup)
        
        lblGoal.font = UIFont(name: Theme.font.normal, size: Theme.fontSize.normal)
        lblGoal.textColor = UIColor(hex:Theme.color.customer.titleGroup)
        
        lblStatus.font = UIFont(name: Theme.font.normal, size: Theme.fontSize.normal)
        lblStatus.textColor = UIColor(hex:Theme.color.customer.titleGroup)
        
        lblPaymentStatus.font = UIFont(name: Theme.font.normal, size: Theme.fontSize.normal)
        lblPaymentStatus.textColor = UIColor(hex:Theme.color.customer.titleGroup)
    }
    
    func configText() {
        
    }
    
    func configLabel(lbl:UILabel,isTitle:Bool = false) {        
        lbl.font = UIFont(name: Theme.font.bold, size: Theme.fontSize.normal)
        lbl.textColor = UIColor(hex:isTitle ? Theme.color.order.listCustomerName : Theme.color.customer.titleGroup)
    }
    
    // MARK: - reuse
    override func prepareForReuse() {
        
        btnCheck.isSelected = false
        object = nil
        isChecked = false
        isSelect = false
        isEdit = false
        lblStatus.textColor = UIColor.clear
        configView()
        configText()
        super.prepareForReuse()
    }
}
