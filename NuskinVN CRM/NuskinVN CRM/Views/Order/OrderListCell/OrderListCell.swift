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
    @IBOutlet var imgAvatar: CImageViewRoundGradient!
    @IBOutlet var lblNameCustomer: UILabel!
    @IBOutlet var lblDateCreated: UILabel!
    @IBOutlet var lblCode: UILabel!
    @IBOutlet var lblGoal: UILabel!
    @IBOutlet var lblTotalPrice: UILabel!
    @IBOutlet var lblStatus: UILabel!
    
    var isEdit:Bool = false
    var object:OrderDO!
    var isSelect:Bool = false
    var isChecked:Bool = false
    var disposeBag = DisposeBag()
    
    var onSelectOrder:((OrderDO, Bool) -> Void)?
    var onEditOrder:((OrderDO) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        lblStatus.text = "loading".localized()
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
    func show(_ order:OrderDO, isEdit:Bool,isSelect:Bool, isChecked:Bool) {
        object = order
        self.isEdit = isEdit
        self.isSelect = isSelect
        self.isChecked = isChecked
        configText()
        configView()
        
        if order.customer().id != 0 {
            if let fullname = order.customer().fullname {
                lblNameCustomer.text = fullname
            }
            
        } else {
            lblNameCustomer.text = "unknown".localized()
        }
        lblTotalPrice.text = "\(order.totalPrice) \("price_unit".localized())"
        lblGoal.text = "\(order.totalPV) \("pv".localized().uppercased())"
        
        if let date = order.date_created {
            let date_created = date as Date
            lblDateCreated.text = date_created.toString(dateFormat: "yyyy-MM-dd HH:mm:ss")
        }
        
        lblCode.text = order.code
        _ = AppConfig.order.listStatus.map({
            if $0["id"] as! Int64 == order.status {
                lblStatus.text = $0["name"] as? String
            }
        })
        
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
        configLabel(lbl: lblGoal)
        configLabel(lbl: lblNameCustomer, isTitle: true)
        configLabel(lbl: lblTotalPrice)
        configLabel(lbl: lblDateCreated)
        configLabel(lbl: lblStatus)
    }
    
    func configText() {
        
    }
    
    func configLabel(lbl:UILabel,isTitle:Bool = false) {        
        lbl.font = UIFont(name: Theme.font.normal, size: Theme.fontSize.normal)
        lbl.textColor = UIColor(hex:isTitle ? Theme.color.order.listCustomerName : Theme.color.customer.titleGroup)
    }
    
    // MARK: - reuse
    override func prepareForReuse() {
        
        btnCheck.isSelected = false
        object = nil
        isChecked = false
        isSelect = false
        isEdit = false
        configView()
        configText()
        super.prepareForReuse()
    }
}
