//
//  EmailController.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 11/5/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class EmailController: UIViewController {

    @IBOutlet var collectLabelAddProruct: [UILabel]!
    @IBOutlet var txtFrom: UITextField!
    @IBOutlet var txtTo: UITextField!
    @IBOutlet var txtSubject: UITextField!
    @IBOutlet var txtFromName: UITextField!
    @IBOutlet var lblMessage: UILabel!
    @IBOutlet var txtBody: UITextView!
    @IBOutlet var btnFirst: CButtonAlert!
    @IBOutlet var btnSecond: CButtonAlert!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var vwcontrol: UIView!
    
    let disposeBag = DisposeBag()
    
    var onDismissComplete:(()->Void)?
    var tapGesture:UITapGestureRecognizer!
    
    
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

        tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        configView()
        configText()
        bindControl()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.onDismissComplete?()
    }
    
    // MARK: - interface
    func show(from:String, to:String) {
        txtFrom.text = from
        txtTo.text = to
        guard let user = UserManager.currentUser() else { return }
        if let name = user.fullname {
            txtFromName.text = name
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
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
    }
    
    
    deinit {
        self.view.removeGestureRecognizer(tapGesture)
        NotificationCenter.default.removeObserver(self)
        print("\(String(describing: EmailController.self)) dealloc")
    }
    
    // MARK: - BIND CONTROL
    func bindControl() {
        btnSecond.rx.tap
            .subscribe(onNext:{ [weak self] in
                if let _self = self {
                    _self.dismiss(animated: true, completion: nil)
                }
            }).addDisposableTo(disposeBag)
        
        btnFirst.rx.tap
            .subscribe(onNext:{ [weak self] in
                guard let user = UserManager.currentUser() else {return}
                guard let _self = self else {return}
                if !_self.validateData() {
                    Support.popup.showAlert(message: "subject_or_body_invalid".localized(), buttons: ["ok".localized()], vc: _self, onAction: {index in
                        
                    },nil)
                    return
                }
                _self.btnFirst.startAnimation(activityIndicatorStyle: .white)
                _self.btnSecond.isHidden = true
                // send
                SyncService.shared.sendEmail(fullname: _self.txtFromName.text!, from: _self.txtFrom.text!, to: _self.txtTo.text!, subject: _self.txtSubject.text!, body: _self.txtBody.text!, completion: { (msg) in
                    _self.btnFirst.stopAnimation()
                    if msg.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).characters.count > 0 {
                        Support.popup.showAlert(message: "send_email_failed".localized(), buttons: ["ok".localized()], vc: _self, onAction: {index in                            
                            _self.btnSecond.isHidden = false
                        },nil)
                    } else {
                        Support.popup.showAlert(message: "send_email_success".localized(), buttons: ["ok".localized()], vc: _self, onAction: {index in
                            _self.onDismissComplete?()
                            _self.btnSecond.isHidden = false
                            _self.dismiss(animated: true, completion: nil)
                        },nil)
                    }
                })
                
            }).addDisposableTo(disposeBag)
    }
    
    // MARK: - private
    func validateData() ->Bool {
        guard let email = txtTo.text else { return false }
        if txtSubject.text?.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines).characters.count == 0 ||
            txtFromName.text?.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines).characters.count == 0 ||
            txtBody.text?.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines).characters.count == 0 ||
            !Support.validate.isValidEmailAddress(emailAddressString: email){
            return false
        } else {
            return true
        }
    }
    
    func configView() {
        btnFirst.backgroundColor = UIColor(_gradient: Theme.colorGradient, frame: btnFirst.frame, isReverse:true)
        btnFirst.setTitleColor(UIColor(hex:Theme.colorAlertButtonTitleColor), for: .normal)
        btnFirst.titleLabel?.font = UIFont(name: Theme.font.bold, size: Theme.fontSize.normal)
        
        btnSecond.backgroundColor = UIColor(_gradient: Theme.colorGradient, frame: btnSecond.frame, isReverse:true)
        btnSecond.setTitleColor(UIColor(hex:Theme.colorAlertButtonTitleColor), for: .normal)
        btnSecond.titleLabel?.font = UIFont(name: Theme.font.bold, size: Theme.fontSize.normal)
        
        lblMessage.textColor = UIColor(hex:Theme.colorAlertTextNormal)
        lblMessage.font = UIFont(name: Theme.font.bold, size: Theme.fontSize.medium)
        
        vwcontrol.layer.cornerRadius = 10;
        vwcontrol.clipsToBounds      = true;
        
        configTextfield(txtFrom)
        configTextfield(txtTo)
        configTextfield(txtSubject)
        configTextfield(txtFromName)
        
        txtBody.layer.cornerRadius = 5
        txtBody.clipsToBounds = true
        
        _ = collectLabelAddProruct.map({
            $0.font = UIFont(name: Theme.font.normal, size: Theme.fontSize.small)!
            $0.textColor = UIColor(hex: Theme.color.customer.subGroup)
        })
        
        txtBody.textColor = UIColor(hex: Theme.color.customer.titleGroup)
        txtBody.font = UIFont(name: Theme.font.normal, size: Theme.fontSize.normal)
    }
    
    func configText() {
        lblMessage.text = "compose_email".localized().uppercased()
        txtFromName.placeholder = "from_name".localized()
        btnFirst.setTitle("send".localized().uppercased(), for: .normal)
        btnSecond.setTitle("cancel".localized().uppercased(), for: .normal)
        
        txtSubject.placeholder = "subject".localized()
        
        _ = collectLabelAddProruct.map({
            $0.text = $0.accessibilityIdentifier?.localized()
        })
        
    }
    
    private func configTextfield(_ textfield:UITextField) {
        textfield.textColor = UIColor(hex: Theme.color.customer.subGroup)
        textfield.font = UIFont(name: Theme.font.bold, size: Theme.fontSize.normal)
    }
}
