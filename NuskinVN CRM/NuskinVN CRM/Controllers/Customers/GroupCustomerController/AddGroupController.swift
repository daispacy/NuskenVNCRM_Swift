//
//  AddGroupController.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 10/4/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import UIKit

class AddGroupController: UIViewController {
    
    // block event
    var onAddGroup:((GroupCustomer) -> Void)?
    var onDismiss:(() -> Void)?
    
    @IBOutlet var vwOverlay: UIView!
    @IBOutlet var iconColor: CImageViewRoundGradient!
    @IBOutlet var txtName: UITextField!
    @IBOutlet var lblGroupColor: UILabel!
    @IBOutlet var lblGroupLevel: UILabel!
    
    @IBOutlet var groupColor: [UIButton]!
    @IBOutlet var groupLevel: [UIButton]!
    
    @IBOutlet var btnAdd: CButtonAlert!
    @IBOutlet var btnCancel: CButtonAlert!
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var containerView: UIView!
    
    var tapGesture:UITapGestureRecognizer!
    var group:GroupCustomer!
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        self.providesPresentationContextTransitionStyle = true
        self.definesPresentationContext = true
        self.modalPresentationStyle=UIModalPresentationStyle.overCurrentContext
        
    }
    
    deinit {
        vwOverlay.removeGestureRecognizer(tapGesture)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissView))
        vwOverlay.addGestureRecognizer(tapGesture)
        
        configView()
        configText()
        
        // default gradient => view on xin file to know tag of buttons
        setSelectedColor(tag: 7)
    }
    
    // MARK: - event
    func dismissView () {
        onDismiss?()
        dismiss(animated: false, completion: nil)
    }
    
    @IBAction func addGroup(_ sender: Any) {
        guard txtName.text!.characters.count > 0 else {
            return
        }
        group.name = txtName.text
        dismissView()
        onAddGroup?(group!)
    }
    
    @IBAction func cancel(_ sender: Any) {
        dismissView()
    }
    
    func switchColor(_ sender: UIButton) {
        setSelectedColor(tag: sender.tag)
    }
    
    func chooseGroupLevel(_ sender: UIButton) {
        _ = groupLevel.map({
            $0.isSelected = false
        })
        sender.isSelected = !sender.isSelected
        
        switch sender.tag {
        case 11:
            group.level = GroupLevel.ten.rawValue
        case 12:
            group.level = GroupLevel.nine.rawValue
        case 13:
            group.level = GroupLevel.seven.rawValue
        case 14:
            group.level = GroupLevel.three.rawValue
        case 15:
            group.level = GroupLevel.one.rawValue
        default:
            group.level = GroupLevel.one.rawValue
        }
    }
    
    // MARK: - config
    func configView() {
        
        _ = groupColor.map({
            
            $0.setTitle("", for: .normal)
            
            var backgroundColorBtn = UIColor.clear
            switch ($0.tag) {
            case 1:
                backgroundColorBtn = UIColor(hex:"0xf54337")
                break;
            case 2:
                backgroundColorBtn = UIColor(hex:"0xea1e63")
                break;
            case 3:
                backgroundColorBtn = UIColor(hex:"0x009788")
                break;
            case 4:
                backgroundColorBtn = UIColor(hex:"0xffeb3c")
                break;
            case 5:
                backgroundColorBtn = UIColor(hex:"0x607d8b")
                break;
            case 6:
                backgroundColorBtn = UIColor(hex:"0x9e9e9e")
                break;
            case 7:
                backgroundColorBtn = UIColor(_gradient: Theme.colorGradient, frame: $0.frame, isReverse: true)
                break;
            default:
                backgroundColorBtn = UIColor.clear
                break;
            }
            $0.backgroundColor = backgroundColorBtn
            $0.addTarget(self, action: #selector(self.switchColor(_:)), for: .touchUpInside)
            $0.clipsToBounds = false
            $0.layer.cornerRadius = 6
            $0.tintColor = UIColor.white
        })
        
        _ = groupLevel.map({
            if let imageCheck = Support.image.iconFont(code: "\u{f14a}", size: 24, color:"0xd4d8db") {
                $0.setImage(imageCheck, for: .selected)
            }
            if let imageUnCheck = Support.image.iconFont(code: "\u{f096}", size: 24, color:"0xd4d8db") {
                $0.setImage(imageUnCheck, for: .normal)
            }
            $0.setTitleColor(UIColor(hex:Theme.color.customer.titleGroup), for: .normal)
            $0.titleLabel?.font = UIFont(name: Theme.font.normal, size: Theme.fontSize.normal)
            $0.addTarget(self, action: #selector(self.chooseGroupLevel(_:)), for: .touchUpInside)
        })
        
        btnAdd.backgroundColor = UIColor(_gradient: Theme.colorGradient, frame: btnAdd.frame, isReverse: true)
        btnAdd.setTitleColor(UIColor.white, for: .normal)
        btnAdd.titleLabel?.font = UIFont(name: Theme.font.bold, size: Theme.fontSize.normal)
        
        btnCancel.backgroundColor = UIColor(_gradient: Theme.colorGradient, frame: btnAdd.frame, isReverse: true)
        btnCancel.setTitleColor(UIColor.white, for: .normal)
        btnCancel.titleLabel?.font = UIFont(name: Theme.font.bold, size: Theme.fontSize.normal)
        
        iconColor.image = UIImage(named: "ic_group_white_75")
        
        lblGroupColor.textColor = UIColor(hex:Theme.color.customer.titleGroup)
        lblGroupColor.font = UIFont(name: Theme.font.bold, size: Theme.fontSize.normal)
        
        lblGroupLevel.textColor = UIColor(hex:Theme.color.customer.titleGroup)
        lblGroupLevel.font = UIFont(name: Theme.font.bold, size: Theme.fontSize.normal)
        
        txtName.textColor = UIColor(hex:Theme.color.customer.titleGroup)
        txtName.font = UIFont(name: Theme.font.normal, size: Theme.fontSize.normal)
        
        containerView.layer.cornerRadius = 12
        containerView.clipsToBounds      = true
        
        group = GroupCustomer(id: 0)
    }
    
    func configText() {
        txtName.placeholder = "placeholder_name_group".localized()
        lblGroupColor.text = "choose_group_color".localized()
        lblGroupLevel.text = "choose_group_level".localized()
        _ = groupLevel.map({
            switch ($0.tag) {
            case 11:
                $0.setTitle("> 10 000 \("point".localized())", for: .normal)
                break;
            case 12:
                $0.setTitle("7000 - 9999 \("point".localized())", for: .normal)
                break;
            case 13:
                $0.setTitle("3000 - 6999 \("point".localized())", for: .normal)
                break;
            case 14:
                $0.setTitle("1000 - 2999 \("point".localized())", for: .normal)
                break;
            case 15:
                $0.setTitle("< 1000 \("point".localized())", for: .normal)
                break;
            default:
                
                break;
            }
        })
    }
    
    // MARK: - private
    func setSelectedColor(tag:Int) {
        _ = groupColor.map({
            if $0.tag == tag {
                if let imageCheck = Support.image.iconFont(code: "\u{f00c}", size: $0.frame.size.width) {
                    $0.setImage(imageCheck, for: .normal)
                }
                if tag == 7 {
                    iconColor.backgroundColor = UIColor(_gradient: Theme.colorGradient, frame: iconColor.frame, isReverse: true)
                } else {
                    iconColor.backgroundColor = $0.backgroundColor
                }
                switch (tag) {
                case 1:
                    group.color = "0xf54337"
                    break;
                case 2:
                    group.color = "0xea1e63"
                    break;
                case 3:
                    group.color = "0x009788"
                    break;
                case 4:
                    group.color = "0xffeb3c"
                    break;
                case 5:
                    group.color = "0x607d8b"
                    break;
                case 6:
                    group.color = "0x9e9e9e"
                    break;
                case 7:
                    group.color = "gradient"
                    break;
                default:
                    group.color = "gradient"
                    break;
                }
            } else {
                $0.setImage(nil, for: .normal)
            }
        })
    }
}
