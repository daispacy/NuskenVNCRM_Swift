//
//  AuthenticViewController.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 9/20/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import UIKit

class AuthenticViewController:UIViewController, AuthenticViewDelegate {
    
    private var authenticView:AuthenticView!
    
    var type_:AuthenticType!
    
    
    init(type:AuthenticType) {
        super.init(nibName: String(describing: AuthenticView.self), bundle: nil)
        
        type_ = type
    }
    
    override func loadView() {
        authenticView = AuthenticView.init(delegate: self, type: type_) 
        self.view = authenticView
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}

extension AuthenticViewController {
    
    func AuthenticViewDidProcessEvent(view: AuthenticView, object: Any) {
        print("\(object)");
        /* fb
         "https://m.me/daiphamit"
         "fb-messenger://user-thread/thuyduongle"
         */
        
        guard let url = URL(string: "zalo://user-thread/0938388208") else {
            return //be safe
        }
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
}
