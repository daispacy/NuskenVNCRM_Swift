//
//  OrderDetailController.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 10/18/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import UIKit
import CoreData
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
    
    var order:OrderDO?
    var customerSelected:CustomerDO?
    var status:Int64 = 0
    var payment_status:Int64 = 1
    var payment_method:Int64 = 1
    var address_order:String = ""
    var transporter:Int64 = 1
    var transporter_id:String = ""
    var order_code:String = ""
    var listProducts:[JSON] = []
    
    let listStatus:[JSON] = AppConfig.order.listStatus
    let listPaymentStatus:[JSON] = AppConfig.order.listPaymentStatus
    let listPaymentMethod:[JSON] = AppConfig.order.listPaymentMethod
    let listTranspoter:[JSON] = AppConfig.order.listTranspoter
    
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
    func edit(_ order:OrderDO) {
        self.order = order
        self.customerSelected = order.customer()
        if let address = order.address {
            self.address_order = address
        }
        self.status = order.status
       self.payment_method = order.payment_option
        
        self.payment_status = order.payment_status
        self.transporter = order.shipping_unit
        
        if let svd = order.svd {
            self.transporter_id = svd
        }
        
        if let code = order.code {
            self.order_code = code
        }
        
        orderProductView.onUpdateProducts = {[weak self] list in
            if let _self = self {
                _self.listProducts = list
            }
        }
        
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
                        let obj = _self.listStatus[index]
                        _self.status = obj["id"] as! Int64
                        
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
                    var listData:[String] = []
                    _ = _self.listStatus.map({listData.append($0["name"] as! String)})
                    popupC.show(data: listData, fromView: _self.btnStatus.superview!)
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
                        let obj = _self.listPaymentStatus[index]
                        _self.payment_status = obj["id"] as! Int64
        
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
                    var listData:[String] = []
                    _ = _self.listPaymentStatus.map({listData.append($0["name"] as! String)})
                    popupC.show(data: listData, fromView: _self.btnPaymentStatus.superview!)
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
                        let obj = _self.listPaymentMethod[index]
                        _self.payment_method = obj["id"] as! Int64
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
                    var listData:[String] = []
                    _ = _self.listPaymentMethod.map({listData.append($0["name"] as! String)})
                    popupC.show(data: listData, fromView: _self.btnPaymentMethod.superview!)
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
                        let obj = _self.listTranspoter[index]
                        _self.transporter = obj["id"] as! Int64
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
                    var listData:[String] = []
                    _ = _self.listTranspoter.map({listData.append($0["name"] as! String)})
                    popupC.show(data: listData, fromView: _self.btnTransporter.superview!)
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
                    
                    if let ord = _self.order {
                        // update
                        ord.customer_id = (_self.customerSelected?.id)!
                        ord.distributor_id = UserManager.currentUser().id_card_no
                        ord.address = _self.address_order
                        ord.last_updated = Date.init(timeIntervalSinceNow: 0) as NSDate
                        ord.status = _self.status
                        ord.payment_option = _self.payment_method
                        ord.payment_status = _self.payment_status
                        ord.shipping_unit = _self.transporter
                        ord.svd = _self.transporter_id
                        ord.code = _self.order_code
//                        ord.tempProducts = _self.listProducts
                        ord.tel = _self.customerSelected?.tel
                        ord.email = _self.customerSelected?.email
                        ord.synced = false
                        OrderManager.updateOrderEntity(ord, onComplete: {
                            OrderItemManager.clearData(from:ord.id, onComplete: {
                                _ = _self.listProducts.map({
                                    var dict = $0
                                    dict["order_id"] = ord.id
                                    dict["id"] = -Int64(Date.init(timeIntervalSinceNow: 0).toString(dateFormat: "89yyyyMMddHHmmss"))!
                                    dict["quantity"] = dict["total"]
                                    if let pro = dict["product"] as? ProductDO {
                                        dict["product_id"] = pro.id
                                    }
                                    _ = OrderItemManager.createOrderItemEntityFrom(dictionary: dict)
                                    try! CoreDataStack.sharedInstance.persistentContainer.viewContext.save()
                                })
                            })                            
                            _self.navigationController?.popViewController(animated: true)
                        })
                        
                    } else {
                        // add
                        let ord = NSEntityDescription.insertNewObject(forEntityName: "OrderDO", into: CoreDataStack.sharedInstance.persistentContainer.viewContext) as! OrderDO
                        ord.id = -Int64(Date.init(timeIntervalSinceNow: 0).toString(dateFormat: "89yyyyMMddHHmmss"))!
                        ord.customer_id = (_self.customerSelected?.id)!
                        ord.distributor_id = UserManager.currentUser().id_card_no
                        ord.address = _self.address_order
                        ord.date_created = Date.init(timeIntervalSinceNow: 0) as NSDate
                        ord.status = _self.status
                        ord.payment_option = _self.payment_method
                        ord.payment_status = _self.payment_status
                        ord.shipping_unit = _self.transporter
                        ord.svd = _self.transporter_id
                        ord.code = _self.order_code
//                        ord.tempProducts = _self.listProducts
                        ord.tel = _self.customerSelected?.tel
                        ord.email = _self.customerSelected?.email
                        OrderManager.updateOrderEntity(ord, onComplete: {
                            OrderItemManager.clearData(from:ord.id, onComplete: {
                                _ = _self.listProducts.map({
                                    var dict = $0
                                    dict["order_id"] = ord.id
                                    dict["quantity"] = dict["total"]
                                    dict["id"] = -Int64(Date.init(timeIntervalSinceNow: 0).toString(dateFormat: "89yyyyMMddHHmmss"))!
                                    if let pro = dict["product"] as? ProductDO {
                                        dict["product_id"] = pro.id
                                    }
                                    _ = OrderItemManager.createOrderItemEntityFrom(dictionary: dict)
                                    try! CoreDataStack.sharedInstance.persistentContainer.viewContext.save()
                                })
                            }) 
                            try! CoreDataStack.sharedInstance.persistentContainer.viewContext.save()
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
        _ = AppConfig.order.listPaymentMethod.map({
            if $0["id"] as! Int64 == payment_method {
                self.btnPaymentMethod.setTitle($0["name"] as? String, for: .normal)
            }
        })
        _ = AppConfig.order.listPaymentStatus.map({
            if $0["id"] as! Int64 == payment_status {
                self.btnPaymentStatus.setTitle($0["name"] as? String, for: .normal)
            }
        })
        _ = AppConfig.order.listStatus.map({
            if $0["id"] as! Int64 == status {
                self.btnStatus.setTitle($0["name"] as? String, for: .normal)
            }
        })
        _ = AppConfig.order.listTranspoter.map({
            if $0["id"] as! Int64 == transporter {
                self.btnTransporter.setTitle($0["name"] as? String, for: .normal)
            }
        })
        
        self.btnPaymentMethod.setTitleColor(UIColor(hex: Theme.color.customer.titleGroup), for: .normal)
        self.btnPaymentStatus.setTitleColor(UIColor(hex: Theme.color.customer.titleGroup), for: .normal)
        self.btnTransporter.setTitleColor(UIColor(hex: Theme.color.customer.titleGroup), for: .normal)
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
        orderCustomerView.onUpdateData = {[weak self] customer, order_code in
            if let _self = self {
                _self.customerSelected = customer
                _self.order_code = order_code
            }
        }
        
        // block product view
        orderProductView.navigationController = self.navigationController
       
        stackViewContainer.insertArrangedSubview(orderCustomerView, at: stackViewContainer.arrangedSubviews.count-2)
        stackViewContainer.insertArrangedSubview(orderProductView, at: stackViewContainer.arrangedSubviews.count-2)
        
        if self.order == nil {
            orderProductView.onUpdateProducts = {[weak self] list in
                if let _self = self {
                    _self.listProducts = list
                }
            }
        }
        
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
