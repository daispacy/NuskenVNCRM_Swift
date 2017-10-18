//
//  OrderCustomerView.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 10/18/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class OrderCustomerView: UIView {
    
    @IBOutlet var collectsLabelBrands: [UILabel]!
    @IBOutlet var lblErrorCode: UILabel!
    @IBOutlet var lblErrorChooseCustomer: UILabel!
    @IBOutlet var txtOrderCode: UITextField!
    @IBOutlet var btnChooseCustomer: CButtonWithImageRight2!
    @IBOutlet var txtEmail: UITextField!
    @IBOutlet var txtTel: UITextField!
    @IBOutlet var txtAddress: UITextField!
    
    @IBOutlet var vwEmail: UIView!
    @IBOutlet var vwTel: UIView!
    @IBOutlet var vwAddress: UIView!
    
    
    var customerSelected:Customer = Customer(id: 0, distributor_id: 0, store_id: 0)
    var orderCode:String = ""
    var disposeBag = DisposeBag()
    var navigationController:UINavigationController?
    var listCustomer:[Customer] = []
    var onUpdateData:((Customer,String)->Void)?
    var order:Order?
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        LocalService.shared.getCustomerWithCustom(sql:"select * from `customer`", onComplete: {[weak self] list in
            if let _self = self {
                _self.listCustomer = list
            }
        })
        
        configText()
        configView()
        binding()
    }
    
    // MARK: - interface
    func show(order:Order) {
        self.order = order
        self.customerSelected = order.customer
        self.txtOrderCode.text = order.order_code
        self.txtTel.text = self.customerSelected.tel
        self.txtAddress.text = self.customerSelected.address
        self.txtEmail.text = self.customerSelected.email
        self.btnChooseCustomer.setTitle(order.customer.fullname, for: .normal)
        self.btnChooseCustomer.setTitleColor(UIColor(hex: Theme.color.customer.titleGroup), for: .normal)
        UIView.animate(withDuration: 0.2, delay: 0, options: [], animations: {
            self.vwTel.alpha = 1
            self.vwEmail.alpha = 1
            self.vwAddress.alpha = 1
        }, completion: { _ in
            self.vwTel.isHidden = false
            self.vwEmail.isHidden = false
            self.vwAddress.isHidden = false
        })
    }
    
    // MARK: - private
    func binding() {
        let nameIsValid = txtOrderCode.rx.text.orEmpty
            .map { $0.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).characters.count > 0 }
            .shareReplay(1)
        
        nameIsValid.bind(to: lblErrorCode.rx.isHidden).disposed(by: disposeBag)
        
        btnChooseCustomer.rx.tap.subscribe(onNext:{ [weak self] in
            if let _self = self {
                let vc = SimpleListController(nibName: "SimpleListController", bundle: Bundle.main)
                _self.navigationController?.pushViewController(vc, animated: true)
                
                vc.onDidLoad = {
                    vc.title = "choose_customer".localized().uppercased()
                    var listData:[String] = []
                    _ = _self.listCustomer.map({
                        listData.append($0.fullname)
                        
                    })
                    vc.showData(data: listData.sorted(by: {$0 < $1}))
                }
                
                vc.onSelectData = {[weak self] name in
                    if let _self = self {
                        _ = _self.listCustomer.map({
                            if $0.fullname == name {
                                _self.customerSelected = $0
                                _self.txtTel.text = _self.customerSelected.tel
                                _self.txtAddress.text = _self.customerSelected.address
                                _self.txtEmail.text = _self.customerSelected.email
                                _self.btnChooseCustomer.setTitle(name, for: .normal)
                                _self.btnChooseCustomer.setTitleColor(UIColor(hex: Theme.color.customer.titleGroup), for: .normal)
                                _self.onUpdateData!(_self.customerSelected,_self.orderCode)
                                UIView.animate(withDuration: 0.2, delay: 0, options: [], animations: {
                                    _self.vwTel.alpha = 1
                                    _self.vwEmail.alpha = 1
                                    _self.vwAddress.alpha = 1
                                }, completion: { _ in
                                    _self.vwTel.isHidden = false
                                    _self.vwEmail.isHidden = false
                                    _self.vwAddress.isHidden = false
                                })
                            }
                        })
                    }
                }
            }
        }).disposed(by: disposeBag)
        
        txtTel.rx.text.orEmpty.subscribe(onNext:{ [weak self] in
            if let _self = self {
                _self.customerSelected.tel = $0
                _self.onUpdateData?(_self.customerSelected,_self.orderCode)
            }
        }).disposed(by: disposeBag)
        txtAddress.rx.text.orEmpty.subscribe(onNext:{ [weak self] in
            if let _self = self {
                _self.customerSelected.address = $0
                _self.onUpdateData?(_self.customerSelected,_self.orderCode)
            }
        }).disposed(by: disposeBag)
        txtOrderCode.rx.text.orEmpty.subscribe(onNext:{ [weak self] in
            if let _self = self {
                _self.orderCode = $0
                _self.onUpdateData?(_self.customerSelected,_self.orderCode)
            }
        }).disposed(by: disposeBag)
        
    }
    
    func configView() {
        _ = collectsLabelBrands.map({
            $0.font = UIFont(name: Theme.font.normal, size: Theme.fontSize.small)!
            $0.textColor = UIColor(hex: Theme.color.customer.subGroup)
        })
        
        configTextfield(txtTel)
        configTextfield(txtEmail)
        configTextfield(txtAddress)
        configTextfield(txtOrderCode)
        
        configButton(btnChooseCustomer)
        txtEmail.isEnabled = false
        
        lblErrorCode.font = UIFont(name: Theme.font.normal, size: Theme.fontSize.small)!
        lblErrorChooseCustomer.font = lblErrorCode.font
        lblErrorCode.textColor = UIColor.red
        lblErrorChooseCustomer.textColor = lblErrorCode.textColor
    }
    
    func configText() {
        _ = collectsLabelBrands.map({
            $0.text = $0.accessibilityIdentifier?.localized()
        })
        
        txtOrderCode.placeholder = "placeholder_order_code".localized()
        txtEmail.placeholder = "placeholder_email".localized()
        txtTel.placeholder = "placeholder_phone".localized()
        txtAddress.placeholder = "placeholder_address".localized()
        
        btnChooseCustomer.setTitle("placeholder_choose_customer".localized(), for: .normal)
        
        lblErrorCode.text = "invalid_order_code".localized()
        lblErrorChooseCustomer.text = "choose_customer".localized()
        
        
    }
    
    private func configButton(_ button:UIButton, isHolder:Bool = false) {
        button.setTitleColor(UIColor(hex:"0xC7C7CD"), for: .normal)
        button.titleLabel?.font = UIFont(name: Theme.font.bold, size: Theme.fontSize.normal)
    }
    
    private func configTextfield(_ textfield:UITextField) {
        textfield.textColor = UIColor(hex: Theme.color.customer.subGroup)
        textfield.font = UIFont(name: Theme.font.bold, size: Theme.fontSize.normal)
    }
}