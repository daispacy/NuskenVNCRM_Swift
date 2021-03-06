//
//  OrderListController.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 10/17/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import UIKit
import CoreData
import RxCocoa
import RxSwift

class OrderListController: RootViewController,
UITableViewDelegate,
UITableViewDataSource,
UISearchBarDelegate{

    @IBOutlet var indicatorLoading: UIActivityIndicatorView!
    @IBOutlet var lblMessageData: UILabel!
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var btnFilterStatus: UIButton!
    @IBOutlet var btnFilterPaymentStatus: UIButton!
    @IBOutlet var btnFilterCustomer: CButtonWithImageRight!
    @IBOutlet var lblstatus: UILabel!
    @IBOutlet var lblPaymentStatus: UILabel!
    @IBOutlet var lblcustomer: UILabel!
    @IBOutlet var stackFilter: UIStackView!
    @IBOutlet var vwFilter: UIView!
    @IBOutlet var stackContainer: UIStackView!
    
    var menuDashboard:MenuDashboardView = Bundle.main.loadNibNamed("MenuDashboardView", owner: self, options: nil)?.first as! MenuDashboardView
        
    var listOrder:[Order] = []
    var tapGesture:UITapGestureRecognizer? // tap hide keyboard search bar
    var status:Int64?
    var payment_status:Int64?
    var customer_id:[Int64] = []
    var searchText:String?
    var listCustomer:[Customer] = []
    var isGotoFromCustomerList:Bool = false
    
    var listStatus:[JSON] = AppConfig.order.listStatus()
    var listPaymentStatus:[JSON] = AppConfig.order.listPaymentStatus()
    
    var fromDate:NSDate? = nil
    var toDate:NSDate? = nil
    var isLifeTime: Bool = true
    var checkSync:Int = 0
    
    // MARK: - init
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "order".localized().uppercased()
        
        // Do any additional setup after loading the view.
        tableView.register(UINib(nibName: "OrderListCell", bundle: Bundle.main), forCellReuseIdentifier: "cell")
        
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.hideKeyboard))
        tapGesture?.cancelsTouchesInView = false
        self.tableView.addGestureRecognizer(tapGesture!)
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 86.4
        
        searchBar.delegate = self
        
        // Do any additional setup after loading the view.
        let rightButtonAdd = UIButton(type: .custom)
        rightButtonAdd.setImage(Support.image.iconFont(code: "\u{f067}", size: 22), for: .normal)
        rightButtonAdd.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        rightButtonAdd.addTarget(self, action: #selector(self.addewOrder(sender:)), for: .touchUpInside)
        let item2 = UIBarButtonItem(customView: rightButtonAdd)
        item2.tag = 99
        let rightButtonFilter = UIButton(type: .custom)
        rightButtonFilter.setImage(Support.image.iconFont(code: "\u{f0b0}", size: 22), for: .normal)
        rightButtonFilter.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        rightButtonFilter.addTarget(self, action: #selector(self.menuFitlerPress(_:)), for: .touchUpInside)
        let itemFilter2 = UIBarButtonItem(customView: rightButtonFilter)
        itemFilter2.tag = 100
        self.navigationItem.rightBarButtonItems = [item2,itemFilter2]
        
        stackContainer.insertArrangedSubview(menuDashboard, at: 0)
        let height:NSLayoutConstraint = menuDashboard.heightAnchor.constraint(equalToConstant: 130)
        height.priority = 750
        menuDashboard.addConstraint(height)
        menuDashboard.onSelectFilter = {[weak self] from, to, isLifeTime in
            guard let _self = self else {return}
            _self.fromDate = from
            _self.toDate = to
            _self.isLifeTime = isLifeTime
            _self.refreshListOrder()
        }
        
        configText()
        configView()
        // add menu from root
        addDefaultMenu(true)
        binding()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
     func reloadSynced(notification:Notification) {
            checkSync += 1
        if checkSync == 2 {
            checkSync = 0
            self.refreshListOrder()
        }
    }
    
    func keyboardWillShow(notification: NSNotification) {
        UIView.animate(withDuration: 0.2) {
            self.menuDashboard.isHidden = true
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.2) {
            self.menuDashboard.isHidden = false
        }
    }
    
    func menuFitlerPress(_ sender:UIBarButtonItem) {
        UIView.animate(withDuration: 0.2) {
            self.vwFilter.isHidden = !self.vwFilter.isHidden
            self.menuDashboard.isHidden = self.vwFilter.isHidden
        }
    }
    
    func addewOrder(sender:UIBarButtonItem) {
        
        let vc = OrderDetailController(nibName: "OrderDetailController", bundle: Bundle.main)
        self.navigationController?.pushViewController(vc, animated: true)
        vc.onPop = {[weak self] customer in
            guard let _self = self else {return}
            if let cus = customer {
                Support.popup.showAlert(message: "\("would_you_like_to_filter_this_customer".localized()): \(cus.fullname ?? "")", buttons: ["no".localized(),"yes".localized()], vc: _self.navigationController!, onAction: {index in
                    if index == 1 {
                        _self.customer_id = [cus.id, cus.local_id].filter{$0 != 0}
                    } else {
                        _self.customer_id = []
                    }
                    _self.syncIfCan()
                },nil)
                return
            } else {
                _self.customer_id = []
            }
            _self.syncIfCan()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        CoreDataStack.sharedInstance.shouldRefresh = {
            DispatchQueue.main.async {
                self.refreshListOrder()
            }
        }
        
        checkSync = 0
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadSynced(notification:)), name: Notification.Name("SyncData:Order"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadSynced(notification:)), name: Notification.Name("SyncData:OrderItem"), object: nil)
        
        listStatus = AppConfig.order.listStatus()
        listPaymentStatus = AppConfig.order.listPaymentStatus()
        refreshListOrder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        self.showTabbar(false)
        NotificationCenter.default.removeObserver(self, name:  Notification.Name("SyncData:Order"), object: nil)
        NotificationCenter.default.removeObserver(self, name:  Notification.Name("SyncData:OrderItem"), object: nil)
        CoreDataStack.sharedInstance.shouldRefresh = nil
    }
    
    override func configText() {
        lblMessageData.text = "order_not_found".localized()
        searchBar.placeholder = "search_order_code".localized()
        btnFilterStatus.setTitle("all".localized(), for: .normal)
        btnFilterPaymentStatus.setTitle("all".localized(), for: .normal)
        btnFilterCustomer.setTitle("all".localized(), for: .normal)
        
        lblstatus.text = "order_status".localized()
        lblPaymentStatus.text = "payment_status".localized()
        lblcustomer.text = "customer".localized()
    }
    
    deinit {
        if self.tableView != nil {
            self.tableView.removeGestureRecognizer(tapGesture!)
        }
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    // MARK: - private
    func refreshListOrder() {
        
        // setup filter customer
        let listCIDS = self.customer_id.filter{$0 != 0}
        if listCIDS.count > 0 {
            if listCustomer.count == 0 {
                CustomerManager.getAllCustomers(onComplete: {[weak self] (list) in
                    guard let _self = self else {return}
                    _self.listCustomer = list
                    let customerDO = _self.listCustomer.filter{
                        listCIDS.contains($0.id) || listCIDS.contains($0.local_id)
                    }
                    if customerDO.count > 0 {
                        _self.btnFilterCustomer.setTitle(customerDO[0].fullname, for: .normal)
                    }
                })
            } else {
                let customerDO = listCustomer.filter{
                    listCIDS.contains($0.id) || listCIDS.contains($0.local_id)
                }
                if customerDO.count > 0 {
                    self.btnFilterCustomer.setTitle(customerDO[0].fullname, for: .normal)
                }
            }
        } else {
            self.btnFilterCustomer.setTitle("all".localized(), for: .normal)
        }
        
        // setup status
        if let sta = self.status {
            _ = AppConfig.order.listStatus().map({item in
                if item["id"] as! Int64 == sta {
                    btnFilterStatus.setTitle(item["name"] as? String, for: .normal)
                }
            })
        }
        
        self.showLoading(isShow: true, isShowMessage: false)
        
        OrderManager.getAllOrders(search: self.searchText, status: self.status, paymentStatus: self.payment_status, customer_id:self.customer_id,fromDate: self.fromDate,toDate: self.toDate,isLifeTime: self.isLifeTime) {[weak self] list in
            DispatchQueue.main.async {
                if let _self = self {

                    Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false, block: {tm in
                    if list.count > 0 {
                        _self.listOrder = list
                        _self.showLoading(isShow: false, isShowMessage: false)
                    } else {
                        _self.showLoading(isShow: false, isShowMessage: true)
                    }
                        _self.tableView.reloadData()
                    })
                }
            }
        }
    }
    
    private func binding() {
        btnFilterStatus.rx.tap
            .subscribe(onNext:{ [weak self] in
                if let _self = self {
                    let popupC = PopupController(nibName: "PopupController", bundle: Bundle.main)
                    popupC.onSelect = {
                        item, index in
                        print("\(item) \(index)")
                        _self.btnFilterStatus.setTitle(item, for: .normal)
                        
                        if index == 0 {
                            _self.status = nil
                        } else {
                            let obj = _self.listStatus[index-1]
                            _self.status = obj["id"] as? Int64
                        }
                        
                        _self.refreshListOrder()
                    }
                    popupC.onDismiss = {
                        _self.btnFilterStatus.imageView!.transform = _self.btnFilterStatus.imageView!.transform.rotated(by: CGFloat(Double.pi))
                    }
                    Support.topVC?.present(popupC, animated: false, completion: {isDone in
                        _self.btnFilterStatus.imageView!.transform = _self.btnFilterStatus.imageView!.transform.rotated(by: CGFloat(Double.pi))
                    })
                    var listData:[String] = ["all".localized()]
                    _ = _self.listStatus.map({listData.append($0["name"] as! String)})
                    popupC.show(data: listData, fromView: _self.btnFilterStatus)
                    popupC.ondeinitial = {
                        [weak self] in
                        guard let _ = self else {return}
//                        _self.preventSyncData()
                    }
                }
            }).addDisposableTo(disposeBag)
        
        btnFilterPaymentStatus.rx.tap
            .subscribe(onNext:{ [weak self] in
                if let _self = self {
                    let popupC = PopupController(nibName: "PopupController", bundle: Bundle.main)
                    popupC.textAlignment = .right
                    popupC.onSelect = {
                        item, index in
                        print("\(item) \(index)")
                        _self.btnFilterPaymentStatus.setTitle(item, for: .normal)
                        
                        if index == 0 {
                            _self.payment_status = nil
                        } else {
                            let obj = _self.listPaymentStatus[index-1]
                            _self.payment_status = obj["id"] as? Int64
                        }
                        _self.refreshListOrder()
                    }
                    popupC.onDismiss = {
                        _self.btnFilterPaymentStatus.imageView!.transform = _self.btnFilterPaymentStatus.imageView!.transform.rotated(by: CGFloat(Double.pi))
                    }
                    Support.topVC?.present(popupC, animated: false, completion: {isDone in
                        _self.btnFilterPaymentStatus.imageView!.transform = _self.btnFilterPaymentStatus.imageView!.transform.rotated(by: CGFloat(Double.pi))
                    })
                    var listData:[String] = ["all".localized()]
                    _ = _self.listPaymentStatus.map({listData.append($0["name"] as! String)})
                    popupC.show(data: listData, fromView: _self.btnFilterPaymentStatus!)
                    popupC.ondeinitial = {
                        [weak self] in
                        guard let _ = self else {return}
//                        _self.preventSyncData()
                    }
                }
            }).addDisposableTo(disposeBag)
        
        btnFilterCustomer.rx.tap
            .subscribe(onNext:{ [weak self] in
                if let _self = self {
                    var listCustomers:[Customer] = []
                    CustomerManager.getAllCustomers(onComplete: { (list) in
                        listCustomers = list
                        _self.listCustomer = list
                        let popupC = PopupController(nibName: "PopupController", bundle: Bundle.main)
                        
                        popupC.onSelect = {
                            item, index in
                            print("\(item) \(index)")
                            _self.btnFilterCustomer.setTitle(item, for: .normal)
                            _self.customer_id = []
                            if index != 0 {
                                let obj = listCustomers[index-1]
                                _self.customer_id.append(obj.id)
                                _self.customer_id.append(obj.local_id)
                            }
                            _self.refreshListOrder()
                        }
                        popupC.onDismiss = {
                            _self.btnFilterCustomer.imageView!.transform = _self.btnFilterCustomer.imageView!.transform.rotated(by: CGFloat(Double.pi))
                        }
                        Support.topVC?.present(popupC, animated: false, completion: {isDone in
                            _self.btnFilterCustomer.imageView!.transform = _self.btnFilterCustomer.imageView!.transform.rotated(by: CGFloat(Double.pi))
                        })
                        var listData:[String] = ["all".localized()]
                        _ = listCustomers.map({listData.append($0.fullname ?? "unknown")})
                        popupC.show(data: listData, fromView: _self.btnFilterCustomer!)
                        popupC.ondeinitial = {
                            [weak self] in
                            guard let _ = self else {return}
                            //                        _self.preventSyncData()
                        }
                    })
                }
            }).addDisposableTo(disposeBag)
    }
    
    func configView() {
        btnFilterStatus.layer.borderWidth = 1.0
        btnFilterStatus.layer.masksToBounds = true
        btnFilterStatus.layer.cornerRadius = 7
        btnFilterStatus.layer.borderColor = UIColor(hex:Theme.colorDBBackgroundDashboard).cgColor
        btnFilterStatus.titleLabel?.font = UIFont(name: Theme.font.bold, size: Theme.fontSize.normal)
        btnFilterStatus.setTitleColor(UIColor(hex:Theme.color.customer.titleGroup), for: .normal)
        
        btnFilterPaymentStatus.layer.borderWidth = 1.0
        btnFilterPaymentStatus.layer.masksToBounds = true
        btnFilterPaymentStatus.layer.cornerRadius = 7
        btnFilterPaymentStatus.layer.borderColor = UIColor(hex:Theme.colorDBBackgroundDashboard).cgColor
        btnFilterPaymentStatus.titleLabel?.font = UIFont(name: Theme.font.bold, size: Theme.fontSize.normal)
        btnFilterPaymentStatus.setTitleColor(UIColor(hex:Theme.color.customer.titleGroup), for: .normal)
        
        btnFilterCustomer.layer.borderWidth = 1.0
        btnFilterCustomer.layer.masksToBounds = true
        btnFilterCustomer.layer.cornerRadius = 7
        btnFilterCustomer.layer.borderColor = UIColor(hex:Theme.colorDBBackgroundDashboard).cgColor
        btnFilterCustomer.titleLabel?.font = UIFont(name: Theme.font.bold, size: Theme.fontSize.normal)
        btnFilterCustomer.setTitleColor(UIColor(hex:Theme.color.customer.titleGroup), for: .normal)
        
        btnFilterPaymentStatus.titleEdgeInsets = UIEdgeInsetsMake(0, -20, 0, 0)
        btnFilterStatus.titleEdgeInsets = UIEdgeInsetsMake(0, -20, 0, 0)
        btnFilterCustomer.titleEdgeInsets = UIEdgeInsetsMake(0, -20, 0, 0)
        
        lblPaymentStatus.font = UIFont(name: Theme.font.normal, size: Theme.fontSize.normal)
        lblstatus.font = UIFont(name: Theme.font.normal, size: Theme.fontSize.normal)
        lblcustomer.font = UIFont(name: Theme.font.normal, size: Theme.fontSize.normal)
    }
    
    func showLoading(isShow:Bool,isShowMessage:Bool) {
        
        lblMessageData.isHidden = !isShowMessage
        
        if isShow {
            indicatorLoading.startAnimating()
            indicatorLoading.isHidden = false
        } else {
            indicatorLoading.stopAnimating()
            indicatorLoading.isHidden = true
        }
    }
    
    func hideKeyboard() {
        self.searchBar.resignFirstResponder()
    }
    
    // MARK: - sync & reload
    func syncIfCan() {
        
        firstSyncData()
//        self.refreshListOrder()
        return
        
        if let bool = LocalService.shared.isShouldSyncData?() {
            if bool == false {
                print("APP IN STATE BUSY, SO WILL SYNCED LATER")
                NotificationCenter.default.post(name:Notification.Name("SyncData:APPBUSY"),object:nil)
                NotificationCenter.default.post(name:Notification.Name("SyncData:FOREOUTSYNC"),object:nil)
                self.refreshListOrder()
                return
            }
        }
        
        if !Support.connectivity.isConnectedToInternet() {
            // Device doesn't have internet connection
            print("Internet Offline")
            NotificationCenter.default.post(name:Notification.Name("SyncData:FOREOUTSYNC"),object:nil)
            self.refreshListOrder()
            return
        }
        
        LocalService.shared.syncOrders(true) { [weak self] in
            guard let _self = self else {return}
//            LocalService.shared.syncOrdersItems {
                DispatchQueue.main.async {
                    _self.refreshListOrder()
                }
//            }
        }
    }
}

// MARK: - searchbar delegate
extension OrderListController {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
        refreshListOrder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.hideKeyboard()
    }
}

// MARK: - tableview delegate
extension OrderListController {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = OrderDetailController(nibName: "OrderDetailController", bundle: Bundle.main)
        self.navigationController?.pushViewController(vc, animated: true)
        vc.edit(self.listOrder[indexPath.row])
        vc.onPop = {[weak self] customer in
            guard let _self = self else {return}
            if let cus = customer {
                Support.popup.showAlert(message: "\("would_you_like_to_filter_this_customer".localized()): \(cus.fullname)", buttons: ["no".localized(),"yes".localized()], vc: _self.navigationController!, onAction: {index in
                    if index == 1 {
                        _self.customer_id = [cus.id, cus.local_id].filter{$0 != 0}
                    } else {
                        _self.customer_id = []
                    }
                    _self.syncIfCan()
                },nil)
                return
            } else {
                _self.customer_id = []
            }
            _self.syncIfCan()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! OrderListCell
        cell.show(listOrder[indexPath.row], isEdit: false, isSelect: false, isChecked: false)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOrder.count
    }
}

// MARK: - FetchResultController delegate
extension OrderListController: NSFetchedResultsControllerDelegate {}

// MARK: - scrollview delegate
extension OrderListController:UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.view.endEditing(true);
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if velocity.y > 0 && !self.vwFilter.isHidden && !self.menuDashboard.isHidden{
            UIView.animate(withDuration: 0.2) {
                self.vwFilter.isHidden = velocity.y > 0
                self.menuDashboard.isHidden = velocity.y > 0
            }
        }
    }
}
