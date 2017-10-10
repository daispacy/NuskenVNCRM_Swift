//
//  CustomerListCell.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 10/5/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import UIKit

class CustomerListCell: UITableViewCell {
    
    @IBOutlet var btnCheck: UIButton!
    @IBOutlet var imgAvatar: CImageViewRoundGradient!
    @IBOutlet var lblName: UILabel!
    @IBOutlet var collectButtonsFunction: [UIButton]!
    @IBOutlet var stackViewContainer: UIStackView!
    
    var onSelectCustomer:((Customer) -> Void)?
    
    var isEdit:Bool = false
    var object:Customer!
    var isSelect:Bool = false
    
    // MARK: - init
    override func awakeFromNib() {
        super.awakeFromNib()
        isSelect = false
        isEdit = false
    }
    
    // MARK: - private
    func configView() {
        
        backgroundColor = UIColor.white
        selectedBackgroundView?.backgroundColor = backgroundColor
        
        lblName.font = UIFont(name: Theme.font.bold, size: Theme.fontSize.normal)
        lblName.textColor = UIColor(hex:Theme.color.customer.titleGroup)
        
        if let imageCheck = Support.image.iconFont(code: "\u{f14a}", size: 24, color:"0xd4d8db") {
            btnCheck.setImage(imageCheck, for: .selected)
        }
        if let imageUnCheck = Support.image.iconFont(code: "\u{f096}", size: 24, color:"0xd4d8db") {
            btnCheck.setImage(imageUnCheck, for: .normal)
        }
        
        btnCheck.isHidden = !isEdit
        
        if isSelect {
            
            let functionView = Bundle.main.loadNibNamed("FunctionStackViewCustomer", owner: self, options: [:])?.first as! FunctionStackViewCustomer
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
    func show(customer:Customer, isEdit:Bool,isSelect:Bool) {
        object = customer
        self.isEdit = isEdit
        self.isSelect = isSelect
        configView()
        lblName.text = object.fullname
    }
    
    // MARK: - check event
    @IBAction func pressCheck(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        onSelectCustomer?(object)
    }
    
    
    // MARK: - reuse
    override func prepareForReuse() {
        
        removeFunctionView()
        
        object = nil
        isSelect = false
        isEdit = false
        configView()
        configText()
        super.prepareForReuse()
    }
}

class FunctionStackViewCustomer: UIView {
    override func awakeFromNib() {
        super.awakeFromNib()
//        translatesAutoresizingMaskIntoConstraints = false
//        heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
}
