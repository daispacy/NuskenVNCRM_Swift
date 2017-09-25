//
//  AuthenticView.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 9/20/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import UIKit

enum AuthenticType: Int {
    case AUTH_LOGIN = 1
    case AUTH_RESETPW
}

protocol AuthenticViewDelegate: class {
    func AuthenticViewDidProcessEvent(view:AuthenticView, isGotoReset:Bool)
}

class AuthenticView: UIView, UITextFieldDelegate {
    
    @IBOutlet fileprivate var scrollVIew: UIScrollView!
    @IBOutlet fileprivate var stckView: UIStackView!
    @IBOutlet fileprivate var txtVNID: UITextField!
    @IBOutlet fileprivate var txtEmail: UITextField!
    @IBOutlet fileprivate var txtPassword: UITextField!
    @IBOutlet fileprivate var btnRemember: UIButton!
    @IBOutlet fileprivate var btnProcess: UIButton!
    @IBOutlet fileprivate var btnGoToResetPassword: UIButton!
    @IBOutlet var lblMEssage: CMessageLabel!
    
    // MARK: - Properties
    weak var delegate_: AuthenticViewDelegate?
    var type_: AuthenticType!
    var email:String?
    var password:String?
    var vnid:String?
    var isRememberID:Bool?
    var activeField:UITextField?
    var tapGesture:UITapGestureRecognizer?
    
    // MARK: - INIT
    func configView(delegate:AuthenticViewDelegate? = nil, type:AuthenticType = .AUTH_LOGIN) {

        delegate_ = delegate
        type_ = type
        
        txtPassword.delegate = self
        txtEmail.delegate = self
        txtVNID.delegate = self
        
        configView()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.hideKeyboard(_:)))
        self.addGestureRecognizer(tapGesture!)
        
        configColor()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        self.removeGestureRecognizer(tapGesture!)
    }
    
    func hideKeyboard(_ sender: UITapGestureRecognizer) {
        resignTextField()
    }
    
    func keyboardWillShow(notification: NSNotification) {
        //Need to calculate keyboard exact size due to Apple suggestions
//        self.scrollVIew.isScrollEnabled = true
        var info = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize!.height, 0.0)
        
        self.scrollVIew.contentInset = contentInsets
        self.scrollVIew.scrollIndicatorInsets = contentInsets
        
        var aRect : CGRect = self.frame
        aRect.size.height -= keyboardSize!.height
        if let activeField = self.activeField {
            if (!aRect.contains(activeField.frame.origin)){
                self.scrollVIew.scrollRectToVisible(activeField.frame, animated: true)
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        //Once keyboard disappears, restore original positions
        var info = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, -keyboardSize!.height, 0.0)
        self.scrollVIew.contentInset = contentInsets
        self.scrollVIew.scrollIndicatorInsets = contentInsets
        resignTextField()
//        self.scrollVIew.isScrollEnabled = false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField){
        activeField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField){
        activeField = nil
        if(textField.isEqual(txtEmail) == true) {
            if(Support.isValidEmailAddress(emailAddressString: textField.text!)) {
                email = textField.text
                lblMEssage.isHidden = true
            } else {
                lblMEssage .setMessage(msg: "msg_err_email".localized(), icon: "checkbox_check")
                lblMEssage.isHidden = false
            }
        } else if(textField.isEqual(txtPassword) == true){
            if(Support.isValidPassword(password:textField.text!)){
                password = textField.text
                lblMEssage.isHidden = true
            } else {
                lblMEssage .setMessage(msg: "msg_err_pw".localized(), icon: "checkbox_check")
                lblMEssage.isHidden = false
            }
        } else if(textField.isEqual(txtVNID) == true){
            if(Support.isValidVNID(vnid: textField.text!)) {
                vnid = textField.text
                lblMEssage.isHidden = true
            } else {
                lblMEssage .setMessage(msg: "msg_err_vnid".localized(), icon: "checkbox_check")
                lblMEssage.isHidden = false
            }
        }
    }
    
    func resignTextField() {
        self.endEditing(true)
    }
    
    // MARK: - BUTTON EVENT
    @IBAction private func processAction(_ sender: UIButton) {
        
        resignTextField()
        
        if(sender.isEqual(btnProcess) == true) {
            delegate_?.AuthenticViewDidProcessEvent(view: self,isGotoReset:false)
        } else if (sender.isEqual(btnGoToResetPassword) == true){
            delegate_?.AuthenticViewDidProcessEvent(view: self,isGotoReset:true)
        }else {
            btnRemember.isSelected = !btnRemember.isSelected
        }
    }
}

// MARK: INTERFACE
extension AuthenticView {
    func configText() {
        txtVNID.placeholder = "placeholder_vnid".localized()
        txtEmail.placeholder = "placeholder_email".localized()
        txtPassword.placeholder = "placeholder_password".localized()
        btnRemember.setTitle("remember_me".localized(), for: .normal)
        btnGoToResetPassword.setTitle("reset_pw".localized(), for: .normal)
        switch type_ {
        case .AUTH_LOGIN:
            btnProcess.setTitle("login".localized(), for: .normal)
            break
        default:
            btnProcess.setTitle("reset_pw".localized(), for: .normal)
            break
        }
    }
}

// MARK: CONFIG
extension AuthenticView {
    
    fileprivate func configView() {
        
        txtPassword.alpha = 0
        btnRemember.alpha = 0
        btnGoToResetPassword.alpha = 0
        txtVNID.alpha = 0
        
        setupControl()
        configText()
        
        switch type_ {
        case .AUTH_LOGIN:
            loadViewLogin()
            break
        case .AUTH_RESETPW:
            loadViewReset()
            break
        case .none:
            return
        case .some(_):
            return
        }
        
        Timer.scheduledTimer(withTimeInterval: 0.4, repeats: false, block: { t in
            self.txtPassword.alpha = 1
            self.btnRemember.alpha = 1
            self.btnGoToResetPassword.alpha = 1
            self.txtVNID.alpha = 1
            t.invalidate()
        })
    }
    
    private func loadViewLogin() {
        txtPassword.isHidden = false
        btnRemember.isHidden = false
        btnGoToResetPassword.isHidden = false
        txtVNID.isHidden = true
        
        self.txtPassword.alpha = 1
        self.btnRemember.alpha = 1
        self.btnGoToResetPassword.alpha = 1
        self.txtVNID.alpha = 0
    }
    
    private func loadViewReset() {
        txtPassword.isHidden = true
        btnRemember.isHidden = true
        btnGoToResetPassword.isHidden = true
        txtVNID.isHidden = false
        
        self.txtPassword.alpha = 0
        self.btnRemember.alpha = 0
        self.btnGoToResetPassword.alpha = 0
        self.txtVNID.alpha = 1
    }
    
    private func setupControl() {
        btnRemember.setImage(UIImage(named:"checkbox_check"), for: .selected)
        btnRemember.setImage(UIImage(named:"checkbox_uncheck"), for: .normal)
    }
    
    fileprivate func configColor() {
        
        self.backgroundColor = UIColor(hex:Theme.colorBottomBar)
        
        btnGoToResetPassword.setTitleColor(UIColor(hex:Theme.colorATTextColor), for: .normal)
        btnRemember.setTitleColor(UIColor(hex:Theme.colorATTextColor), for: .normal)
        
        btnProcess.backgroundColor = UIColor(hex:Theme.colorATButtonBackgroundColor)
        btnProcess.setTitleColor(UIColor(hex:Theme.colorATButtonTitleColor), for: .normal)
        
        txtVNID.layer.borderColor = UIColor(hex:Theme.colorATBorderColor).cgColor
        txtVNID.backgroundColor = UIColor.clear
        txtVNID.textColor = UIColor(hex:Theme.colorATTextColor)
        
        txtEmail.layer.borderColor = UIColor(hex:Theme.colorATBorderColor).cgColor
        txtEmail.backgroundColor = UIColor.clear
        txtEmail.textColor = UIColor(hex:Theme.colorATTextColor)
        
        txtPassword.layer.borderColor = UIColor(hex:Theme.colorATBorderColor).cgColor
        txtPassword.backgroundColor = UIColor.clear
        txtPassword.textColor = UIColor(hex:Theme.colorATTextColor)
        
        lblMEssage.textColor = UIColor(hex:Theme.colorATTextColor)
    }
}