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
    var gotoOrderList:((Customer)->Void)?
    var onDismiss:(() -> Void)?
    
    let functionView = Bundle.main.loadNibNamed("FunctionStackViewCustomer", owner: self, options: [:])?.first as! FunctionStackViewCustomer
    let customerBlock = Bundle.main.loadNibNamed("CustomerBlockView", owner: self, options: [:])?.first as! CustomerBlockView
    @IBOutlet var vwOverlay: UIView!
    var tapGesture:UITapGestureRecognizer!
    var hostView: UIView?
    
    var involkeEmailView:((Customer)->Void)?
    var needReloadData:(()->Void)?
    
    var object:Customer?
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
        }, completion: {[weak self] bool in
            Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false, block: {timer in
                timer.invalidate()
                guard let _self = self else {return}
                _self.startTutorial()
            })
        })
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
    func show(_ customer:Customer, is30:Bool = false) {
        object = customer
        
        self.is30 = is30
        
        addTableView()
        self.view.layoutIfNeeded()
    }
    
    
    
    // MARK: - PRIVATE
    func addTableView() {
        
        guard let data = object else { return }
        
        customerBlock.showInfoCustomer(customer: data,self.is30)
        
        var listFunction:[JSON] = [["tag":Int(FUNCTION_ORDER)!,"img":"ic_order_list_gradient_72"]] // default is order
        
        if AppConfig.deeplink.facebook().characters.count > 0 {
            if data.facebook.characters.count > 0 {
                listFunction.append(["tag":Int(FUNCTION_FACEBOOK)!,"img":"ic_facebook_gradient_48"])
            }
        }
        
            if data.tel.characters.count > 0 {
                listFunction.append(["tag":Int(FUNCTION_CALL)!,"img":"ic_phone_gradient_48"])
                listFunction.append(["tag":Int(FUNCTION_SMS)!,"img":"ic_sms_72"])
            }
        
            if data.email.characters.count > 0 {
                listFunction.append(["tag":Int(FUNCTION_EMAIL)!,"img":"ic_email_gradient"])
            }
        
        if AppConfig.deeplink.skype().characters.count > 0 {
            if data.skype.characters.count > 0 {
                listFunction.append(["tag":Int(FUNCTION_SKYPE)!,"img":"ic_skype_gradient_72"])
            }
        }
        
        if AppConfig.deeplink.viber().characters.count > 0 {
            if data.viber.characters.count > 0 {
                listFunction.append(["tag":Int(FUNCTION_VIBER)!,"img":"ic_viber_gradient_72"])
            }
        }
        
        if AppConfig.deeplink.zalo().characters.count > 0 {
            if data.zalo.characters.count > 0 {
                listFunction.append(["tag":Int(FUNCTION_ZALO)!,"img":"ic_zalo_128"])
            }
        }
        
        
        functionView.loadListFunction(json: listFunction)
        functionView.onSelectFunction = {[weak self]
            identifier in
            guard let _self = self else {return}
            
            if identifier == Int(FUNCTION_FACEBOOK)!/*"facebook"*/ {
                _self.openDeepLink(link: AppConfig.deeplink.facebook().replacingOccurrences(of: "[|id|]", with: data.facebook), linkItunes: AppConfig.deeplink.facebookLinkItunes())
            } else if identifier == Int(FUNCTION_SKYPE)!/*"skype"*/ {
                _self.openDeepLink(link: AppConfig.deeplink.skype().replacingOccurrences(of: "[|id|]", with: data.skype), linkItunes: AppConfig.deeplink.skypeLinkItunes())
            } else if identifier == Int(FUNCTION_VIBER)!/*"viber"*/ {
                _self.openDeepLink(link: AppConfig.deeplink.viber().replacingOccurrences(of: "[|id|]", with: data.viber), linkItunes: AppConfig.deeplink.viberLinkItunes())
            } else if identifier == Int(FUNCTION_CALL)!/*"tel"*/ {
                guard let number = URL(string: "tel://" + data.tel) else { return }
                UIApplication.shared.open(number)
            } else if identifier == Int(FUNCTION_ZALO)!/*"zalo"*/ {
                _self.openDeepLink(link: AppConfig.deeplink.zalo().replacingOccurrences(of: "[|id|]", with: data.zalo), linkItunes: AppConfig.deeplink.zaloLinkItunes())
            } else if identifier == Int(FUNCTION_EMAIL)!/*"send email"*/ {
                _self.dissMissView()
                _self.involkeEmailView?(data)
            }  else if identifier == Int(FUNCTION_SMS)!/*"sms"*/ {
                guard let number = URL(string: "sms:" + data.tel) else { return }
                UIApplication.shared.open(number)
            } else if identifier == 1/*"order list"*/ {
                _self.dissMissView()
                _self.gotoOrderList?(data)
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

// MARK: - ShowCase
extension PopupCustomerFunctionController: MaterialShowcaseDelegate {
    
    func checkNextTutorial() {
        self.functionView.startTutorial()
    }
    
    // MARK: - init showcase
    func startTutorial(_ step:Int = 1) {
        // showcase
        if AppConfig.setting.isShowTutorial(with: POPUP_FUNCTION_SCENE) {
            checkNextTutorial()
            return
        }
        
        configShowcase(MaterialShowcase(), step) { showcase, shouldShow in
            if shouldShow {
                showcase.delegate = self
                showcase.show(completion: nil)
            }
        }
    }
    
    func configShowcase(_ showcase:MaterialShowcase,_ step:Int = 1,_ shouldShow:((MaterialShowcase,Bool)->Void)) {
        if step == 1 {
            showcase.setTargetView(view: customerBlock.lblBirthday)
            showcase.primaryText = ""
            showcase.identifier = LAST_DATE_CUSTOMER_ORDERED
            showcase.secondaryText = "last_date_customer_order".localized()
            shouldShow(showcase,true)
        } else if step == 2 {
            showcase.setTargetView(view: customerBlock.vwStatus)
            showcase.primaryText = ""
            showcase.identifier = STATUS_MARK_REMINDER_CUSTOMER
            showcase.secondaryText = "status_mark_reminder_customer".localized()
            shouldShow(showcase,true)
        } else if step == 3 {
            showcase.setTargetView(view: customerBlock.btnCheckCongrat)
            showcase.primaryText = ""
            showcase.identifier = MARK_REMINDERED_CUSTOMER
            showcase.secondaryText = "mark_reminder_customer".localized()
            shouldShow(showcase,true)
        } else {
            shouldShow(showcase,false)
            if step > 3 {
                AppConfig.setting.setFinishShowcase(key: POPUP_FUNCTION_SCENE)
                checkNextTutorial()
            }
        }
    }
    
    // MARK: - showcase delegate
    //    func showCaseWillDismiss(showcase: MaterialShowcase) {
    //        print("Showcase \(showcase.identifier) will dismiss.")
    //    }
    func showCaseDidDismiss(showcase: MaterialShowcase) {
        if let step = showcase.identifier {
            if let s = Int(step) {
                let ss = s + 1
                startTutorial(ss)
            }
        }
        
    }
}
