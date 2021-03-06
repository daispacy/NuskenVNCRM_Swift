//
//  CustomerListCell.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 10/5/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import CoreData

class CustomerSelectedListCell: UITableViewCell {
    
    @IBOutlet var btnCheck: UIButton!
    @IBOutlet var imgAvatar: CImageViewRoundGradient!
    @IBOutlet var lblName: UILabel!
    @IBOutlet var btnEdit: UIButton!
    @IBOutlet var stackViewContainer: UIStackView!
    var viewcontroller:UIViewController?
    
    var onSelectCustomer:((Customer, Bool) -> Void)?
    var onEditCustomer:((Customer) -> Void)?
    var onRegisterAgainPreventSync:(()->Void)?
    
    var isEdit:Bool = false
    var object:Customer?
    var isSelect:Bool = false
    var isChecked:Bool = false
    var disposeBag = DisposeBag()
    
    // MARK: - init
    override func awakeFromNib() {
        super.awakeFromNib()
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
        
        btnEdit.rx.tap.subscribe(onNext:{ [weak self] in
            if let _self = self {
                if let obj = _self.object {
                    _self.onEditCustomer?(obj)
                }
            }
        }).addDisposableTo(disposeBag)
    }
    
    // MARK: - private
    func configView() {
        
        backgroundColor = UIColor.white
        selectedBackgroundView?.backgroundColor = backgroundColor
        
        lblName.font = UIFont(name: Theme.font.bold, size: Theme.fontSize.normal)
        lblName.textColor = UIColor(hex:Theme.color.customer.titleGroup)
        
        if let imageCheck = Support.image.iconFont(code: "\u{f14a}", size: 24, color:"0x71757A") {
            btnCheck.setImage(imageCheck, for: .selected)
        }
        if let imageUnCheck = Support.image.iconFont(code: "\u{f096}", size: 24, color:"0x71757A") {
            btnCheck.setImage(imageUnCheck, for: .normal)
        }
    }
    
    func removeFunctionView() {
        _ = stackViewContainer.arrangedSubviews.map({
            if $0 .isKind(of: FunctionStackViewCustomer.self) {
                $0.removeFromSuperview()
            }
        })
    }
    
    func configText() {
        
    }
    
    // MARK: - interface
    func show(customer:Customer, isEdit:Bool,isSelect:Bool, isChecked:Bool) {
        object = customer
        self.isEdit = isEdit
        self.isSelect = isSelect
        self.isChecked = isChecked
        configView()
        
        lblName.text = customer.fullname
        
        if customer.getNumberOrders() > 0 {
            self.btnCheck.isEnabled = false
        }
        
        let cus = customer
        let avaStr = cus.avatar
        if let urlAvatar = cus.urlAvatar {
            if avaStr.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines).characters.count > 0 {
                if avaStr.contains(".jpg") || avaStr.contains(".png"){
                    imgAvatar.loadImageUsingCacheWithURLString(urlAvatar,size:nil, placeHolder: nil)
                } else {
                    if let dataDecoded : Data = Data(base64Encoded: avaStr, options: .ignoreUnknownCharacters) {
                        let decodedimage = UIImage(data: dataDecoded)
                        imgAvatar.image = decodedimage
                    }
                }
            }
        } else {
            if let dataDecoded : Data = Data(base64Encoded: avaStr, options: .ignoreUnknownCharacters) {
                let decodedimage = UIImage(data: dataDecoded)
                imgAvatar.image = decodedimage
            }
        }
        
    }
    
    func setSelect() {
        guard let customer = object else { return}
        if customer.getNumberOrders() > 0 {
            guard let vc = self.viewcontroller else {return}
            Support.popup.showAlert(message: "this_customer_have_order_cant_delete".localized(), buttons: ["ok".localized()], vc: vc, onAction: {i in
                
            }, { [weak self] index in
                guard let _self = self else {return}
                _self.onRegisterAgainPreventSync?()
            })
            
            return
        }
        btnCheck.isSelected = !btnCheck.isSelected
        self.isChecked = btnCheck.isSelected
        onSelectCustomer?(object!,btnCheck.isSelected)
    }
    
    // MARK: - check event
    @IBAction func pressCheck(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        onSelectCustomer?(object!,sender.isSelected)
    }
    
    
    // MARK: - reuse
    override func prepareForReuse() {
        removeFunctionView()
        imgAvatar.image = nil
        btnCheck.isSelected = false
        btnCheck.isEnabled = true
        isChecked = false
        isSelect = false
        isEdit = false
        configView()
        configText()
        super.prepareForReuse()
    }
}
