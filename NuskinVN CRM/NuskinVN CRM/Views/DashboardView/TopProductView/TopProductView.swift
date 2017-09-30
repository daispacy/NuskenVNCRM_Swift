//
//  TopProductView.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 9/30/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import UIKit
import FontAwesomeKit

// MARK: - TOP PRODUCT VIEW
class TopProductView: UIView {

    @IBOutlet var lblTitleView: UILabel!
    @IBOutlet var btnRevenue: UIButton!
    @IBOutlet var btnNumber: UIButton!
    @IBOutlet var stackViewProductList: UIStackView!
    @IBOutlet var btnOtherProduct: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configText()
        configView()
    }
    
    func configView() {
        
        lblTitleView.font = UIFont(name: Theme.font.bold, size: Theme.fontSize.medium)
        lblTitleView.textColor = UIColor(hex: Theme.colorDBTitleChart)
        
        btnRevenue.backgroundColor = UIColor(_gradient: Theme.colorGradient, frame: btnRevenue.frame, isReverse:true)
        btnRevenue.setTitleColor(UIColor(hex:Theme.colorAlertButtonTitleColor), for: .normal)
        btnRevenue.layer.cornerRadius = 5
        
        btnNumber.backgroundColor = UIColor(_gradient: Theme.colorGradient, frame: btnRevenue.frame, isReverse:true)
        btnNumber.setTitleColor(UIColor(hex:Theme.colorAlertButtonTitleColor), for: .normal)
        btnNumber.layer.cornerRadius = 5
        
        btnOtherProduct.tintColor = UIColor(hex:"0x349ad5")
        btnOtherProduct.setTitleColor(UIColor(_gradient: Theme.colorGradient, frame: btnOtherProduct.titleLabel!.frame, isReverse: false), for: .normal)
        
        // test temp data
        for _ in 0..<11 {
            let blockTop = Bundle.main.loadNibNamed("BlockTopProductView", owner: self, options: nil)?.first as! BlockTopProductView
            stackViewProductList.insertArrangedSubview(blockTop, at: stackViewProductList.arrangedSubviews.count)
        }
    }
    
    func configText() {
        lblTitleView.text = "top_ten_product".localized()
        
        btnNumber.setTitle("    \("number".localized())    ", for: .normal)
        btnRevenue.setTitle("    \("revenue".localized())    ", for: .normal)
        
        if let checkIcon = Support.imageWithIconFont(code: "\u{f067}", size: 22,color: "0xe30b7a") {
            btnOtherProduct.setImage(checkIcon, for: .normal)
        }
        btnOtherProduct.setTitle("other_product".localized(), for: .normal)
        
        self.layoutIfNeeded()
        self.setNeedsDisplay()
    }
}

// MARK: - BLOCK TOP PRODUCT
class BlockTopProductView: UIView {
    
    @IBOutlet var icon: UIImageView!
    @IBOutlet var lblName: UILabel!
    @IBOutlet var lblSub: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configView()
    }
    
    func configView() {
        icon.image = UIImage(named: "ic_top_product_block")
        
        lblName.text = "Tên sản phẩm thuộc top 10"
        lblSub.text = "32,6 triệu USD"
        
        lblName.font = UIFont(name: Theme.font.bold, size: Theme.fontSize.normal)
        lblName.textColor = UIColor(hex: Theme.colorDBTotalChartNormal)
        
        lblName.font = UIFont(name: Theme.font.bold, size: Theme.fontSize.normal)
        lblName.textColor = UIColor(hex: Theme.colorDBTotalChartNormal)
        
        lblSub.font = UIFont(name: Theme.font.normal, size: Theme.fontSize.normal)
        lblSub.textColor = UIColor(hex: Theme.colorDBTextNormal)
    }
}
