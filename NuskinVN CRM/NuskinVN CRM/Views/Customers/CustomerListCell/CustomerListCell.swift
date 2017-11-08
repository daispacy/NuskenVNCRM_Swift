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
    
    var onSelectCustomer:((CustomerDO, Bool) -> Void)?
    var onEditCustomer:((CustomerDO) -> Void)?
    var gotoOrderList:((CustomerDO)->Void)?
    var involkeEmailView:((CustomerDO)->Void)?
    
    var isEdit:Bool = false
    var object:CustomerDO?
    var isSelect:Bool = false
    var isChecked:Bool = false
    var disposeBag = DisposeBag()
    
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
            var listFunction:[JSON] = [["tag":8,"img":"ic_dashboard_gradient_72"],["tag":1,"img":"ic_order_list_gradient_72"]] // default is order
            if let obj = self.object {
                if AppConfig.deeplink.facebook().characters.count > 0 {
                    if obj.facebook.characters.count > 0 {
                        listFunction.append(["tag":5,"img":"ic_facebook_gradient_48"])
                    }
                }
                
                if let tel = obj.tel {
                    if tel.characters.count > 0 {
                        listFunction.append(["tag":4,"img":"ic_phone_gradient_48"])
                    }
                }
                
                if let email = obj.email {
                    if email.characters.count > 0 {
                        listFunction.append(["tag":7,"img":"ic_email_gradient"])
                    }
                }
                
                if AppConfig.deeplink.skype().characters.count > 0 {
                    if obj.skype.characters.count > 0 {
                        listFunction.append(["tag":3,"img":"ic_skype_gradient_72"])
                    }
                }
                
                if AppConfig.deeplink.viber().characters.count > 0 {
                    if obj.viber.characters.count > 0 {
                        listFunction.append(["tag":2,"img":"ic_viber_gradient_72"])
                    }
                }
                
                if AppConfig.deeplink.zalo().characters.count > 0 {
                    if obj.zalo.characters.count > 0 {
                        listFunction.append(["tag":6,"img":"ic_zalo_72"])
                    }
                }
                
            }
            let topVC = Support.topVC!
            functionView.loadListFunction(json: listFunction)
            functionView.onSelectFunction = {[weak self]
                identifier in
                guard let _self = self else {return}
                guard let obj = self?.object else {return}
                print("open \(identifier)")
                if identifier == 5/*"facebook"*/ {
                    _self.openDeepLink(link: AppConfig.deeplink.facebook().replacingOccurrences(of: "[|id|]", with: obj.facebook), linkItunes: AppConfig.deeplink.facebookLinkItunes())
                } else if identifier == 3/*"skype"*/ {
                    _self.openDeepLink(link: AppConfig.deeplink.skype().replacingOccurrences(of: "[|id|]", with: obj.skype), linkItunes: AppConfig.deeplink.skypeLinkItunes())
                } else if identifier == 2/*"viber"*/ {
                    _self.openDeepLink(link: AppConfig.deeplink.viber().replacingOccurrences(of: "[|id|]", with: obj.viber), linkItunes: AppConfig.deeplink.viberLinkItunes())
                } else if identifier == 4/*"tel"*/ {
                    guard let number = URL(string: "tel://" + obj.tel!) else { return }
                    UIApplication.shared.open(number)
                } else if identifier == 6/*"zalo"*/ {
                    _self.openDeepLink(link: AppConfig.deeplink.zalo().replacingOccurrences(of: "[|id|]", with: obj.zalo), linkItunes: AppConfig.deeplink.zaloLinkItunes())
                } else if identifier == 1/*"order list"*/ {
                    _self.gotoOrderList?(obj)
                } else if identifier == 7/*"send email"*/ {
                    _self.involkeEmailView?(obj)
                } else if identifier == 8/*"dashboard"*/ {
                    let vc = DashboardCustomerController(nibName: "DashboardCustomerController", bundle: Bundle.main)
                    vc.customer = obj
                    topVC.present(vc, animated: true, completion: nil)
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
    func show(customer:CustomerDO, isEdit:Bool,isSelect:Bool, isChecked:Bool) {
        object = customer
        
        self.isEdit = isEdit
        self.isSelect = isSelect
        self.isChecked = isChecked
        configView()
        
        lblName.text = customer.fullname
       
        let cus = customer
        if let avaStr = cus.avatar {
            if let urlAvatar = cus.urlAvatar {
                if avaStr.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines).characters.count > 0 {
                    if avaStr.contains(".jpg") || avaStr.contains(".png"){
                        imgAvatar.loadImageUsingCacheWithURLString(urlAvatar, placeHolder: nil)
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
