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
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configText()
        configView()
        binding()
    }
    
    // MARK: - private
    func binding() {
        let nameIsValid = txtTel.rx.text.orEmpty
            .map { $0.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).characters.count > 0 }
            .shareReplay(1)
 
        nameIsValid.bind(to: lblErrorCode.rx.isHidden).disposed(by: disposeBag)
        
        btnChooseCustomer.rx.tap.subscribe(onNext:{ [weak self] in
            let vc = CustomerListController(nibName: "CustomerListController", bundle: Bundle.main)
            vc.onSelectCustomer = {[weak self]
                customer in
                self?.customerSelected = customer
                self?.txtTel.text = customer.tel
                self?.txtAddress.text = customer.address
                self?.txtEmail.text = customer.email
                UIView.animate(withDuration: 0.2, delay: 0, options: [], animations: {
                    self?.vwTel.alpha = 1
                    self?.vwEmail.alpha = 1
                    self?.vwAddress.alpha = 1
                }, completion: { _ in
                    self?.vwTel.isHidden = false
                    self?.vwEmail.isHidden = false
                    self?.vwAddress.isHidden = false
                })
            }
            self?.navigationController?.pushViewController(vc, animated: true)
            
        }).disposed(by: disposeBag)
        
        txtTel.rx.text.orEmpty.subscribe(onNext:{ [weak self] in
            self?.customerSelected.tel = $0
        }).disposed(by: disposeBag)
        txtAddress.rx.text.orEmpty.subscribe(onNext:{ [weak self] in
            self?.customerSelected.address = $0
        }).disposed(by: disposeBag)
        txtOrderCode.rx.text.orEmpty.subscribe(onNext:{ [weak self] in
            self?.orderCode = $0
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
    }
    
    func configText() {
        _ = collectsLabelBrands.map({
            $0.text = $0.accessibilityIdentifier?.localized()
        })
        
        txtOrderCode.placeholder = "placeholder_fullname".localized()
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
