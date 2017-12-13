//
//  CustomerListCell.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 10/5/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import CoreData

class CustomerListCell: UITableViewCell {
    
    @IBOutlet var imgAvatar: CImageViewRoundGradient!
    @IBOutlet var lblName: UILabel!
    @IBOutlet var btnEdit: UIButton!
    @IBOutlet var stackViewContainer: UIStackView!
    
    var onSelectCustomer:((Customer, Bool) -> Void)?
    var onEditCustomer:((Customer) -> Void)?
    var gotoOrderList:((Customer)->Void)?
    var involkeEmailView:((Customer)->Void)?
    
    var isEdit:Bool = false
    var object:Customer?
    var isSelect:Bool = false
    var isChecked:Bool = false
    var disposeBag = DisposeBag()
    var isRemoveFunctionRelateToOrder:Bool = false
    
    // MARK: - init
    override func awakeFromNib() {
        super.awakeFromNib()
        isSelect = false
        isEdit = false
        
        let bgColorView = UIView()
        let btLine = UIView()
        bgColorView.addSubview(btLine)
        btLine.backgroundColor = UIColor(hex:"0xEBEBF1")
        btLine.translatesAutoresizingMaskIntoConstraints = false
        btLine.heightAnchor.constraint(equalToConstant: 1).isActive = true
        btLine.leadingAnchor.constraint(equalTo: bgColorView.leadingAnchor, constant: 40).isActive = true
        btLine.trailingAnchor.constraint(equalTo: bgColorView.trailingAnchor, constant: 0).isActive = true
        btLine.bottomAnchor.constraint(equalTo: bgColorView.bottomAnchor, constant: 0).isActive = true
        bgColorView.backgroundColor = UIColor.clear
        selectedBackgroundView = bgColorView
        
        btnEdit.rx.tap.subscribe(onNext:{ [weak self] in
            if let _self = self {
                if let obj = _self.object {
                    _self.onEditCustomer?(obj)
                }
            }
        }).addDisposableTo(disposeBag)
    }
    
    // MARK: - private
    func configView() {
        
        backgroundColor = UIColor.white
        selectedBackgroundView?.backgroundColor = backgroundColor
        
        lblName.font = UIFont(name: Theme.font.bold, size: Theme.fontSize.normal)
        lblName.textColor = UIColor(hex:Theme.color.customer.titleGroup)
        
        if isSelect {
            
            let functionView = Bundle.main.loadNibNamed("FunctionStackViewCustomer", owner: self, options: [:])?.first as! FunctionStackViewCustomer
            var listFunction:[JSON] = [["tag":Int(FUNCTION_DASHBOARD)!,"img":"ic_dashboard_gradient_72"],["tag":Int(FUNCTION_ORDER)!,"img":"ic_order_list_gradient_72"]] // default is order
            if let obj = self.object {
                if AppConfig.deeplink.facebook().characters.count > 0 {
                    if obj.facebook.characters.count > 0 {
                        listFunction.append(["tag":Int(FUNCTION_FACEBOOK)!,"img":"ic_facebook_gradient_48"])
                    }
                }
                
                    if obj.tel.characters.count > 0 {
                        listFunction.append(["tag":Int(FUNCTION_CALL)!,"img":"ic_phone_gradient_48"])
                    }
                
                    if obj.tel.characters.count > 0 {
                        listFunction.append(["tag":Int(FUNCTION_SMS)!,"img":"ic_sms_72"])
                    }
                
                    if obj.email.characters.count > 0 {
                        listFunction.append(["tag":Int(FUNCTION_EMAIL)!,"img":"ic_email_gradient"])
                    }
                
                if AppConfig.deeplink.skype().characters.count > 0 {
                    if obj.skype.characters.count > 0 {
                        listFunction.append(["tag":Int(FUNCTION_SKYPE)!,"img":"ic_skype_gradient_72"])
                    }
                }
                
                if AppConfig.deeplink.viber().characters.count > 0 {
                    if obj.viber.characters.count > 0 {
                        listFunction.append(["tag":Int(FUNCTION_VIBER)!,"img":"ic_viber_gradient_72"])
                    }
                }
                
                if AppConfig.deeplink.zalo().characters.count > 0 {
                    if obj.zalo.characters.count > 0 {
                        listFunction.append(["tag":Int(FUNCTION_ZALO)!,"img":"ic_zalo_128"])
                    }
                }
                
                if isRemoveFunctionRelateToOrder {
                    listFunction.remove(at: 1)
                    listFunction.remove(at: 0)
                }
            }
            let topVC = Support.topVC!
            functionView.loadListFunction(json: listFunction)
            functionView.onSelectFunction = {[weak self]
                identifier in
                guard let _self = self else {return}
                guard let obj = self?.object else {return}
                print("open \(identifier)")
                if identifier == Int(FUNCTION_FACEBOOK)!/*"facebook"*/ {
                    _self.openDeepLink(link: AppConfig.deeplink.facebook().replacingOccurrences(of: "[|id|]", with: obj.facebook), linkItunes: AppConfig.deeplink.facebookLinkItunes())
                } else if identifier == Int(FUNCTION_SKYPE)!/*"skype"*/ {
                    _self.openDeepLink(link: AppConfig.deeplink.skype().replacingOccurrences(of: "[|id|]", with: obj.skype), linkItunes: AppConfig.deeplink.skypeLinkItunes())
                } else if identifier == Int(FUNCTION_VIBER)!/*"viber"*/ {
                    _self.openDeepLink(link: AppConfig.deeplink.viber().replacingOccurrences(of: "[|id|]", with: obj.viber), linkItunes: AppConfig.deeplink.viberLinkItunes())
                } else if identifier == Int(FUNCTION_CALL)!/*"tel"*/ {
                    guard let number = URL(string: "tel://" + obj.tel) else { return }
                    UIApplication.shared.open(number)
                } else if identifier == Int(FUNCTION_ZALO)!/*"zalo"*/ {
                    _self.openDeepLink(link: AppConfig.deeplink.zalo().replacingOccurrences(of: "[|id|]", with: obj.zalo), linkItunes: AppConfig.deeplink.zaloLinkItunes())
                } else if identifier == Int(FUNCTION_ORDER)!/*"order list"*/ {
                    _self.gotoOrderList?(obj)
                } else if identifier == Int(FUNCTION_EMAIL)!/*"send email"*/ {
                    _self.involkeEmailView?(obj)
                } else if identifier == Int(FUNCTION_DASHBOARD)!/*"dashboard"*/ {
                    let vc = DashboardCustomerController(nibName: "DashboardCustomerController", bundle: Bundle.main)
                    vc.customer = obj
                    topVC.present(vc, animated: true, completion: nil)
                }  else if identifier == Int(FUNCTION_SMS)!/*"sms"*/ {
                    guard let number = URL(string: "sms:" + obj.tel) else { return }
                    UIApplication.shared.open(number)
                }
            }
            stackViewContainer.insertArrangedSubview(functionView, at: stackViewContainer.arrangedSubviews.count)
        }
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
    
    func removeFunctionView() {
        _ = stackViewContainer.arrangedSubviews.map({
            if $0 .isKind(of: FunctionStackViewCustomer.self) {
                $0.removeFromSuperview()
            }
        })
    }
    
    func configText() {
        
    }
    
    // MARK: - interface
    func show(customer:Customer, isEdit:Bool,isSelect:Bool, isChecked:Bool,_ isRemoveFunctionRelateOrder:Bool = false) {
        object = customer
        self.isRemoveFunctionRelateToOrder = isRemoveFunctionRelateOrder
        self.isEdit = isEdit
        self.isSelect = isSelect
        self.isChecked = isChecked
        configView()
        
        lblName.text = customer.fullname
       
        let cus = customer
        let avaStr = cus.avatar
        if let urlAvatar = cus.urlAvatar {
            if avaStr.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines).characters.count > 0 {
                if avaStr.contains(".jpg") || avaStr.contains(".png"){
                    imgAvatar.loadImageUsingCacheWithURLString(urlAvatar,size:nil, placeHolder: nil)
                } else {
                    if let dataDecoded : Data = Data(base64Encoded: avaStr, options: .ignoreUnknownCharacters) {
                        let decodedimage = UIImage(data: dataDecoded)
                        imgAvatar.image = decodedimage
                    }
                }
            }
        } else {
            if let dataDecoded : Data = Data(base64Encoded: avaStr, options: .ignoreUnknownCharacters) {
                let decodedimage = UIImage(data: dataDecoded)
                imgAvatar.image = decodedimage
            }
        }
        
        
    }
    
    // MARK: - check event
    @IBAction func pressCheck(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        onSelectCustomer?(object!,sender.isSelected)
    }
    
    
    // MARK: - reuse
    override func prepareForReuse() {
        removeFunctionView()
        imgAvatar.image = nil
        isChecked = false
        isSelect = false
        isEdit = false
        configView()
        configText()
        super.prepareForReuse()
    }
}

class FunctionStackViewCustomer: UIView {
    
    @IBOutlet var stackContainer: UIStackView!
    
    var onSelectFunction:((Int)->Void)?
    
    var disposeBag = DisposeBag()
    
    // MARK: - init
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // MARK: - event
    func buttonTouch(_ sender:UIButton) {
        self.onSelectFunction?(sender.tag)
    }
    
    // MARK: - interface
    func loadListFunction(json:[JSON]) {
        if json.count == 0 {return}
        
        for item in json {
            createButton(item: item)
        }
    }
    
    // MARK: - private
    func createButton(item:JSON) {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: item["img"] as! String), for: .normal)
        button.addTarget(self, action: #selector(self.buttonTouch(_:)), for: .touchUpInside)
        stackContainer.insertArrangedSubview(button, at: stackContainer.arrangedSubviews.count)
        button.translatesAutoresizingMaskIntoConstraints = false
        let width = button.widthAnchor.constraint(equalToConstant: 50)
        let height = button.heightAnchor.constraint(equalToConstant: 50)
        width.priority = 750
        height.priority = 750
        button.addConstraints([width,height])
        button.tag = item["tag"] as! Int
    }
}

extension FunctionStackViewCustomer: MaterialShowcaseDelegate {
    
    // MARK: - init showcase
    func startTutorial() {
        checkNextStep(1)
    }
    
    func checkNextStep(_ step:Int = 1) {
        // showcase
        configShowcase(MaterialShowcase(), step) { showcase, shouldShow in
            if shouldShow {
                showcase.delegate = self
                showcase.show(completion: nil)
            }
        }
    }
    
    func configShowcase(_ showcase:MaterialShowcase,_ step:Int = 1,_ shouldShow:((MaterialShowcase,Bool)->Void)) {

        if step > 9 {
            shouldShow(showcase,false)
            return
        }
        
        var btn:UIView? = nil
        
        for item in stackContainer.arrangedSubviews {
            if item.tag == step {
                btn = item
                break
            }
        }
        
        guard let view = btn else {checkNextStep(step+1); return}

        // showcase
        showcase.setTargetView(view: view)
        showcase.primaryText = ""
        if step == 1 && !AppConfig.setting.isShowTutorial(with: DASHBOARD_FUNCTION_SCENE) && view.tag == step {
            showcase.identifier = FUNCTION_DASHBOARD
            showcase.secondaryText = "click_here_show_dashboard_customer".localized()
            shouldShow(showcase,true)
            AppConfig.setting.setFinishShowcase(key: DASHBOARD_FUNCTION_SCENE)
        } else if step == 2 && !AppConfig.setting.isShowTutorial(with: ORDER_FUNCTION_SCENE) && view.tag == step{
            showcase.identifier = FUNCTION_ORDER
            showcase.secondaryText = "click_here_show_list_orders_customer".localized()
            shouldShow(showcase,true)
            AppConfig.setting.setFinishShowcase(key: ORDER_FUNCTION_SCENE)
        } else if step == 3 && !AppConfig.setting.isShowTutorial(with: FACEBOOK_FUNCTION_SCENE) && view.tag == step {
            showcase.identifier = FUNCTION_FACEBOOK
            showcase.secondaryText = "click_here_interact_customer_facebook".localized()
            shouldShow(showcase,true)
            AppConfig.setting.setFinishShowcase(key: FACEBOOK_FUNCTION_SCENE)
        } else if step == 4 && !AppConfig.setting.isShowTutorial(with: CALL_FUNCTION_SCENE) && view.tag == step {
            showcase.identifier = FUNCTION_CALL
            showcase.secondaryText = "click_here_call_customer".localized()
            shouldShow(showcase,true)
            AppConfig.setting.setFinishShowcase(key: CALL_FUNCTION_SCENE)
        } else if step == 5 && !AppConfig.setting.isShowTutorial(with: SMS_FUNCTION_SCENE) && view.tag == step {
            showcase.identifier = FUNCTION_SMS
            showcase.secondaryText = "click_here_sms_customer".localized()
            shouldShow(showcase,true)
            AppConfig.setting.setFinishShowcase(key: SMS_FUNCTION_SCENE)
        } else if step == 6 && !AppConfig.setting.isShowTutorial(with: EMAIL_FUNCTION_SCENE) && view.tag == step {
            showcase.identifier = FUNCTION_EMAIL
            showcase.secondaryText = "click_here_email_customer".localized()
            shouldShow(showcase,true)
            AppConfig.setting.setFinishShowcase(key: EMAIL_FUNCTION_SCENE)
        } else if step == 7 && !AppConfig.setting.isShowTutorial(with: SKYPE_FUNCTION_SCENE) && view.tag == step {
            showcase.identifier = FUNCTION_SKYPE
            showcase.secondaryText = "click_here_interact_customer_skype".localized()
            shouldShow(showcase,true)
            AppConfig.setting.setFinishShowcase(key: SKYPE_FUNCTION_SCENE)
        } else if step == 8 && !AppConfig.setting.isShowTutorial(with: VIBER_FUNCTION_SCENE) && view.tag == step {
            showcase.identifier = FUNCTION_VIBER
            showcase.secondaryText = "click_here_interact_customer_viber".localized()
            shouldShow(showcase,true)
            AppConfig.setting.setFinishShowcase(key: VIBER_FUNCTION_SCENE)
        } else if step == 9 && !AppConfig.setting.isShowTutorial(with: ZALO_FUNCTION_SCENE) && view.tag == step {
            showcase.identifier = FUNCTION_ZALO
            showcase.secondaryText = "click_here_interact_customer_zalo".localized()
            shouldShow(showcase,true)
            AppConfig.setting.setFinishShowcase(key: ZALO_FUNCTION_SCENE)
        } else {
            checkNextStep(step+1)
        }
    }
    
    func showCaseDidDismiss(showcase: MaterialShowcase) {
        if let step = showcase.identifier {
            if let s = Int(step) {
                let ss = s + 1
                checkNextStep(ss)
            }
        }
        
    }
}
