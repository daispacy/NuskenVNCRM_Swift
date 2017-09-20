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
    func AuthenticViewDidProcessEvent(view:AuthenticView)
}

class AuthenticView: UIView {
    
    @IBOutlet fileprivate var scrollVIew: UIScrollView!
    @IBOutlet fileprivate var stckView: UIStackView!
    @IBOutlet fileprivate var txtVNID: UITextField!
    @IBOutlet fileprivate var txtEmail: UITextField!
    @IBOutlet fileprivate var txtPassword: UITextField!
    @IBOutlet fileprivate var btnRemember: UIButton!
    @IBOutlet fileprivate var btnProcess: UIButton!
    
    // MARK: - Properties
    weak var delegate_: AuthenticViewDelegate?
    var type_: AuthenticType!
    var email:String?
    var password:String?
    var vnid:String?
    var isRememberID:Bool?
    
    // MARK: - INIT
    func configView(delegate:AuthenticViewDelegate? = nil, type:AuthenticType = .AUTH_LOGIN) {

        delegate_ = delegate
        type_ = type
        
        configView()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    // MARK: - BUTTON EVENT
    @IBAction private func processAction(_ sender: UIButton) {
        if(sender.isEqual(btnProcess) == true) {
            delegate_?.AuthenticViewDidProcessEvent(view: self)
        } else {
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
        
        setupControl()
        configText()
        
        switch type_ {
        case .AUTH_LOGIN:
            loadViewLogin()
            break
        case .AUTH_RESETPW:
            loadViewReset()
            break
        default:
            loadViewReset()
            break
        }
    }
    
    private func loadViewLogin() {
        txtVNID.isHidden = true
    }
    
    private func loadViewReset() {
        txtPassword.isHidden = true
        btnRemember.isHidden = true
    }
    
    private func setupControl() {
        btnRemember.setImage(UIImage(named:"checkbox_check"), for: .selected)
        btnRemember.setImage(UIImage(named:"checkbox_uncheck"), for: .normal)
    }
}
