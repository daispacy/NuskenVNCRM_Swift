//
//  OrderDetailController.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 10/18/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class OrderDetailController: RootViewController {
    
    var tapGesture:UITapGestureRecognizer!
    @IBOutlet var stackViewContainer: UIStackView!
    @IBOutlet var collectLabelOrderDetail: [UILabel]!
    @IBOutlet var btnStatus: CButtonWithImageRight2!
    @IBOutlet var btnPaymentStatus: CButtonWithImageRight2!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var addressOrder: UITextField!
    @IBOutlet var btnPaymentMethod: CButtonWithImageRight2!
    @IBOutlet var btnTransporter: CButtonWithImageRight2!
    @IBOutlet var txtTransporterID: UITextField!
    @IBOutlet var btnProcess: CButtonAlert!
    @IBOutlet var btnCancel: CButtonAlert!
    
    var order:Order?
    var customerSelected:Customer = Customer(id: 0, distributor_id: 0, store_id: 0)
    var status:Int64 = 0
    var payment_status:Int64 = 0
    var payment_method:String = "cod".localized()
    var address_order:String = ""
    var transporter:String = "Vnpost - EMS".localized()
    var transporter_id:String = ""
    var order_code:String = ""
    var listProducts:[Product] = []
    
    let listStatus:[String] = AppConfig.order.listStatus
    let listPaymentStatus:[String] = AppConfig.order.listPaymentStatus
    let listPaymentMethod:[String] = AppConfig.order.listPaymentMethod
    let listTranspoter:[String] = AppConfig.order.listTranspoter
    
    let orderProductView = Bundle.main.loadNibNamed("OrderProductListView", owner: self, options: [:])?.first as! OrderProductListView
    let orderCustomerView = Bundle.main.loadNibNamed("OrderCustomerView", owner: self, options: [:])?.first as! OrderCustomerView
    
    // MARK: - init
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        self.scrollView.addGestureRecognizer(tapGesture!)
        
        configView()
        configText()
        binding()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    deinit {
        self.view.removeGestureRecognizer(tapGesture)
        NotificationCenter.default.removeObserver(self)
        print("\(String(describing: OrderDetailController.self)) dealloc")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // MARK: - interface
    func edit(_ order:Order) {
        self.order = order
        self.customerSelected = order.customer
        self.address_order = order.address
        self.status = order.status
        self.payment_method = order.payment_method
        self.payment_status = order.status
        self.transporter = order.shipping_unit
        self.transporter_id = order.transporter_id
        self.order_code = order.order_code
        self.listProducts = order.products
        self.customerSelected.tel = order.tel
        self.customerSelected.email = order.email
        orderProductView.show(order: order)
        orderCustomerView.show(order: order)
        configText()
    }
    
    // MARK: - private
    func binding() {
        btnStatus.rx.tap
            .subscribe(onNext:{ [weak self] in
                if let _self = self {
                    let popupC = PopupController(nibName: "PopupController", bundle: Bundle.main)
                    popupC.onSelect = {
                        item, index in
                        print("\(item) \(index)")
                        _self.btnStatus.setTitle(item, for: .normal)
                        _self.btnStatus.setTitleColor(UIColor(hex: Theme.color.customer.titleGroup), for: .normal)
                        _self.status = Int64(index)
                    }
                    popupC.onDismiss = {
                        _self.btnStatus.imageView!.transform = _self.btnStatus.imageView!.transform.rotated(by: CGFloat(Double.pi))
                    }
                    var topVC = UIApplication.shared.keyWindow?.rootViewController
                    while((topVC!.presentedViewController) != nil){
                        topVC = topVC!.presentedViewController
                    }
                    topVC?.present(popupC, animated: false, completion: {isDone in
                        _self.btnStatus.imageView!.transform = _self.btnStatus.imageView!.transform.rotated(by: CGFloat(Double.pi))
                    })
                    popupC.show(data: _self.listStatus, fromView: _self.btnStatus.superview!)
                }
            }).disposed(by: disposeBag)
        
        btnPaymentStatus.rx.tap
            .subscribe(onNext:{ [weak self] in
                if let _self = self {
                    let popupC = PopupController(nibName: "PopupController", bundle: Bundle.main)
                    popupC.onSelect = {
                        item, index in
                        print("\(item) \(index)")
                        _self.btnPaymentStatus.setTitle(item, for: .normal)
                        _self.btnPaymentStatus.setTitleColor(UIColor(hex: Theme.color.customer.titleGroup), for: .normal)
                        _self.payment_status = Int64(index)
                    }
                    popupC.onDismiss = {
                        _self.btnPaymentStatus.imageView!.transform = _self.btnPaymentStatus.imageView!.transform.rotated(by: CGFloat(Double.pi))
                    }
                    var topVC = UIApplication.shared.keyWindow?.rootViewController
                    while((topVC!.presentedViewController) != nil){
                        topVC = topVC!.presentedViewController
                    }
                    topVC?.present(popupC, animated: false, completion: {isDone in
                        _self.btnPaymentStatus.imageView!.transform = _self.btnPaymentStatus.imageView!.transform.rotated(by: CGFloat(Double.pi))
                    })
                    popupC.show(data: _self.listPaymentStatus, fromView: (_self.btnPaymentStatus.superview)!)
                }
            }).disposed(by: disposeBag)
        
        btnPaymentMethod.rx.tap
            .subscribe(onNext:{ [weak self] in
                if let _self = self {
                    let popupC = PopupController(nibName: "PopupController", bundle: Bundle.main)
                    popupC.onSelect = {
                        item, index in
                        print("\(item) \(index)")
                        _self.btnPaymentMethod.setTitle(item, for: .normal)
                        _self.btnPaymentMethod.setTitleColor(UIColor(hex: Theme.color.customer.titleGroup), for: .normal)
                        _self.payment_method = item
                    }
                    popupC.onDismiss = {
                        _self.btnPaymentMethod.imageView!.transform = _self.btnPaymentMethod.imageView!.transform.rotated(by: CGFloat(Double.pi))
                    }
                    var topVC = UIApplication.shared.keyWindow?.rootViewController
                    while((topVC!.presentedViewController) != nil){
                        topVC = topVC!.presentedViewController
                    }
                    topVC?.present(popupC, animated: false, completion: {isDone in
                        _self.btnPaymentMethod.imageView!.transform = _self.btnPaymentMethod.imageView!.transform.rotated(by: CGFloat(Double.pi))
                    })
                    popupC.show(data: _self.listPaymentMethod, fromView: (_self.btnPaymentMethod.superview)!)
                }
            }).disposed(by: disposeBag)
        
        btnTransporter.rx.tap
            .subscribe(onNext:{ [weak self] in
                if let _self = self {
                    let popupC = PopupController(nibName: "PopupController", bundle: Bundle.main)
                    popupC.onSelect = {
                        item, index in
                        print("\(item) \(index)")
                        _self.btnTransporter.setTitle(item, for: .normal)
                        _self.btnTransporter.setTitleColor(UIColor(hex: Theme.color.customer.titleGroup), for: .normal)
                        _self.transporter = item
                    }
                    popupC.onDismiss = {
                        _self.btnTransporter.imageView!.transform = _self.btnTransporter.imageView!.transform.rotated(by: CGFloat(Double.pi))
                    }
                    var topVC = UIApplication.shared.keyWindow?.rootViewController
                    while((topVC!.presentedViewController) != nil){
                        topVC = topVC!.presentedViewController
                    }
                    topVC?.present(popupC, animated: false, completion: {isDone in
                        _self.btnTransporter.imageView!.transform = _self.btnTransporter.imageView!.transform.rotated(by: CGFloat(Double.pi))
                    })
                    popupC.show(data: _self.listTranspoter, fromView: (_self.btnTransporter.superview)!)
                }
            }).disposed(by: disposeBag)
        
        txtTransporterID.rx.text.orEmpty.subscribe(onNext:{ [weak self] in
            if let _self = self {
                _self.transporter_id = $0
            }
        }).disposed(by: disposeBag)
        
        addressOrder.rx.text.orEmpty.subscribe(onNext:{ [weak self] in
            if let _self = self {
                _self.address_order = $0
            }
        }).disposed(by: disposeBag)
        
        btnCancel.rx.tap
            .subscribe(onNext:{ [weak self] in
                if let _self = self {
                    _self.navigationController?.popViewController(animated: true)
                }
            }).disposed(by: disposeBag)
        
        btnProcess.rx.tap
            .subscribe(onNext:{ [weak self] in
                if let _self = self {
                    var ord = Order()
                    
                    if let or = _self.order {
                        // update
                        ord = or
                        ord.store_id = UserManager.currentUser().id_card_no
                        ord.customer_id = _self.customerSelected.server_id
                        ord.address = _self.address_order
                        ord.date_created = Date.init(timeIntervalSinceNow: 0).toString(dateFormat: "yyyy-MM-dd HH:mm:ss")
                        ord.status = _self.status
                        ord.payment_method = _self.payment_method
                        ord.payment_status = _self.payment_status
                        ord.shipping_unit = _self.transporter
                        ord.transporter_id = _self.transporter_id
                        ord.order_code = _self.order_code
                        ord.tempProducts = _self.listProducts
                        ord.tel = _self.customerSelected.tel
                        ord.email = _self.customerSelected.email
                        LocalService.shared.updateOrder(obj: ord, onComplete: {
                            _self.navigationController?.popViewController(animated: true)
                        })
                    } else {
                        // add
                        
                        ord.store_id = UserManager.currentUser().id_card_no
                        ord.customer_id = _self.customerSelected.server_id
                        ord.address = _self.address_order
                        ord.date_created = Date.init(timeIntervalSinceNow: 0).toString(dateFormat: "yyyy-MM-dd HH:mm:ss")
                        ord.status = _self.status
                        ord.payment_method = _self.payment_method
                        ord.payment_status = _self.payment_status
                        ord.shipping_unit = _self.transporter
                        ord.transporter_id = _self.transporter_id
                        ord.order_code = _self.order_code
                        ord.tempProducts = _self.listProducts
                        ord.tel = _self.customerSelected.tel
                        ord.email = _self.customerSelected.email
                        LocalService.shared.addOrder(obj: ord, onComplete: {
                            _self.navigationController?.popViewController(animated: true)
                        })
                    }
                }
            }).disposed(by: disposeBag)
    }
    
    override func configText() {
        _ = collectLabelOrderDetail.map({
            $0.text = $0.accessibilityIdentifier?.localized()
        })
        
        addressOrder.placeholder = "address_order".localized()
        txtTransporterID.placeholder = "transporter_id".localized()
        
        self.btnPaymentMethod.setTitle(payment_method, for: .normal)
        self.btnPaymentMethod.setTitleColor(UIColor(hex: Theme.color.customer.titleGroup), for: .normal)
        self.btnPaymentStatus.setTitle(listPaymentStatus[Int(payment_status)], for: .normal)
        self.btnPaymentStatus.setTitleColor(UIColor(hex: Theme.color.customer.titleGroup), for: .normal)
        self.btnTransporter.setTitle(transporter, for: .normal)
        self.btnTransporter.setTitleColor(UIColor(hex: Theme.color.customer.titleGroup), for: .normal)
        self.btnStatus.setTitle(listStatus[Int(status)], for: .normal)
        self.btnStatus.setTitleColor(UIColor(hex: Theme.color.customer.titleGroup), for: .normal)
        
        if self.order == nil {
            btnProcess.setTitle("add".localized().uppercased(), for: .normal)
            title = "add_order".localized().uppercased()
        } else {
            btnProcess.setTitle("update".localized(), for: .normal)
            title = "edit_order".localized().uppercased()
        }
        
        btnCancel.setTitle("cancel".localized(), for: .normal)

            addressOrder.text = self.address_order
        
            txtTransporterID.text = self.transporter_id
        
        
    }
    
    func configView() {
        
        // block order customer view
        orderCustomerView.navigationController = self.navigationController
        orderCustomerView.onUpdateData = { customer, order_code in
            self.customerSelected = customer
            self.order_code = order_code
        }
        
        // block product view
        orderProductView.navigationController = self.navigationController
        orderProductView.onUpdateProducts = {list in
            self.listProducts = list
        }
        
        stackViewContainer.insertArrangedSubview(orderCustomerView, at: stackViewContainer.arrangedSubviews.count-2)
        stackViewContainer.insertArrangedSubview(orderProductView, at: stackViewContainer.arrangedSubviews.count-2)
        
        _ = collectLabelOrderDetail.map({
            $0.font = UIFont(name: Theme.font.normal, size: Theme.fontSize.small)!
            $0.textColor = UIColor(hex: Theme.color.customer.subGroup)
        })
        
        configButton(btnStatus)
        configButton(btnTransporter)
        configButton(btnPaymentMethod)
        configButton(btnPaymentStatus)
        
        configTextfield(txtTransporterID)
        configTextfield(addressOrder)
        
        btnProcess.backgroundColor = UIColor(_gradient: Theme.colorGradient, frame: btnProcess.frame, isReverse:true)
        btnProcess.setTitleColor(UIColor(hex:Theme.colorAlertButtonTitleColor), for: .normal)
        btnProcess.titleLabel?.font = UIFont(name: Theme.font.normal, size: Theme.fontSize.normal)
        
        btnCancel.backgroundColor = UIColor(_gradient: Theme.colorGradient, frame: btnCancel.frame, isReverse:true)
        btnCancel.setTitleColor(UIColor(hex:Theme.colorAlertButtonTitleColor), for: .normal)
        btnCancel.titleLabel?.font = UIFont(name: Theme.font.normal, size: Theme.fontSize.normal)
    }
    
    func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        //Need to calculate keyboard exact size due to Apple suggestions
        //        self.scrollVIew.isScrollEnabled = true
        var info = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize!.height, 0.0)
        
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        
        var aRect : CGRect = self.view.frame
        aRect.size.height -= keyboardSize!.height
    }
    
    func keyboardWillHide(notification: NSNotification) {
        
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        hideKeyboard()
    }
    
    private func configButton(_ button:UIButton, isHolder:Bool = false) {
        button.setTitleColor(UIColor(hex:"0xC7C7CD"), for: .normal)
        button.titleLabel?.font = UIFont(name: Theme.font.bold, size: Theme.fontSize.normal)
    }
    
    private func configTextfield(_ textfield:UITextField) {
        textfield.textColor = UIColor(hex: Theme.color.customer.subGroup)
        textfield.font = UIFont(name: Theme.font.bold, size: Theme.fontSize.normal)
    }
}
