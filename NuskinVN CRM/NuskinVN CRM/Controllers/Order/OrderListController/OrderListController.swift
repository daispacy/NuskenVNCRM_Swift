//
//  OrderListController.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 10/17/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import UIKit
import CoreData

class OrderListController: RootViewController,
UITableViewDelegate,
UITableViewDataSource{

    @IBOutlet var indicatorLoading: UIActivityIndicatorView!
    @IBOutlet var lblMessageData: UILabel!
    @IBOutlet var tableView: UITableView!
    
    var listOrder:[OrderDO] = []
    var tapGesture:UITapGestureRecognizer? // tap hide keyboard search bar
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "order".localized().uppercased()
        
        // Do any additional setup after loading the view.
        tableView.register(UINib(nibName: "OrderListCell", bundle: Bundle.main), forCellReuseIdentifier: "cell")
        
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.hideKeyboard))
        tapGesture?.cancelsTouchesInView = false
        self.tableView.addGestureRecognizer(tapGesture!)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.didSyncedData(notification:)), name: Notification.Name("SyncData:Order"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.didSyncedData(notification:)), name: Notification.Name("SyncData:OrderItem"), object: nil)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 86.4
        
        // Do any additional setup after loading the view.
        let rightButtonMenu = UIButton(type: .custom)
        rightButtonMenu.setImage(Support.image.iconFont(code: "\u{f067}", size: 22), for: .normal)
        rightButtonMenu.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        rightButtonMenu.addTarget(self, action: #selector(self.menuPress(sender:)), for: .touchUpInside)
        let item2 = UIBarButtonItem(customView: rightButtonMenu)
        self.navigationItem.rightBarButtonItem  = item2
        
        configText()
        configView()
    }
    
    func menuPress(sender:UIButton) {
        let vc = OrderDetailController(nibName: "OrderDetailController", bundle: Bundle.main)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshListOrder()
    }
    
    override func configText() {
        lblMessageData.text = "order_not_found".localized()
    }
    
    deinit {
        if self.tableView != nil {
            self.tableView.removeGestureRecognizer(tapGesture!)
        }
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - private
    func refreshListOrder() {
        listOrder.removeAll()
        OrderManager.getAllOrders(search: nil) {[weak self] list in
            if let _self = self {
                if list.count > 0 {
                    _self.listOrder.append(contentsOf: list)
                    _self.tableView.reloadData()
                    _self.showLoading(isShow: false, isShowMessage: false)
                } else {
                    _self.showLoading(isShow: false, isShowMessage: true)
                }
            }
        }
    }
    
    func configView() {
        
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
    
    func didSyncedData(notification:Notification) {
        refreshListOrder()
    }
    
    func hideKeyboard() {
//        self.searchBar.resignFirstResponder()
    }
}

// MARK: - tableview delegate
extension OrderListController {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = OrderDetailController(nibName: "OrderDetailController", bundle: Bundle.main)
        self.navigationController?.pushViewController(vc, animated: true)
        vc.edit(self.listOrder[indexPath.row])        
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
