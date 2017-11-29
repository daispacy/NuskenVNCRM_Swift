//
//  AuthenticViewController.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 9/20/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import UIKit
import Localize_Swift

class AuthenticViewController:RootViewController, AuthenticViewDelegate {
    
    fileprivate var authenticView:AuthenticView!
    
    var type_:AuthenticType!
    var actionSheet: UIAlertController!
    
    init(type:AuthenticType) {
        super.init(nibName: String(describing: AuthenticView.self), bundle: nil)
        
        type_ = type
    }
    
    override func loadView() {
        authenticView = Bundle.main.loadNibNamed(String(describing: AuthenticView.self), owner: self, options: nil)?.first as! AuthenticView
        authenticView.configView(delegate:self,type:type_)
        self.view = authenticView
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // should call change text all view here
    override func configText() {
        authenticView.configText()
    }
}

extension AuthenticViewController {
    
    func AuthenticViewDidBackLogin(view: AuthenticView) {
        self.type_ = .AUTH_LOGIN
        changeStateView()
    }
    
    func AuthenticViewDidProcessEvent(view: AuthenticView, isGotoReset: Bool) {
        
        if(isGotoReset) {
            self.type_ = .AUTH_RESETPW
            changeStateView()
        } else {
            authenticView.btnProcess.startAnimation(activityIndicatorStyle: .gray)
            if(self.type_ == .AUTH_RESETPW) {
                // involke api reset password
                SyncService.shared.reset(email: authenticView.email!, username: authenticView.vnid!, onDone: { [weak self] in
                    if let _self = self {
                        _self.authenticView.btnProcess.stopAnimation()
                        let test = CustomAlertController(nibName: String(describing: CustomAlertController.self), bundle: Bundle.main)
                        _self.present(test, animated: false, completion: {done in
                            let paragraph = NSMutableParagraphStyle()
                            paragraph.lineSpacing = 7
                            paragraph.alignment = .center
                            
                            //total ones
                            let attributedFirst = NSMutableAttributedString(string:"\("link_password_has_send_to_email".localized())\n", attributes: [NSFontAttributeName:UIFont(name: Theme.font.normal, size: Theme.fontSize.normal)!,NSParagraphStyleAttributeName:paragraph])
                            let attributedMain = NSMutableAttributedString(string: "\(_self.authenticView.email!)\n", attributes: [NSFontAttributeName:UIFont(name: Theme.font.bold, size: Theme.fontSize.normal)!,NSForegroundColorAttributeName:UIColor.darkGray,NSParagraphStyleAttributeName:paragraph])
                            let attributeLast = NSMutableAttributedString(string:"\("plese_check_email_and_change_password".localized())\n", attributes: [NSFontAttributeName:UIFont(name: Theme.font.normal, size: Theme.fontSize.normal)!,NSParagraphStyleAttributeName:paragraph])
                            attributedFirst.append(attributedMain)
                            attributedFirst.append(attributeLast)
                            test.message(attribute: attributedFirst, buttons: ["ok".localized().uppercased()], select: { i in
                                _self.type_ = .AUTH_LOGIN
                                _self.changeStateView()
                            })
                        })
                    }
                }, onFail: {[weak self] msg in
                    if let _self = self {
                        _self.authenticView.btnProcess.stopAnimation()
                        let test = CustomAlertController(nibName: "CustomAlertController", bundle: Bundle.main)
                        _self.present(test, animated: false, completion: {done in
                            test.message(message: msg, buttons: ["ok".localized().uppercased()], select: {
                                i in
                                print("item select \(i)")
                            })
                        })
                    }
                })
                
            } else if(self.type_ == .AUTH_LOGIN){
                // involke api login
                SyncService.shared.login(email: nil, username: authenticView.vnid, password: authenticView.password!, completion: {
                    [weak self] result in
                    if let _self = self {
                        switch result {
                        case .success(_):
//                            _self.authenticView.btnProcess.stopAnimation()
//                            let vc = SyncDataController(nibName: "SyncDataController", bundle: Bundle.main) as SyncDataController
                            AppConfig.navigation.changeRootControllerTo(viewcontroller: LaunchController(nibName: "LaunchController", bundle: Bundle.main))
//                            AppConfig.navigation.gotoDashboardAfterSigninSuccess()
                        case .failure(_):
                            _self.authenticView.btnProcess.stopAnimation()
                            let test = CustomAlertController(nibName: String(describing: CustomAlertController.self), bundle: Bundle.main)
                            _self.present(test, animated: false, completion: {done in
                                test.message(message: "msg_login_failed_or_user_invalid".localized(), buttons: ["ok".localized().uppercased()], select: {
                                    i in
                                    print("item select \(i)")
                                })
                            })
                        }
                    }
                })
            }
            
            //            let uinaviVC = UINavigationController.init(rootViewController: DashboardViewController())
            //
            //            UIView.transition(with: appdelegate.window!, duration: 0.5, options: .overrideInheritedCurve, animations: {
            //                appdelegate.window?.rootViewController = uinaviVC
            //                appdelegate.window?.makeKeyAndVisible()
            //            }, completion: nil)
            
        }
        
        
        
        //        let test = CalendarViewController(nibName: "CalendarViewController", bundle: Bundle.main)
        //        present(test, animated: false, completion: nil)
        
    }
    
    func test(object:KxMenuItem){
        print("\(object.title)")
    }
    
    private func changeStateView() {
        UIView.transition(with: self.authenticView, duration: 0.2, options: .transitionCrossDissolve, animations: {
            self.authenticView.configView(delegate: self, type: self.type_)
        }, completion: {done in
            self.authenticView.configView(delegate: self, type: self.type_)
        })
    }
}
