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
    var listCustomer:[Customer] = []
    var listGroup:[GroupCustomer] = []
    let localService:LocalService = LocalService.init()
    var groupSelected:String! = "all".localized()
    var searchText:String! = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBarController?.delegate = self
        // Do any additional setup after loading the view.
        
        configView()
        configText()
        
        localService.delegate_ = self
        searchBar.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let itemTabbar = UITabBarItem(title: "title_tabbar_button_dashboard".localized(), image: UIImage(named: "tabbar_dashboard"), selectedImage: UIImage(named: "tabbar_dashboard")?.withRenderingMode(.alwaysOriginal))
        itemTabbar.tag = 9
        tabBarItem  = itemTabbar
        
        localService.getAllGroup()
        refreshListCustomer()
    }
    
    override func configText() {
        title = "customer".localized().uppercased()
        lblMessageData.text = "customer_not_found".localized()
        btnFilterGroup.setTitle("choose_group".localized(), for: .normal)
        searchBar.placeholder = "search".localized()
    }
    
    func refreshListCustomer() {
        
        var sql:String = "select * from customer where (1 > 0) "
        if groupSelected != "all".localized() {
            if let gr = groupSelected {
                sql.append("AND 'group' = (select id from 'group' where name = '\(gr)') ")
            }
        }
        if searchText.characters.count > 0 {
            if let text = searchText {
                sql.append(" AND (firstname like '\(text)' OR lastname like '\(text)%') OR phone like '\(text)%' OR email like '\(text)%'")
            }
        }
        print(sql)
        localService.customSelectSQL(sql: sql)
        showLoading(isShow: true, isShowMessage: false)
    }
    
    // MARK: - event button
    @IBAction func chooseGroup(_ sender: UIButton) {
        let popupC = PopupController(nibName: "PopupController", bundle: Bundle.main)
        popupC.onSelect = {
            item, index in
            print("\(item) \(index)")
            self.groupSelected = item
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
                listData.append($0.name!)
            })
        }
        popupC.show(data: listData, fromView: sender)
    }
    
    @IBAction func addNewCustomer(_ sender: Any) {
        let vc = GroupCustomerController(nibName: "GroupCustomerController", bundle: Bundle.main)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func checkOrDeleteCustomers(_ sender: Any) {
        isEdit = !isEdit
        configView()
        tableView.reloadData()
    }
    
}

// MARK: - tableview delegate
extension CustomerListController {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! CustomerListCell
        
        cell.show(customer: listCustomer[indexPath.row], isEdit: isEdit)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
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
            }
        }
    }
    
    func localService(localService: LocalService, didFailed: Any, type:LocalServiceType) {
        
    }
}

// MARK: - private
extension CustomerListController {
    func configView() {
        
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
        
        //        lblMessageData.isHidden = !isShowMessage
        
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
