//
//  CustomAlertController.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 9/22/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import UIKit

class CustomAlertController: UIViewController {

    @IBOutlet var lblMessage: UILabel!
    @IBOutlet var btnFirst: CButtonAlert!
    @IBOutlet var btnSecond: CButtonAlert!
    @IBOutlet var vwcontrol: UIView!
    
    private var select_: ((Int) -> Void)?
    
    var tapGesture:UITapGestureRecognizer?
    
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
        
        btnFirst.isHidden = true
        btnSecond.isHidden = true
        
        btnFirst.backgroundColor = UIColor(_gradient: Theme.colorGradient, frame: btnFirst.frame, isReverse:true)
        btnFirst.setTitleColor(UIColor(hex:Theme.colorAlertButtonTitleColor), for: .normal)
        btnFirst.titleLabel?.font = UIFont(name: Theme.font.normal, size: Theme.fontSize.normal)
        
        btnSecond.backgroundColor = UIColor(_gradient: Theme.colorGradient, frame: btnSecond.frame, isReverse:true)
        btnSecond.setTitleColor(UIColor(hex:Theme.colorAlertButtonTitleColor), for: .normal)
        btnSecond.titleLabel?.font = UIFont(name: Theme.font.normal, size: Theme.fontSize.normal)
    
        lblMessage.textColor = UIColor(hex:Theme.colorAlertTextNormal)
        lblMessage.font = UIFont(name: Theme.font.normal, size: Theme.fontSize.normal)
        
        vwcontrol.layer.cornerRadius = 10;
        vwcontrol.clipsToBounds      = true;
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if(tapGesture != nil) {
            self.view.removeGestureRecognizer(tapGesture!)
        }
    }
    
    deinit {
        print("\(String(describing: CustomAlertController.self)) dealloc")
    }
    
    // MARK: - INTERFACE
    func message(message:String? = "", buttons:Array<String>? = nil,select: @escaping (Int) -> Void) {
        select_ = select
        
        // setup button
        if(buttons != nil) {
            showButton(buttons!)
        } else {
            tapGesture = UITapGestureRecognizer(target: self.view, action: #selector(self.dismissView(gesture:)))
        }
        
        //handle message
        lblMessage?.text = message
    }
    
    func message(attribute:NSAttributedString? = nil, buttons:Array<String>? = nil,select: @escaping (Int) -> Void) {
        select_ = select
        
        // setup button
        if(buttons != nil) {
            showButton(buttons!)
        } else {
            tapGesture = UITapGestureRecognizer(target: self.view, action: #selector(self.dismissView(gesture:)))
        }
        
        //handle message
        lblMessage.attributedText = attribute
    }
    
    // MARK: - BUTTON EVENT
    @IBAction private func buttonPress(_ sender: UIButton) {
        
        dismiss(animated: false, completion: nil)
        
        if(sender.isEqual(btnFirst) == true) {
            select_?(0)
        } else {
            select_?(1)
        }
    }
    
    func dismissView (gesture:UITapGestureRecognizer) {
        dismiss(animated: false, completion: nil)
    }
    
    // MARK: - PRIVATE
    private func showButton(_ listButtons:Array<String>?) {
        
        guard let list = listButtons else {
            return
        }
        btnFirst?.isHidden = false
        let text1:String = list[0]
        btnFirst?.setTitle("    \(text1)    ", for: .normal)
        if(list.count > 1) {
            let text2 = list[1]
            btnSecond?.isHidden = false
            btnSecond?.setTitle("    \(text2)    ", for: .normal)
        } else {
            btnSecond?.isHidden = true
        }
    }
}
