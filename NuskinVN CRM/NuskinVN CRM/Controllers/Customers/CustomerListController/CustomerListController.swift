//
//  CustomerListController.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 10/5/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import UIKit
import CoreData

class CustomerListController: RootViewController,
    UISearchBarDelegate,
    UITableViewDelegate,
    UITableViewDataSource,
UITabBarControllerDelegate {
    
    @IBOutlet var indicatorLoading: UIActivityIndicatorView!
    @IBOutlet var lblMessageData: UILabel!
    @IBOutlet var btnFilterGroup: UIButton!
    @IBOutlet var btnAddNewCustomer: UIButton!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var btnCheckOrDelete: UIButton!
    
    var isEdit: Bool = false
    var listCustomer:[CustomerDO] = [] // list customer for tableview
    var listGroup:[GroupDO] = [] // list group for combobox
    var groupSelected:GroupDO?// group filter
    var searchText:String! = "" // search text
    var expandRow:NSInteger = -1 // row expand
    var listCustomerSelected:[CustomerDO] = [] //list customer select to remove
    var tapGesture:UITapGestureRecognizer? // tap hide keyboard search bar
    var onSelectCustomer:((NSManagedObject)->Void)?
    var isJumpToOrderList:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBarController?.delegate = self
        
        // Do any additional setup after loading the view.
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = UITableViewAutomaticDimension
        tableView.register(UINib(nibName: "CustomerListCell", bundle: Bundle.main), forCellReuseIdentifier: "cell")
        tableView.register(UINib(nibName: "CustomerSelectedListCell", bundle: Bundle.main), forCellReuseIdentifier: "cellSelected")
        
        searchBar.delegate = self
        
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.hideKeyboard))
        tapGesture?.cancelsTouchesInView = false
        self.tableView.addGestureRecognizer(tapGesture!)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.didSyncedCustomer(notification:)), name: Notification.Name("SyncData:Customer"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.didSyncedGroup(notification:)), name: Notification.Name("SyncData:Group"), object: nil)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 50
        
        configView()
        configText()
        // add menu from root
        addDefaultMenu()
    }
    
    deinit {

        if self.tableView != nil {
            self.tableView.removeGestureRecognizer(tapGesture!)
            NotificationCenter.default.removeObserver(self)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let itemTabbar = UITabBarItem(title: "title_tabbar_button_dashboard".localized().uppercased(), image: UIImage(named: "tabbar_dashboard"), selectedImage: UIImage(named: "tabbar_dashboard")?.withRenderingMode(.alwaysOriginal))
        itemTabbar.tag = 9
        tabBarItem  = itemTabbar
        self.isJumpToOrderList = false
        updateTableContent()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.isEdit {
            self.preventSyncData()
        } else {
            if LocalService.shared.isShouldSyncData != nil {
                print("REMOVE REGISTER PREVENT SYNC CUSTOMER LIST: \(self.isEdit)")
                LocalService.shared.isShouldSyncData = nil
            }
        }
    }
    
    func updateTableContent() {
        self.listCustomer.removeAll()
        if !self.isEdit {
            self.listCustomerSelected.removeAll()
        }
        reload()
        
        GroupManager.getAllGroup(onComplete: {[weak self] list in
            if let _self = self {
                _self.listGroup = list
            }
        })
        
        showLoading(isShow: true, isShowMessage: false)
        
        CustomerManager.getAllCustomers(search: self.searchText, group: self.groupSelected) {[weak self] list in
            if let _self = self {
            
                _self.listCustomer.append(contentsOf: list)
                if list.count > 0 {
                    _self.showLoading(isShow: false, isShowMessage: false)
                } else {
                    _self.showLoading(isShow: false, isShowMessage: true)
                }
            
                _self.reload()
            }
        }
    }
    
    func reload() {
        if let tableview = self.tableView {
            tableview.reloadData()
        }
    }
    
    override func configText() {
        title = "customer".localized().uppercased()
        lblMessageData.text = "customer_not_found".localized()
        btnFilterGroup.setTitle("choose_group".localized(), for: .normal)
        searchBar.placeholder = "search".localized()
    }
    
    func didSyncedGroup(notification:Notification) {
        GroupManager.getAllGroup(onComplete: {[weak self] list in
            if let _self = self {
                _self.listGroup = list
            }
        })
    }
    func didSyncedCustomer(notification:Notification) {
        updateTableContent()
    }
    
    func hideKeyboard() {
        self.searchBar.resignFirstResponder()
    }
    
    // MARK: - event button
    @IBAction func chooseGroup(_ sender: UIButton) {
        let popupC = PopupController(nibName: "PopupController", bundle: Bundle.main)
        popupC.onSelect = {[weak self]
            item, index in
            guard let _self = self else { return }
            print("\(item) \(index)")
            if index > 0 {
                _self.groupSelected = _self.listGroup[index-1]
            } else {
                _self.groupSelected = nil
            }
            _self.btnFilterGroup.setTitle(item, for: .normal)
            _self.updateTableContent()
            //            self.refreshListCustomer()
        }
        popupC.onDismiss = {
            sender.imageView!.transform = sender.imageView!.transform.rotated(by: CGFloat(Double.pi))
        }
        var topVC = UIApplication.shared.keyWindow?.rootViewController
        while((topVC!.presentedViewController) != nil){
            topVC = topVC!.presentedViewController
        }
        topVC?.present(popupC, animated: false, completion: {isDone in
            sender.imageView!.transform = sender.imageView!.transform.rotated(by: CGFloat(Double.pi))
        })
        var listData:[String] = ["all".localized()]
        if listGroup.count > 0 {
            _ = listGroup.map({
                if let name = $0.group_name {
                    listData.append(name)
                }
            })
        }
        popupC.show(data: listData, fromView: sender)
        popupC.ondeinitial = {
            [weak self] in
            guard let _self = self else {return}
            if _self.isEdit {
                _self.preventSyncData()
            }
        }
    }
    
    @IBAction func addNewCustomer(_ sender: Any) {
        //        let vc = CustomerDetailController(nibName: "CustomerDetailController", bundle: Bundle.main)
        //        self.navigationController?.pushViewController(vc, animated: true)
        let vc = GroupCustomerController(nibName: "GroupCustomerController", bundle: Bundle.main)
            vc.gotoFromCustomerList = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func checkOrDeleteCustomers(_ sender: Any) {
        isEdit = !isEdit
        
        if isEdit {
            self.preventSyncData()
        } else {
            if LocalService.shared.isShouldSyncData != nil {
                print("REMOVE REGISTER PREVENT SYNC CUSTOMER LIST: \(self.isEdit)")
                LocalService.shared.isShouldSyncData = nil
            }
        }
        
        if !isEdit {
            if self.listCustomerSelected.count > 0 {
                Support.popup.showAlert(message: "would_you_like_delete_customers".localized(), buttons: ["cancel".localized(),"ok".localized()], vc: self, onAction: {i in
                    
                    if i == 1 {
                        _ = self.listCustomerSelected.map({
                            
                            let cus = $0
                            cus.status = 0
                            cus.synced = false
                            CustomerManager.updateCustomerEntity(cus, onComplete: {})
                        })
                        self.listCustomerSelected.removeAll()
                        self.configView()
                        self.updateTableContent()
                        return
                    } else {
                        self.configView()
                        self.updateTableContent()
                    }
                },nil)
            } else {
                configView()
                updateTableContent()
            }
        } else {
            configView()
            updateTableContent()
        }
    }
    
}

// MARK: - tableview delegate
extension CustomerListController {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let customer = listCustomer[indexPath.row]
        
        if self.isEdit {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellSelected") as! CustomerSelectedListCell
            let isCheked = self.listCustomerSelected.filter({($0).email == (listCustomer[indexPath.row]).email}).count > 0
            cell.viewcontroller = self
            cell.show(customer: customer, isEdit: isEdit, isSelect:expandRow == indexPath.row, isChecked: isCheked)
            cell.onSelectCustomer = {[weak self] customer, isAdd in
                if let _self = self {
                    if isAdd {
                        _self.listCustomerSelected.append(customer)
                    } else {
                        let obj = customer
                        _self.listCustomerSelected = _self.listCustomerSelected.filter{ ($0).id != obj.id }
                    }
                }
            }
            cell.onEditCustomer = {[weak self]
                customer in
                if let _self = self {
                    let vc = CustomerDetailController(nibName: "CustomerDetailController", bundle: Bundle.main)
                    _self.navigationController?.pushViewController(vc, animated: true)
                    
//                    vc.onDidLoad = {
                        vc.edit(customer: customer)
//                        return true
//                    }
                }
            }
            cell.onRegisterAgainPreventSync = {
                [weak self] in
                guard let _self = self else {return}
                _self.preventSyncData()
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! CustomerListCell
            cell.show(customer: customer, isEdit: isEdit, isSelect:expandRow == indexPath.row, isChecked: false)
            
            cell.onEditCustomer = {[weak self]
                customer in
                if let _self = self {
                    let vc = CustomerDetailController(nibName: "CustomerDetailController", bundle: Bundle.main)
                    _self.navigationController?.pushViewController(vc, animated: true)
                    vc.onDidLoad = {
                        vc.edit(customer: customer)
                        return true
                    }
                }
            }
            cell.gotoOrderList = {[weak self] customer in
                guard let _self = self else {return}
                let itemTabbar = UITabBarItem(title: "title_tabbar_button_customer".localized().uppercased(), image: UIImage(named: "tabbar_customer"), selectedImage: UIImage(named: "tabbar_customer")?.withRenderingMode(.alwaysOriginal))
                itemTabbar.tag = 10
                _self.tabBarItem  = itemTabbar
                let nv = _self.tabBarController?.viewControllers![1] as! UINavigationController
                let vc = nv.viewControllers[0] as! OrderListController
                vc.customer_id = [customer.id,customer.local_id]
                _self.tabBarController?.selectedIndex = 1
            }
            cell.involkeEmailView = {[weak self] customer in
                guard let _self = self else {return}
                guard let user = UserManager.currentUser() else {return}
                let vc = EmailController(nibName: "EmailController", bundle: Bundle.main)
//                _self.showTabbar(false)
                _self.navigationController?.present(vc, animated: true, completion: {
                    vc.show(from: user.email!, to: customer.email!)
                })
                vc.onDismissComplete = {[weak self] in
                    guard let _self = self else {return}
//                    _self.showTabbar(true)
                    _self.refreshAvatar()
                }
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if onSelectCustomer != nil {
            self.navigationController?.popViewController(animated: true)
            onSelectCustomer?(listCustomer[indexPath.row])
            return
        }
        if isEdit {
            let cell = tableView.cellForRow(at: indexPath) as! CustomerSelectedListCell
            cell.setSelect()
        } else {
            let customer = listCustomer[indexPath.row]
            if expandRow == indexPath.row {
                // reset expand
                expandRow = -1
                self.tableView.reloadData()
            } else {
                expandRow = indexPath.row
                self.tableView.beginUpdates()
                self.tableView.reloadSections(IndexSet(integersIn: 0...0), with: UITableViewRowAnimation.automatic)
                self.tableView.endUpdates()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listCustomer.count
    }
}

// MARK: - searchbar delegate
extension CustomerListController {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
        updateTableContent()
    }
}

// MARK: - private
extension CustomerListController {
    func configView() {
        
        btnFilterGroup.layer.borderWidth = 1.0
        btnFilterGroup.layer.masksToBounds = true
        btnFilterGroup.layer.cornerRadius = 7
        btnFilterGroup.layer.borderColor = UIColor(hex:Theme.colorDBBackgroundDashboard).cgColor
        btnFilterGroup.titleLabel?.font = UIFont(name: Theme.font.normal, size: Theme.fontSize.normal)
        btnFilterGroup.setTitleColor(UIColor(hex:Theme.color.customer.titleGroup), for: .normal)
        
        lblMessageData.font = UIFont(name: Theme.font.normal, size: Theme.fontSize.normal)
        lblMessageData.textColor = UIColor(hex:Theme.color.customer.subGroup)
        
        let textFieldInsideUISearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideUISearchBar?.textColor = UIColor(hex:Theme.color.customer.titleGroup)
        textFieldInsideUISearchBar?.font = UIFont(name: Theme.font.normal, size: Theme.fontSize.normal)
        
        
        if isEdit {
            btnCheckOrDelete.setImage(UIImage(named: "delete_white_48"), for: .normal)
            btnCheckOrDelete.backgroundColor = UIColor(hex:"0xf44336")
        } else {
            btnCheckOrDelete.setImage(UIImage(named: "ic_check_white_48"), for: .normal)
            btnCheckOrDelete.backgroundColor = UIColor(hex:"0x009688")
        }
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
}

// MARK: - tabbar delegate
extension CustomerListController {
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        if(self.presentedViewController != nil) {
            return false
        }
        
        if tabBarController.tabBar.selectedItem?.tag == 1{
            let itemTabbar = UITabBarItem(title: "title_tabbar_button_customer".localized().uppercased(), image: UIImage(named: "tabbar_customer"), selectedImage: UIImage(named: "tabbar_customer")?.withRenderingMode(.alwaysOriginal))
            itemTabbar.tag = 10
            tabBarItem  = itemTabbar
        } else {
            if tabBarItem.tag == 9 {
                AppConfig.navigation.changeController(to: DashboardViewController(), on: tabBarController, index: 0)
            }
        }
        return true
    }
}
