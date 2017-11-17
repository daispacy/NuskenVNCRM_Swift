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

class UserProfileController: RootViewController, UINavigationControllerDelegate,UIImagePickerControllerDelegate {
    
    @IBOutlet var scrollView: UIScrollView!
    
    @IBOutlet var imvAvatar: CImageViewRoundGradient!
    @IBOutlet var btnChoosePhotos: UIButton!
    
    @IBOutlet var collectBrand: [UILabel]!
    
    @IBOutlet var txtName: UITextField!
    @IBOutlet var txtEmail: UITextField!
    @IBOutlet var txtAddress: UITextField!
    @IBOutlet var txtPhone: UITextField!
    @IBOutlet var btnProcess: CButtonAlert!
    @IBOutlet var btnCancel: CButtonAlert!
    @IBOutlet var txtVNID: UITextField!
    @IBOutlet var lblErrorEmail: UILabel!
    @IBOutlet var lblErrorName: UILabel!
    @IBOutlet var btnChangePassword: CButtonAlert!
    
    var activeField:UITextField?
    var tapGesture:UITapGestureRecognizer?
    var customer:CustomerDO?
    var onDismissComplete:(()->Void)?
    var onDidRotate:(()->Void)?

    var avatar:String?
    
    // MARK: - INIT
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
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
        btnChoosePhotos.rx.tap
            .subscribe(onNext:{ [weak self] in
                if let _self = self {
                    _self.showSelectGetPhotos()
                }
            })
            .addDisposableTo(disposeBag)
        
        btnProcess.rx.tap
            .subscribe(onNext:{ [weak self] in
                if let _self = self {
                    
                    if !_self.validdateData() {
                        Support.popup.showAlert(message: "email_invalid_or_name_invalid".localized(), buttons: ["ok".localized()], vc: _self, onAction: {index in
                            
                        }, { [weak self] index in
                            guard let _self = self else {return}
                            _self.preventSyncData()
                        })
                        return
                    }
                    
                    guard let user = UserManager.currentUser() else {
                        Support.popup.showAlert(message: "please_login_before_use_this_function".localized(), buttons: ["ok".localized()], vc: _self, onAction: {index in
                            
                        }, { [weak self] index in
                            guard let _self = self else {return}
                            _self.preventSyncData()
                        })
                        return
                    }
                    
                    user.fullname = _self.txtName.text
                    user.address = _self.txtAddress.text
                    user.tel = _self.txtPhone.text
                    user.email = _self.txtEmail.text
                    if let ava = _self.avatar {
                        user.avatar = ava
                    }
                    user.synced = false
                    UserManager.save()
                    Support.popup.showAlert(message: "update_profile_success".localized(), buttons: ["ok".localized()], vc: _self, onAction: {index in
                        
                    }, {
                        LocalService.shared.isShouldSyncData = {[weak self] in
                            if let _ = self {
                                return false
                            }
                            return true
                        }
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
        
        btnChangePassword.rx.tap
            .subscribe(onNext:{ [weak self] in
                if let _self = self {
                    let vc = ChangePasswordController(nibName: "ChangePasswordController", bundle: Bundle.main)
                    _self.present(vc, animated: true, completion: nil)
                    vc.deinitial = {
                        guard let _self = self else {return}
                        _self.preventSyncData()
                    }
                }
                
            })
            .addDisposableTo(disposeBag)
    }
    
    func validdateData() -> Bool {
        guard let email = self.txtEmail.text, let name = self.txtName.text else { return false }
        let checkEmail = Support.validate.isValidEmailAddress(emailAddressString: email)
        let checkName = name.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).characters.count > 0
        lblErrorEmail.isHidden = checkEmail
        lblErrorName.isHidden = checkName
        
        return  checkEmail && checkName
    }
    
    func showSelectGetPhotos() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        let cancelAction = UIAlertAction(title: "cancel".localized(), style: UIAlertActionStyle.cancel) { (result : UIAlertAction) -> Void in
            alertController.dismiss(animated: true, completion: nil)
        }
        let okAction = UIAlertAction(title: "take_a_photo".localized(), style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
            let imagePickerController = UIImagePickerController()
            
            imagePickerController.sourceType = .camera
            imagePickerController.modalPresentationStyle = .fullScreen
            imagePickerController.delegate = self
            self.present(imagePickerController, animated: true, completion: nil)
            
        }
        let actionPhotos = UIAlertAction(title: "photo_library".localized(), style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
            let imagePickerController = UIImagePickerController()
            
            imagePickerController.sourceType = .photoLibrary
            imagePickerController.modalPresentationStyle = .popover
            imagePickerController.delegate = self
            self.present(imagePickerController, animated: true, completion:nil)
            
        }
        alertController.addAction(cancelAction)
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alertController.addAction(okAction)
        }
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            alertController.addAction(actionPhotos)
        }
        Support.topVC?.present(alertController, animated: true, completion: nil)
    }
    
    private func configView() {
        
        configTextfield(txtName)
        configTextfield(txtEmail)
        configTextfield(txtPhone)
        configTextfield(txtAddress)
        configTextfield(txtVNID)
        
        btnProcess.backgroundColor = UIColor(_gradient: Theme.colorGradient, frame: btnProcess.frame, isReverse:true)
        btnProcess.setTitleColor(UIColor(hex:Theme.colorAlertButtonTitleColor), for: .normal)
        btnProcess.titleLabel?.font = UIFont(name: Theme.font.bold, size: Theme.fontSize.normal)
        
        btnCancel.backgroundColor = UIColor(_gradient: Theme.colorGradient, frame: btnCancel.frame, isReverse:true)
        btnCancel.setTitleColor(UIColor(hex:Theme.colorAlertButtonTitleColor), for: .normal)
        btnCancel.titleLabel?.font = UIFont(name: Theme.font.bold, size: Theme.fontSize.normal)
        
        btnChangePassword.backgroundColor = UIColor(_gradient: Theme.colorGradient, frame: btnCancel.frame, isReverse:true)
        btnChangePassword.setTitleColor(UIColor(hex:Theme.colorAlertButtonTitleColor), for: .normal)
        btnChangePassword.titleLabel?.font = UIFont(name: Theme.font.bold, size: Theme.fontSize.normal)
        
        lblErrorName.font = UIFont(name: Theme.font.normal, size: Theme.fontSize.small)!
        lblErrorEmail.font = lblErrorName.font
        lblErrorName.textColor = UIColor.red
        lblErrorEmail.textColor = lblErrorName.textColor
        
        _ = collectBrand.map({
            $0.font = UIFont(name: Theme.font.normal, size: Theme.fontSize.small)!
            $0.textColor = UIColor(hex: Theme.color.customer.subGroup)
        })
    }
    
    override func configText() {
        
        txtName.placeholder = "placeholder_fullname".localized()
        txtVNID.placeholder = "placeholder_vnid".localized()
        txtEmail.placeholder = "placeholder_email".localized()
        txtPhone.placeholder = "placeholder_phone".localized()
        txtAddress.placeholder = "placeholder_address".localized()
        lblErrorEmail.text = "invalid_email".localized()

        btnProcess.setTitle("update".localized().uppercased(), for: .normal)
        title = "my_profile".localized().uppercased()
        
        btnCancel.setTitle("quit".localized().uppercased(), for: .normal)
        btnChangePassword.setTitle("change_pw".localized().uppercased(), for: .normal)
        
        lblErrorEmail.text = "invalid_email".localized()
        lblErrorName.text = "invalid_fullname".localized()
        
        _ = collectBrand.map({
            $0.text = $0.accessibilityIdentifier?.localized()
        })
        
        guard let user = UserManager.currentUser() else { return }
        txtName.text = user.fullname
        txtVNID.text = user.username
        txtEmail.text = user.email
        txtPhone.text = user.tel
        txtAddress.text = user.address
        
        if let avaStr = user.avatar {
            if let urlAvatar = user.urlAvatar {
                if avaStr.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines).characters.count > 0 {
                    if avaStr.contains(".jpg") || avaStr.contains(".png"){
                        imvAvatar.loadImageUsingCacheWithURLString(urlAvatar,size:nil, placeHolder: nil)
                    } else {
                        if let dataDecoded : Data = Data(base64Encoded: avaStr, options: .ignoreUnknownCharacters) {
                            let decodedimage = UIImage(data: dataDecoded)
                            imvAvatar.image = decodedimage
                        }
                    }
                }
            } else {
                if let dataDecoded : Data = Data(base64Encoded: avaStr, options: .ignoreUnknownCharacters) {
                    let decodedimage = UIImage(data: dataDecoded)
                    imvAvatar.image = decodedimage
                }
            }
        }
        
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

extension UserProfileController {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let imgScale = image.resizeImageWith(newSize: CGSize(width: 100, height: 100))
            imvAvatar.image = imgScale
            picker.dismiss(animated: true, completion: nil)
            let imageData:NSData = UIImagePNGRepresentation(imgScale)! as NSData
            let strBase64 = imageData.base64EncodedString(options: .lineLength64Characters)
            self.avatar = strBase64            
        }
    }
}
