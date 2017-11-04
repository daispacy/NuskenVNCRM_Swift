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
    @IBOutlet var txtCustomerCity: UITextField!
    @IBOutlet var txtCustomerDistrict: UITextField!
    @IBOutlet var txtAddressOrder: UITextField!
    @IBOutlet var btnDistrict: CButtonWithImageRight2!
    @IBOutlet var btnCity: CButtonWithImageRight2!
    
    @IBOutlet var vwEmail: UIView!
    @IBOutlet var vwTel: UIView!
    @IBOutlet var vwAddress: UIView!
    @IBOutlet var vwcity: UIView!
    @IBOutlet var vwDistricct: UIView!
    
    
    var customerSelected:CustomerDO?
    var orderCode:String = ""
    var orderAddress:String = ""
    var disposeBag = DisposeBag()
    var navigationController:UINavigationController?
    var listCustomer:[CustomerDO] = []
    var onUpdateData:((CustomerDO?,String,String,String,String)->Void)?
    var onSelectCustomer:((CustomerDO?)->Void)?
    var order:OrderDO?
    var listCountry:[City] = []
    var city:String = ""
    var district:String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        CustomerManager.getAllCustomers {[weak self] list in
            if let _self = self {
                _self.listCustomer = list
            }
        }
        
        LocalService.shared.getAllCity(complete: {[weak self] list in
            if let _self = self {
                DispatchQueue.main.async {
                    _self.listCountry = list
                }
            }
        })
        
        configText()
        configView()
        binding()
    }
    
    // MARK: - interface
    func show(order:OrderDO) {
        self.order = order
        self.customerSelected = order.customer()
        if let code = order.code {
            self.orderCode = code
            self.txtOrderCode.text = code
        }
        
        if let code = order.address {
            self.orderAddress = code
            self.txtAddressOrder.text = code
        }
        
        if order.district.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).characters.count > 0 {
            let code1 = order.district
            self.district = code1
            self.btnDistrict.setTitle(code1, for: .normal)
            self.btnDistrict.setTitleColor(UIColor(hex: Theme.color.customer.titleGroup), for: .normal)
        }
        
        if order.city.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).characters.count > 0 {
            let code2 = order.city
            self.city = code2
            self.btnCity.setTitle(code2, for: .normal)
            self.btnCity.setTitleColor(UIColor(hex: Theme.color.customer.titleGroup), for: .normal)
        }
        
        if let customer = order.customer() {
            self.btnChooseCustomer.setTitle(customer.fullname, for: .normal)
            self.btnChooseCustomer.setTitleColor(UIColor(hex: Theme.color.customer.titleGroup), for: .normal)
            
            if let tel = customer.tel {
                self.txtTel.text = tel
            }
            
            if let address = customer.address {
                self.txtAddress.text = address
            }
            
            if let email = customer.email {
                self.txtEmail.text = email
            }
            
            if let email = customer.county {
                self.txtCustomerDistrict.text = email
            }
            
            if let email = customer.city {
                self.txtCustomerCity.text = email
            }
        }
        UIView.animate(withDuration: 0.2, delay: 0, options: [], animations: {
            self.vwTel.alpha = 1
            self.vwEmail.alpha = 1
            self.vwAddress.alpha = 1
            self.vwDistricct.alpha = 1
            self.vwcity.alpha = 1
        }, completion: { _ in
            self.vwTel.isHidden = false
            self.vwEmail.isHidden = false
            self.vwAddress.isHidden = false
            self.vwDistricct.isHidden = false
            self.vwcity.isHidden = false
        })
    }
    
    func reloadCityDistrict(_ isClear:Bool = true) {
        if !isClear {
            _ = self.listCountry.map({
                if self.district == $0.name{
                    self.btnDistrict.setTitle($0.name, for: .normal)
                    self.btnDistrict.setTitleColor(UIColor(hex: Theme.color.customer.titleGroup), for: .normal)
                }
                if self.city == $0.name{
                    self.btnCity.setTitle($0.name, for: .normal)
                    self.btnCity.setTitleColor(UIColor(hex: Theme.color.customer.titleGroup), for: .normal)
                }
            })
            
        } else {
            self.btnDistrict.setTitle("placeholder_district".localized(), for: .normal)
            self.btnDistrict.setTitleColor(UIColor(hex: Theme.color.customer.subGroup), for: .normal)
            
            btnCity.setTitle("placeholder_city".localized(), for: .normal)
            btnCity.setTitleColor(UIColor(hex: Theme.color.customer.subGroup), for: .normal)
        }                
    }
    
    // MARK: - private
    func binding() {
        
        btnCity.rx.tap
            .subscribe(onNext:{ [weak self] in
                if let _self = self {
                    
                    var listData:[String] = []
                    _ = _self.listCountry.filter{$0.country_id == 0}.map({
                        listData.append($0.name)
                    })
                    
                    let vc = SimpleListController(nibName: "SimpleListController", bundle: Bundle.main)
                    vc.onDidLoad = {
                        vc.title = "choose_city".localized().uppercased()
                        vc.showData(data: listData)
                        return true
                    }
                    vc.onSelectData = { name in
                        _ = _self.listCountry.map({
                            if $0.name == name {
                                _self.city = name
                            }
                        })
                        if name != _self.btnCity.titleLabel?.text {
                            _self.btnDistrict.setTitle("placeholder_district".localized(), for: .normal)
                            _self.btnDistrict.setTitleColor(UIColor(hex: Theme.color.customer.subGroup), for: .normal)
                        }
                        _self.btnCity.setTitle(name, for: .normal)
                        _self.btnCity.setTitleColor(UIColor(hex: Theme.color.customer.titleGroup), for: .normal)
                        if !_self.btnDistrict.isEnabled {
                            _self.btnDistrict.isEnabled = true
                        }
                    }
                    _self.navigationController?.pushViewController(vc, animated: true)
                    if self?.customerSelected != nil {
                        _self.onUpdateData?(_self.customerSelected!,_self.orderCode,_self.orderAddress,_self.city,_self.district)
                    }
                }
            })
            .addDisposableTo(disposeBag)
        
        btnDistrict.rx.tap
            .subscribe(onNext:{ [weak self] in
                if let _self = self {
                    if let city = _self.btnCity.titleLabel?.text  {
                        if city == "placeholder_city".localized() {
                            return
                        }
                    }
                    let vc = SimpleListController(nibName: "SimpleListController", bundle: Bundle.main)
                    _self.navigationController?.pushViewController(vc, animated: true)
                    
                    var listData:[String] = []
                    
                    _ = _self.listCountry.map({
                        if let city = _self.btnCity.titleLabel?.text  {
                            if $0.name == city {
                                let country:City = $0
                                let listFilter:[City] = _self.listCountry.filter{
                                    $0.country_id == country.id
                                }
                                
                                _ = listFilter.map({
                                    listData.append($0.name)
                                })
                                
                                vc.onDidLoad = {
                                    vc.title = "choose_district".localized().uppercased()
                                    vc.showData(data: listData)
                                    return true
                                }
                            }
                        }
                    })
                    
                    
                    vc.onSelectData = { name in
                        _ = _self.listCountry.map({
                            if $0.name == name && $0.country_id > 0{
                                _self.district = $0.name
                            }
                        })
                        _self.btnDistrict.setTitle(name, for: .normal)
                        _self.btnDistrict.setTitleColor(UIColor(hex: Theme.color.customer.titleGroup), for: .normal)
                        if self?.customerSelected != nil {
                            _self.onUpdateData?(_self.customerSelected!,_self.orderCode,_self.orderAddress,_self.city,_self.district)
                        }
                    }
                }
            })
            .addDisposableTo(disposeBag)
        
        btnChooseCustomer.rx.tap.subscribe(onNext:{ [weak self] in
            if let _self = self {
                let vc = SimpleListController(nibName: "SimpleListController", bundle: Bundle.main)
                _self.navigationController?.pushViewController(vc, animated: true)
                vc.title = "choose_customer".localized().uppercased()
                var listData:[String] = []
                _ = _self.listCustomer.map({
                    if let fullname = $0.fullname {
                        listData.append(fullname)
                    }
                })
                vc.showData(data: listData.sorted(by: {$0 < $1}))                
                
                vc.onSelectData = {[weak self] name in
                    if let _self = self {
                        _ = _self.listCustomer.map({
                            if $0.fullname == name {
                                _self.customerSelected = $0
                                _self.txtTel.text = _self.customerSelected?.tel
                                _self.txtAddress.text = _self.customerSelected?.address
                                _self.txtEmail.text = _self.customerSelected?.email
                                _self.txtCustomerDistrict.text = _self.customerSelected?.county
                                _self.txtCustomerCity.text = _self.customerSelected?.city
                                _self.btnChooseCustomer.setTitle(name, for: .normal)
                                _self.btnChooseCustomer.setTitleColor(UIColor(hex: Theme.color.customer.titleGroup), for: .normal)
                                if _self.lblErrorChooseCustomer.isHidden == false {
                                    _self.lblErrorChooseCustomer.isHidden = true
                                }
                                _self.onUpdateData?($0,_self.orderCode,_self.orderAddress,_self.city,_self.district)
                                UIView.animate(withDuration: 0.2, delay: 0, options: [], animations: {
                                    _self.vwTel.alpha = 1
                                    _self.vwEmail.alpha = 1
                                    _self.vwAddress.alpha = 1
                                    _self.vwcity.alpha = 1
                                    _self.vwDistricct.alpha = 1
                                }, completion: { _ in
                                    _self.vwTel.isHidden = false
                                    _self.vwEmail.isHidden = false
                                    _self.vwAddress.isHidden = false
                                    _self.vwDistricct.isHidden = false
                                    _self.vwcity.isHidden = false
                                    _self.onSelectCustomer?(_self.customerSelected!)
                                })
                            }
                        })
                    }
                }
            }
        }).addDisposableTo(disposeBag)
        
        txtTel.rx.text.orEmpty.subscribe(onNext:{ [weak self] in
            if let _self = self {
                _self.customerSelected?.tel = $0
                if self?.customerSelected != nil {
                    _self.onUpdateData?(_self.customerSelected!,_self.orderCode,_self.orderAddress,_self.city,_self.district)
                }
            }
        }).addDisposableTo(disposeBag)
        txtAddress.rx.text.orEmpty.subscribe(onNext:{ [weak self] in
            if let _self = self {
                _self.customerSelected?.address = $0
                if self?.customerSelected != nil {
                    _self.onUpdateData?(_self.customerSelected!,_self.orderCode,_self.orderAddress,_self.city,_self.district)
                }
            }
        }).addDisposableTo(disposeBag)
        txtOrderCode.rx.text.orEmpty.subscribe(onNext:{ [weak self] in
            if let _self = self {
                _self.orderCode = $0
                _self.lblErrorCode.isHidden = true                
                if self?.customerSelected != nil {
                    _self.onUpdateData?(_self.customerSelected!,_self.orderCode,_self.orderAddress,_self.city,_self.district)
                }
            }
        }).addDisposableTo(disposeBag)
        txtAddressOrder.rx.text.orEmpty.subscribe(onNext:{ [weak self] in
            if let _self = self {
                _self.orderAddress = $0
                if self?.customerSelected != nil {
                    _self.onUpdateData?(_self.customerSelected!,_self.orderCode,_self.orderAddress,_self.city,_self.district)
                }
            }
        }).addDisposableTo(disposeBag)
        
    }
    
    func configView() {
        _ = collectsLabelBrands.map({
            $0.font = UIFont(name: Theme.font.normal, size: Theme.fontSize.small)!
            $0.textColor = UIColor(hex: Theme.color.customer.subGroup)
        })
        
        configTextfield(txtTel)
        configTextfield(txtEmail)
        configTextfield(txtAddress)
        configTextfield(txtCustomerCity)
        configTextfield(txtCustomerDistrict)
        configTextfield(txtOrderCode)
        configTextfield(txtAddressOrder)
        
        configButton(btnChooseCustomer)
        txtEmail.isEnabled = false
        
        lblErrorCode.font = UIFont(name: Theme.font.normal, size: Theme.fontSize.small)!
        lblErrorChooseCustomer.font = lblErrorCode.font
        lblErrorCode.textColor = UIColor.red
        lblErrorChooseCustomer.textColor = lblErrorCode.textColor
        lblErrorCode.isHidden = true
    }
    
    func configText() {
        _ = collectsLabelBrands.map({
            $0.text = $0.accessibilityIdentifier?.localized()
        })
        
        txtOrderCode.placeholder = "placeholder_order_code".localized()
        txtEmail.placeholder = "placeholder_email".localized()
        txtTel.placeholder = "placeholder_phone".localized()
        txtAddress.placeholder = "placeholder_address".localized()
        txtCustomerDistrict.placeholder = "placeholder_district".localized()
        txtCustomerCity.placeholder = "placeholder_city".localized()
        txtAddressOrder.placeholder = "address_order".localized()
        
        btnChooseCustomer.setTitle("placeholder_choose_customer".localized(), for: .normal)
        
        lblErrorCode.text = "invalid_order_code".localized()
        lblErrorChooseCustomer.text = "choose_customer".localized()
        
        self.btnDistrict.setTitle("placeholder_district".localized(), for: .normal)
        self.btnDistrict.setTitleColor(UIColor(hex: Theme.color.customer.subGroup), for: .normal)
        btnDistrict.titleLabel?.font = UIFont(name: Theme.font.bold, size: Theme.fontSize.normal)
        btnCity.setTitle("placeholder_city".localized(), for: .normal)
        btnCity.setTitleColor(UIColor(hex: Theme.color.customer.subGroup), for: .normal)
        btnCity.titleLabel?.font = UIFont(name: Theme.font.bold, size: Theme.fontSize.normal)
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
