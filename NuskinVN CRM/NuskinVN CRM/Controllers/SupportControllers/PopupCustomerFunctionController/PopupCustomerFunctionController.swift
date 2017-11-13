//
//  PopupController.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 10/2/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import UIKit

class PopupCustomerFunctionController: UIViewController {

    var startAnimation:(()->Void)?
    var ondeinitial:(() -> Void)?
    var onSelect:((String,Int) -> Void)?
    var onSelectObject:((JSON) -> Void)?
    var onDismiss:(() -> Void)?
    
    let functionView = Bundle.main.loadNibNamed("FunctionStackViewCustomer", owner: self, options: [:])?.first as! FunctionStackViewCustomer
    let customerBlock = Bundle.main.loadNibNamed("CustomerBlockView", owner: self, options: [:])?.first as! CustomerBlockView
    @IBOutlet var vwOverlay: UIView!
    var tapGesture:UITapGestureRecognizer!
    var hostView: UIView?
    
    var involkeEmailView:((CustomerDO)->Void)?
    var needReloadData:(()->Void)?
    
    var object:CustomerDO?
    var is30:Bool = false
    
    let maxHeight:CGFloat = 250
    
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

        // Do any additional setup after loading the view.
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dissMissView))
        vwOverlay.addGestureRecognizer(tapGesture)
        
        // prevent sync data while working with order
        LocalService.shared.isShouldSyncData = {[weak self] in
            if let _ = self {
                return false
            }
            return true
        }
        
        customerBlock.needReloadData = {
            [weak self] in
            guard let _self = self else {return}
            _self.dissMissView()
            _self.needReloadData?()
        }
    }
   
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        functionView.transform = CGAffineTransform(scaleX: 0, y: 0.5)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: [], animations: {
            self.functionView.transform = .identity // get back to original scale in an animated way
        }, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        LocalService.shared.isShouldSyncData = nil
    }
    
    deinit {
        vwOverlay.removeGestureRecognizer(tapGesture)
        print("deinit PopupCustomerFunctionController")
        self.ondeinitial?()
    }
    
//    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
//
//    }
    
    // MARK:  - INTERFACE
    func show(_ customer:CustomerDO, is30:Bool = false) {
        object = customer
        
        self.is30 = is30
        
        addTableView()
        self.view.layoutIfNeeded()
        
    }
    
    
    
    // MARK: - PRIVATE
    func addTableView() {
        
        guard let data = object else { return }
        
        customerBlock.showInfoCustomer(customer: data,self.is30)
        
        var listFunction:[JSON] = [] // default is order
        
        if AppConfig.deeplink.facebook().characters.count > 0 {
            if data.facebook.characters.count > 0 {
                listFunction.append(["tag":5,"img":"ic_facebook_gradient_48"])
            }
        }
        
        if let tel = data.tel {
            if tel.characters.count > 0 {
                listFunction.append(["tag":4,"img":"ic_phone_gradient_48"])
            }
        }
        
        if let tel = data.tel {
            if tel.characters.count > 0 {
                listFunction.append(["tag":9,"img":"ic_sms_72"])
            }
        }
        
        if let email = data.email {
            if email.characters.count > 0 {
                listFunction.append(["tag":7,"img":"ic_email_gradient"])
            }
        }
        
        if AppConfig.deeplink.skype().characters.count > 0 {
            if data.skype.characters.count > 0 {
                listFunction.append(["tag":3,"img":"ic_skype_gradient_72"])
            }
        }
        
        if AppConfig.deeplink.viber().characters.count > 0 {
            if data.viber.characters.count > 0 {
                listFunction.append(["tag":2,"img":"ic_viber_gradient_72"])
            }
        }
        
        if AppConfig.deeplink.zalo().characters.count > 0 {
            if data.zalo.characters.count > 0 {
                listFunction.append(["tag":6,"img":"ic_zalo_128"])
            }
        }
        
        
        functionView.loadListFunction(json: listFunction)
        functionView.onSelectFunction = {[weak self]
            identifier in
            guard let _self = self else {return}
            
            if identifier == 5/*"facebook"*/ {
                _self.openDeepLink(link: AppConfig.deeplink.facebook().replacingOccurrences(of: "[|id|]", with: data.facebook), linkItunes: AppConfig.deeplink.facebookLinkItunes())
            } else if identifier == 3/*"skype"*/ {
                _self.openDeepLink(link: AppConfig.deeplink.skype().replacingOccurrences(of: "[|id|]", with: data.skype), linkItunes: AppConfig.deeplink.skypeLinkItunes())
            } else if identifier == 2/*"viber"*/ {
                _self.openDeepLink(link: AppConfig.deeplink.viber().replacingOccurrences(of: "[|id|]", with: data.viber), linkItunes: AppConfig.deeplink.viberLinkItunes())
            } else if identifier == 4/*"tel"*/ {
                guard let number = URL(string: "tel://" + data.tel!) else { return }
                UIApplication.shared.open(number)
            } else if identifier == 6/*"zalo"*/ {
                _self.openDeepLink(link: AppConfig.deeplink.zalo().replacingOccurrences(of: "[|id|]", with: data.zalo), linkItunes: AppConfig.deeplink.zaloLinkItunes())
            } else if identifier == 7/*"send email"*/ {
                _self.dissMissView()
                _self.involkeEmailView?(data)
            }  else if identifier == 9/*"sms"*/ {
                guard let number = URL(string: "sms:" + data.tel!) else { return }
                UIApplication.shared.open(number)
            }
        }
        let uistackView = UIStackView(frame: CGRect.zero)
        uistackView.axis = .vertical
        uistackView.spacing = 5
        uistackView.addArrangedSubview(customerBlock)
        uistackView.addArrangedSubview(functionView)
        view.addSubview(uistackView)
        uistackView.translatesAutoresizingMaskIntoConstraints = false
        uistackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        uistackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        view.bottomAnchor.constraint(equalTo: uistackView.bottomAnchor, constant: 104).isActive = true
    }
    
    func openDeepLink(link:String, linkItunes:String) {
        if let url = URL(string:link) {
            let installed = UIApplication.shared.canOpenURL(url)
            if installed {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                if let urlLink = URL(string: linkItunes) {
                    if UIApplication.shared.canOpenURL(urlLink) {
                        UIApplication.shared.open(urlLink, options: [:], completionHandler: nil)
                    }
                }
            }
        }
    }
    
    func dissMissView () {
        onDismiss?()
        dismiss(animated: false, completion: nil)
    }
}
