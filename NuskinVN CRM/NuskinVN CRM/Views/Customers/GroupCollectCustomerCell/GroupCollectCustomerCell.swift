//
//  GroupCollectCustomerCell.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 10/3/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import UIKit
import CoreData

class GroupCollectCustomerCell: UICollectionViewCell {
    
    var object:GroupDO!
    
    var onSelectOption: ((Any,GroupDO) -> Void)?
    
    @IBOutlet var icon: CImageViewRoundGradient!
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var lblSubtitle: UILabel!
    @IBOutlet var btnOption: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configView()
    }
    
    // MARK: - INTERFACE
    func show(data:GroupDO) {
        
        object = data
        
        if let name = object.group_name {
        lblTitle.text = name.uppercased()
        if name == "add_group".localized() {
            backgroundColor = UIColor.clear
            icon.image = Support.image.iconFont(code: "\u{f067}", size: icon.frame.size.width*30/100)
            btnOption.isHidden = true
            lblSubtitle.isHidden = true
        }
        } else {
            lblTitle.text = ""
        }
        
        if let customers = object.customers{
            lblSubtitle.text = "\(customers.count) \("member".localized())"
        } else {
            lblSubtitle.text = "0 \("member".localized())"
        }

        if lblSubtitle.text?.characters.count == 0 {
            lblSubtitle.isHidden = true
        }
        
        if let properties = object.properties {
            if let data = properties.data(using: String.Encoding.utf8) {
                do {
                    if let pro:JSON = try JSONSerialization.jsonObject(with: data, options: []) as? JSON {
                        if let color = pro["color"] as? String {
                            if color == "gradient" {
                                icon.backgroundColor = UIColor(_gradient: Theme.colorGradient, frame: icon.frame, isReverse: true)
                            } else {
                                icon.backgroundColor = UIColor(hex:color)
                            }
                        }
                    }
                } catch {
                    print("warning parse properties GROUP: \(properties)")
                }
            }
        }
        
        if ((object.distributor_id == 0 && object.id > 0) || object.isTemp) {
            btnOption.isHidden = true
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
        btnOption.isHidden = false
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
