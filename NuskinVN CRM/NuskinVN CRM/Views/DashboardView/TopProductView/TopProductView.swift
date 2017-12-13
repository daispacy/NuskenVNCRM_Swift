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
    
    var onMoreProduct:(()->Void)?
    var getNextTutorial:(()->Void)?
    
    var dataReal:[JSON] = []
    
    var maxTopProduct:Int = 10
    
    var btnClicked:UIButton?
    // MARK: - init
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configText()
        configView()
    }
    
    // MARK: - interface
    func loadData(data:[JSON]) {
        dataReal = data
        reloadData()
    }
    
    func reloadData() {
        var bool = false
        if let btn = btnClicked {
            if btn.isEqual(btnNumber) {
                bool = true
            }
        }
        if !bool {
            dataReal = dataReal.sorted {
                $0["total"] as! Int64 > $1["total"] as! Int64
            }
        } else {
            dataReal = dataReal.sorted { $0["quantity"] as! Int64 > $1["quantity"] as! Int64 }
        }
        
        _ = stackViewProductList.arrangedSubviews.map{$0.removeFromSuperview()}
        var i = 0
        for item in dataReal {
            if i < maxTopProduct {
                let blockTop = Bundle.main.loadNibNamed("BlockTopProductView", owner: self, options: nil)?.first as! BlockTopProductView
                stackViewProductList.insertArrangedSubview(blockTop, at: stackViewProductList.arrangedSubviews.count)
                blockTop.loadData(json: item,isQuantity: bool)
            } else {
                break
            }
            i += 1
        }
        
        btnOtherProduct.removeFromSuperview()
//        if maxTopProduct >= dataReal.count {
//            btnOtherProduct.removeFromSuperview()
//        }
    }
    
    // MARK: - event
    @IBAction func chooseData(_ sender: UIButton) {
        self.btnClicked = sender
        reloadData()
    }
    
    @IBAction func moreProduct(_ sender: Any) {
        self.onMoreProduct?()
    }
    
    
    // MARK: - private
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
    }
    
    func configText() {
        lblTitleView.text = "top_ten_product".localized()
        
        btnNumber.setTitle("    \("number".localized())    ", for: .normal)
        btnRevenue.setTitle("    \("revenue".localized())    ", for: .normal)
        
        if let checkIcon = Support.image.iconFont(code: "\u{f067}", size: 22,color: "0xe30b7a") {
            btnOtherProduct.setImage(checkIcon, for: .normal)
        }
        btnOtherProduct.setTitle("other_product".localized(), for: .normal)
        
        self.layoutIfNeeded()
        self.setNeedsDisplay()
    }
}

// MARK: - BLOCK TOP PRODUCT
class BlockTopProductView: CViewSwitchLanguage {
    
    @IBOutlet var icon: UIImageView!
    @IBOutlet var lblName: UILabel!
    @IBOutlet var lblSub: UILabel!
    
    // MARK: - init & override
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configView()
    }
    
    override func reloadTexts() {
        // set text here
    }
    
    // MARK: - interface
    func loadData(json:JSON, isQuantity:Bool = false) {
        if let pro = json["product"] as? Product,
            let total = json["total"] as? Int64,
            let quantity = json["quantity"] as? Int64 {
            
            let imgStr = pro.avatar
                if imgStr.characters.count > 0 {
                    icon.loadImageUsingCacheWithURLString("\(Server.domainImage.rawValue)/upload/1/products/m_\(imgStr)",size:nil, placeHolder: UIImage(named:"ic_top_product_block"))
                }
            let n = pro.name
                lblName.text = n
            if isQuantity {
                lblSub.text = "\(quantity.toTextPrice()) \("unit".localized())"
            } else {
                lblSub.text = "\(total.toTextPrice()) \("price_unit".localized())"
            }
        }
    }
    
    // MARK: - private
    func configView() {
        
        lblName.font = UIFont(name: Theme.font.bold, size: Theme.fontSize.normal)
        lblName.textColor = UIColor(hex: Theme.colorDBTotalChartNormal)
        
        lblName.font = UIFont(name: Theme.font.bold, size: Theme.fontSize.normal)
        lblName.textColor = UIColor(hex: Theme.colorDBTotalChartNormal)
        
        lblSub.font = UIFont(name: Theme.font.normal, size: Theme.fontSize.normal)
        lblSub.textColor = UIColor(hex: Theme.colorDBTextNormal)
    }
}

// MARK: - ShowCase
extension TopProductView: MaterialShowcaseDelegate {
    
    // MARK: - init showcase
    func startTutorial(_ step:Int = 1) {
        
        // showcase
        configShowcase(MaterialShowcase(), step) { showcase, shouldShow in
            if shouldShow {
                showcase.delegate = self
                showcase.show(completion: nil)
            }
        }
    }
    
    func configShowcase(_ showcase:MaterialShowcase,_ step:Int = 1,_ shouldShow:((MaterialShowcase,Bool)->Void)) {
        if step ==  1 {
            showcase.setTargetView(view: btnRevenue)
            showcase.primaryText = ""
            showcase.identifier = BUTTON_PROCESSED_ORDER
            showcase.secondaryText = "click_here_view_revenue_products".localized()
            shouldShow(showcase,true)
        } else if step == 2 {
            showcase.setTargetView(view: btnNumber)
            showcase.primaryText = ""
            showcase.identifier = BUTTON_UNPROCESSED_ORDER
            showcase.secondaryText = "click_here_view_number_products".localized()
            shouldShow(showcase,true)
        } else {
            shouldShow(showcase,false)
            if step > 2 {
                AppConfig.setting.setFinishShowcase(key: REPORT_PRODUCT_SCENE)
                self.getNextTutorial?()
            }
        }
    }
    
    func showCaseDidDismiss(showcase: MaterialShowcase) {
        if let step = showcase.identifier {
            print(step)
            if let s = Int(step) {
                let ss = s + 1
                startTutorial(ss)
            }
        }
        
    }
}
