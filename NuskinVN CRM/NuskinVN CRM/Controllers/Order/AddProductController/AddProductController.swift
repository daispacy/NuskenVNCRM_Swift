//
//  CustomAlertController.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 9/22/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import UIKit
import CoreData
import RxSwift
import RxCocoa

class AddProductController: UIViewController {
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var lblMessage: UILabel!
    @IBOutlet var lblError: CMessageLabel!
    @IBOutlet var btnFirst: CButtonAlert!
    @IBOutlet var btnSecond: CButtonAlert!
    @IBOutlet var vwcontrol: UIView!
    @IBOutlet var txtName: UITextField!
    @IBOutlet var txtTotal: UITextField!
    @IBOutlet var txtPrice: UITextField!
    @IBOutlet var txtPV: UITextField!
    @IBOutlet var txtSugguestPrice: UITextField!
    @IBOutlet var collectLabelAddProruct: [UILabel]!
    
    var onAddData:((JSON,Bool)->Void)?
    var onCheckProductExist:((ProductDO)->Bool)?
    var onChangeOrderItem:((OrderItemDO)->Void)?
    var tapGesture:UITapGestureRecognizer!
    var product:ProductDO?
    var orderItem:OrderItemDO?
    var disposeBag = DisposeBag()
    var isEdit:Bool = false
    
    // MARK: - INIT
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        self.providesPresentationContextTransitionStyle = true
        self.definesPresentationContext = true
        self.modalPresentationStyle=UIModalPresentationStyle.overCurrentContext
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        bindControl()
        super.viewDidLoad()
        configView()
        configText()
        
        LocalService.shared.isShouldSyncData = {[weak self] in
            if let _self = self {
                return false
            }
            return true
        }
        
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if(tapGesture != nil) {
            self.view.removeGestureRecognizer(tapGesture!)
        }
    }
    
    // MARK: - custom
    func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        //Need to calculate keyboard exact size due to Apple suggestions
        //        self.scrollVIew.isScrollEnabled = true
        var info = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize!.height, 0.0)
        
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        
        var aRect : CGRect = self.view.frame
        aRect.size.height -= keyboardSize!.height
    }
    
    func keyboardWillHide(notification: NSNotification) {
        
        var info = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, -keyboardSize!.height, 0.0)
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        hideKeyboard()
    }
    
    
    deinit {
        self.view.removeGestureRecognizer(tapGesture)
        NotificationCenter.default.removeObserver(self)
        print("\(String(describing: AddProductController.self)) dealloc")
    }
    
    // MARK: - INTERFACE
    func showProduct(_ product:ProductDO) {
        self.product = product
        txtName.text = product.name
        txtSugguestPrice.text = "\(product.price.toTextPrice())"
        txtPrice.text = "\(product.price)"
        txtTotal.text = "\(1)"
        txtPV.text = "\(product.pv.toTextPrice())"
        configText()
        configView()
    }
    
    func edit(json:JSON) {
        self.isEdit = true
        if let pro = json["product"] as? ProductDO {
            self.product = pro
            txtName.text = pro.name
            txtSugguestPrice.text = "\(pro.price.toTextPrice())"
            txtPV.text = "\(pro.pv.toTextPrice())"
        }
        if let quantity = Int64("\(json["total"] ?? 0)") {
            txtTotal.text = "\(quantity)"
        }
        
        if let price = Int64("\(json["price"] ?? 0)") {
            txtPrice.text = "\(price)"
        }
    }
    
    func edit(orderItem:OrderItemDO) {
        self.isEdit = true
        self.orderItem = orderItem
        //        txtName.text = product.name
        //        txtPrice.text = "\(product.price)"
        //        txtTotal.text = "\(product.price)"
        configText()
        configView()
    }
    
    // MARK: - BIND CONTROL
    func bindControl() {
                txtTotal.rx.text.orEmpty.subscribe(onNext:{ [weak self] in
                    if let _self = self,
                        let product = self?.product {
                        let text = $0
                        if text.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines).characters.count > 0 {
                            _self.txtPV.text = "\(Int64(text)! * product.pv)"
                        }
                    }
                }).addDisposableTo(disposeBag)
    }
    
    // MARK: - BUTTON EVENT
    @IBAction private func buttonPress(_ sender: UIButton) {
        
        if(sender.isEqual(btnFirst) == true) {
            
            if !validateData() {
                lblError.text = "please_provide_price_and_quantity".localized()
                lblError.isHidden = false
                return
            }
            if let strprice = self.txtPrice.text,
                let pro = self.product,
                let strtotal = self.txtTotal.text {
                
                if let price = Int64(strprice),
                    let total = Int64(strtotal){
                    if price < pro.price {
                        lblError.text = "price_not_lower_sugguest_price".localized()
                        lblError.isHidden = false
                        return
                    }
                    
                    if let orderItem = self.orderItem {
                        orderItem.price = price
                        orderItem.quantity = total
                        self.onChangeOrderItem?(orderItem)
                        self.dismiss(animated: false, completion: nil)
                    } else {
                        if let pro = self.product {
                            if self.isEdit == false {
                                if let checkProduct = self.onCheckProductExist {
                                    let bool = checkProduct(pro)
                                    if bool {
                                        Support.popup.showAlert(message: "product_exist_in_order".localized(), buttons: ["ok".localized()], vc: self, onAction: {index in
                                                                                     
                                        })
                                        return
                                    }
                                }
                            }
                            self.onAddData?(["total":total,"price":price,"product":pro],self.isEdit)
                            self.dismiss(animated: false, completion: nil)
                        }
                    }
                    
                } else {
                    lblError.text = "price_or_quantity_invalid".localized()
                    lblError.isHidden = false
                    return
                }
            }
            
        } else {
            dismiss(animated: false, completion: nil)
        }
    }
    
    func dismissView (gesture:UITapGestureRecognizer) {
        dismiss(animated: false, completion: nil)
    }
    
    // MARK: - PRIVATE
    func validateData() ->Bool {
        if txtPrice.text?.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines).characters.count == 0 ||
            txtTotal.text?.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines).characters.count == 0 ||
            txtName.text?.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines).characters.count == 0 {
            return false
        } else {
            return true
        }
    }
    
    func configView() {
        btnFirst.backgroundColor = UIColor(_gradient: Theme.colorGradient, frame: btnFirst.frame, isReverse:true)
        btnFirst.setTitleColor(UIColor(hex:Theme.colorAlertButtonTitleColor), for: .normal)
        btnFirst.titleLabel?.font = UIFont(name: Theme.font.normal, size: Theme.fontSize.normal)
        
        btnSecond.backgroundColor = UIColor(_gradient: Theme.colorGradient, frame: btnSecond.frame, isReverse:true)
        btnSecond.setTitleColor(UIColor(hex:Theme.colorAlertButtonTitleColor), for: .normal)
        btnSecond.titleLabel?.font = UIFont(name: Theme.font.normal, size: Theme.fontSize.normal)
        
        lblMessage.textColor = UIColor(hex:Theme.colorAlertTextNormal)
        lblMessage.font = UIFont(name: Theme.font.normal, size: Theme.fontSize.normal)
        
        vwcontrol.layer.cornerRadius = 10;
        vwcontrol.clipsToBounds      = true;
        
        configTextfield(txtName)
        configTextfield(txtTotal)
        configTextfield(txtPrice)
        configTextfield(txtSugguestPrice)
        configTextfield(txtPV)
        
        _ = collectLabelAddProruct.map({
            $0.font = UIFont(name: Theme.font.normal, size: Theme.fontSize.small)!
            $0.textColor = UIColor(hex: Theme.color.customer.subGroup)
        })
        
        lblError.textColor = UIColor.red
        lblError.font = UIFont(name: Theme.font.normal, size: Theme.fontSize.small)
        
    }
    
    func configText() {
        if self.isEdit {
            lblMessage.text = "edit_product".localized().uppercased()
            btnFirst.setTitle("update".localized().uppercased(), for: .normal)
        } else {
            lblMessage.text = "add_product".localized().uppercased()
            btnFirst.setTitle("add".localized().uppercased(), for: .normal)
        }
        
        btnSecond.setTitle("cancel".localized().uppercased(), for: .normal)
        
        txtName.placeholder = "placeholder_product_name".localized()
        txtSugguestPrice.placeholder = "recommend_price".localized()
        txtPV.placeholder = "pv".localized()
        txtPrice.placeholder = "placeholder_price".localized()
        txtTotal.placeholder = "placeholder_quantity".localized()
        
        _ = collectLabelAddProruct.map({
            $0.text = $0.accessibilityIdentifier?.localized()
        })
        
    }
    
    private func configTextfield(_ textfield:UITextField) {
        textfield.textColor = UIColor(hex: Theme.color.customer.subGroup)
        textfield.font = UIFont(name: Theme.font.bold, size: Theme.fontSize.normal)
    }
    
}
