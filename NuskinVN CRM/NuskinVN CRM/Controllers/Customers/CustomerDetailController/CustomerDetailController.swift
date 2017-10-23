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
    var customer:CustomerDO?
    var listCountry:[City] = []
    
    var groupSelected:GroupDO?
    var birthday:Date?
    var gender:Int64 = 0
    var avatar:String?
    
    override func viewDidLoad() {
           super.viewDidLoad()
        
        title = "add_customer".localized().uppercased()
        
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
    func edit(customer:CustomerDO) {
        self.customer = customer
        self.isEdit = true
        let listGroups = customer.listGroups()
        if listGroups.count > 0 {
            self.groupSelected = listGroups.first
        }
        
    }
    
    func setGroupSelected(group:GroupDO) {
        self.groupSelected = group
        self.btnGroup.setTitle(group.group_name, for: .normal)
        self.btnGroup.setTitleColor(UIColor(hex: Theme.color.customer.titleGroup), for: .normal)
    }
    
    // MARK: - private
    private func bindControl() {
        
        // validate
        let funcValidateEmail = Support.validate.self
        
        let nameIsValid = txtName.rx.text.orEmpty
            .map { $0.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).characters.count > 0 }
            .shareReplay(1)
        let emailIsValid = txtEmail.rx.text.orEmpty
            .map { funcValidateEmail.isValidEmailAddress(emailAddressString: $0) && CustomerDO.isExist(email:$0,except:self.isEdit)}
            .shareReplay(1)
        
        nameIsValid.bind(to: lblErrorName.rx.isHidden).disposed(by: disposeBag)
        emailIsValid.bind(to: lblErrorEmail.rx.isHidden).disposed(by: disposeBag)
        
        let everythingValid = Observable.combineLatest(nameIsValid, emailIsValid) { $0 && $1 }
            .shareReplay(1)
        
        everythingValid
            .bind(to: btnProcess.rx.isEnabled)
            .disposed(by: disposeBag)
        
        //listern data
        txtEmail.rx.text.orEmpty.subscribe(onNext:{ [weak self] in
            if let _self = self {
                if CustomerDO.isExist(email:$0,except:_self.isEdit) {
                    _self.lblErrorEmail.text = "email_has_exist".localized()
                } else {
                    _self.lblErrorEmail.text = "invalid_email".localized()
                }
            }
        }).disposed(by: disposeBag)
        
        
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
            .disposed(by: disposeBag)
        
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
            .disposed(by: disposeBag)
        
        btnChoosePhotos.rx.tap
            .subscribe(onNext:{ [weak self] in
                if let _self = self {
                    _self.showSelectGetPhotos()
                }
            })
            .disposed(by: disposeBag)
        
        btnGender.rx.tap
            .subscribe(onNext:{ [weak self] in
                if let _self = self {
                    let popupC = PopupController(nibName: "PopupController", bundle: Bundle.main)
                    popupC.onSelect = {
                        item, index in
                        print("\(item) \(index)")
                        _self.btnGender.setTitle(item, for: .normal)
                        _self.btnGender.setTitleColor(UIColor(hex: Theme.color.customer.titleGroup), for: .normal)
                        _self.gender = Int64(index)
                    }
                    popupC.onDismiss = {
                        _self.btnGender.imageView!.transform = _self.btnGender.imageView!.transform.rotated(by: CGFloat(Double.pi))
                    }
                    var topVC = UIApplication.shared.keyWindow?.rootViewController
                    while((topVC!.presentedViewController) != nil){
                        topVC = topVC!.presentedViewController
                    }
                    topVC?.present(popupC, animated: false, completion: {isDone in
                        _self.btnGender.imageView!.transform = _self.btnGender.imageView!.transform.rotated(by: CGFloat(Double.pi))
                    })
                    popupC.show(data: ["male".localized(),"female".localized()], fromView: _self.btnGender.superview!)
                }
            })
            .disposed(by: disposeBag)
        
        btnCity.rx.tap
            .subscribe(onNext:{ [weak self] in
                if let _self = self {
                    DispatchQueue.main.async {
                        var listData:[String] = []
                        _ = _self.listCountry.filter{$0.country_id == 0}.map({
                            listData.append($0.name)
                        })
                        
                        let vc = SimpleListController(nibName: "SimpleListController", bundle: Bundle.main)
                        vc.onDidLoad = {
                            vc.title = "choose_city".localized().uppercased()
                            vc.showData(data: listData.sorted(by: {$0 < $1}))
                        }
                        vc.onSelectData = { name in
                            _self.btnCity.setTitle(name, for: .normal)
                            _self.btnCity.setTitleColor(UIColor(hex: Theme.color.customer.titleGroup), for: .normal)
                            if !_self.btnDistrict.isEnabled {
                                _self.btnDistrict.isEnabled = true
                            }
                        }
                        _self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            })
            .disposed(by: disposeBag)
        
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
                                    vc.showData(data: listData.sorted(by: {$0 < $1}))
                                }
                            }
                        }
                    })
                    
                    
                    vc.onSelectData = { name in
                        _self.btnDistrict.setTitle(name, for: .normal)
                        _self.btnDistrict.setTitleColor(UIColor(hex: Theme.color.customer.titleGroup), for: .normal)
                    }
                }
            })
            .disposed(by: disposeBag)
        
        // event process
        btnProcess.rx.tap
            .subscribe(onNext:{ [weak self] in
                if let _self = self {
                    if _self.customer == nil{
                        let customer = NSEntityDescription.insertNewObject(forEntityName: "CustomerDO", into: CoreDataStack.sharedInstance.persistentContainer.viewContext) as! CustomerDO
                        customer.id = -Int64(Date.init(timeIntervalSinceNow: 0).toString(dateFormat: "89yyyyMMddHHmmss"))!
                        customer.status = 1
                        customer.email = _self.txtEmail.text
                        customer.fullname = _self.txtName.text
                        customer.address = _self.txtAddress.text
                        customer.avatar = _self.avatar
                        customer.city = _self.btnCity.titleLabel?.text
                        customer.county  = _self.btnDistrict.titleLabel?.text
                        customer.gender = _self.gender
                        customer.tel = _self.txtPhone.text
                        customer.setSkype(_self.txtSkype.text ?? "")
                        customer.setFacebook(_self.txtFacebook.text ?? "")
                        customer.setZalo(_self.txtZalo.text ?? "")
                        customer.setViber(_self.txtViber.text ?? "")
                        customer.synced = false
                        if let group = _self.groupSelected {
                                customer.group_id = group.id
                        }
                        customer.distributor_id = UserManager.currentUser().id_card_no
                        customer.store_id = UserManager.currentUser().store_id
                        
                        CustomerManager.updateCustomerEntity(customer, onComplete: {
                            _self.navigationController?.popToRootViewController(animated: true)
                        })
                    } else {
                        if let customerUpdate = _self.customer {
                            customerUpdate.fullname = _self.txtName.text
                            customerUpdate.address = _self.txtAddress.text
                            customerUpdate.avatar = _self.avatar
                            customerUpdate.city = _self.btnCity.titleLabel?.text
                            customerUpdate.county  = _self.btnDistrict.titleLabel?.text
                            customerUpdate.gender = _self.gender
                            customerUpdate.tel = _self.txtPhone.text
                            customerUpdate.setSkype(_self.txtSkype.text ?? "")
                            customerUpdate.setFacebook(_self.txtFacebook.text ?? "")
                            customerUpdate.setZalo(_self.txtZalo.text ?? "")
                            customerUpdate.setViber(_self.txtViber.text ?? "")
                            customerUpdate.distributor_id = UserManager.currentUser().id_card_no
                            customerUpdate.store_id = UserManager.currentUser().store_id
                            customerUpdate.synced = false
                            if let group = _self.groupSelected {
                                customerUpdate.group_id = group.id
                            }
                            CustomerManager.updateCustomerEntity(customerUpdate, onComplete: {
                                _self.navigationController?.popToRootViewController(animated: true)
                            })
                        }
                    }
                }
            })
            .disposed(by: disposeBag)
        
        btnCancel.rx.tap
            .subscribe(onNext:{ [weak self] in
                if let _self = self {
                    _self.navigationController?.popViewController(animated: true)
                }
                
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
        
        
            if let group = self.groupSelected {
                if let group_name = group.group_name {
                    if group_name.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).characters.count > 0 {
                        self.btnGroup.setTitle(group_name, for: .normal)
                        self.btnGroup.setTitleColor(UIColor(hex: Theme.color.customer.titleGroup), for: .normal)
                    }
                }
            }
        
        
        // set value when edit a customer
        if self.customer != nil {
            
            txtEmail.isEnabled = false
            
            txtName.text = customer?.fullname
            txtEmail.text = customer?.email
            txtZalo.text = customer?.zalo
            txtPhone.text = customer?.tel
            txtSkype.text = customer?.skype
            txtViber.text = customer?.viber
            txtFacebook.text = customer?.facebook
            txtAddress.text = customer?.address
            
            if customer?.gender == 0 {
                btnGender.setTitle("male".localized(), for: .normal)
            } else {
                btnGender.setTitle("female".localized(), for: .normal)
            }
            if let cus = self.customer {
//                if customer.birthday.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).characters.count > 0 {
//                    btnBirthday.setTitle(customer.birthday, for: .normal)
//                    self.btnBirthday.setTitleColor(UIColor(hex: Theme.color.customer.titleGroup), for: .normal)
//                }
                if let city = cus.city {
                    if city.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).characters.count > 0 {
                        btnCity.setTitle(city, for: .normal)
                        self.btnCity.setTitleColor(UIColor(hex: Theme.color.customer.titleGroup), for: .normal)
                        btnDistrict.isEnabled = true
                    }
                }
                
                if let country = cus.county {
                    if country.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).characters.count > 0 {
                        btnDistrict.setTitle(country, for: .normal)
                        self.btnDistrict.setTitleColor(UIColor(hex: Theme.color.customer.titleGroup), for: .normal)
                    }
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
            if let group_name = group.group_name {
                self.btnGroup.setTitle(group_name, for: .normal)
                self.btnGroup.setTitleColor(UIColor(hex: Theme.color.customer.titleGroup), for: .normal)
            } else {
                btnGroup.setTitle("placeholder_group".localized(), for: .normal)
                self.btnGroup.setTitleColor(UIColor(hex: Theme.color.customer.subGroup), for: .normal)
            }
        } else {
             btnGroup.setTitle("placeholder_group".localized(), for: .normal)
            self.btnGroup.setTitleColor(UIColor(hex: Theme.color.customer.subGroup), for: .normal)
        }
        
        if customer == nil {
            btnProcess.setTitle("add".localized().uppercased(), for: .normal)
        } else {
            btnProcess.setTitle("update".localized().uppercased(), for: .normal)
        }
        
        btnCancel.setTitle("cancel".localized(), for: .normal)
        
        lblErrorEmail.text = "invalid_email".localized()
        lblErrorName.text = "invalid_fullname".localized()
        
        _ = collectBrand.map({
            $0.text = $0.accessibilityIdentifier?.localized()
        })
        
        if let cus = customer {
            if let avaStr = cus.avatar {
                if let dataDecoded : Data = Data(base64Encoded: avaStr, options: .ignoreUnknownCharacters) {
                    let decodedimage = UIImage(data: dataDecoded)
                    imvAvatar.image = decodedimage
                    self.avatar = avaStr
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
            imvAvatar.image = image.resizeImageWith(newSize: CGSize(width: 100, height: 100))
            picker.dismiss(animated: true, completion: nil)
            let imageData:NSData = UIImagePNGRepresentation(image)! as NSData
            let strBase64 = imageData.base64EncodedString(options: .lineLength64Characters)
            self.avatar = strBase64            
        }
    }
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : Any]?) {
        // Whatever you want here
        
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
