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
    
    func AuthenticViewDidProcessEvent(view: AuthenticView, isGotoReset: Bool) {
        
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        
        if(isGotoReset) {
            self.type_ = .AUTH_RESETPW
        } else {
            
            if(self.type_ == .AUTH_RESETPW) {
                // involke api reset password
                
            } else if(self.type_ == .AUTH_LOGIN){
                // involke api login
                
            }
            if(self.type_ == .AUTH_LOGIN) {
                return
            }
            self.type_ = .AUTH_LOGIN
            
            
            let uinaviVC = UINavigationController.init(rootViewController: DashboardViewController())
            
            UIView.transition(with: appdelegate.window!, duration: 0.5, options: .overrideInheritedCurve, animations: {
                appdelegate.window?.rootViewController = uinaviVC
                appdelegate.window?.makeKeyAndVisible()
            }, completion: nil)
            
        }                
        
        changeStateView()
        
        //        let test = CustomAlertController(nibName: String(describing: CustomAlertController.self), bundle: Bundle.main)
        //        self.present(test, animated: false, completion: nil)
        //        test.message(message: "msg_test".localized(), buttons: ["ok".localized()], select: {
        //            i in
        //            print("item select \(i)")
        //        })
    }
    
    func test(object:KxMenuItem){
        print("\(object.title)")
    }
    
    private func changeStateView() {
        UIView.transition(with: self.authenticView, duration: 0.2, options: .transitionCrossDissolve, animations: {
            self.authenticView.configView(delegate: self, type: self.type_)
        }, completion: nil)
    }
}
