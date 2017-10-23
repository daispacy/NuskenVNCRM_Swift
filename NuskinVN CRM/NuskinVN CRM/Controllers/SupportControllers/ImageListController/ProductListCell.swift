//
//  ImageListCell.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 10/22/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import UIKit
import CoreData

class ProductListCell: UITableViewCell {

    @IBOutlet var avatar: UIImageView!
    @IBOutlet var lblName: UILabel!
    @IBOutlet var lblOther: UILabel!
    @IBOutlet var lblPrice: UILabel!
    
    var product:ProductDO?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func show(_ product:ProductDO) {
        self.product = product
        
        if let name = product.name {
            lblName.text = name
        }
       
        if let imgStr = product.avatar {
            avatar.loadImageUsingCacheWithURLString("\(Server.domainImage.rawValue)/upload/1/products/a_\(imgStr)", placeHolder: UIImage(named:"ic_top_product_block"))
        }
        
        lblOther.text = "PV: \(product.pv)"
        lblPrice.text = "\(product.price) \("price_unit".localized())"
    }
    
    override func prepareForReuse() {
        product = nil
    }
}
