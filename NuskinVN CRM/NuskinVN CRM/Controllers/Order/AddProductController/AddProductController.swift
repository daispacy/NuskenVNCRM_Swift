//
//  CustomAlertController.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 9/22/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import UIKit

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
    @IBOutlet var collectLabelAddProruct: [UILabel]!
    
    var onChangeProduct:((Product,Bool)->Void)?
    var onValidateProduct:((String,Bool)->Bool)!
    var tapGesture:UITapGestureRecognizer!
    var product:Product?
    
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
        super.viewDidLoad()
        configView()
        configText()
        
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
    func edit(product:Product) {
        self.product = product
        self.product?.tempName = product.name
        txtName.text = product.name
        txtPrice.text = "\(product.quantity)"
        txtTotal.text = "\(product.price)"
        configText()
        configView()
    }
    
    // MARK: - BUTTON EVENT
    @IBAction private func buttonPress(_ sender: UIButton) {
        
        if(sender.isEqual(btnFirst) == true) {
            if var pro = self.product{
                if !validateData() {
                    lblError.text = "please_provide_full_information".localized()
                    lblError.isHidden = false
                } else {
                    if pro.isValid(exceptMe: true) && self.onValidateProduct(txtName.text!,true){
                         lblError.isHidden = true
                        pro.name = txtName.text!
                        if let price = txtPrice.text {
                            pro.price = Int64(price)!
                        }
                        if let quantity = txtTotal.text {
                            pro.quantity = Int64(quantity)!
                        }
                        onChangeProduct?(pro,true)
                        self.dismiss(animated: false, completion: nil)
                    } else{
                        lblError.isHidden = false
                        lblError.text = "product_is_exist".localized()
                    }
                }
            } else {
                if validateData() == false {
                    lblError.text = "please_provide_full_information".localized()
                    lblError.isHidden = false
                } else {
                    var product = Product()
                    product.name = txtName.text!
                    if let price = txtPrice.text {
                        product.price = Int64(price)!
                    }
                    if let quantity = txtTotal.text {
                        product.quantity = Int64(quantity)!
                    }
                    if product.isValid() && self.onValidateProduct(txtName.text!,false){
                        lblError.isHidden = true
                        onChangeProduct?(product,false)
                        self.dismiss(animated: false, completion: nil)
                        
                    } else{
                        lblError.isHidden = false
                        lblError.text = "product_is_exist".localized()
                    }
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
        
        _ = collectLabelAddProruct.map({
            $0.font = UIFont(name: Theme.font.normal, size: Theme.fontSize.small)!
            $0.textColor = UIColor(hex: Theme.color.customer.subGroup)
        })
        
        lblError.textColor = UIColor.red
        lblError.font = UIFont(name: Theme.font.normal, size: Theme.fontSize.small)
        
    }
    
    func configText() {
        if self.product != nil {
            lblMessage.text = "edit_product".localized().uppercased()
            btnFirst.setTitle("update".localized().uppercased(), for: .normal)
        } else {
            lblMessage.text = "add_product".localized().uppercased()
            btnFirst.setTitle("add".localized().uppercased(), for: .normal)
        }
        
        btnSecond.setTitle("cancel".localized().uppercased(), for: .normal)
        
        txtName.placeholder = "placeholder_product_name".localized()
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
