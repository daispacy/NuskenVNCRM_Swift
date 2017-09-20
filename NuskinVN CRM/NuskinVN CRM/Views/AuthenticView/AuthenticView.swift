//
//  AuthenticView.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 9/20/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import UIKit

enum AuthenticType {
    case AUTH_LOGIN
    case AUTH_RESETPW
}

protocol AuthenticViewDelegate: class {
    func AuthenticViewDidProcessEvent(view:AuthenticView,object:Any)
}

class AuthenticView: UIView {
    
    @IBOutlet fileprivate var scrollVIew: UIScrollView!
    @IBOutlet fileprivate var stckView: UIStackView!
    @IBOutlet fileprivate var txtVNID: UITextField!
    @IBOutlet fileprivate var txtEmail: UITextField!
    @IBOutlet fileprivate var txtPassword: UITextField!
    @IBOutlet fileprivate var btnRemember: UIButton!
    @IBOutlet fileprivate var btnProcess: UIButton!
    
    // MARK: - Properties
    
    weak fileprivate var delegate_: AuthenticViewDelegate?
    var type_: AuthenticType!
    
    // MARK: - INIT
    
    init(delegate:AuthenticViewDelegate? = nil, type:AuthenticType = .AUTH_LOGIN) {
        
        super.init(frame:CGRect.zero)
        
        let view = loadFromXib()
        // only assign variable after here
        view.frame = bounds
        
        view.delegate_ = delegate
        view.type_ = type
        
        addSubview(view)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func loadFromXib() -> AuthenticView
    {
        return Bundle.main.loadNibNamed(String(describing: AuthenticView.self), owner: self, options: nil)?.first as! AuthenticView
    }
    

    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    // MARK: - BUTTON EVENT
    
    @IBAction fileprivate func processAction(_ sender: UIButton) {
        delegate_?.AuthenticViewDidProcessEvent(view: self, object:["lon":"chim"])
    }
}

extension AuthenticView {
    
}
