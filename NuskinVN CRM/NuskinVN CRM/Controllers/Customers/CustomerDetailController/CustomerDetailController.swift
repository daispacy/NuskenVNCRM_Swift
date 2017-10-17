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

class CustomerDetailController: RootViewController {
    
    @IBOutlet var scrollView: UIScrollView!
    
    @IBOutlet var imvAvatar: CImageViewRoundGradient!
    @IBOutlet var btnChoosePhotos: UIButton!
    
    @IBOutlet var collectBrand: [UILabel]!
    
    
    @IBOutlet var txtName: UITextField!
    @IBOutlet var txtEmail: UITextField!
    @IBOutlet var btnBirthday: CButtonWithImageRight1!
    @IBOutlet var txtAddress: UITextField!
    @IBOutlet var btnGender: CButtonWithImageRight2!
    @IBOutlet var txtPhone: UITextField!
    @IBOutlet var txtFacebook: UITextField!
    @IBOutlet var txtSkype: UITextField!
    @IBOutlet var txtViber: UITextField!
    @IBOutlet var txtZalo: UITextField!
    @IBOutlet var btnDistrict: CButtonWithImageRight2!
    @IBOutlet var btnCity: CButtonWithImageRight2!
    @IBOutlet var btnGroup: CButtonWithImageRight2!
    @IBOutlet var btnProcess: CButtonAlert!
    @IBOutlet var btnCancel: CButtonAlert!
    
    @IBOutlet var lblErrorEmail: UILabel!
    @IBOutlet var lblErrorName: UILabel!
    
    var isEdit:Bool = false
    var activeField:UITextField?
    var tapGesture:UITapGestureRecognizer?
    var customer:Customer = Customer(id: 0, distributor_id: User.currentUser().id!, store_id: User.currentUser().store_id!)
    var listCountry:[City] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "add_customer".uppercased().localized()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.hideKeyboard))
        self.view.addGestureRecognizer(tapGesture!)
        
        LocalService.shared().getAllCity(complete: {[weak self] list in
            DispatchQueue.main.async {
                self?.listCountry = list
            }
        })
        
        configText()
        configView()
        bindControl()
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
    
    // MARK: - interface
    func edit(customer:Customer) {
        self.customer = customer
        self.isEdit = true
        configView()
    }
    
    func setGroupSelected(group:GroupCustomer) {
        if group.server_id == 0 {
            self.customer.group_id = group.id
        } else {
            self.customer.group_id = group.server_id
        }
    }
    
    // MARK: - private
    private func bindControl() {
        
        // validate
        let funcValidateEmail = Support.validate.self
        
        let nameIsValid = txtName.rx.text.orEmpty
            .map { $0.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).characters.count > 0 }
            .shareReplay(1)
        let emailIsValid = txtEmail.rx.text.orEmpty
            .map { funcValidateEmail.isValidEmailAddress(emailAddressString: $0) && !self.customer.isExist}
            .shareReplay(1)
        
        nameIsValid.bind(to: lblErrorName.rx.isHidden).disposed(by: disposeBag)
        emailIsValid.bind(to: lblErrorEmail.rx.isHidden).disposed(by: disposeBag)
        
        let everythingValid = Observable.combineLatest(nameIsValid, emailIsValid) { $0 && $1 }
            .shareReplay(1)
        
        everythingValid
            .bind(to: btnProcess.rx.isEnabled)
            .disposed(by: disposeBag)
        
        //listern data
        txtName.rx.text.orEmpty.subscribe(onNext:{ [weak self] in
            self?.customer.fullname = $0
        })
            .disposed(by: disposeBag)
        
        txtEmail.rx.text.orEmpty.subscribe(onNext:{ [weak self] in
            self?.customer.email = $0
            if ((self?.customer.isExist)!) {
                self?.lblErrorEmail.text = "email_has_exist".localized()
            } else {
                self?.lblErrorEmail.text = "invalid_email".localized()
            }
        })
            .disposed(by: disposeBag)
        
        txtZalo.rx.text.orEmpty.subscribe(onNext:{ [weak self] in
            self?.customer.zalo = $0
        })
            .disposed(by: disposeBag)
        
        txtPhone.rx.text.orEmpty.subscribe(onNext:{ [weak self] in
            self?.customer.tel = $0
        })
            .disposed(by: disposeBag)
        txtSkype.rx.text.orEmpty.subscribe(onNext:{ [weak self] in
            self?.customer.skype = $0
        })
            .disposed(by: disposeBag)
        txtViber.rx.text.orEmpty.subscribe(onNext:{ [weak self] in
            self?.customer.viber = $0
        })
            .disposed(by: disposeBag)
        txtFacebook.rx.text.orEmpty.subscribe(onNext:{ [weak self] in
            self?.customer.facebook = $0
        })
            .disposed(by: disposeBag)
        txtAddress.rx.text.orEmpty.subscribe(onNext:{ [weak self] in
            self?.customer.address = $0
        })
            .disposed(by: disposeBag)
        
        btnBirthday.rx.tap
            .subscribe(onNext:{ [weak self] in
                
                let datePicker = DatePickerController(nibName: "DatePickerController", bundle: Bundle.main)
                datePicker.onSelectDate = { date in
                    self?.customer.birthday = date
                    self?.btnBirthday.setTitle(date, for: .normal)
                    self?.btnBirthday.setTitleColor(UIColor(hex: Theme.color.customer.titleGroup), for: .normal)
                }
                self?.present(datePicker, animated: false, completion: {
                    datePicker.setTitle(title: "select_date".localized())
                    if let dateStr = self?.customer.birthday {
                        if dateStr.characters.count > 0 {
                            datePicker.setDate(date: dateStr.toDate())
                        }
                    }
                })
            })
            .disposed(by: disposeBag)
        
        btnGroup.rx.tap
            .subscribe(onNext:{ [weak self] in
                
                let vc = GroupCustomerController(nibName: "GroupCustomerController", bundle: Bundle.main)
                vc.onSelectGroup = {group in
                    if group.server_id == 0 {
                        self?.customer.group_id = group.id
                    } else {
                        self?.customer.group_id = group.server_id
                    }
                    self?.btnGroup.setTitle(group.name, for: .normal)
                    self?.btnGroup.setTitleColor(UIColor(hex: Theme.color.customer.titleGroup), for: .normal)
                }
                self?.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: disposeBag)
        
        btnChoosePhotos.rx.tap
            .subscribe(onNext:{ [weak self] in
                self?.showSelectGetPhotos()
            })
            .disposed(by: disposeBag)
        
        btnGender.rx.tap
            .subscribe(onNext:{ [weak self] in
                let popupC = PopupController(nibName: "PopupController", bundle: Bundle.main)
                popupC.onSelect = {
                    item, index in
                    print("\(item) \(index)")
                    self?.btnGender.setTitle(item, for: .normal)
                    self?.btnGender.setTitleColor(UIColor(hex: Theme.color.customer.titleGroup), for: .normal)
                    self?.customer.gender = Int64(index)
                }
                popupC.onDismiss = {
                    self?.btnGender.imageView!.transform = (self?.btnGender.imageView!.transform.rotated(by: CGFloat(Double.pi)))!
                }
                var topVC = UIApplication.shared.keyWindow?.rootViewController
                while((topVC!.presentedViewController) != nil){
                    topVC = topVC!.presentedViewController
                }
                topVC?.present(popupC, animated: false, completion: {isDone in
                    self?.btnGender.imageView!.transform = (self?.btnGender.imageView!.transform.rotated(by: CGFloat(Double.pi)))!
                })
                popupC.show(data: ["male".localized(),"female".localized()], fromView: (self?.btnGender.superview)!)
            })
            .disposed(by: disposeBag)
        
        btnCity.rx.tap
            .subscribe(onNext:{ [weak self] in
                DispatchQueue.main.async {
                    var listData:[String] = []
                    _ = self?.listCountry.filter{$0.country_id == 0}.map({
                        listData.append($0.name)
                    })
                    
                    let vc = SimpleListController(nibName: "SimpleListController", bundle: Bundle.main)
                    vc.onDidLoad = {
                        vc.showData(data: listData.sorted(by: {$0 < $1}))
                    }                    
                    vc.onSelectData = { name in
                        self?.customer.city = name
                        self?.btnCity.setTitle(name, for: .normal)
                        self?.btnCity.setTitleColor(UIColor(hex: Theme.color.customer.titleGroup), for: .normal)
                        if !(self?.btnDistrict.isEnabled)! {
                            self?.btnDistrict.isEnabled = true
                        }
                    }
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
            })
            .disposed(by: disposeBag)
        
        btnDistrict.rx.tap
            .subscribe(onNext:{ [weak self] in
                if self?.customer.country == "placeholder_city".localized() {
                    return
                }
                let vc = SimpleListController(nibName: "SimpleListController", bundle: Bundle.main)
                self?.navigationController?.pushViewController(vc, animated: true)
                
                var listData:[String] = []
                
                _ = self?.listCountry.map({
                    if $0.name == self?.customer.city {
                        let country:City = $0
                        let listFilter:[City] = (self?.listCountry.filter{
                            $0.country_id == country.id
                            })!
                        
                        _ = listFilter.map({
                            listData.append($0.name)
                        })
                        
                        vc.onDidLoad = {
                            vc.showData(data: listData.sorted(by: {$0 < $1}))
                        }
                    }
                })
                
                
                vc.onSelectData = { name in
                    self?.customer.city = name
                    self?.btnDistrict.setTitle(name, for: .normal)
                    self?.btnDistrict.setTitleColor(UIColor(hex: Theme.color.customer.titleGroup), for: .normal)
                }
                
            })
            .disposed(by: disposeBag)
        
        // event process
        let localService = LocalService.shared()
        btnProcess.rx.tap
            .subscribe(onNext:{
                if self.customer.server_id == 0 && self.customer.id == 0{
                    if localService.addCustomer(object: (self.customer)) {
                        LocalService.shared().startSyncData()
                        self.navigationController?.popToRootViewController(animated: true)
                    }
                } else {
                    if localService.updateCustomer(object: (self.customer)) {
                        LocalService.shared().startSyncData()
                        self.navigationController?.popToRootViewController(animated: true)
                    }
                }
                
            })
            .disposed(by: disposeBag)
        
        btnCancel.rx.tap
            .subscribe(onNext:{ [weak self] in
                self?.navigationController?.popViewController(animated: true)
                
            })
            .disposed(by: disposeBag)
    }
    
    func showSelectGetPhotos() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        let cancelAction = UIAlertAction(title: "cancel".localized(), style: UIAlertActionStyle.cancel) { (result : UIAlertAction) -> Void in
            alertController.dismiss(animated: true, completion: nil)
        }
        let okAction = UIAlertAction(title: "camera".localized(), style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
            let imagePickerController = UIImagePickerController()
            
            imagePickerController.sourceType = .camera
            imagePickerController.modalPresentationStyle = .fullScreen
            imagePickerController.delegate = self as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
            self.present(imagePickerController, animated: true, completion: nil)
            
        }
        let actionPhotos = UIAlertAction(title: "photo_library".localized(), style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
            let imagePickerController = UIImagePickerController()
            
            imagePickerController.sourceType = .photoLibrary
            imagePickerController.modalPresentationStyle = .popover
            imagePickerController.delegate = self as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
            self.present(imagePickerController, animated: true, completion: nil)
            
        }
        alertController.addAction(cancelAction)
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alertController.addAction(okAction)
        }
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            alertController.addAction(actionPhotos)
        }
        self.navigationController?.present(alertController, animated: true, completion: nil)
    }
    
    private func configView() {
        
        
        configButton(btnCity)
        configButton(btnGroup)
        configButton(btnGender)
        configButton(btnBirthday)
        configButton(btnDistrict)
        btnDistrict.isEnabled = false
        
        configTextfield(txtName)
        configTextfield(txtEmail)
        configTextfield(txtPhone)
        configTextfield(txtSkype)
        configTextfield(txtViber)
        configTextfield(txtFacebook)
        configTextfield(txtZalo)
        configTextfield(txtAddress)
        
        btnProcess.backgroundColor = UIColor(_gradient: Theme.colorGradient, frame: btnProcess.frame, isReverse:true)
        btnProcess.setTitleColor(UIColor(hex:Theme.colorAlertButtonTitleColor), for: .normal)
        btnProcess.titleLabel?.font = UIFont(name: Theme.font.normal, size: Theme.fontSize.normal)
        
        btnCancel.backgroundColor = UIColor(_gradient: Theme.colorGradient, frame: btnCancel.frame, isReverse:true)
        btnCancel.setTitleColor(UIColor(hex:Theme.colorAlertButtonTitleColor), for: .normal)
        btnCancel.titleLabel?.font = UIFont(name: Theme.font.normal, size: Theme.fontSize.normal)
        
        lblErrorName.font = UIFont(name: Theme.font.normal, size: Theme.fontSize.small)!
        lblErrorEmail.font = lblErrorName.font
        lblErrorName.textColor = UIColor.red
        lblErrorEmail.textColor = lblErrorName.textColor
        
        _ = collectBrand.map({
            $0.font = UIFont(name: Theme.font.normal, size: Theme.fontSize.small)!
            $0.textColor = UIColor(hex: Theme.color.customer.subGroup)
        })
        
        if customer.groupName.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).characters.count > 0 {
            btnGroup.setTitle(customer.groupName, for: .normal)
            self.btnGroup.setTitleColor(UIColor(hex: Theme.color.customer.titleGroup), for: .normal)
        }
        
        // set value when edit a customer
        if self.customer.email.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).characters.count > 0 {
            
            txtEmail.isEnabled = false
            
            txtName.text = customer.fullname
            txtEmail.text = customer.email
            txtZalo.text = customer.zalo
            txtPhone.text = customer.tel
            txtSkype.text = customer.skype
            txtViber.text = customer.viber
            txtFacebook.text = customer.facebook
            txtAddress.text = customer.address
            
            if customer.gender == 0 {
                btnGender.setTitle("male".localized(), for: .normal)
            } else {
                btnGender.setTitle("female".localized(), for: .normal)
            }
            if customer.birthday.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).characters.count > 0 {
                btnBirthday.setTitle(customer.birthday, for: .normal)
                self.btnBirthday.setTitleColor(UIColor(hex: Theme.color.customer.titleGroup), for: .normal)
            }
            
            if customer.city.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).characters.count > 0 {
                btnCity.setTitle(customer.city, for: .normal)
                self.btnCity.setTitleColor(UIColor(hex: Theme.color.customer.titleGroup), for: .normal)
                btnDistrict.isEnabled = true
            }
            
            if customer.country.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).characters.count > 0 {
                btnDistrict.setTitle(customer.country, for: .normal)
                self.btnDistrict.setTitleColor(UIColor(hex: Theme.color.customer.titleGroup), for: .normal)
            }
            
            self.btnGender.setTitleColor(UIColor(hex: Theme.color.customer.titleGroup), for: .normal)
            
        }
    }
    
    override func configText() {
        
        txtName.placeholder = "placeholder_fullname".localized()
        txtEmail.placeholder = "placeholder_email".localized()
        txtPhone.placeholder = "placeholder_phone".localized()
        txtFacebook.placeholder = "placeholder_facebook".localized()
        txtSkype.placeholder = "placeholder_skype".localized()
        txtViber.placeholder = "placeholder_viber".localized()
        txtZalo.placeholder = "placeholder_zalo".localized()
        txtAddress.placeholder = "placeholder_address".localized()
        
        btnGender.setTitle("placeholder_gender".localized(), for: .normal)
        btnBirthday.setTitle("placeholder_birthday".localized(), for: .normal)
        btnDistrict.setTitle("placeholder_district".localized(), for: .normal)
        btnCity.setTitle("placeholder_city".localized(), for: .normal)
        btnGroup.setTitle("placeholder_group".localized(), for: .normal)
        
        if customer.id == 0 {
            btnProcess.setTitle("add".localized(), for: .normal)
        } else {
            btnProcess.setTitle("update".localized(), for: .normal)
        }
        
        btnCancel.setTitle("cancel".localized(), for: .normal)
        
        lblErrorEmail.text = "invalid_email".localized()
        lblErrorName.text = "invalid_fullname".localized()
        
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

extension CustomerDetailController: UIImagePickerControllerDelegate {
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        // Whatever you want here
        imvAvatar.image = image.resizeImageWith(newSize: CGSize(width: 100, height: 100))
        picker.dismiss(animated: true, completion: nil)
        let imageData:NSData = UIImagePNGRepresentation(image)! as NSData
        let strBase64 = imageData.base64EncodedString(options: .lineLength64Characters)
        self.customer.tempAvatar = strBase64
    }
}

class CButtonWithImageRight1: UIButton {
    override func layoutSubviews() {
        super.layoutSubviews()
        imageEdgeInsets = UIEdgeInsetsMake(0, frame.size.width-5, 0, 25)
        titleEdgeInsets = UIEdgeInsetsMake(0, -15, 0, 0)
    }
}

class CButtonWithImageRight2: UIButton {
    override func layoutSubviews() {
        super.layoutSubviews()
        imageEdgeInsets = UIEdgeInsetsMake(0, frame.size.width - 10, 0, 20)
        titleEdgeInsets = UIEdgeInsetsMake(0, -13, 0, 0)
    }
}
