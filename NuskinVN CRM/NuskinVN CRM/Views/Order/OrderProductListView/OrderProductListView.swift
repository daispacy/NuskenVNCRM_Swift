//
//  OrderProductListView.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 10/18/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import UIKit
import CoreData
import RxCocoa
import RxSwift

class OrderProductListView: UIView {
    
    @IBOutlet var stackViewContainer: UIStackView!
    @IBOutlet var lbltitle: CLabelGradient!
    @IBOutlet var btnAddProduct: UIButton!
    var order:OrderDO?
    var disposeBage = DisposeBag()
//    var listOrderItem:[OrderItemDO] = []
//    var listEditProduct:[OrderItemDO] = []
    var listOrderItem:[JSON] = []
    var onUpdateProducts:(([JSON])->Void)?
    var isFirstLoaded:Bool = false
    var isDisableEdit:Bool = false
    var onRegisterPreventSyncAgain:(()->Void)?
    var navigationController:UINavigationController?
    
    // MARK: - init
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configText()
        configView()
        binding()
    }
    
    // MARK: - interface
    func show(order:OrderDO) {
        self.order = order
        refreshData()
    }
    
    func disableControl() {
        isDisableEdit = true
        btnAddProduct.isHidden = true
        _ = stackViewContainer.arrangedSubviews.map({ view in
            if view.isKind(of: BlockOrderProductView.self) {
                let v = view as! BlockOrderProductView
                v.disableControl()
            }
        })
    }
    
    // MARK: - private
    func binding() {
        // MARK: - Select Product
        btnAddProduct.rx.tap.subscribe(onNext:{[weak self] in
            guard let _self = self else {
                return
            }
            let vc = ProductListController(nibName: "ProductListController", bundle: Bundle.main) 
            _self.navigationController?.pushViewController(vc, animated: true)
            vc.onSelectData = {[weak self] product in
                if let _self = self {
                    _self.navigationController?.popViewController(animated: true)
                    _self.handleProduct(product: product)
                }
            }
            
        }).disposed(by: disposeBage)
    }
    
    func refreshData() {
        _ = stackViewContainer.arrangedSubviews.map({[weak self] in
            if let _self = self {
                if $0.isEqual(_self.lbltitle) || $0.isEqual(_self.btnAddProduct) {
                    print("dont remove title & button add")
                } else {
                    $0.removeFromSuperview()
                }
            }
        })
        
        
        if self.listOrderItem.count == 0 && !isFirstLoaded{
            isFirstLoaded = true
            if let order = self.order {
                if order.numberOrderItems() == 0 {
                    return
                }
                self.listOrderItem.append(contentsOf: order.orderItems().flatMap({
                    ["price":$0.price,"total":$0.quantity,"product":$0.product()!]
                }))
                
                if self.listOrderItem.count > 0 {
                    _ = self.listOrderItem.map({
                        let blockProduct = Bundle.main.loadNibNamed("BlockOrderProductView", owner: self, options: [:])?.first as! BlockOrderProductView
                        self.stackViewContainer.insertArrangedSubview(blockProduct, at: self.stackViewContainer.arrangedSubviews.count-1)
                        blockProduct.show(json:$0)
                        blockProduct.onSelectEditJSON = {[weak self]
                            orderitem in
                            if let _self = self {
                                _self.handleProduct(json: orderitem)
                            }
                        }
                        blockProduct.onSelectDeleteJSON = {[weak self]
                            data in
                            if let _self = self {
                                Support.popup.showAlert(message: "would_you_like_to_delete_product".localized(), buttons: ["cancel".localized(),"ok".localized()], vc: _self.navigationController!, onAction: {index in
                                    if index == 1 {
                                        if let index = _self.listOrderItem.index(where: {
                                            if let pro = $0["product"] as? ProductDO,
                                                let pro1 = data["product"] as? ProductDO{
                                                return pro.name == pro1.name
                                            }
                                            return false
                                        })
                                        {
                                            _self.listOrderItem.remove(at: index)
                                            _self.refreshData()
                                        }
                                    }
                                },{[weak self] in
                                    guard let _self = self else {return}
                                    _self.onRegisterPreventSyncAgain?()
                                })
                            }
                        }
                    })
                }
            }
        } else {
            if self.listOrderItem.count > 0 {
                _ = self.listOrderItem.map({
                    let blockProduct = Bundle.main.loadNibNamed("BlockOrderProductView", owner: self, options: [:])?.first as! BlockOrderProductView
                    self.stackViewContainer.insertArrangedSubview(blockProduct, at: self.stackViewContainer.arrangedSubviews.count-1)
                    blockProduct.show(json:$0)
                    blockProduct.onSelectEditJSON = {
                        orderitem in
                        self.handleProduct(json: orderitem)
                    }
                    blockProduct.onSelectDeleteJSON = {
                        data in
                        Support.popup.showAlert(message: "would_you_like_to_delete_product".localized(), buttons: ["cancel".localized(),"ok".localized()], vc: self.navigationController!, onAction: {index in
                            if index == 1 {
                                if let index = self.listOrderItem.index(where: {
                                    if let pro = $0["product"] as? ProductDO,
                                        let pro1 = data["product"] as? ProductDO{
                                        return pro.name == pro1.name
                                    }
                                    return false
                                })
                                {
                                    self.listOrderItem.remove(at: index)
                                    self.refreshData()
                                }
                            }
                        },{[weak self] in
                        guard let _self = self else {return}
                        _self.onRegisterPreventSyncAgain?()
                    })
                    }
                })
            }
            
        }
        
        
        self.onUpdateProducts?(listOrderItem)
    }
    
    func handleProduct(product:ProductDO? = nil, json:JSON? = nil, order:OrderItemDO? = nil) {
       
        let vc = AddProductController(nibName: "AddProductController", bundle: Bundle.main)
        var topVC = UIApplication.shared.keyWindow?.rootViewController
        while((topVC!.presentedViewController) != nil){
            topVC = topVC!.presentedViewController
        }
        topVC?.present(vc, animated: false, completion: {
            if let pro = product {
                vc.showProduct(pro)
            }
            if let orderItem = json {
                vc.edit(json: orderItem)
            }            
            if let orderItem = order {
                vc.edit(orderItem: orderItem)
            }
        })
        vc.onCheckProductExist = {
            product in
            if let index = self.listOrderItem.index(where: {
                if let pro = $0["product"] as? ProductDO {
                   return pro.name == product.name
                }
                
                return false
            })
            {
                return index >= 0
            }
            return false
        }
        vc.onAddData = {
            data, isEdit in
            if isEdit {
                if let index = self.listOrderItem.index(where: {
                    if let pro = $0["product"] as? ProductDO,
                        let pro1 = data["product"] as? ProductDO{
                        return pro.name == pro1.name
                    }
                    return false
                })
                {
                    self.listOrderItem.remove(at: index)
                }
            }
            self.listOrderItem.append(data)
            self.refreshData()
        }
        vc.ondeinitial = {
            [weak self] in
            guard let _self = self else { return}
            _self.onRegisterPreventSyncAgain?()
        }
        
//        vc.onChangeOrderItem = { orderItem in
//            self.listEditProduct.append(orderItem)
//            self.refreshData()
//        }
    }
    
    func configView() {
        btnAddProduct.tintColor = UIColor(hex:"0x349ad5")
        btnAddProduct.setTitleColor(UIColor(_gradient: Theme.colorGradient, frame: btnAddProduct.titleLabel!.frame, isReverse: false), for: .normal)
    }
    
    func configText() {
        if let checkIcon = Support.image.iconFont(code: "\u{f067}", size: 22,color: "0xe30b7a") {
            btnAddProduct.setImage(checkIcon, for: .normal)
        }
        btnAddProduct.setTitle("add_product".localized().uppercased(), for: .normal)
        
        lbltitle.text = "product".localized().uppercased()
        lbltitle.font = UIFont(name: Theme.font.bold, size: Theme.fontSize.medium)
        
        self.layoutIfNeeded()
        self.setNeedsDisplay()
    }
}

// MARK: - BLOCK ORDER PRODUCT VIEW
class BlockOrderProductView: UIView, UIGestureRecognizerDelegate {
    
    @IBOutlet var lblName: UILabel!
    @IBOutlet var lblTotal: UILabel!
    @IBOutlet var lblPrice: UILabel!
    @IBOutlet var vwControl: UIView!
    @IBOutlet var btnDelete: UIButton!
    @IBOutlet var imgProduct: UIImageView!
    
    var tapGesture:UITapGestureRecognizer!
    var onSelectEdit:((OrderItemDO)->Void)?
    var onSelectDelete:((OrderItemDO)->Void)?
    var onSelectEditJSON:((JSON)->Void)?
    var onSelectDeleteJSON:((JSON)->Void)?
    var product:OrderItemDO?
    var json:JSON?
    var isIgnoreTouh:Bool = false
    
    // MARK: - init
    override func awakeFromNib() {
        super.awakeFromNib()
        configView()
        configText()
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.processEdit(_:)))
        tapGesture.delegate = self
        tapGesture.cancelsTouchesInView = false
        self.addGestureRecognizer(tapGesture)
    }
    
    deinit {
        if tapGesture != nil {
            self.removeGestureRecognizer(tapGesture!)
        }
    }
    
    // MARK: - interface
    func show(product:OrderItemDO) {
        self.product = product
        
        lblName.text = product.name
        lblTotal.text = "\(product.quantity) \("unit".localized())"
        lblPrice.text = "\(product.price) \("price_unit".localized().uppercased())"
    }
    
    func disableControl() {
        vwControl.removeFromSuperview()
        if tapGesture != nil {
            self.removeGestureRecognizer(tapGesture!)
        }
    }
    
    func show(json:JSON) {
        self.json = json
        if let pro = json["product"] as? ProductDO{
            lblName.text = pro.name
            if let imgStr = pro.avatar {
                if imgStr.characters.count > 0 {
                    imgProduct.loadImageUsingCacheWithURLString("\(Server.domainImage.rawValue)/upload/1/products/m_\(imgStr)",size:nil, placeHolder: UIImage(named:"ic_top_product_block"))
                }
            }
        }
        if let quantity = Int64("\(json["total"] ?? 0)"),
            let price = Int64("\(json["price"] ?? 0)")
            {
            lblPrice.text = "\((price*quantity).toTextPrice()) \("price_unit".localized().uppercased())"
            lblTotal.text = "\(quantity.toTextPrice()) \("unit".localized())"
        }
    }
    
    // MARK: - event process
    func processEdit(_ sender: UIGestureRecognizer) {
        if isIgnoreTouh {return}
        if self.json != nil {
            onSelectEditJSON?(self.json!)
        } else {
            if let pro = self.product {
                onSelectEdit?(pro)
            }
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let view = touch.view {
            if view.isDescendant(of: self.btnDelete) {
                isIgnoreTouh = true
                return false
            }
        }
        isIgnoreTouh = false
        return true
    }
    
    @IBAction func processRemove(_ sender: Any) {
        
        if self.json != nil {
            onSelectDeleteJSON?(self.json!)
        } else {
            if let pro = self.product {
                onSelectDelete?(pro)
            }
        }
        
    }
    
    // MARK: - private
    func configView() {
        
        
        configLabel(lbl: lblTotal)
        configLabel(lbl: lblPrice)
        
        lblName.font = UIFont(name: Theme.font.bold, size: Theme.fontSize.normal)!
        lblName.textColor = UIColor(hex: Theme.color.customer.titleGroup)
    }
    
    func configText() {
        
    }
    
    func configLabel(lbl:UILabel) {
        lbl.font = UIFont(name: Theme.font.normal, size: Theme.fontSize.normal)!
        lbl.textColor = UIColor(hex: Theme.color.customer.titleGroup)
    }
    
    
}
