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
    @IBOutlet var txtOtherTransporter: UITextField!
    
    @IBOutlet var lblTotalPrice: UILabel!
    @IBOutlet var lblTotalPV: UILabel!
    @IBOutlet var lblTextTotalPriccce: UILabel!
    @IBOutlet var lblTextTotalPV: UILabel!
    
    @IBOutlet var btnSaveOrder: CButtonAlert!
    @IBOutlet var btnProcess: CButtonAlert!
    @IBOutlet var btnCancel: CButtonAlert!
    @IBOutlet var vwOtherTransporter: UIView!
    
    var order:OrderDO?
    var customerSelected:CustomerDO?
    var status:Int64 = 0
    var payment_status:Int64 = 1
    var payment_method:Int64 = 1
    var address_order:String = ""
    var transporter:Int64 = 1
    var district:String = ""
    var city:String = ""
    var transporter_id:String = ""
    var order_code:String = ""
    var listProducts:[JSON] = []
    var onPop:((CustomerDO?)->Void)?
    
    var listStatus:[JSON] = AppConfig.order.listStatus()
    var listPaymentStatus:[JSON] = AppConfig.order.listPaymentStatus()
    var listPaymentMethod:[JSON] = AppConfig.order.listPaymentMethod()
    var listTranspoter:[JSON] = AppConfig.order.listTranspoter()
    
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
        
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        listStatus = AppConfig.order.listStatus()
        listPaymentStatus = AppConfig.order.listPaymentStatus()
        listPaymentMethod = AppConfig.order.listPaymentMethod()
        listTranspoter = AppConfig.order.listTranspoter()
        self.preventSyncData()
    }
    
    // MARK: - interface
    func edit(_ order:OrderDO) {
        self.order = order
        self.customerSelected = order.customer()
        if let address = order.address {
            self.address_order = address
        }
        
        self.district = order.district
        self.city = order.city
        orderCustomerView.onUpdateData = {[weak self] customer, order_code, order_address, city, district in
            if let _self = self {
                _self.customerSelected = customer
                _self.order_code = order_code
                _self.address_order = order_address
                _self.district = district
                _self.city = city
            }
        }
        
        orderCustomerView.onSelectCustomer = {[weak self] customer in
            if let _self = self {
                _self.customerSelected = customer
                if let cus = customer {
                    if let add = cus.address {
                        Support.popup.showAlert(message: "same_address_customer".localized(), buttons: ["no".localized(),"    \("yes".localized())    "], vc: _self.navigationController!, onAction: {[weak self] index in
                            if let _self = self {                                
                                if index == 1 {
                                    _self.addressOrder.text = add
                                    _self.address_order = add
                                    _self.orderCustomerView.orderAddress = add
                                    _self.orderCustomerView.txtAddressOrder.text = add
                                    _self.city = cus.city ?? ""
                                    _self.district = cus.county ?? ""
                                    _self.orderCustomerView.city = cus.city ?? ""
                                    _self.orderCustomerView.district = cus.county ?? ""
                                    _self.orderCustomerView.reloadCityDistrict(false)
                                } else {
                                    _self.addressOrder.text = ""
                                    _self.address_order = ""
                                    _self.orderCustomerView.orderAddress = ""
                                    _self.orderCustomerView.txtAddressOrder.text = ""
                                    _self.city = ""
                                    _self.district = ""
                                    _self.orderCustomerView.reloadCityDistrict()
                                }
                                
                            }
                            
                            }, { [weak self] index in
                                guard let _self = self else {return}
                                _self.preventSyncData()
                        })
                    }
                }
            }
        }
        
        orderProductView.onUpdateProducts = {[weak self] list in
            if let _self = self {
                _self.listProducts = list
                _self.updatePricePV()
            }
        }
        
        onDidLoad = {[weak self] in
            if let _self = self  {
                _self.orderProductView.show(order: order)
                _self.orderCustomerView.show(order: order)
                
                _self.status = order.status
                _self.payment_method = order.payment_option
                
                if let address = order.transporter_other {
                    _self.txtOtherTransporter.text = address
                }
                
                _self.payment_status = order.payment_status
                _self.transporter = order.shipping_unit
                _self.vwOtherTransporter.isHidden = _self.transporter != 4
                
                if let svd = order.svd {
                    _self.transporter_id = svd
                }
                
                if let code = order.code {
                    _self.order_code = code
                }
                _self.configText()
                _ = AppConfig.order.listStatus().map({[weak self] item in
                    if let _self = self {
                        if order.status == item["id"] as! Int64 {
                            if item["name"] as! String == "process".localized() {
                                _self.btnStatus.isEnabled = false
                                _self.addressOrder.isEnabled = false
                                _self.btnPaymentMethod.isEnabled = false
                                _self.btnTransporter.isEnabled = false
                                _self.txtTransporterID.isEnabled = false
                                _self.orderProductView.disableControl()
                                _self.orderCustomerView.btnChooseCustomer.isEnabled = false
                                _self.orderCustomerView.txtOrderCode.isEnabled = false
                            }
                        }
                    }
                })
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
                    Support.topVC?.present(popupC, animated: false, completion: {isDone in
                        _self.btnStatus.imageView!.transform = _self.btnStatus.imageView!.transform.rotated(by: CGFloat(Double.pi))
                    })
                    var listData:[String] = []
                    _ = _self.listStatus.map({listData.append($0["name"] as! String)})
                    popupC.show(data: listData, fromView: _self.btnStatus.superview!)
                    popupC.ondeinitial = {
                        [weak self] in
                        guard let _self = self else {return}
                        _self.preventSyncData()
                    }
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
                    Support.topVC?.present(popupC, animated: false, completion: {isDone in
                        _self.btnPaymentStatus.imageView!.transform = _self.btnPaymentStatus.imageView!.transform.rotated(by: CGFloat(Double.pi))
                    })
                    var listData:[String] = []
                    _ = _self.listPaymentStatus.map({listData.append($0["name"] as! String)})
                    popupC.show(data: listData, fromView: _self.btnPaymentStatus.superview!)
                    popupC.ondeinitial = {
                        [weak self] in
                        guard let _self = self else {return}
                        _self.preventSyncData()
                    }
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
                    Support.topVC?.present(popupC, animated: false, completion: {isDone in
                        _self.btnPaymentMethod.imageView!.transform = _self.btnPaymentMethod.imageView!.transform.rotated(by: CGFloat(Double.pi))
                    })
                    var listData:[String] = []
                    _ = _self.listPaymentMethod.map({listData.append($0["name"] as! String)})
                    popupC.show(data: listData, fromView: _self.btnPaymentMethod.superview!)
                    popupC.ondeinitial = {
                        [weak self] in
                        guard let _self = self else {return}
                        _self.preventSyncData()
                    }
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
                        
                        _self.vwOtherTransporter.isHidden = _self.transporter != 4
                    }
                    popupC.onDismiss = {
                        _self.btnTransporter.imageView!.transform = _self.btnTransporter.imageView!.transform.rotated(by: CGFloat(Double.pi))
                    }
                    Support.topVC?.present(popupC, animated: false, completion: {isDone in
                        _self.btnTransporter.imageView!.transform = _self.btnTransporter.imageView!.transform.rotated(by: CGFloat(Double.pi))
                    })
                    var listData:[String] = []
                    _ = _self.listTranspoter.map({listData.append($0["name"] as! String)})
                    popupC.show(data: listData, fromView: _self.btnTransporter.superview!)
                    popupC.ondeinitial = {
                        [weak self] in
                        guard let _self = self else {return}
                        _self.preventSyncData()
                    }
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
        
        btnSaveOrder.rx.tap
            .subscribe(onNext:{ [weak self] in
                if let _self = self {
                    _self.getImageOfScrollView()
                }
            }).addDisposableTo(disposeBag)
        
        btnProcess.rx.tap
            .subscribe(onNext:{ [weak self] in
                if let _self = self {
                    guard let user = UserManager.currentUser() else {
                        Support.popup.showAlert(message: "please_login_before_use_this_function".localized(), buttons: ["ok".localized()], vc: _self.navigationController!, onAction: {index in
                            
                        },{[weak self] in
                            guard let _self = self else {return}
                            _self.preventSyncData()
                            
                        })
                        return
                    }
                    
//                    if _self.order_code.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).characters.count == 0 {
//                        _self.orderCustomerView.lblErrorCode.isHidden = false
//                    } else {
//                        _self.orderCustomerView.lblErrorCode.isHidden = true
//                    }
                    guard let customer = _self.customerSelected else {
                        _self.orderCustomerView.lblErrorChooseCustomer.isHidden = false
                        Support.popup.showAlert(message: "sorry_please_select_a_customer".localized(), buttons: ["ok".localized()], vc: _self.navigationController!, onAction: {index in
                            
                        },{[weak self] in
                            guard let _self = self else {return}
                            _self.preventSyncData()
                        })
                        return
                    }
                    _self.orderCustomerView.lblErrorChooseCustomer.isHidden = true
//                    if _self.orderCustomerView.lblErrorCode.isHidden == false {
//                        Support.popup.showAlert(message: "sorry_please_provide_order_code".localized(), buttons: ["ok".localized()], vc: _self.navigationController!, onAction: {index in
//                            
//                        },{[weak self] in
//                            guard let _self = self else {return}
//                            _self.preventSyncData()
//                        })
//                        return
//                    }
                    
                    if let ord = _self.order {
                        // update
                        if !ord.validateCode(code: _self.order_code, oldCode: ord.code!, except: true) {
                            _self.orderCustomerView.lblErrorCode.isHidden = false
                            Support.popup.showAlert(message: "order_code_is_exist".localized(), buttons: ["ok".localized()], vc: _self.navigationController!, onAction: {index in
                                
                            },{[weak self] in
                                guard let _self = self else {return}
                                _self.preventSyncData()
                            })
                            return
                        }
                        ord.customer_id = (_self.customerSelected?.id)!
                        ord.address = _self.address_order
                        ord.last_updated = Date.init(timeIntervalSinceNow: 0) as NSDate
                        ord.status = _self.status
                        ord.payment_option = _self.payment_method
                        ord.payment_status = _self.payment_status
                        ord.shipping_unit = _self.transporter
                        ord.svd = _self.transporter_id
                        ord.code = _self.order_code
                        ord.setCity(_self.city)
                        ord.setDistrict(_self.district)
                        if let orther = _self.txtOtherTransporter.text {
                            ord.setOtherTransporter(orther)
                        }
//                        ord.date_created = _self.order?.date_created
//                        ord.tempProducts = _self.listProducts
                        ord.tel = customer.tel
                        ord.email = customer.email
                        ord.synced = false
                        OrderManager.updateOrderEntity(ord, onComplete: {
                            OrderItemManager.clearData(from:ord.id, onComplete: {
                                let container = CoreDataStack.sharedInstance.persistentContainer
                                container.performBackgroundTask() { (context) in
                                    _ = _self.listProducts.map({
                                        var dict = $0
                                        dict["order_id"] = ord.id
                                        dict["id"] = -Int64(Date.init(timeIntervalSinceNow: 0).toString(dateFormat: "89yyyyMMddHHmmss"))!
                                        dict["quantity"] = dict["total"]
                                        if let pro = dict["product"] as? ProductDO {
                                            dict["product_id"] = pro.id
                                        }
                                        _ = OrderItemManager.createOrderItemEntityFrom(dictionary: dict,context)
                                    })
                                    do {
                                        try context.save()
                                    } catch {
                                        fatalError("Failure to save context: \(error)")
                                    }
                                }
                            })
                            _self.navigationController?.popViewController(animated: true)
                            _self.onPop?(customer)
                        })
                        
                    } else {
                        // add
                        let ord = NSEntityDescription.insertNewObject(forEntityName: "OrderDO", into: CoreDataStack.sharedInstance.persistentContainer.viewContext) as! OrderDO
                        
                        if !OrderDO.validateCode(code: _self.order_code) {
                            _self.orderCustomerView.lblErrorCode.isHidden = false
                            Support.popup.showAlert(message: "order_code_is_exist".localized(), buttons: ["ok".localized()], vc: _self.navigationController!, onAction: {index in
                                
                            },{[weak self] in
                                guard let _self = self else {return}
                                _self.preventSyncData()
                            })
                            return
                        }
                        
                        ord.id = -Int64(Date.init(timeIntervalSinceNow: 0).toString(dateFormat: "89yyyyMMddHHmmss"))!
                        if let customer = _self.customerSelected {
                            ord.customer_id = customer.id
                            ord.tel = customer.tel
                            ord.email = customer.email
                        }
                        ord.synced = false
                        ord.distributor_id = user.id
                        ord.address = _self.address_order
                        ord.date_created = Date.init(timeIntervalSinceNow: 0) as NSDate
                        ord.last_updated = Date.init(timeIntervalSinceNow: 0) as NSDate
                        ord.status = _self.status
                        ord.payment_option = _self.payment_method
                        ord.payment_status = _self.payment_status
                        ord.shipping_unit = _self.transporter
                        ord.svd = _self.transporter_id
                        ord.code = _self.order_code
                        ord.setCity(_self.city)
                        ord.setDistrict(_self.district)
                        if let orther = _self.txtOtherTransporter.text {
                            ord.setOtherTransporter(orther)
                        }
//                        ord.tempProducts = _self.listProducts
                        OrderManager.updateOrderEntity(ord, onComplete: {
                            OrderItemManager.clearData(from:ord.id, onComplete: {
                                let container = CoreDataStack.sharedInstance.persistentContainer
                                container.performBackgroundTask() { (context) in
                                    _ = _self.listProducts.map({
                                        var dict = $0
                                        dict["order_id"] = ord.id
                                        dict["id"] = -Int64(Date.init(timeIntervalSinceNow: 0).toString(dateFormat: "89yyyyMMddHHmmss"))!
                                        dict["quantity"] = dict["total"]
                                        if let pro = dict["product"] as? ProductDO {
                                            dict["product_id"] = pro.id
                                        }
                                        _ = OrderItemManager.createOrderItemEntityFrom(dictionary: dict,context)
                                    })
                                    do {
                                        try context.save()
                                    } catch {
                                        fatalError("Failure to save context: \(error)")
                                    }
                                }
                            }) 
                            _self.navigationController?.popViewController(animated: true)
                            _self.onPop?(customer)
                        })
                    }
                }
            }).addDisposableTo(disposeBag)
    }
    
    override func configText() {
        
        _ = collectLabelOrderDetail.map({
            $0.text = $0.accessibilityIdentifier?.localized()
        })
        txtOtherTransporter.placeholder = "transporter_other".localized()
        addressOrder.placeholder = "address_order".localized()
        txtTransporterID.placeholder = "transporter_id".localized()
        _ = AppConfig.order.listPaymentMethod().map({[weak self] item in
            if let _self = self {
                if item["id"] as! Int64 == _self.payment_method {
                    _self.btnPaymentMethod.setTitle(item["name"] as? String, for: .normal)
                }
            }
        })
        _ = AppConfig.order.listPaymentStatus().map({[weak self] item in
            if let _self = self {
                if item["id"] as! Int64 == _self.payment_status {
                    _self.btnPaymentStatus.setTitle(item["name"] as? String, for: .normal)
                }
            }
        })
        _ = AppConfig.order.listStatus().map({[weak self] item in
            if let _self = self {
                if item["id"] as! Int64 == _self.status {
                    _self.btnStatus.setTitle(item["name"] as? String, for: .normal)
                }
            }
        })
        _ = AppConfig.order.listTranspoter().map({[weak self] item in
            if let _self = self {
                if item["id"] as! Int64 == _self.transporter {
                    _self.btnTransporter.setTitle(item["name"] as? String, for: .normal)
                }
            }
        })
        
        self.btnPaymentMethod.setTitleColor(UIColor(hex: Theme.color.customer.titleGroup), for: .normal)
        self.btnPaymentStatus.setTitleColor(UIColor(hex: Theme.color.customer.titleGroup), for: .normal)
        self.btnTransporter.setTitleColor(UIColor(hex: Theme.color.customer.titleGroup), for: .normal)
        self.btnStatus.setTitleColor(UIColor(hex: Theme.color.customer.titleGroup), for: .normal)
        
        if self.order == nil {
            btnProcess.setTitle("add".localized().uppercased().uppercased(), for: .normal)
            title = "add_order".localized().uppercased()
        } else {
            btnProcess.setTitle("update".localized().uppercased(), for: .normal)
            title = "edit_order".localized().uppercased()
        }
        
        btnCancel.setTitle("cancel".localized().uppercased(), for: .normal)
        btnSaveOrder.setTitle("save_photo".localized().uppercased(), for: .normal)
        
        addressOrder.text = self.address_order
        
        txtTransporterID.text = self.transporter_id
        
        lblTextTotalPriccce.text = "total_price".localized()
        lblTextTotalPV.text = "PV".localized()
        updatePricePV()
    }
    
    func updatePricePV() {
        var price:Int64 = 0
        var pv:Int64 = 0
        
        if listProducts.count > 0 {
            _ = self.listProducts.map({
                var dict = $0
                if let pr = dict["price"] as? Int64,
                    let product = dict["product"] as? ProductDO,
                    let quantity = dict["total"] as? Int64 {
                    price += (pr * quantity)
                    pv += (product.pv * quantity)
                }
                
            })
        }
        
        lblTotalPrice.text = "\(price.toTextPrice()) \("price_unit".localized().uppercased())"
        lblTotalPV.text = "\(pv.toTextPrice()) \("pv".localized().uppercased())"
    }
    
    func configView() {
        
        // block order customer view
        orderCustomerView.navigationController = self.navigationController
        
        
        // block product view
        orderProductView.navigationController = self.navigationController
       
        stackViewContainer.insertArrangedSubview(orderCustomerView, at: stackViewContainer.arrangedSubviews.count-3)
        stackViewContainer.insertArrangedSubview(orderProductView, at: stackViewContainer.arrangedSubviews.count-3)
        
        if self.order == nil {
            orderProductView.onUpdateProducts = {[weak self] list in
                if let _self = self {
                    _self.listProducts = list
                    _self.updatePricePV()
                }
            }
            
            orderProductView.onRegisterPreventSyncAgain = {
                [weak self] in
                guard let _self = self else {return}
                _self.preventSyncData()
            }
            
            orderCustomerView.onUpdateData = {[weak self] customer, order_code, order_address, city, district in
                if let _self = self {
                    _self.customerSelected = customer
                    _self.order_code = order_code
                    _self.address_order = order_address
                    _self.district = district
                    _self.city = city
                }
            }
            
            orderCustomerView.onSelectCustomer = {[weak self] customer in
                if let _self = self {
                    _self.customerSelected = customer
                    if let cus = customer {
                        if let add = cus.address {
                            Support.popup.showAlert(message: "same_address_customer".localized(), buttons: ["no".localized(),"    \("yes".localized())    "], vc: _self.navigationController!, onAction: {[weak self] index in
                                if let _self = self {
                                    if index == 1 {
                                        _self.addressOrder.text = add
                                        _self.address_order = add
                                        _self.orderCustomerView.orderAddress = add
                                        _self.orderCustomerView.txtAddressOrder.text = add
                                        _self.city = cus.city ?? ""
                                        _self.district = cus.county ?? ""
                                        _self.orderCustomerView.city = cus.city ?? ""
                                        _self.orderCustomerView.district = cus.county ?? ""
                                        _self.orderCustomerView.reloadCityDistrict(false)
                                    } else {
                                        _self.addressOrder.text = ""
                                        _self.address_order = ""
                                        _self.orderCustomerView.orderAddress = ""
                                        _self.orderCustomerView.txtAddressOrder.text = ""
                                        _self.city = ""
                                        _self.district = ""
                                        _self.orderCustomerView.reloadCityDistrict()
                                    }                                   
                                }
                                
                                },{[weak self] in
                                    guard let _self = self else {return}
                                    _self.preventSyncData()
                            })
                        }
                    }
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
        configTextfield(txtOtherTransporter)
        
        btnProcess.backgroundColor = UIColor(_gradient: Theme.colorGradient, frame: btnProcess.frame, isReverse:true)
        btnProcess.setTitleColor(UIColor(hex:Theme.colorAlertButtonTitleColor), for: .normal)
        btnProcess.titleLabel?.font = UIFont(name: Theme.font.bold, size: Theme.fontSize.normal)
        
        btnCancel.backgroundColor = UIColor(_gradient: Theme.colorGradient, frame: btnCancel.frame, isReverse:true)
        btnCancel.setTitleColor(UIColor(hex:Theme.colorAlertButtonTitleColor), for: .normal)
        btnCancel.titleLabel?.font = UIFont(name: Theme.font.bold, size: Theme.fontSize.normal)
        
        btnSaveOrder.backgroundColor = UIColor(_gradient: Theme.colorGradient, frame: btnCancel.frame, isReverse:true)
        btnSaveOrder.setTitleColor(UIColor(hex:Theme.colorAlertButtonTitleColor), for: .normal)
        btnSaveOrder.titleLabel?.font = UIFont(name: Theme.font.bold, size: Theme.fontSize.normal)
        
        lblTotalPV.textColor = UIColor(hex: Theme.colorNavigationBar)
        lblTotalPV.font = UIFont(name: Theme.font.bold, size: Theme.fontSize.medium)
        lblTotalPrice.textColor = UIColor(hex: Theme.colorNavigationBar)
        lblTotalPrice.font = UIFont(name: Theme.font.bold, size: Theme.fontSize.medium)
        lblTextTotalPV.textColor = UIColor(hex: Theme.color.customer.subGroup)
        lblTextTotalPV.font = UIFont(name: Theme.font.bold, size: Theme.fontSize.normal)
        lblTextTotalPriccce.textColor = UIColor(hex: Theme.color.customer.subGroup)
        lblTextTotalPriccce.font = UIFont(name: Theme.font.bold, size: Theme.fontSize.normal)
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

// MARK: - TAKE A SCREEN SHOT
extension OrderDetailController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func getImageOfScrollView(){
        
        let exportView = Bundle.main.loadNibNamed("FormExportOrderDetailView", owner: self, options: [:])?.first as! FormExportOrderDetailView
//        exportView.onReady = {[weak self] in
//            guard let _self = self else {return}
//
//        }
        if !exportView.load(self.order) {return}
        exportView.layoutSubviews()
        UIGraphicsBeginImageContext(exportView.frame.size)
        let context = UIGraphicsGetCurrentContext()
        //        let savedContentOffset = scrollView.contentOffset
        //        let savedFrame = scrollView.frame
        
        //        scrollView.contentOffset = CGPoint.zero
        exportView.frame = CGRect(x: 0, y: 0, width: exportView.frame.size.width, height: exportView.frame.size.height)
        exportView.layoutIfNeeded()
        
        exportView.backgroundColor!.setFill()
        context!.fill(exportView.frame)
        
        exportView.layer.render(in: context!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        //        scrollView.contentOffset = savedContentOffset
        //        scrollView.frame = savedFrame
        
        UIGraphicsEndImageContext()
        
        UIImageWriteToSavedPhotosAlbum(image!, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    //MARK: - Add image to Library
    func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let _ = error {
            // we got back an error!
            Support.popup.showAlert(message: "error_save_to_photo".localized(), buttons: ["ok".localized()], vc: self.navigationController!, onAction: {index in
                
            },{[weak self] in
                guard let _self = self else {return}
                _self.preventSyncData()
            })
        } else {
            Support.popup.showAlert(message: "order_have_save_to_photo_success_do_you_want_go_to_photo".localized(), buttons: ["no".localized(),"yes".localized()], vc: self.navigationController!, onAction: {index in
                if index == 1 {
                    UIApplication.shared.open(URL(string:"photos-redirect://")!)
                }
            },{[weak self] in
                guard let _self = self else {return}
                _self.preventSyncData()
            })
        }
    }
}
