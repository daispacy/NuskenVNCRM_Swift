//
//  CustomerDetailController.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 10/6/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import CoreData

class ChangePasswordController: RootViewController {
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var collectBrand: [UILabel]!
    
    @IBOutlet var txtNewPW: UITextField!
    @IBOutlet var txtReTypePW: UITextField!
    @IBOutlet var btnProcess: CButtonAlert!
    @IBOutlet var btnCancel: CButtonAlert!
    @IBOutlet var txtCurrentPW: UITextField!
    @IBOutlet var lblErrorNewPW: UILabel!
    @IBOutlet var lblErrorRetypePW: UILabel!
    @IBOutlet var lblTitle: UILabel!
    
    var activeField:UITextField?
    var tapGesture:UITapGestureRecognizer?
    var customer:Customer?
    var onDismissComplete:(()->Void)?
    var deinitial:(()->Void)?
    var onDidRotate:(()->Void)?

    var avatar:String?
    
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.hideKeyboard))
        self.view.addGestureRecognizer(tapGesture!)
        
        configText()
        configView()
        bindControl()
        
        LocalService.shared.isShouldSyncData = {[weak self] in
            if let _ = self {
                return false
            }
            return true
        }
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        self.onDidRotate?()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        LocalService.shared.isShouldSyncData = nil
    }
    
    deinit {
        self.view.removeGestureRecognizer(tapGesture!)
        self.deinitial?()
    }
    
    // MARK: - custom
    func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        //Need to calculate keyboard exact size due to Apple suggestions        
        var info = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize!.height, 0.0)
        
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        
        var aRect : CGRect = self.view.frame
        aRect.size.height -= keyboardSize!.height
        if let activeField = self.activeField {
            if (!aRect.contains(activeField.frame.origin)){
                self.scrollView.scrollRectToVisible(activeField.frame, animated: true)
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        //Once keyboard disappears, restore original positions
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        hideKeyboard()
    }
    
    // MARK: - private
    private func bindControl() {
        // event process
        btnProcess.rx.tap
            .subscribe(onNext:{ [weak self] in
                if let _self = self {
                    
                    if !_self.validdateData() {
                        Support.popup.showAlert(message: "invalid_password".localized(), buttons: ["ok".localized()], vc: _self, onAction: {index in
                            
                        }, { [weak self] index in
                            guard let _self = self else {return}
                            _self.preventSyncData()
                        })
                        return
                    }
                    
                    if _self.passwordSameNew() {
                        Support.popup.showAlert(message: "new_password_not_same_current_password".localized(), buttons: ["ok".localized()], vc: _self, onAction: {index in
                            
                        }, { [weak self] index in
                            guard let _self = self else {return}
                            _self.preventSyncData()
                        })
                        return
                    }
                    
                    if !_self.checkPasswordSame() {
                        Support.popup.showAlert(message: "password_note_same".localized(), buttons: ["ok".localized()], vc: _self, onAction: {index in
                            
                        }, { [weak self] index in
                            guard let _self = self else {return}
                            _self.preventSyncData()
                        })
                        return
                    }
                    
                    guard let _ = UserManager.currentUser() else {
                        Support.popup.showAlert(message: "please_login_before_use_this_function".localized(), buttons: ["ok".localized()], vc: _self, onAction: {index in
                            
                        }, { [weak self] index in
                            guard let _self = self else {return}
                            _self.preventSyncData()
                        })
                        return
                    }
                    _self.btnProcess.startAnimation(activityIndicatorStyle: .white)
                    _self.btnCancel.isHidden = true
                    SyncService.shared.changePW(current: _self.txtCurrentPW.text!, newPW: _self.txtNewPW.text!, retypePW: _self.txtReTypePW.text!, onDone: {
                        _self.btnProcess.stopAnimation()
                        _self.btnCancel.isHidden = false
                        Support.popup.showAlert(message: "change_password_success".localized(), buttons: ["ok".localized()], vc: _self, onAction: {[weak self] index in
                            guard let _self = self else {return}
                            _self.dismiss(animated: true, completion: nil)
                            _self.onDismissComplete?()
                            }, {
                                LocalService.shared.isShouldSyncData = {[weak self] in
                                    if let _ = self {
                                        return false
                                    }
                                    return true
                                }
                        })
                    }, onFail: { message in
                        _self.btnProcess.stopAnimation()
                        _self.btnCancel.isHidden = false
                        var msg = "change_password_failed".localized()
                        if let mess = message as? String {
                            if mess.characters.count > 0 {
                                msg = mess
                            }
                        }
                        Support.popup.showAlert(message: msg, buttons: ["ok".localized()], vc: _self, onAction: {[weak self] index in
                            
                            }, {
                                LocalService.shared.isShouldSyncData = {[weak self] in
                                    if let _ = self {
                                        return false
                                    }
                                    return true
                                }
                        })
                    })
                    
                }
                
            })
            .addDisposableTo(disposeBag)
        
        btnCancel.rx.tap
            .subscribe(onNext:{ [weak self] in
                if let _self = self {
                    _self.dismiss(animated: true, completion:nil)
                    _self.onDismissComplete?()
                }
                
            })
            .addDisposableTo(disposeBag)
    }
    
    func validdateData() -> Bool {
        guard let cpw = self.txtCurrentPW.text, let npw = self.txtNewPW.text, let rpw = self.txtReTypePW.text  else { return false }
        let checkCPW = Support.validate.isValidPassword(password: cpw)
        let checkNPW = Support.validate.isValidPassword(password: npw)
        let checkRPW = Support.validate.isValidPassword(password: rpw)
        lblErrorNewPW.isHidden = checkNPW
        lblErrorRetypePW.isHidden = checkRPW
        
        return  checkRPW && checkCPW && checkNPW
    }
    
    func passwordSameNew() -> Bool {
        guard let cpw = self.txtCurrentPW.text, let npw = self.txtNewPW.text else { return false }
        return  cpw.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).lowercased() == npw.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).lowercased()
    }
    
    func checkPasswordSame() -> Bool {
        guard let npw = self.txtNewPW.text, let rpw = self.txtReTypePW.text  else { return false }
        lblErrorRetypePW.isHidden = npw == rpw
        return npw == rpw
    }

    private func configView() {
        
        configTextfield(txtNewPW)
        configTextfield(txtReTypePW)
        configTextfield(txtCurrentPW)
        
        btnProcess.backgroundColor = UIColor(_gradient: Theme.colorGradient, frame: btnProcess.frame, isReverse:true)
        btnProcess.setTitleColor(UIColor(hex:Theme.colorAlertButtonTitleColor), for: .normal)
        btnProcess.titleLabel?.font = UIFont(name: Theme.font.bold, size: Theme.fontSize.normal)
        
        btnCancel.backgroundColor = UIColor(_gradient: Theme.colorGradient, frame: btnCancel.frame, isReverse:true)
        btnCancel.setTitleColor(UIColor(hex:Theme.colorAlertButtonTitleColor), for: .normal)
        btnCancel.titleLabel?.font = UIFont(name: Theme.font.bold, size: Theme.fontSize.normal)
        
        lblErrorRetypePW.font = UIFont(name: Theme.font.normal, size: Theme.fontSize.small)!
        lblErrorNewPW.font = lblErrorRetypePW.font
        lblErrorRetypePW.textColor = UIColor.red
        lblErrorNewPW.textColor = lblErrorRetypePW.textColor
        
        lblTitle.textColor = UIColor(hex:Theme.colorNavigationBar)
        lblTitle.font = UIFont(name: Theme.font.bold, size: Theme.fontSize.medium)
        
        _ = collectBrand.map({
            $0.font = UIFont(name: Theme.font.normal, size: Theme.fontSize.small)!
            $0.textColor = UIColor(hex: Theme.color.customer.subGroup)
        })
    }
    
    override func configText() {
        
        txtNewPW.placeholder = "new_password".localized()
        txtCurrentPW.placeholder = "current_password".localized()
        txtReTypePW.placeholder = "retype_password".localized()
        
        lblErrorNewPW.text = "invalid_password".localized()
        lblErrorRetypePW.text = "invalid_retype_password".localized()

        btnProcess.setTitle("update".localized().uppercased(), for: .normal)
        lblTitle.text = "change_pw".localized().uppercased()
        
        btnCancel.setTitle("cancel".localized().uppercased(), for: .normal)
        
        _ = collectBrand.map({
            $0.text = $0.accessibilityIdentifier?.localized()
        })
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
