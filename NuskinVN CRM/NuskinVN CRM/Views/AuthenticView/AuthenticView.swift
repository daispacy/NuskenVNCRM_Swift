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
    func AuthenticViewDidBackLogin(view:AuthenticView)
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
    @IBOutlet var btnProcess: CButton!
    @IBOutlet fileprivate var btnGoToResetPassword: UIButton!
    @IBOutlet weak var btnGotoForgetPassword: UIButton!
    @IBOutlet var lblMEssage: CMessageLabel!
    @IBOutlet weak var btnSupport: UIButton!
    
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
        
        txtPassword.isSecureTextEntry = true
        
        txtEmail.text = ""
        txtPassword.text = ""        
        
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
    }
    
    func resignTextField() {
        self.endEditing(true)
    }
    
    // MARK: - BUTTON EVENT
    @IBAction private func processAction(_ sender: UIButton) {
        
        resignTextField()
        
        if(sender.isEqual(btnProcess) == true) {

            var stringMessage:String = ""
            
            if(Support.validate.isValidVNID(vnid: txtVNID.text!)) {
                vnid = txtVNID.text
            } else {
                if stringMessage.characters.count > 0 {
                    stringMessage.append("\n\("msg_err_vnid".localized())")
                } else {
                    stringMessage.append("msg_err_vnid".localized())
                }
            }
            
            if type_ == .AUTH_LOGIN {
                if(Support.validate.isValidPassword(password:txtPassword.text!)){
                    password = txtPassword.text
                } else {
                    if stringMessage.characters.count > 0 {
                        stringMessage.append("\n\("msg_err_pw".localized())")
                    } else {
                        stringMessage.append("msg_err_pw".localized())
                    }
                }
            } else {
                if(Support.validate.isValidEmailAddress(emailAddressString: txtEmail.text!)) {
                    email = txtEmail.text
                } else {
                    stringMessage.append("msg_err_email".localized())
                }
            }
            
            lblMEssage.setMessage(msg: stringMessage, icon: "\u{f071}")
            lblMEssage.isHidden = stringMessage.characters.count == 0
            
            if lblMEssage.isHidden == true {
                delegate_?.AuthenticViewDidProcessEvent(view: self,isGotoReset:false)
            }
        } else if (sender.isEqual(btnGoToResetPassword) == true){
            if type_ == .AUTH_RESETPW {
                delegate_?.AuthenticViewDidBackLogin(view: self)
            } else {
                delegate_?.AuthenticViewDidProcessEvent(view: self,isGotoReset:true)
            }
        } else if sender.isEqual(btnRemember){
            btnRemember.isSelected = !btnRemember.isSelected
            AppConfig.setting.setRememerID(isRemember: btnRemember.isSelected)
        } else if (sender.isEqual(btnGotoForgetPassword) == true){
            delegate_?.AuthenticViewDidProcessEvent(view: self,isGotoReset:true)
        }
    }
    
    @IBAction func processSupport(_ sender: Any) {
        let vc1 = EmailController(nibName: "EmailController", bundle: Bundle.main)
        Support.topVC!.present(vc1, animated: true, completion: {
            vc1.show(from: "", to: "48hrs_reply_vietnam@nuskin.com")
        })
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
            btnProcess.setTitle("send_pw".localized().uppercased(), for: .normal)
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
        btnGotoForgetPassword.alpha = 0
        stackEmail.alpha = 0
        
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
        stackVNID.isHidden = false
        stackEmail.isHidden = true
        
        self.txtPassword.alpha = 1
        self.btnRemember.alpha = 1
        self.btnGoToResetPassword.alpha = 1
        self.btnGotoForgetPassword.alpha = 1
        stackEmail.alpha = 0
        
        btnGoToResetPassword.setTitle("register".localized().uppercased(), for: .normal)
        btnGotoForgetPassword.setTitle("reset_pw".localized().uppercased(), for: .normal)
        btnSupport.setTitle("support".localized().uppercased(), for: .normal)
    }
    
    private func loadViewReset() {
        stackPassword.isHidden = true
        btnRemember.isHidden = true
        stackVNID.isHidden = false
        stackEmail.isHidden = false
        
        self.txtPassword.alpha = 0
        self.btnRemember.alpha = 0
        self.btnGoToResetPassword.alpha = 0
        self.btnGotoForgetPassword.alpha = 0
        stackEmail.alpha = 1
        
        btnGoToResetPassword.setTitle("login".localized().uppercased(), for: .normal)
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
        
        btnGotoForgetPassword.setTitleColor(UIColor(hex:Theme.colorATTextColor), for: .normal)
        btnGotoForgetPassword.titleLabel?.font = UIFont(name: Theme.font.normal, size: Theme.fontSize.normal)
        
        btnSupport.setTitleColor(UIColor(hex:Theme.colorATTextColor), for: .normal)
        btnSupport.titleLabel?.font = UIFont(name: Theme.font.normal, size: Theme.fontSize.small)
        
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
