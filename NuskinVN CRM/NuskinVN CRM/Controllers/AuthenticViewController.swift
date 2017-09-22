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
    
    private var authenticView:AuthenticView!
    
    var type_:AuthenticType!
    var actionSheet: UIAlertController!
    
    init(type:AuthenticType) {
        super.init(nibName: String(describing: AuthenticView.self), bundle: nil)
        
        type_ = type
    }
    
    override func loadView() {
        authenticView = Bundle.main.loadNibNamed(String(describing: AuthenticView.self), owner: self, options: nil)?.first as! AuthenticView
        authenticView.configView(delegate:self,type:.AUTH_RESETPW)
        self.view = authenticView
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // should call change text all view here
    override func configText() {
        authenticView.configText()
    }
}

extension AuthenticViewController {
    
    func AuthenticViewDidProcessEvent(view: AuthenticView) {
        print("Get event from AuthenticView");
        let uinaviVC = UINavigationController.init(rootViewController: DashboardViewController())
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        UIView.transition(with: appdelegate.window!, duration: 0.5, options: .transitionCrossDissolve, animations: {
            appdelegate.window?.rootViewController = uinaviVC
            appdelegate.window?.makeKeyAndVisible()
        }, completion: nil)
    }
}
