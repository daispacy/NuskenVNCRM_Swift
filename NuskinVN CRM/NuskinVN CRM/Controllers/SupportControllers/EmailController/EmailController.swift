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

// MARK: - EmailController
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
    @IBOutlet weak var btnAttach: CButtonAlert!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var vwcontrol: UIView!
    @IBOutlet weak var stackAttach: UIStackView!
    @IBOutlet weak var vwAttach: UIView!
    @IBOutlet weak var vwFromEmail: UIView!
    
    let disposeBag = DisposeBag()
    
    var onDismissComplete:(()->Void)?
    var tapGesture:UITapGestureRecognizer!
    var shouldHideButtonAttach:Bool = false
    
    var listAttachs:[String] = []
    var listSize:[Int] = []
    
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
        reloadAttach()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.onDismissComplete?()
    }
    
    // MARK: - interface
    func show(from:String, to:String) {
        txtFrom.text = from
        txtTo.text = to
        if from.characters.count == 0 {
            vwFromEmail.isHidden = true
            txtTo.isEnabled = false
        }
        guard let user = UserManager.currentUser() else { return }
        if let name = user.fullname {
            txtFromName.text = name
        }
    }
    
    func reloadAttach() {
        _ = stackAttach.arrangedSubviews.map{$0.removeFromSuperview()}
        shouldHideButtonAttach = listAttachs.count > 4
        btnAttach.isHidden = shouldHideButtonAttach
        vwAttach.isHidden = listAttachs.count == 0
        _ = listAttachs.map ({
            let view = Bundle.main.loadNibNamed("EmailAttachView", owner: self, options: [:])?.first as! EmailAttachView
            view.onRemoveAttach = {[weak self] attach in
                guard let _self = self else {return}
                var i = 0
                for item in _self.listAttachs {
                    if item == attach {
                        break
                    }
                    i += 1
                }
                _self.listAttachs.remove(at:i)
                _self.listSize.remove(at:i)
                _self.reloadAttach()
            }
            
            stackAttach.addArrangedSubview(view)
            view.loadAttach(attach: $0)
        })
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
        
        btnAttach.rx.tap
            .subscribe(onNext:{ [weak self] in
                guard let _self = self else {return}
                _self.showSelectGetPhotos()
            }).addDisposableTo(disposeBag)
        
        btnFirst.rx.tap
            .subscribe(onNext:{ [weak self] in
                guard let _self = self else {return}
                if !_self.validateData() {
                    Support.popup.showAlert(message: "subject_or_body_invalid".localized(), buttons: ["ok".localized()], vc: _self, onAction: {index in
                        
                    },nil)
                    return
                }
                _self.btnFirst.startAnimation(activityIndicatorStyle: .white)
                _self.btnSecond.isHidden = true
                _self.btnAttach.isHidden = true
                // send
                SyncService.shared.sendEmail(fullname: _self.txtFromName.text!, from: _self.txtFrom.text!, to: _self.txtTo.text!, subject: _self.txtSubject.text!, body: _self.txtBody.text!, attachs:_self.listAttachs, completion: { (msg) in
                    _self.btnFirst.stopAnimation()
                    if msg.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).characters.count > 0 {
                        Support.popup.showAlert(message: "send_email_failed".localized(), buttons: ["ok".localized()], vc: _self, onAction: {index in                            
                            _self.btnSecond.isHidden = false
                            if !_self.shouldHideButtonAttach {
                                _self.btnAttach.isHidden = false
                            }
                        },nil)
                    } else {
                        Support.popup.showAlert(message: "send_email_success".localized(), buttons: ["ok".localized()], vc: _self, onAction: {index in
                            _self.onDismissComplete?()
                            _self.btnSecond.isHidden = false
                            if !_self.shouldHideButtonAttach {
                                _self.btnAttach.isHidden = false
                            }
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
        
        btnAttach.backgroundColor = UIColor(_gradient: Theme.colorGradient, frame: btnSecond.frame, isReverse:true)
        btnAttach.setTitleColor(UIColor(hex:Theme.colorAlertButtonTitleColor), for: .normal)
        btnAttach.titleLabel?.font = UIFont(name: Theme.font.bold, size: Theme.fontSize.normal)
        
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
        btnAttach.setTitle("attach_file".localized(), for: .normal)
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

extension EmailController:UINavigationControllerDelegate,UIImagePickerControllerDelegate {
    
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let maxSize = 1024*1024*2
        var totalSize = 0
        _ = listSize.map {totalSize += $0}
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let ratio = (image.size.height/image.size.width)
            let imgScale = image.resizeImageWith(newSize: CGSize(width: image.size.width > 728 ? 728 : image.size.width, height: image.size.height > 728*ratio ? 728*ratio : image.size.height))
            picker.dismiss(animated: true, completion: nil)
            let imageData:NSData = UIImageJPEGRepresentation(imgScale, 0.5)! as NSData
            let strBase64 = imageData.base64EncodedString(options: .lineLength64Characters)
            if (listAttachs.filter{$0 == strBase64}).count > 0 {
                Support.popup.showAlert(message: "photo_has_choosed".localized(), buttons: ["ok".localized()], vc: self, onAction: {index in
                    
                },nil)
                return
            }
            
            if totalSize >= maxSize {
                Support.popup.showAlert(message: "max_size_attach_2MB".localized(), buttons: ["ok".localized()], vc: self, onAction: {index in
                    
                },nil)
                return
            }
            
            listSize.append(imageData.length)
            listAttachs.append(strBase64)
            reloadAttach()
        }
        print("START SYNC DATA WHEN UIImagePickerController CLOSED")
//        LocalService.shared.startSyncData()
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("START SYNC DATA WHEN UIImagePickerController CLOSED")
//        LocalService.shared.startSyncData()
        picker.dismiss(animated: true) {
            
        }
    }
}

// MARK: - EmailAttachView
class EmailAttachView: UIView {
    
    // MARK: - Closures
    var onRemoveAttach:((String)->Void)?
    
    // MARK: - properties
    @IBOutlet weak var btnRemove: UIButton!
    @IBOutlet weak var imgAttach: UIImageView!
    
    var attach:String?
    
    // MARK: - INIT
    override func awakeFromNib() {
        super.awakeFromNib()
        self.translatesAutoresizingMaskIntoConstraints = false
        let width:NSLayoutConstraint = self.widthAnchor.constraint(equalToConstant: 60)
        let height:NSLayoutConstraint = self.heightAnchor.constraint(equalToConstant: 60)
        self.addConstraints([width,height])
    }
    
    // MARK: - event
    @IBAction func processRemove(_ sender: Any) {
        guard let att = self.attach else { return }
        self.onRemoveAttach?(att)
    }
    
    // MARK: - interface
    func loadAttach(attach:String) {
        self.attach = attach
        if let imgStr = self.attach {
            if let dataDecoded : Data = Data(base64Encoded: imgStr, options: .ignoreUnknownCharacters) {
                let decodedimage = UIImage(data: dataDecoded)
                imgAttach.image = decodedimage
            }
        }
    }
}
