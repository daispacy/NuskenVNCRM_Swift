//
//  AuthenticView.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 9/20/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import UIKit
import FontAwesomeKit

enum AuthenticType: Int {
    case AUTH_LOGIN = 1
    case AUTH_RESETPW
}

protocol AuthenticViewDelegate: class {
    func AuthenticViewDidProcessEvent(view:AuthenticView, isGotoReset:Bool)
}

class AuthenticView: CViewSwitchLanguage, UITextFieldDelegate {
    
    @IBOutlet fileprivate var scrollVIew: UIScrollView!
    @IBOutlet fileprivate var stckView: UIStackView!
    @IBOutlet var stackVNID: UIStackView!
    @IBOutlet var stackEmail: UIStackView!
    @IBOutlet var stackPassword: UIStackView!
    @IBOutlet var iconVNID: CImageView!
    @IBOutlet var iconEmail: CImageView!
    @IBOutlet var iconPassword: CImageView!
    @IBOutlet fileprivate var txtVNID: CInput!
    @IBOutlet fileprivate var txtEmail: CInput!
    @IBOutlet fileprivate var txtPassword: CInput!
    @IBOutlet fileprivate var btnRemember: CButtonWithImage!
    @IBOutlet fileprivate var btnProcess: CButton!
    @IBOutlet fileprivate var btnGoToResetPassword: UIButton!
    @IBOutlet var lblMEssage: CMessageLabel!
    
    @IBOutlet var topContraintLogo: NSLayoutConstraint!
    
    
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
        configColor()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.hideKeyboard(_:)))
        self.addGestureRecognizer(tapGesture!)
    }
    
    deinit {
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
            if(Support.validate.isValidEmailAddress(emailAddressString: textField.text!)) {
                email = textField.text
                lblMEssage.isHidden = true
            } else {
                lblMEssage .setMessage(msg: "msg_err_email".localized(), icon: "\u{f071}")
                lblMEssage.isHidden = false
            }
        } else if(textField.isEqual(txtPassword) == true){
            if(Support.validate.isValidPassword(password:textField.text!)){
                password = textField.text
                lblMEssage.isHidden = true
            } else {
                lblMEssage .setMessage(msg: "msg_err_pw".localized(), icon: "\u{f071}")
                lblMEssage.isHidden = false
            }
        } else if(textField.isEqual(txtVNID) == true){
            if(Support.validate.isValidVNID(vnid: textField.text!)) {
                vnid = textField.text
                lblMEssage.isHidden = true
            } else {
                lblMEssage .setMessage(msg: "msg_err_vnid".localized(), icon: "\u{f071}")
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
    
    // from protocol
    override func reloadTexts() {
        configText()
    }
}

// MARK: INTERFACE
extension AuthenticView {
    func configText() {
        txtVNID.placeholder = "placeholder_vnid".localized()
        txtEmail.placeholder = "placeholder_email".localized()
        txtPassword.placeholder = "placeholder_password".localized()
        btnRemember.setTitle("remember_me".localized(), for: .normal)
        btnGoToResetPassword.setTitle("reset_pw".localized().uppercased(), for: .normal)
        btnProcess.titleLabel?.font = UIFont(name: Theme.font.normal, size: Theme.fontSize.normal)
        switch type_ {
        case .AUTH_LOGIN:
            btnProcess.setTitle("login".localized().uppercased(), for: .normal)
            break
        default:
            btnProcess.setTitle("reset_pw".localized().uppercased(), for: .normal)
            break
        }
        self.setNeedsLayout()
        self.layoutIfNeeded()
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
        stackPassword.isHidden = false
        btnRemember.isHidden = false
        btnGoToResetPassword.isHidden = false
        stackVNID.isHidden = true
        
        self.txtPassword.alpha = 1
        self.btnRemember.alpha = 1
        self.btnGoToResetPassword.alpha = 1
        self.txtVNID.alpha = 0
    }
    
    private func loadViewReset() {
        stackPassword.isHidden = true
        btnRemember.isHidden = true
        btnGoToResetPassword.isHidden = true
        stackVNID.isHidden = false
        
        self.txtPassword.alpha = 0
        self.btnRemember.alpha = 0
        self.btnGoToResetPassword.alpha = 0
        txtVNID.alpha = 1
    }
    
    private func setupControl() {
        if let imageCheck = Support.image.iconFont(code: "\u{f14a}", size: 22) {
            btnRemember.setImage(imageCheck, for: .selected)            
        }
        if let imageUnCheck = Support.image.iconFont(code: "\u{f0c8}", size: 22) {
            btnRemember.setImage(imageUnCheck, for: .normal)
        }
    }
    
    fileprivate func configColor() {
        
        self.backgroundColor = UIColor(hex:Theme.colorBottomBar)
        
        btnGoToResetPassword.setTitleColor(UIColor(hex:Theme.colorATTextColor), for: .normal)
        btnGoToResetPassword.titleLabel?.font = UIFont(name: Theme.font.normal, size: Theme.fontSize.normal)
        
        btnRemember.setTitleColor(UIColor(hex:Theme.colorATTextColor), for: .normal)
        btnRemember.titleLabel?.font = UIFont(name: Theme.font.normal, size: Theme.fontSize.small)
        
        btnProcess.backgroundColor = UIColor(hex:Theme.colorATButtonBackgroundColor)
        if let titleLabel = btnProcess.titleLabel {
            btnProcess.setTitleColor(UIColor(_gradient:Theme.colorGradient,
                                             frame:titleLabel.frame), for: .normal)
        }
        
        txtVNID.layer.borderColor = UIColor(hex:Theme.colorATBorderColor).cgColor
        txtVNID.backgroundColor = UIColor.clear
        txtVNID.textColor = UIColor(hex:Theme.colorATTextColor)
        txtVNID.font = UIFont(name: Theme.font.normal, size: Theme.fontSize.normal)
        
        txtEmail.layer.borderColor = UIColor(hex:Theme.colorATBorderColor).cgColor
        txtEmail.backgroundColor = UIColor.clear
        txtEmail.textColor = UIColor(hex:Theme.colorATTextColor)
        txtEmail.font = UIFont(name: Theme.font.normal, size: Theme.fontSize.normal)
        
        txtPassword.layer.borderColor = UIColor(hex:Theme.colorATBorderColor).cgColor
        txtPassword.backgroundColor = UIColor.clear
        txtPassword.textColor = UIColor(hex:Theme.colorATTextColor)
        txtPassword.font = UIFont(name: Theme.font.normal, size: Theme.fontSize.normal)
        
        lblMEssage.textColor = UIColor(hex:Theme.colorATTextColor)
        lblMEssage.font = UIFont(name: Theme.font.normal, size: Theme.fontSize.small)
    }
}
