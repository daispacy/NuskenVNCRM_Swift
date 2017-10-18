//
//  OrderProductListView.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 10/18/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class OrderProductListView: UIView {
    
    @IBOutlet var stackViewContainer: UIStackView!
    @IBOutlet var lbltitle: CLabelGradient!
    @IBOutlet var btnAddProduct: UIButton!
    var order:Order?
    var disposeBage = DisposeBag()
    var listEditProduct:[Product] = []
    var onUpdateProducts:(([Product])->Void)?
    
    var navigationController:UINavigationController?
    
    // MARK: - init
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configText()
        configView()
        binding()
    }
    
    // MARK: - interface
    func show(order:Order) {
        self.order = order
        let or = order
            let listProduct = LocalService.shared.getAllProduct(orderID: or.id)
            if listProduct.count > 0 {
                self.listEditProduct.append(contentsOf: listProduct)
            }
        
        refreshData()
    }
    
    // MARK: - private
    func binding() {
        btnAddProduct.rx.tap.subscribe(onNext:{[weak self] in
            guard let _self = self else {
                return
            }
            _self.handleProduct()
            
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
        
        var listData:[Product] = []
        
        if self.listEditProduct.count > 0 {
            _ = self.listEditProduct.map({
                let blockProduct = Bundle.main.loadNibNamed("BlockOrderProductView", owner: self, options: [:])?.first as! BlockOrderProductView
                self.stackViewContainer.insertArrangedSubview(blockProduct, at: self.stackViewContainer.arrangedSubviews.count-1)
                blockProduct.show(product:$0)
                blockProduct.onSelectDelete = { product in
                    Support.popup.showAlert(message: "would_you_like_to_delete_product".localized(), buttons: ["cancel".localized(),"ok".localized()], vc: self.navigationController!, onAction: {index in
                        
                    })
                }
                blockProduct.onSelectEdit = { product in
                    self.handleProduct(product: product)
                }
            })
            listData.append(contentsOf: self.listEditProduct)
        }
        onUpdateProducts?(listData)
    }
    
    func handleProduct(product:Product? = nil) {
        let vc = AddProductController(nibName: "AddProductController", bundle: Bundle.main)
        self.navigationController?.present(vc, animated: false, completion: {
            if let pro = product {
                vc.edit(product: pro)
            }
        })
        vc.onChangeProduct = {
            product, except in
            
            if self.validateProduct(name: product.name, except: false) && !except{
                self.listEditProduct.append(product)
            } else {
                let index = self.listEditProduct.index(where: { (item) -> Bool in
                    item.name == product.tempName
                })
                self.listEditProduct[index!] = product
            }
            self.refreshData()
        }
        vc.onValidateProduct = { name,except in
            return self.validateProduct(name: name, except: except)
        }
    }
    
    func validateProduct(name:String,except:Bool) -> Bool {
        let filter =  self.listEditProduct.filter{ $0.name == name}
        if filter.count == 0 {
            return true
        } else if except && filter.count == 1 {
            return true
        } else {
            return false
        }
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
class BlockOrderProductView: UIView {
    
    @IBOutlet var lblName: UILabel!
    @IBOutlet var lblTotal: UILabel!
    @IBOutlet var lblPrice: UILabel!
    
    var onSelectEdit:((Product)->Void)?
    var onSelectDelete:((Product)->Void)?
    var product:Product?
    
    // MARK: - init
    override func awakeFromNib() {
        super.awakeFromNib()
        configView()
        configText()
    }
    
    // MARK: - interface
    func show(product:Product) {
        self.product = product
        
        lblName.text = product.name
        lblTotal.text = "\(product.quantity) \("unit".localized())"
        lblPrice.text = "\(product.price) \("price_unit".localized().uppercased())"
        
    }
    
    // MARK: - event process
    @IBAction func processEdit(_ sender: Any) {
        if let pro = self.product {
            onSelectEdit?(pro)
        }
    }
    
    @IBAction func processRemove(_ sender: Any) {
        if let pro = self.product {
            onSelectDelete?(pro)
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
