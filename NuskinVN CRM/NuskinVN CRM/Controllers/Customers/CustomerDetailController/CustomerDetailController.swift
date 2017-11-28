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

class CustomerDetailController: RootViewController, UINavigationControllerDelegate,UIImagePickerControllerDelegate {
    
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
    var customer:Customer?
    var listCountry:[City] = []
    
    var groupSelected:Group?
    var birthday:Date?
    var gender:Int64 = 0
    var city_id:Int64 = 0
    var district_id:Int64 = 0
    var avatar:String?
            
    override func viewDidLoad() {
           super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.hideKeyboard))
        self.view.addGestureRecognizer(tapGesture!)
        self.navigationController?.delegate = self
        LocalService.shared.getAllCity(complete: {[weak self] list in
            if let _self = self {
                DispatchQueue.main.async {
                    _self.listCountry = list
                }
            }
        })
        
        configText()
        configView()
        bindControl()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.preventSyncData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
    }
    
    deinit {
        LocalService.shared.isShouldSyncData = nil
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
        self.avatar = customer.avatar
        self.city_id = customer.city_id
        self.district_id = customer.district_id
        self.gender = customer.gender
        if let birth = customer.birthday as Date?{
            self.birthday = birth
        }
        
        let listGroups = customer.listGroups()
        if listGroups.count > 0 {
            self.groupSelected = listGroups.first
        }
        onDidLoad = {[weak self] in
            guard let _self = self else { return true }
            _self.configText()
            return true
        }
        
    }
    
    func setGroupSelected(group:Group) {
        self.groupSelected = group
        onDidLoad = { [weak self] in
            if let _self = self {
            _self.btnGroup.setTitle(group.group_name, for: .normal)
            _self.btnGroup.setTitleColor(UIColor(hex: Theme.color.customer.titleGroup), for: .normal)
                return true
            }
            return true
        }
    }
    
    // MARK: - private
    private func bindControl() {
        
        //listern data
        txtEmail.rx.text.orEmpty.subscribe(onNext:{ [weak self] in
            if let _self = self {
                var oldemail = ""
                if let cus = _self.customer {
                    oldemail = cus.email
                }
                _self.lblErrorEmail.isHidden = true
                
                if Customer.isExist(email:$0, oldEmail: oldemail,except:_self.isEdit) {
                    _self.lblErrorEmail.text = "email_has_exist".localized()
                } else {
                    _self.lblErrorEmail.text = "invalid_email".localized()
                }
            }
        }).addDisposableTo(disposeBag)
        
        
        btnBirthday.rx.tap
            .subscribe(onNext:{ [weak self] in
                if let _self = self {
                    let datePicker = DatePickerController(nibName: "DatePickerController", bundle: Bundle.main)
                    datePicker.onSelectDate = { strDate,date in
                        _self.birthday = date
                        _self.btnBirthday.setTitle(strDate, for: .normal)
                        _self.btnBirthday.setTitleColor(UIColor(hex: Theme.color.customer.titleGroup), for: .normal)
                    }
                    _self.present(datePicker, animated: false, completion: {
                        datePicker.setTitle(title: "select_date".localized())
                        
                        if let date = _self.birthday {
                            datePicker.setDate(date: date)
                        }
                        
                    })
                }
            })
            .addDisposableTo(disposeBag)
        
        btnGroup.rx.tap
            .subscribe(onNext:{ [weak self] in
                if let _self = self {
                    let vc = GroupCustomerController(nibName: "GroupCustomerController", bundle: Bundle.main)
                    vc.onSelectGroup = {group in
                        _self.groupSelected = group
                        _self.btnGroup.setTitle(group.group_name, for: .normal)
                        _self.btnGroup.setTitleColor(UIColor(hex: Theme.color.customer.titleGroup), for: .normal)
                    }
                    _self.navigationController?.pushViewController(vc, animated: true)
                }
            })
            .addDisposableTo(disposeBag)
        
        btnChoosePhotos.rx.tap
            .subscribe(onNext:{ [weak self] in
                if let _self = self {
                    _self.showSelectGetPhotos()
                }
            })
            .addDisposableTo(disposeBag)
        
        btnGender.rx.tap
            .subscribe(onNext:{ [weak self] in
                if let _self = self {
                    let popupC = PopupController(nibName: "PopupController", bundle: Bundle.main)
                    popupC.onSelect = {
                        item, index in
                        print("\(item) \(index)")
                        _self.btnGender.setTitle(item, for: .normal)
                        _self.btnGender.setTitleColor(UIColor(hex: Theme.color.customer.titleGroup), for: .normal)
                        _self.gender = Int64(index + 1)
                    }
                    popupC.onDismiss = {
                        _self.btnGender.imageView!.transform = _self.btnGender.imageView!.transform.rotated(by: CGFloat(Double.pi))
                    }
                    Support.topVC?.present(popupC, animated: false, completion: {isDone in
                        _self.btnGender.imageView!.transform = _self.btnGender.imageView!.transform.rotated(by: CGFloat(Double.pi))
                    })
                    popupC.show(data: ["male".localized(),"female".localized()], fromView: _self.btnGender.superview!)
                    popupC.ondeinitial = {
                        [weak self] in
                        guard let _self = self else {return}
                        _self.preventSyncData()
                    }
                }
            })
            .addDisposableTo(disposeBag)
        
        btnCity.rx.tap
            .subscribe(onNext:{ [weak self] in
                if let _self = self {
                    
                    var listData:[String] = []
                    _ = _self.listCountry.filter{$0.country_id == 0}.map({
                        listData.append($0.name)
                    })
                    
                    let vc = SimpleListController(nibName: "SimpleListController", bundle: Bundle.main)
                    vc.onDidLoad = {
                        vc.title = "choose_city".localized().uppercased()
                        vc.showData(data: listData)
                        return true
                    }
                    vc.onSelectData = { name in
                        _ = _self.listCountry.map({
                            if $0.name == name {
                                _self.city_id = $0.id
                            }
                        })
                        if name != _self.btnCity.titleLabel?.text {
                            _self.btnDistrict.setTitle("placeholder_district".localized(), for: .normal)
                            _self.btnDistrict.setTitleColor(UIColor(hex: Theme.color.customer.subGroup), for: .normal)
                            _self.district_id = 0
                        }
                        _self.btnCity.setTitle(name, for: .normal)
                        _self.btnCity.setTitleColor(UIColor(hex: Theme.color.customer.titleGroup), for: .normal)
                        if !_self.btnDistrict.isEnabled {
                            _self.btnDistrict.isEnabled = true
                        }
                    }
                    _self.navigationController?.pushViewController(vc, animated: true)
                    
                }
            })
            .addDisposableTo(disposeBag)
        
        btnDistrict.rx.tap
            .subscribe(onNext:{ [weak self] in
                if let _self = self {
                    if let city = _self.btnCity.titleLabel?.text  {
                        if city == "placeholder_city".localized() {
                            return
                        }
                    }
                    let vc = SimpleListController(nibName: "SimpleListController", bundle: Bundle.main)
                    _self.navigationController?.pushViewController(vc, animated: true)
                    
                    var listData:[String] = []
                    
                    _ = _self.listCountry.map({
                        if let city = _self.btnCity.titleLabel?.text  {
                            if $0.name == city {
                                let country:City = $0
                                let listFilter:[City] = _self.listCountry.filter{
                                    $0.country_id == country.id
                                }
                                
                                _ = listFilter.map({
                                    listData.append($0.name)
                                })
                                
                                vc.onDidLoad = {
                                    vc.title = "choose_district".localized().uppercased()
                                    vc.showData(data: listData)
                                    return true
                                }
                            }
                        }
                    })
                    
                    
                    vc.onSelectData = { name in
                        _ = _self.listCountry.map({
                            if $0.name == name && $0.country_id > 0{
                                _self.district_id = $0.id
                            }
                        })
                        _self.btnDistrict.setTitle(name, for: .normal)
                        _self.btnDistrict.setTitleColor(UIColor(hex: Theme.color.customer.titleGroup), for: .normal)
                    }
                }
            })
            .addDisposableTo(disposeBag)
        
        // event process
        btnProcess.rx.tap
            .subscribe(onNext:{ [weak self] in
                if let _self = self {
                    
                    if !_self.validdateData() {
                        Support.popup.showAlert(message: "email_invalid_or_name_customer_invalid".localized(), buttons: ["ok".localized()], vc: _self.navigationController!, onAction: {index in
                            
                        }, { [weak self] index in
                            guard let _self = self else {return}
                            _self.preventSyncData()
                        })
                        return
                    }
                    
                    guard let user = UserManager.currentUser() else {
                        Support.popup.showAlert(message: "please_login_before_use_this_function".localized(), buttons: ["ok".localized()], vc: _self.navigationController!, onAction: {index in
                            
                        }, { [weak self] index in
                            guard let _self = self else {return}
                            _self.preventSyncData()
                        })
                        return
                    }
                    
                    if _self.customer == nil {
                        
                        var customer = Customer()
                        customer.id = -Int64(Date.init(timeIntervalSinceNow: 0).toString(dateFormat: "89yyyyMMddHHmmss"))!
                        customer.status = 1
                        customer.date_created = Date.init(timeIntervalSinceNow: 0) as NSDate
                        customer.email = _self.txtEmail.text ?? ""
                        customer.fullname = _self.txtName.text ?? ""
                        customer.address = _self.txtAddress.text ?? ""
                        customer.avatar = _self.avatar ?? ""
                        customer.city = _self.btnCity.titleLabel?.text ?? ""
                        customer.county  = _self.btnDistrict.titleLabel?.text ?? ""
                        customer.gender = _self.gender
                        customer.tel = _self.txtPhone.text ?? ""
                        customer.setSkype(_self.txtSkype.text ?? "")
                        customer.setFacebook(_self.txtFacebook.text ?? "")
                        customer.setZalo(_self.txtZalo.text ?? "")
                        customer.setViber(_self.txtViber.text ?? "")
                        customer.city_id = _self.city_id
                        customer.district_id = _self.district_id
                        if let birth = _self.birthday as NSDate? {
                            customer.birthday = birth
                        }
                        customer.synced = false
                        if let group = _self.groupSelected {
                                customer.group_id = group.id
                        }
                        customer.distributor_id = user.id
                        customer.store_id = user.store_id
                        CustomerManager.saveCustomerWith(array: [customer.toDO]) {
                            DispatchQueue.main.async {
                                _self.navigationController?.popToRootViewController(animated: true)
                            }
                        }
                    } else {
                        if var customerUpdate = _self.customer {
                            customerUpdate.email = _self.txtEmail.text ?? ""
                            customerUpdate.fullname = _self.txtName.text ?? ""
                            customerUpdate.address = _self.txtAddress.text ?? ""
                            customerUpdate.avatar = _self.avatar ?? ""
                            customerUpdate.city = _self.btnCity.titleLabel?.text ?? ""
                            customerUpdate.county  = _self.btnDistrict.titleLabel?.text ?? ""
                            customerUpdate.gender = _self.gender
                            customerUpdate.tel = _self.txtPhone.text ?? ""
                            customerUpdate.setSkype(_self.txtSkype.text ?? "")
                            customerUpdate.setFacebook(_self.txtFacebook.text ?? "")
                            customerUpdate.setZalo(_self.txtZalo.text ?? "")
                            customerUpdate.setViber(_self.txtViber.text ?? "")
                            customerUpdate.distributor_id = user.id
                            customerUpdate.store_id = user.store_id
                            customerUpdate.city_id = _self.city_id
                            customerUpdate.district_id = _self.district_id
                            if let birth = _self.birthday as NSDate? {
                                customerUpdate.birthday = birth
                            }
                            
                            customerUpdate.synced = false
                            if let group = _self.groupSelected {
                                customerUpdate.group_id = group.id
                            }
                            CustomerManager.update([customerUpdate.toDO]) {
                                DispatchQueue.main.async {
                                    _self.navigationController?.popToRootViewController(animated: true)
                                }
                            }
                        }
                    }
                }
            })
            .addDisposableTo(disposeBag)
        
        btnCancel.rx.tap
            .subscribe(onNext:{ [weak self] in
                if let _self = self {
                    _self.navigationController?.popViewController(animated: true)
                }
                
            })
            .addDisposableTo(disposeBag)
    }
    
    func validdateData() -> Bool {
        guard let email = self.txtEmail.text, let name = self.txtName.text else { return false }
        var oldemail = ""
        if let cus = self.customer {
            oldemail = cus.email
        }
        let checkEmail = Support.validate.isValidEmailAddress(emailAddressString: email) && !Customer.isExist(email:email,oldEmail: oldemail,except:self.isEdit)
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
        btnProcess.titleLabel?.font = UIFont(name: Theme.font.bold, size: Theme.fontSize.normal)
        
        btnCancel.backgroundColor = UIColor(_gradient: Theme.colorGradient, frame: btnCancel.frame, isReverse:true)
        btnCancel.setTitleColor(UIColor(hex:Theme.colorAlertButtonTitleColor), for: .normal)
        btnCancel.titleLabel?.font = UIFont(name: Theme.font.bold, size: Theme.fontSize.normal)
        
        lblErrorName.font = UIFont(name: Theme.font.normal, size: Theme.fontSize.small)!
        lblErrorEmail.font = lblErrorName.font
        lblErrorName.textColor = UIColor.red
        lblErrorEmail.textColor = lblErrorName.textColor
        
        _ = collectBrand.map({
            $0.font = UIFont(name: Theme.font.normal, size: Theme.fontSize.small)!
            $0.textColor = UIColor(hex: Theme.color.customer.subGroup)
        })
        
        
            if let group = self.groupSelected {
                let group_name = group.group_name
                    if group_name.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).characters.count > 0 {
                        self.btnGroup.setTitle(group_name, for: .normal)
                        self.btnGroup.setTitleColor(UIColor(hex: Theme.color.customer.titleGroup), for: .normal)
                    }
            }
        
        
        // set value when edit a customer
        if self.customer != nil {
            
            txtName.text = customer?.fullname
            txtEmail.text = customer?.email
            txtZalo.text = customer?.zalo
            txtPhone.text = customer?.tel
            txtSkype.text = customer?.skype
            txtViber.text = customer?.viber
            txtFacebook.text = customer?.facebook
            txtAddress.text = customer?.address
            
            if customer?.gender == 1 {
                btnGender.setTitle("male".localized(), for: .normal)
            } else {
                btnGender.setTitle("female".localized(), for: .normal)
            }
            if let cus = self.customer {

                let city = cus.city
                    if city.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).characters.count > 0 {
                        btnCity.setTitle(city, for: .normal)
                        self.btnCity.setTitleColor(UIColor(hex: Theme.color.customer.titleGroup), for: .normal)
                        btnDistrict.isEnabled = true
                    }
                
                let country = cus.county
                    if country.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).characters.count > 0 {
                        btnDistrict.setTitle(country, for: .normal)
                        self.btnDistrict.setTitleColor(UIColor(hex: Theme.color.customer.titleGroup), for: .normal)
                    }
                
                if let birth = cus.birthday as Date? {
                    self.btnBirthday.setTitle(birth.toString(dateFormat: "dd/MM/yyyy"), for: .normal)
                    self.btnBirthday.setTitleColor(UIColor(hex: Theme.color.customer.titleGroup), for: .normal)
                }
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
        if let group = self.groupSelected {
            let group_name = group.group_name
                self.btnGroup.setTitle(group_name, for: .normal)
                self.btnGroup.setTitleColor(UIColor(hex: Theme.color.customer.titleGroup), for: .normal)
        } else {
             btnGroup.setTitle("placeholder_group".localized(), for: .normal)
            self.btnGroup.setTitleColor(UIColor(hex: Theme.color.customer.subGroup), for: .normal)
        }
        
        if !self.isEdit {
            btnProcess.setTitle("add".localized().uppercased(), for: .normal)
            title = "add_customer".localized().uppercased()
        } else {
            btnProcess.setTitle("update".localized().uppercased(), for: .normal)
            title = "edit_customer".localized().uppercased()
        }
        
        btnCancel.setTitle("cancel".localized(), for: .normal)
        
        lblErrorEmail.text = "invalid_email".localized()
        lblErrorName.text = "invalid_fullname".localized()
        
        _ = collectBrand.map({
            $0.text = $0.accessibilityIdentifier?.localized()
        })
        
        if let cus = customer {
            let avaStr = cus.avatar
                if let urlAvatar = cus.urlAvatar {
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

extension CustomerDetailController {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let imgScale = image.resizeImageWith(newSize: CGSize(width: 100, height: 100))
            imvAvatar.image = imgScale
            picker.dismiss(animated: true, completion: nil)
            let imageData:NSData = UIImageJPEGRepresentation(imgScale, 0.5)! as NSData
            let strBase64 = imageData.base64EncodedString(options: .lineLength64Characters)
            self.avatar = strBase64            
        }
//        print("START SYNC DATA WHEN UIImagePickerController CLOSED")
//        LocalService.shared.startSyncData()
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//        print("START SYNC DATA WHEN UIImagePickerController CLOSED")
//        LocalService.shared.startSyncData()
        picker.dismiss(animated: true) {
            
        }
    }
}
