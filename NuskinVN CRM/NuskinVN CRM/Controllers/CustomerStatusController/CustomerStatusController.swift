//
//  CustomerListController.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 10/5/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import UIKit
import CoreData

class CustomerStatusController:UIViewController,
    UISearchBarDelegate,
    UITableViewDelegate,
    UITableViewDataSource {
    
    @IBOutlet var indicatorLoading: UIActivityIndicatorView!
    @IBOutlet var lblMessageData: UILabel!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var tableView: UITableView!
    
    var listCustomer:[CustomerDO] = [] // list customer for tableview
    var searchText:String! = "" // search text
    var expandRow:NSInteger = -1 // row expand
    var oldExpandRow:NSInteger = -1 // row expand
    var tapGesture:UITapGestureRecognizer? // tap hide keyboard search bar
    var onSelectCustomer:((NSManagedObject)->Void)?
    var onGotoOrderList:(([Int64])->Void)?
    var isOrdered:Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let btnClose = UIButton(type: .custom)
        btnClose.addTarget(self, action: #selector(self.close(_:)), for: .touchUpInside)
        btnClose.setTitle("close".localized().uppercased(), for: UIControlState())
        let itemNotification = UIBarButtonItem(customView: btnClose)
        
        self.navigationItem.rightBarButtonItems  = [itemNotification]
        
        // Do any additional setup after loading the view.
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = UITableViewAutomaticDimension
        tableView.register(UINib(nibName: "CustomerListCell", bundle: Bundle.main), forCellReuseIdentifier: "cell")
        tableView.register(UINib(nibName: "CustomerSelectedListCell", bundle: Bundle.main), forCellReuseIdentifier: "cellSelected")
        
        searchBar.delegate = self
        
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.hideKeyboard))
        tapGesture?.cancelsTouchesInView = false
        self.tableView.addGestureRecognizer(tapGesture!)
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 50
        
        configView()
        configText()
    }
    
    deinit {

        if self.tableView != nil {
            self.tableView.removeGestureRecognizer(tapGesture!)
            NotificationCenter.default.removeObserver(self)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let i = self.isOrdered {
            load(i)
        }
    }
    
    func load(_ isorder:Bool = false) {
        
        self.isOrdered = isorder
        title = isorder ? "customer_has_order".localized().uppercased() : "customer_not_order_yet".localized().uppercased()
        
        self.listCustomer.removeAll()
        reload()
        
        showLoading(isShow: true, isShowMessage: false)
        
        CustomerManager.getAllCustomers(search: self.searchText, group: nil) {[weak self] list in
            if let _self = self {
            
                var listTemp:[CustomerDO] = []
                if _self.isOrdered! {
                    listTemp = list.filter{$0.getNumberOrders() > 0}
                } else {
                    listTemp = list.filter{$0.getNumberOrders() == 0}
                }
                
                _self.listCustomer.append(contentsOf: listTemp)
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
    
    func configText() {
        title = "customer".localized().uppercased()
        lblMessageData.text = "customer_not_found".localized()
        searchBar.placeholder = "search".localized()
    }
    
    func close(_ sender:UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func hideKeyboard() {
        self.searchBar.resignFirstResponder()
    }
    
}

// MARK: - tableview delegate
extension CustomerStatusController {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let customer = listCustomer[indexPath.row]
        
       
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! CustomerListCell
        
        var check = expandRow == indexPath.row
        if oldExpandRow == indexPath.row {
            check = false
        }
            cell.show(customer: customer, isEdit: false, isSelect:check, isChecked: false)
            
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
                _self.dismiss(animated: true, completion: nil)
                _self.onGotoOrderList?([customer.id,customer.local_id].filter{$0 != 0})
            }
            cell.involkeEmailView = {[weak self] customer in
                guard let _ = self else {return}
                guard let user = UserManager.currentUser() else {return}
                let vc = EmailController(nibName: "EmailController", bundle: Bundle.main)
//                _self.showTabbar(false)
                Support.topVC?.present(vc, animated: true, completion: {
                    vc.show(from: user.email!, to: customer.email!)
                })
                vc.onDismissComplete = {[weak self] in
                    guard let _ = self else {return}
                }
            }
            return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if onSelectCustomer != nil {
            self.navigationController?.popViewController(animated: true)
            onSelectCustomer?(listCustomer[indexPath.row])
            return
        }
        //            let customer = listCustomer[indexPath.row]
        if expandRow == indexPath.row {
            // reset expand
            expandRow = -1
        } else {
            oldExpandRow = expandRow
            expandRow = indexPath.row
        }
        self.tableView.reloadRows(at: [indexPath,IndexPath(row: oldExpandRow, section: 0)], with: .fade)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listCustomer.count
    }
}

// MARK: - searchbar delegate
extension CustomerStatusController {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
        load()
    }
}

// MARK: - private
extension CustomerStatusController {
    func configView() {
        
        lblMessageData.font = UIFont(name: Theme.font.normal, size: Theme.fontSize.normal)
        lblMessageData.textColor = UIColor(hex:Theme.color.customer.subGroup)
        
        let textFieldInsideUISearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideUISearchBar?.textColor = UIColor(hex:Theme.color.customer.titleGroup)
        textFieldInsideUISearchBar?.font = UIFont(name: Theme.font.normal, size: Theme.fontSize.normal)
        
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
