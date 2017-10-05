//
//  GroupCollectCustomerCell.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 10/3/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import UIKit

class GroupCollectCustomerCell: UICollectionViewCell {
    
    var object:GroupCustomer!
    
    var onSelectOption: ((Any,GroupCustomer) -> Void)?
    
    @IBOutlet var icon: CImageViewRoundGradient!
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var lblSubtitle: UILabel!
    @IBOutlet var btnOption: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configView()
    }
    
    // MARK: - INTERFACE
    func show(data:GroupCustomer) {
        
        object = data
        
        if let title = object.name {
            lblTitle.text = title.uppercased()
            if title == "add_group".localized() {
                backgroundColor = UIColor.clear
                icon.image = Support.image.iconFont(code: "\u{f067}", size: icon.frame.size.width*30/100)
                btnOption.isHidden = true
            }
        }
        
        if object.numberCustomer != nil {
            lblSubtitle.text! = "\(object.numberCustomer!)"
        }
        
        if lblSubtitle.text?.characters.count == 0 {
            lblSubtitle.isHidden = true
        }
        
        if let color = object.color {
            if color == "gradient" {
                icon.backgroundColor = UIColor(_gradient: Theme.colorGradient, frame: icon.frame, isReverse: true)
            } else {
                icon.backgroundColor = UIColor(hex:color)
            }
        }
    }
    
    // MARK: - event
    @IBAction func optionPress(_ sender: Any) {
        
        onSelectOption?(sender,object)
    }
    
    // MARK: - PRIVATE
    func configView() {
        lblTitle.font = UIFont(name: Theme.font.bold, size: Theme.fontSize.normal)
        lblSubtitle.font = UIFont(name: Theme.font.normal, size: Theme.fontSize.small)
        
        lblTitle.textColor = UIColor(hex:Theme.color.customer.titleGroup)
        lblSubtitle.textColor = UIColor(hex:Theme.color.customer.subGroup)
        
        object = nil
        lblSubtitle.isHidden = false
        btnOption.isHidden = false
        lblSubtitle.text = ""
        lblTitle.text = ""
        backgroundColor = UIColor.white
        icon.image = UIImage(named: "ic_group_white_75")
        icon.backgroundColor = UIColor(_gradient: Theme.colorGradient, frame: icon.frame, isReverse: true)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        configView()
    }
}
