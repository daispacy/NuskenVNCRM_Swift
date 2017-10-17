//
//  CustomerListController.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 10/5/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import UIKit

class CustomerListController: RootViewController,
    UISearchBarDelegate,
    UITableViewDelegate,
    UITableViewDataSource,
    LocalServiceDelegate,
UITabBarControllerDelegate{
    
    
    @IBOutlet var indicatorLoading: UIActivityIndicatorView!
    @IBOutlet var lblMessageData: UILabel!
    @IBOutlet var btnFilterGroup: UIButton!
    @IBOutlet var btnAddNewCustomer: UIButton!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var btnCheckOrDelete: UIButton!
    
    var isEdit: Bool = false
    var listCustomer:[Customer] = [] // list customer for tableview
    var listGroup:[GroupCustomer] = [] // list group for combobox
    let localService:LocalService = LocalService.shared
    var groupSelected:GroupCustomer! = GroupCustomer.init(id: 0, distributor_id: 0, store_id: 0) // group filter
    var searchText:String! = "" // search text
    var expandRow:NSInteger = -1 // row expand
    var listCustomerSelected:[Customer] = [] //list customer select to remove
    var tapGesture:UITapGestureRecognizer? // tap hide keyboard search bar
    var onSelectCustomer:((Customer)->Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBarController?.delegate = self
        // Do any additional setup after loading the view.
        
        configView()
        configText()
        
        localService.delegate_ = self
        searchBar.delegate = self
        
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.hideKeyboard))
        tapGesture?.cancelsTouchesInView = false
        self.tableView.addGestureRecognizer(tapGesture!)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.didSyncedData(notification:)), name: Notification.Name("SyncData:Customer"), object: nil)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 50
    }
    
    deinit {
        if self.tableView != nil {
            self.tableView.removeGestureRecognizer(tapGesture!)
            NotificationCenter.default.removeObserver(self)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let itemTabbar = UITabBarItem(title: "title_tabbar_button_dashboard".localized(), image: UIImage(named: "tabbar_dashboard"), selectedImage: UIImage(named: "tabbar_dashboard")?.withRenderingMode(.alwaysOriginal))
        itemTabbar.tag = 9
        tabBarItem  = itemTabbar
        
        refreshListCustomer()
    }
    
    override func configText() {
        title = "customer".localized().uppercased()
        lblMessageData.text = "customer_not_found".localized()
        btnFilterGroup.setTitle("choose_group".localized(), for: .normal)
        searchBar.placeholder = "search".localized()
    }
    
    func didSyncedData(notification:Notification) {
        
        refreshListCustomer()
    }
    
    func hideKeyboard() {
        self.searchBar.resignFirstResponder()
    }
    
    func refreshListCustomer() {
        
        LocalService.shared.getAllGroup { [weak self] list in
            self?.listGroup.removeAll()
            if list.count > 0 {
                self?.listGroup.append(contentsOf: list)
            }
        }
        
        self.listCustomer.removeAll()
        self.tableView.reloadData()
        
        var sql:String = "select * from `customer` where (`status` = '1') "
        if groupSelected.id != 0 {
            if let gr = groupSelected {
                if gr.server_id > 0 {
                    sql.append("AND (`group_id` = '\(gr.server_id)')")
                } else {
                    sql.append("AND (`group_id` = '\(gr.id)')")
                }
            }
        }
        if searchText.characters.count > 0 {
            if let text = searchText {
                sql.append(" AND (`fullname` like '\(text)%' OR `tel` like '\(text)%' OR `email` like '\(text)%')")
            }
        }
        print(sql)
        showLoading(isShow: true, isShowMessage: false)
        do {
            try LocalService.shared.db.transaction {
        localService.getCustomerWithCustom(sql: sql)
            }
        } catch {
            print("cant involke refresh list customer")
        }
    }
    
    // MARK: - event button
    @IBAction func chooseGroup(_ sender: UIButton) {
        let popupC = PopupController(nibName: "PopupController", bundle: Bundle.main)
        popupC.onSelect = {
            item, index in
            print("\(item) \(index)")
            if index > 0 {
                self.groupSelected = self.listGroup[index-1]
            } else {
                self.groupSelected = GroupCustomer(id: 0, distributor_id: 0, store_id: 0)
            }
            self.btnFilterGroup.setTitle(item, for: .normal)
            self.refreshListCustomer()
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
                listData.append($0.name)
            })
        }
        popupC.show(data: listData, fromView: sender)
    }
    
    @IBAction func addNewCustomer(_ sender: Any) {
//        let vc = CustomerDetailController(nibName: "CustomerDetailController", bundle: Bundle.main)
//        self.navigationController?.pushViewController(vc, animated: true)
        let vc = GroupCustomerController(nibName: "GroupCustomerController", bundle: Bundle.main)
        vc.onDidLoad = {
            vc.gotoFromCustomerList = true
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func checkOrDeleteCustomers(_ sender: Any) {
        isEdit = !isEdit
        if !isEdit {
            if self.listCustomerSelected.count > 0 {
                Support.popup.showAlert(message: "would_you_like_delete_customers?".localized(), buttons: ["cancel".localized(),"ok".localized()], vc: self, onAction: {
                    i in
                    if i == 1 {
                        _ = self.listCustomerSelected.map({
                            var cus = $0
                            cus.status = 0
                            _ = LocalService.shared.updateCustomer(object: cus)
                            LocalService.shared.startSyncData()
                        })
                        self.listCustomerSelected.removeAll()
                        self.configView()
                        self.refreshListCustomer()
                    } else {
                        self.listCustomerSelected.removeAll()
                    }
                })
            }
        }
        configView()
        refreshListCustomer()
    }
    
}

// MARK: - tableview delegate
extension CustomerListController {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! CustomerListCell
        cell.removeFunctionView()
        let isCheked = self.listCustomerSelected.filter({$0.email == listCustomer[indexPath.row].email}).count > 0
        cell.show(customer: listCustomer[indexPath.row], isEdit: isEdit, isSelect:expandRow == indexPath.row, isChecked: isCheked)
        cell.onSelectCustomer = {[weak self] customer, isAdd in
            if isAdd {
                self?.listCustomerSelected.append(customer)
            } else {
                self?.listCustomerSelected = (self?.listCustomerSelected.filter{ $0.id != customer.id })!
            }
        }
        cell.onEditCustomer = {[weak self]
            customer in
            let vc = CustomerDetailController(nibName: "CustomerDetailController", bundle: Bundle.main)
            vc.customer = customer
            self?.navigationController?.pushViewController(vc, animated: true)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if onSelectCustomer != nil {
            self.navigationController?.popViewController(animated: true)
            onSelectCustomer?(listCustomer[indexPath.row])            
            return
        }
        if isEdit {
            let cell = tableView.cellForRow(at: indexPath) as! CustomerListCell
            cell.setSelect()
        } else {
            let customer:Customer = listCustomer[indexPath.row]
            if expandRow == indexPath.row || !customer.isShouldOpenFunctionView {
                // reset expand
                expandRow = -1
                tableView.reloadData()
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
        refreshListCustomer()
    }
}

// MARK: - LocalService delegate
extension CustomerListController {
    func localService(localService: LocalService, didReceiveData: Any, type:LocalServiceType) {
        DispatchQueue.main.async {
            switch (type) {
            case .customer:
                let list:[Customer] = didReceiveData as! [Customer]
                if list.count > 0 {
                    self.listCustomer.removeAll()
                    self.listCustomer.append(contentsOf: list)
                    self.tableView.reloadData()
                    self.showLoading(isShow: false, isShowMessage: false)
                } else {
                    self.showLoading(isShow: false, isShowMessage: true)
                }
            case .group:
                let list:[GroupCustomer] = didReceiveData as! [GroupCustomer]
                if list.count > 0 {
                    self.listGroup.removeAll()
                    self.listGroup.append(contentsOf: list)
                }
            case .order:
                break
            }
        }
    }
    
    func localService(localService: LocalService, didFailed: Any, type:LocalServiceType) {
        
    }
}

// MARK: - private
extension CustomerListController {
    func configView() {
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = UITableViewAutomaticDimension
        tableView.register(UINib(nibName: "CustomerListCell", bundle: Bundle.main), forCellReuseIdentifier: "cell")
        
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
        
        if tabBarController.tabBar.selectedItem?.tag == 1 {
            let itemTabbar = UITabBarItem(title: "title_tabbar_button_customer".localized(), image: UIImage(named: "tabbar_customer"), selectedImage: UIImage(named: "tabbar_customer")?.withRenderingMode(.alwaysOriginal))
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
