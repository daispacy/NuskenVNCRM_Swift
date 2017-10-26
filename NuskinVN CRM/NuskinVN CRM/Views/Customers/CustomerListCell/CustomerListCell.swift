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

class CustomerListCell: UITableViewCell {
    
    @IBOutlet var imgAvatar: CImageViewRoundGradient!
    @IBOutlet var lblName: UILabel!
    @IBOutlet var btnEdit: UIButton!
    @IBOutlet var stackViewContainer: UIStackView!
    
    
    var onSelectCustomer:((CustomerDO, Bool) -> Void)?
    var onEditCustomer:((CustomerDO) -> Void)?
    
    var isEdit:Bool = false
    var object:CustomerDO?
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
        
        if isSelect {
            
            let functionView = Bundle.main.loadNibNamed("FunctionStackViewCustomer", owner: self, options: [:])?.first as! FunctionStackViewCustomer
            if let obj = self.object {
                functionView.btnViber.isHidden = obj.viber.characters.count > 0
                functionView.btnSkype.isHidden = obj.skype.characters.count > 0
                functionView.btnZalo.isHidden = obj.zalo.characters.count > 0
                functionView.btnFacebook.isHidden = obj.facebook.characters.count > 0
            }
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
    func show(customer:CustomerDO, isEdit:Bool,isSelect:Bool, isChecked:Bool) {
        object = customer
        self.isEdit = isEdit
        self.isSelect = isSelect
        self.isChecked = isChecked
        configView()
        
        lblName.text = customer.fullname
       
        if let avaStr = customer.avatar {
            if avaStr.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines).characters.count > 0 {
                if avaStr.contains(".jpg") {
                    imgAvatar.loadImageUsingCacheWithURLString("\(Server.domainImage.rawValue)/upload/1/customers/\(avaStr.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)", placeHolder: nil)
                } else {
                    if let dataDecoded : Data = Data(base64Encoded: avaStr, options: .ignoreUnknownCharacters) {
                        let decodedimage = UIImage(data: dataDecoded)
                        imgAvatar.image = decodedimage
                    }
                }
            }
        }
        
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
        }).addDisposableTo(disposeBag)
        btnZalo.rx.tap.subscribe(onNext: {[weak self] in
            if let _self = self {
                _self.onSelectFunction?("zalo")
            }
        }).addDisposableTo(disposeBag)
        btnSkype.rx.tap.subscribe(onNext: {[weak self] in
            if let _self = self {
                _self.onSelectFunction?("skype")
            }
        }).addDisposableTo(disposeBag)
        btnViber.rx.tap.subscribe(onNext: {[weak self] in
            if let _self = self {
                _self.onSelectFunction?("viber")
            }
        }).addDisposableTo(disposeBag)
    }
}
