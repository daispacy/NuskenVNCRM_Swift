//
//  FormExportOrderDetailView.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 11/9/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import UIKit

class FormExportOrderDetailView: UIView {

    // MARK: - Outlet
    // title
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblTitleProduct: UILabel!
    
    //information order
    @IBOutlet weak var lblOrderCode: UILabel!
    @IBOutlet weak var lblDateCreated: UILabel!
    
    @IBOutlet weak var lblDistributor: UILabel!
    @IBOutlet weak var lblDistributorPhone: UILabel!

    @IBOutlet weak var lblCustomer: UILabel!
    @IBOutlet weak var lblCustomerPhone: UILabel!
    
    @IBOutlet weak var lblAddressCustomer: UILabel!
    @IBOutlet weak var lblCityDistrictCustomer: UILabel!
    
    @IBOutlet weak var lblOrderAddress: UILabel!
    @IBOutlet weak var lblOrderStatus: UILabel!
    @IBOutlet weak var lblPaymentStatus: UILabel!
    @IBOutlet weak var lblPaymentMethod: UILabel!
    
    @IBOutlet weak var lblShipping: UILabel!
    @IBOutlet weak var lblSVD: UILabel!
    
    //list product
    @IBOutlet weak var stackListProducts: UIStackView!
    
    // summary
    @IBOutlet var lblTotalPrice: UILabel!
    @IBOutlet var lblTotalPV: UILabel!
    @IBOutlet var lblTextTotalPriccce: UILabel!
    @IBOutlet var lblTextTotalPV: UILabel!
    
    var isReady:Bool = false
    var onReady:(()->Void)?
    
    // MARK: - INIT
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if isReady {
            isReady = false
            self.onReady?()
        }
    }
    
    // MARK: - interface
    func load(_ order:OrderDO? = nil) -> Bool {
        guard let user = UserManager.currentUser(),
              let item = order else {return false}
        guard let customer = item.customer() else { return false}
        
        configView()
        configText()
        
        if let code = item.code {
            lblOrderCode.text = "\(lblOrderCode.text!): \(code)"
        }
        
        if let date = item.last_updated {
            let date_created = date as Date
            lblDateCreated.text = "\(lblDateCreated.text!) \(date_created.toString(dateFormat: "dd/MMyyyy HH:mm:ss"))"
        }
        
        if let code = user.fullname {
            lblDistributor.text = "\(lblDistributor.text!): \(code)"
        }
        
        if let code = user.tel {
            lblDistributorPhone.text = "\(lblDistributorPhone.text!): \(code)"
        }
        
        if let code = customer.fullname {
            lblCustomer.text = "\(lblCustomer.text!): \(code)"
        }
        
        if let code = customer.tel {
            lblCustomerPhone.text = "\(lblCustomerPhone.text!): \(code)"
        }
        
        if let code = customer.address {
            lblAddressCustomer.text = "\(lblAddressCustomer.text!): \(code)"
        }
        
        if let code = customer.city, let code1 = customer.county {
            lblCityDistrictCustomer.text = "\("city".localized()): \(code)       \("district".localized()): \(code1)"
        }
        
        if let code = item.address {
            lblOrderAddress.text = "\(lblOrderAddress.text!): \(code)"
        }
        
        _ = AppConfig.order.listPaymentMethod().map({[weak self] i in
            if let _self = self {
                if i["id"] as! Int64 == item.payment_option {
                    _self.lblPaymentMethod.text = "\(_self.lblPaymentMethod.text!): \(i["name"] as! String)"
                }
            }
        })
        _ = AppConfig.order.listPaymentStatus().map({[weak self] i in
            if let _self = self {
                if i["id"] as! Int64 == item.payment_status {
                    _self.lblPaymentStatus.text = "\(_self.lblPaymentStatus.text!): \(i["name"] as! String)"
                }
            }
        })
        _ = AppConfig.order.listStatus().map({[weak self] i in
            if let _self = self {
                if i["id"] as! Int64 == item.status {
                    _self.lblOrderStatus.text = "\(_self.lblOrderStatus.text!): \(i["name"] as! String)"
                }
            }
        })
        _ = AppConfig.order.listTranspoter().map({[weak self] i in
            if let _self = self {
                if i["id"] as! Int64 == item.shipping_unit {
                    _self.lblShipping.text = "\(_self.lblShipping.text!): \(i["name"] as! String)"
                }
            }
        })
        
        if let ortherShipping = item.transporter_other {
            lblShipping.text = "\(lblShipping.text!): \(ortherShipping)"
        }
        
        if let code = item.svd {
            lblSVD.text = "\(lblSVD.text!): \(code)"
        }
        
        var price:Int64 = 0
        var pv:Int64 = 0
        
        if item.orderItems().count > 0 {
            var i = 1
            _ = item.orderItems().map({
                if let product = $0.product() {
                    price += ($0.price * $0.quantity)
                    pv += (product.pv * $0.quantity)
                    
                    let stack = UIStackView(frame: CGRect.zero)
                    stack.axis = .horizontal
                    stack.spacing = 30
                    stack.distribution = .fillEqually
                    let label = UILabel(frame: CGRect.zero)
                    label.numberOfLines = 0
                    label.textAlignment = .left
                    configLabel(label)
                    label.text = "\(i). \(product.name!)"
                    
                    let label1 = UILabel(frame: CGRect.zero)
                    label1.numberOfLines = 0
                    label1.textAlignment = .left
                    configLabel(label1)
                    label1.text = "\("quantity".localized()): \($0.quantity) \("unit".localized())\n\("price".localized()): \(($0.quantity*$0.price).toTextPrice()) \("price_unit".localized())\n\("pv".localized().uppercased()): \((product.pv * $0.quantity).toTextPrice())"
                    
                    stack.insertArrangedSubview(label, at: stack.arrangedSubviews.count)
                    stack.insertArrangedSubview(label1, at: stack.arrangedSubviews.count)
//                    stack.heightAnchor.constraint(equalToConstant: 40).isActive = true
                    
                    stackListProducts.insertArrangedSubview(stack, at: stackListProducts.arrangedSubviews.count)
                    i += 1
                }
            })
        }
        
        lblTotalPrice.text = "\(price.toTextPrice()) \("price_unit".localized().uppercased())"
        lblTotalPV.text = "\(pv.toTextPrice()) \("pv".localized().uppercased())"
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.heightAnchor.constraint(equalToConstant: 650 + CGFloat(60*item.orderItems().count)).isActive = true
        self.layoutIfNeeded()
        self.setNeedsDisplay()
        isReady = true
        return true
    }
    
    // MARK: - private
    func configText() {
        lblTitle.text = "page_order".localized().uppercased()
        lblTitleProduct.text = "infor_product".localized().uppercased()
        lblOrderCode.text = "order_code".localized()
        lblDistributor.text = "distributor".localized()
        lblDistributorPhone.text = "phone".localized()
        lblCustomer.text = "customer".localized()
        lblCustomerPhone.text = "phone".localized()
        lblAddressCustomer.text = "address".localized()
        lblOrderAddress.text = "order_address".localized()
        
        lblOrderStatus.text = "order_status".localized()
        lblPaymentMethod.text = "payment_method".localized()
        lblPaymentStatus.text = "payment_status".localized()
        lblShipping.text = "transporter".localized()
        lblSVD.text = "transporter_id".localized()
        lblDateCreated.text = "date_created_order".localized()
        
        lblTextTotalPriccce.text = "total_price".localized()
        lblTextTotalPV.text = "PV".localized()
    }
    
    func configView() {
        
        _ = [lblOrderCode,lblDistributor,lblDistributorPhone,lblCustomer,lblCustomerPhone,lblAddressCustomer,lblCityDistrictCustomer,lblOrderAddress,lblOrderStatus,lblPaymentStatus,lblPaymentMethod,lblShipping,lblSVD,lblTitle,lblTitleProduct,lblDateCreated].map{configLabel($0)}
        
        lblTotalPV.textColor = UIColor(hex: Theme.colorNavigationBar)
        lblTotalPV.font = UIFont(name: Theme.font.bold, size: Theme.fontSize.medium)
        lblTotalPrice.textColor = UIColor(hex: Theme.colorNavigationBar)
        lblTotalPrice.font = UIFont(name: Theme.font.bold, size: Theme.fontSize.medium)
        lblTextTotalPV.textColor = UIColor(hex: Theme.color.customer.subGroup)
        lblTextTotalPV.font = UIFont(name: Theme.font.bold, size: Theme.fontSize.normal)
        lblTextTotalPriccce.textColor = UIColor(hex: Theme.color.customer.subGroup)
        lblTextTotalPriccce.font = UIFont(name: Theme.font.bold, size: Theme.fontSize.normal)
    }
    
    func configLabel(_ textfield:UILabel) {
        textfield.textColor = UIColor(hex: Theme.color.customer.subGroup)
        textfield.font = UIFont(name: Theme.font.bold, size: Theme.fontSize.normal)
    }
}
