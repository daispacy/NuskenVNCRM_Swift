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
    
    @IBOutlet weak var lblCityDistrictCustomer: UILabel!
    
    @IBOutlet weak var lblOrderAddress: UILabel!
    @IBOutlet weak var lblOrderStatus: UILabel!
    @IBOutlet weak var lblPaymentStatus: UILabel!
    @IBOutlet weak var lblPaymentMethod: UILabel!
    
    @IBOutlet weak var lblShipping: UILabel!
    @IBOutlet weak var lblSVD: UILabel!
    
    //list product
    @IBOutlet weak var stackListProducts: UIStackView!
    @IBOutlet var collectTitlesTable: [UILabel]!
    @IBOutlet weak var btlView: CViewBorder!
    @IBOutlet weak var btView: CViewBorder!
    @IBOutlet weak var btView1: CViewBorder!
    @IBOutlet weak var btrView: CViewBorder!
    
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
        
        let code = item.city
        let code1 = item.district
        lblCityDistrictCustomer.text = "\("city".localized()): \(code)       \("district".localized()): \(code1)"
        
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
                    stack.spacing = 0
                    stack.alignment = .fill
                    stack.distribution = .fill
                    
                    // name
                    var tn:[ViewBorderType] = [.left]
                    if i == item.orderItems().count {
                        tn = [.bottom,.left]
                    }
                    let viewProduct = CViewBorder(frame: CGRect.zero, tn)
                    let name = UILabel(frame: CGRect.zero)
                    name.numberOfLines = 0
                    name.textAlignment = .left
                    configLabel(name)
                    name.text = "\(i). \(product.name!)"
                    viewProduct.addSubview(name)
                    addContraint(name,10,10)
                    
                    // quantity
                    var tq:[ViewBorderType] = [.left,.right]
                    if i == item.orderItems().count {
                        tq = [.bottom,.left,.right]
                    }
                    let viewQuantity = CViewBorder(frame: CGRect.zero, tq)
                    let quantity = UILabel(frame: CGRect.zero)
                    quantity.numberOfLines = 0
                    quantity.textAlignment = .center
                    configLabel(quantity)
                    quantity.text = "\($0.quantity.toTextPrice()) \("unit".localized()) "
                    viewQuantity.addSubview(quantity)
                    addContraint(quantity)
                    
                    // price
                    var tp:[ViewBorderType] = [.right]
                    if i == item.orderItems().count {
                        tp = [.bottom,.right]
                    }
                    let viewPrice = CViewBorder(frame: CGRect.zero, tp)
                    let price = UILabel(frame: CGRect.zero)
                    price.numberOfLines = 0
                    price.textAlignment = .center
                    configLabel(price)
                    price.text = "\($0.price.toTextPrice()) \("price_unit".localized())"
                    viewPrice.addSubview(price)
                    addContraint(price)
                    
                    // price
                    var tt:[ViewBorderType] = [.right]
                    if i == item.orderItems().count {
                        tt = [.bottom,.right]
                    }
                    let viewTotal = CViewBorder(frame: CGRect.zero, tt)
                    let total = UILabel(frame: CGRect.zero)
                    total.numberOfLines = 0
                    total.textAlignment = .center
                    configLabel(total)
                    total.text = "\(($0.quantity*$0.price).toTextPrice()) \("price_unit".localized())"
                    viewTotal.addSubview(total)
                    addContraint(total)
                    
                    
                    stack.insertArrangedSubview(viewProduct, at: stack.arrangedSubviews.count)
                    stack.insertArrangedSubview(viewQuantity, at: stack.arrangedSubviews.count)
                    viewQuantity.translatesAutoresizingMaskIntoConstraints = false
                    viewQuantity.widthAnchor.constraint(equalToConstant: 150).isActive = true
                    stack.insertArrangedSubview(viewPrice, at: stack.arrangedSubviews.count)
                    viewPrice.translatesAutoresizingMaskIntoConstraints = false
                    viewPrice.widthAnchor.constraint(equalToConstant: 200).isActive = true
                    stack.insertArrangedSubview(viewTotal, at: stack.arrangedSubviews.count)
                    viewTotal.translatesAutoresizingMaskIntoConstraints = false
                    viewTotal.widthAnchor.constraint(equalToConstant: 300).isActive = true
                    stack.translatesAutoresizingMaskIntoConstraints = false
                    stack.heightAnchor.constraint(equalToConstant: 50).isActive = true
                    
                    stackListProducts.insertArrangedSubview(stack, at: stackListProducts.arrangedSubviews.count)
                    i += 1
                }
            })
        }
        
        let stack = UIStackView(frame: CGRect.zero)
        stack.axis = .horizontal
        stack.spacing = 0
        stack.alignment = .fill
        stack.distribution = .fill
        
        // name
        let tn:[ViewBorderType] = [.bottom,.left]
        let viewProduct = CViewBorder(frame: CGRect.zero, tn)
        let name = UILabel(frame: CGRect.zero)
        name.numberOfLines = 0
        name.textAlignment = .left
        name.textColor = UIColor(hex: Theme.colorNavigationBar)
        name.font = UIFont(name: Theme.font.bold, size: Theme.fontSize.medium)
        name.text = "total_price".localized()
        viewProduct.addSubview(name)
        addContraint(name,10,10)
        
        // quantity
        let tq:[ViewBorderType] = [.left,.bottom,.right]
        let viewQuantity = CViewBorder(frame: CGRect.zero, tq)
        
        // price
        let tp:[ViewBorderType] = [.bottom,.right]
        let viewPrice = CViewBorder(frame: CGRect.zero, tp)
        
        // price
        let tt:[ViewBorderType] = [.bottom,.right]
        let viewTotal = CViewBorder(frame: CGRect.zero, tt)
        let total = UILabel(frame: CGRect.zero)
        total.numberOfLines = 0
        total.textAlignment = .center
        total.textColor = UIColor(hex: Theme.colorNavigationBar)
        total.font = UIFont(name: Theme.font.bold, size: Theme.fontSize.medium)
        total.text = "\(price.toTextPrice()) \("price_unit".localized().uppercased())"
        viewTotal.addSubview(total)
        addContraint(total)
        
        
        stack.insertArrangedSubview(viewProduct, at: stack.arrangedSubviews.count)
        stack.insertArrangedSubview(viewQuantity, at: stack.arrangedSubviews.count)
        viewQuantity.translatesAutoresizingMaskIntoConstraints = false
        viewQuantity.widthAnchor.constraint(equalToConstant: 150).isActive = true
        stack.insertArrangedSubview(viewPrice, at: stack.arrangedSubviews.count)
        viewPrice.translatesAutoresizingMaskIntoConstraints = false
        viewPrice.widthAnchor.constraint(equalToConstant: 200).isActive = true
        stack.insertArrangedSubview(viewTotal, at: stack.arrangedSubviews.count)
        viewTotal.translatesAutoresizingMaskIntoConstraints = false
        viewTotal.widthAnchor.constraint(equalToConstant: 300).isActive = true
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        stackListProducts.insertArrangedSubview(stack, at: stackListProducts.arrangedSubviews.count)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.heightAnchor.constraint(equalToConstant: 600 + CGFloat(50*item.orderItems().count)).isActive = true
        self.layoutIfNeeded()
        self.setNeedsDisplay()
        isReady = true
        return true
    }
    
    // MARK: - private
    func addContraint(_ label:UILabel,_ leading:CGFloat = 0,_ trailing:CGFloat = 0) {
        label.translatesAutoresizingMaskIntoConstraints = false
        label.topAnchor.constraint(equalTo: label.superview!.topAnchor).isActive = true
        label.leadingAnchor.constraint(equalTo: label.superview!.leadingAnchor,constant: leading).isActive = true
        label.superview?.bottomAnchor.constraint(equalTo: label.bottomAnchor).isActive = true
        label.superview?.trailingAnchor.constraint(equalTo: label.trailingAnchor, constant: trailing).isActive = true
    }
    
    func configText() {
        lblTitle.text = "page_order".localized().uppercased()
        lblTitleProduct.text = "infor_product".localized().uppercased()
        lblOrderCode.text = "order_code".localized()
        lblDistributor.text = "distributor".localized()
        lblDistributorPhone.text = "phone".localized()
        lblCustomer.text = "customer".localized()
        lblCustomerPhone.text = "phone".localized()
        lblOrderAddress.text = "order_address".localized()
        
        lblOrderStatus.text = "order_status".localized()
        lblPaymentMethod.text = "payment_method".localized()
        lblPaymentStatus.text = "payment_status".localized()
        lblShipping.text = "transporter".localized()
        lblSVD.text = "transporter_id".localized()
        lblDateCreated.text = "date_created_order".localized()
    }
    
    func configView() {
        
        _ = [lblOrderCode,lblDistributor,lblDistributorPhone,lblCustomer,lblCustomerPhone,lblCityDistrictCustomer,lblOrderAddress,lblOrderStatus,lblPaymentStatus,lblPaymentMethod,lblShipping,lblSVD,lblTitle,lblTitleProduct,lblDateCreated].map{configLabel($0)}
        
        _ = collectTitlesTable.map{configLabel($0)}
        
        btView.type = [.left,.bottom,.top]
        btlView.type = [.bottom,.top,.left]
        btView1.type = [.bottom,.top]
        btrView.type = [.left,.bottom,.top,.right]
    }
    
    func configLabel(_ textfield:UILabel) {
        textfield.textColor = UIColor(hex: Theme.color.customer.subGroup)
        textfield.font = UIFont(name: Theme.font.bold, size: Theme.fontSize.normal)
    }
}
