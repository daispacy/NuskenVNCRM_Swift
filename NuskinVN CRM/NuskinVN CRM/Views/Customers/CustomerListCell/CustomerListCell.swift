//
//  CustomerListCell.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 10/5/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import UIKit

class CustomerListCell: UITableViewCell {

    @IBOutlet var stackViewFunction: UIStackView!
    
    @IBOutlet var btnCheck: UIButton!
    @IBOutlet var imgAvatar: CImageViewRoundGradient!
    @IBOutlet var lblName: UILabel!
    @IBOutlet var collectButtonsFunction: [UIButton]!
    
    var onSelectCustomer:((Customer) -> Void)?
    
    var isEdit:Bool = false
    var object:Customer!
    var isSelect:Bool = false
    
    // MARK: - init
    override func awakeFromNib() {
        super.awakeFromNib()
        configView()
        configText()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    // MARK: - private
    func configView() {
        lblName.font = UIFont(name: Theme.font.bold, size: Theme.fontSize.normal)
        lblName.textColor = UIColor(hex:Theme.color.customer.titleGroup)
        
        if let imageCheck = Support.image.iconFont(code: "\u{f14a}", size: 24, color:"0xd4d8db") {
            btnCheck.setImage(imageCheck, for: .selected)
        }
        if let imageUnCheck = Support.image.iconFont(code: "\u{f096}", size: 24, color:"0xd4d8db") {
            btnCheck.setImage(imageUnCheck, for: .normal)
        }
        btnCheck.isHidden = !isEdit
        
        stackViewFunction.isHidden = !isSelect
    }
    
    func configText() {
        isSelect = !isSelect
        configView()
    }
    
    // MARK: - interface
    func show(customer:Customer, isEdit:Bool) {
        object = customer
        self.isEdit = isEdit
        configView()
    }
    
    // MARK: - check event
    @IBAction func pressCheck(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        onSelectCustomer?(object)
    }
    
    
    // MARK: - reuse
    override func prepareForReuse() {
        super.prepareForReuse()
        configView()
        configText()
    }
}
