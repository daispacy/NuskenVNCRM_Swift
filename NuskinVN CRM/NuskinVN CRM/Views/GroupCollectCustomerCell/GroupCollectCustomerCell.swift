//
//  GroupCollectCustomerCell.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 10/3/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import UIKit

class GroupCollectCustomerCell: UICollectionViewCell {
    
    var object:[String:Any]?
    
    @IBOutlet var icon: UIImageView!
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var lblSubtitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        lblSubtitle.text = ""
        lblTitle.text = ""
        
        configView()
    }
    
    // MARK: - INTERFACE
    func show(data:[String:Any]) {
        object = data
        guard let obj = object else { return }
        
        if let title:String = obj["title"] as? String {
            lblTitle.text = title.uppercased()
        }
        
        if let title:String = obj["subTitle"] as? String {
            lblSubtitle.text = title
        }
        
        if lblSubtitle.text?.characters.count == 0 {
            lblSubtitle.isHidden = true
            icon.backgroundColor = UIColor(hex:Theme.color.customer.subGroup)
        }
        
        if let ic = obj["icon"] {
            icon.image = UIImage(named: ic as! String)
        }
        
        if let ic = obj["iconfont"] {
            icon.image = Support.image.iconFont(code: ic as! String, size: icon.frame.size.width*30/100)
        }
    }
    
    // MARK: - PRIVATE
    func configView() {
        lblTitle.font = UIFont(name: Theme.font.bold, size: Theme.fontSize.normal)
        lblSubtitle.font = UIFont(name: Theme.font.normal, size: Theme.fontSize.small)
        
        lblTitle.textColor = UIColor(hex:Theme.color.customer.titleGroup)
        lblSubtitle.textColor = UIColor(hex:Theme.color.customer.subGroup)
        
        icon.layer.cornerRadius = icon.frame.size.width/2
        icon.layer.masksToBounds = true
    }
}
