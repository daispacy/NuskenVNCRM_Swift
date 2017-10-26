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
        
        // prevent sync data while working with order
        LocalService.shared.isShouldSyncData = {[weak self] in
            if let _ = self {
                return false
            }
            return true
        }
        
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
        
        orderCustomerView.onUpdateData = {[weak self] customer, order_code in
            if let _self = self {
                _self.customerSelected = customer
                _self.order_code = order_code
            }
        }
        
        orderProductView.onUpdateProducts = {[weak self] list in
            if let _self = self {
                _self.listProducts = list
            }
        }
        onDidLoad = {[weak self] in
            if let _self = self  {
                _self.orderProductView.show(order: order)
                _self.orderCustomerView.show(order: order)
                _self.configText()
            }
            return true
        }
        
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
            }).addDisposableTo(disposeBag)
        
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
            }).addDisposableTo(disposeBag)
        
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
            }).addDisposableTo(disposeBag)
        
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
            }).addDisposableTo(disposeBag)
        
        txtTransporterID.rx.text.orEmpty.subscribe(onNext:{ [weak self] in
            if let _self = self {
                _self.transporter_id = $0
            }
        }).addDisposableTo(disposeBag)
        
        addressOrder.rx.text.orEmpty.subscribe(onNext:{ [weak self] in
            if let _self = self {
                _self.address_order = $0
            }
        }).addDisposableTo(disposeBag)
        
        btnCancel.rx.tap
            .subscribe(onNext:{ [weak self] in
                if let _self = self {
                    _self.navigationController?.popViewController(animated: true)
                }
            }).addDisposableTo(disposeBag)
        
        btnProcess.rx.tap
            .subscribe(onNext:{ [weak self] in
                if let _self = self {
                    guard let user = UserManager.currentUser() else {
                        Support.popup.showAlert(message: "please_login_before_use_this_function".localized(), buttons: ["ok".localized()], vc: _self.navigationController!, onAction: {index in
                            
                        })
                        return
                    }
                    
                    if _self.order_code.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).characters.count == 0 {
                        _self.orderCustomerView.lblErrorCode.isHidden = false
                    } else {
                        _self.orderCustomerView.lblErrorCode.isHidden = true
                    }
                    guard let customer = _self.customerSelected else {
                        _self.orderCustomerView.lblErrorChooseCustomer.isHidden = false
                        Support.popup.showAlert(message: "sorry_please_select_a_customer".localized(), buttons: ["ok".localized()], vc: _self.navigationController!, onAction: {index in
                            
                        })
                        return
                    }
                    _self.orderCustomerView.lblErrorChooseCustomer.isHidden = true
                    if _self.orderCustomerView.lblErrorCode.isHidden == false {
                        Support.popup.showAlert(message: "sorry_please_provide_order_code".localized(), buttons: ["ok".localized()], vc: _self.navigationController!, onAction: {index in
                            
                        })
                        return
                    }
                    
                    if let ord = _self.order {
                        // update
                        
                        ord.customer_id = (_self.customerSelected?.id)!
                        ord.address = _self.address_order
                        ord.last_updated = Date.init(timeIntervalSinceNow: 0) as NSDate
                        ord.status = _self.status
                        ord.payment_option = _self.payment_method
                        ord.payment_status = _self.payment_status
                        ord.shipping_unit = _self.transporter
                        ord.svd = _self.transporter_id
                        ord.code = _self.order_code
//                        ord.date_created = _self.order?.date_created
//                        ord.tempProducts = _self.listProducts
                        ord.tel = customer.tel
                        ord.email = customer.email
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
                        if let customer = _self.customerSelected {
                            ord.customer_id = customer.id
                            ord.tel = customer.tel
                            ord.email = customer.email
                        }
                        ord.synced = false
                        ord.distributor_id = user.id_card_no
                        ord.address = _self.address_order
                        ord.date_created = Date.init(timeIntervalSinceNow: 0) as NSDate
                        ord.last_updated = Date.init(timeIntervalSinceNow: 0) as NSDate
                        ord.status = _self.status
                        ord.payment_option = _self.payment_method
                        ord.payment_status = _self.payment_status
                        ord.shipping_unit = _self.transporter
                        ord.svd = _self.transporter_id
                        ord.code = _self.order_code
//                        ord.tempProducts = _self.listProducts
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
            }).addDisposableTo(disposeBag)
    }
    
    override func configText() {
        _ = collectLabelOrderDetail.map({
            $0.text = $0.accessibilityIdentifier?.localized()
        })
        
        addressOrder.placeholder = "address_order".localized()
        txtTransporterID.placeholder = "transporter_id".localized()
        _ = AppConfig.order.listPaymentMethod.map({[weak self] item in
            if let _self = self {
                if item["id"] as! Int64 == payment_method {
                    _self.btnPaymentMethod.setTitle(item["name"] as? String, for: .normal)
                }
            }
        })
        _ = AppConfig.order.listPaymentStatus.map({[weak self] item in
            if let _self = self {
                if item["id"] as! Int64 == payment_status {
                    _self.btnPaymentStatus.setTitle(item["name"] as? String, for: .normal)
                }
            }
        })
        _ = AppConfig.order.listStatus.map({[weak self] item in
            if let _self = self {
                if item["id"] as! Int64 == status {
                    _self.btnStatus.setTitle(item["name"] as? String, for: .normal)
                }
            }
        })
        _ = AppConfig.order.listTranspoter.map({[weak self] item in
            if let _self = self {
                if item["id"] as! Int64 == transporter {
                    _self.btnTransporter.setTitle(item["name"] as? String, for: .normal)
                }
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
            orderCustomerView.onUpdateData = {[weak self] customer, order_code in
                if let _self = self {
                    _self.customerSelected = customer
                    _self.order_code = order_code
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
