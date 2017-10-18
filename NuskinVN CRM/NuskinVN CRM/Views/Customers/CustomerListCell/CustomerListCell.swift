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

class CustomerListCell: UITableViewCell {
    
    @IBOutlet var btnCheck: UIButton!
    @IBOutlet var imgAvatar: CImageViewRoundGradient!
    @IBOutlet var lblName: UILabel!
    @IBOutlet var btnEdit: UIButton!
    @IBOutlet var stackViewContainer: UIStackView!
    
    
    var onSelectCustomer:((Customer, Bool) -> Void)?
    var onEditCustomer:((Customer) -> Void)?
    
    var isEdit:Bool = false
    var object:Customer!
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
                _self.onEditCustomer?(_self.object)
            }
        }).disposed(by: disposeBag)
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
        
        btnCheck.isHidden = !isEdit
        btnCheck.isSelected = isChecked
        
        if isSelect {
            
            let functionView = Bundle.main.loadNibNamed("FunctionStackViewCustomer", owner: self, options: [:])?.first as! FunctionStackViewCustomer
            functionView.btnViber.isHidden = self.object.viber.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).characters.count == 0
            functionView.btnSkype.isHidden = self.object.skype.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).characters.count == 0
            functionView.btnZalo.isHidden = self.object.zalo.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).characters.count == 0
            functionView.btnFacebook.isHidden = self.object.facebook.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).characters.count == 0
            
            functionView.onSelectFunction = {[weak self]
                identifier in
                print("open \(identifier)")
                if identifier == "facebook" {
                    
                } else if identifier == "skype" {
                    
                } else if identifier == "viber" {
                    
                } else if identifier == "zalo" {
                    
                }
            }
            stackViewContainer.insertArrangedSubview(functionView, at: stackViewContainer.arrangedSubviews.count)
            
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
        lblName.text = object.fullname
        if object.getAvatar != UIImage() {
            imgAvatar.image = object.getAvatar
        }
    }
    
    func setSelect() {
        btnCheck.isSelected = !btnCheck.isSelected
        self.isChecked = btnCheck.isSelected
        onSelectCustomer?(object,btnCheck.isSelected)
    }
    
    // MARK: - check event
    @IBAction func pressCheck(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        onSelectCustomer?(object,sender.isSelected)
    }
    
    
    // MARK: - reuse
    override func prepareForReuse() {
        removeFunctionView()
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

class FunctionStackViewCustomer: UIView {
    
    @IBOutlet var btnFacebook: UIButton!
    @IBOutlet var btnZalo: UIButton!
    @IBOutlet var btnSkype: UIButton!
    @IBOutlet var btnViber: UIButton!
    
    var onSelectFunction:((String)->Void)?
    
    var disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        btnFacebook.rx.tap.subscribe(onNext: { [weak self] in
            if let _self = self {
                _self.onSelectFunction?("facebook")
            }
        }).disposed(by: disposeBag)
        btnZalo.rx.tap.subscribe(onNext: {[weak self] in
            if let _self = self {
                _self.onSelectFunction?("zalo")
            }
        }).disposed(by: disposeBag)
        btnSkype.rx.tap.subscribe(onNext: {[weak self] in
            if let _self = self {
                _self.onSelectFunction?("skype")
            }
        }).disposed(by: disposeBag)
        btnViber.rx.tap.subscribe(onNext: {[weak self] in
            if let _self = self {
                _self.onSelectFunction?("viber")
            }
        }).disposed(by: disposeBag)
    }
}
