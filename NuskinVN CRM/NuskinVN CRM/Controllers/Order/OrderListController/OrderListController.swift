//
//  OrderListController.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 10/17/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import UIKit

class OrderListController: RootViewController,
UITableViewDelegate,
UITableViewDataSource,
LocalServiceDelegate{

    @IBOutlet var indicatorLoading: UIActivityIndicatorView!
    @IBOutlet var lblMessageData: UILabel!
    @IBOutlet var tableView: UITableView!
    
    var listOrder:[Order] = []
    let localService:LocalService = LocalService.shared
    var tapGesture:UITapGestureRecognizer? // tap hide keyboard search bar
    
    override func viewDidLoad() {
        super.viewDidLoad()

        localService.delegate_ = self
        
        // Do any additional setup after loading the view.
        tableView.register(UINib(nibName: "OrderListCell", bundle: Bundle.main), forCellReuseIdentifier: "cell")
        
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.hideKeyboard))
        tapGesture?.cancelsTouchesInView = false
        self.tableView.addGestureRecognizer(tapGesture!)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.didSyncedData(notification:)), name: Notification.Name("SyncData:Order"), object: nil)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 50
        
        // Do any additional setup after loading the view.
        let rightButtonMenu = UIButton(type: .custom)
        rightButtonMenu.setImage(UIImage(named: "menu_white_icon"), for: .normal)
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
        title = "customer".localized().uppercased()
        lblMessageData.text = "order_not_found".localized()
    }
    
    deinit {
        self.tableView.removeGestureRecognizer(tapGesture!)
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - private
    func refreshListOrder() {
        listOrder.removeAll()
        localService.getAllOrder()
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
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOrder.count
    }
}

// MARK: - LocalService delegate
extension OrderListController {
    func localService(localService: LocalService, didReceiveData: Any, type: LocalServiceType) {
        DispatchQueue.main.async {
            switch (type) {
            case .customer:
                break
            case .group:
                break
            case .order:
                let list:[Order] = didReceiveData as! [Order]
                if list.count > 0 {
                    self.listOrder.append(contentsOf: list)
                    self.tableView.reloadData()
                    self.showLoading(isShow: false, isShowMessage: false)
                } else {
                    self.showLoading(isShow: false, isShowMessage: true)
                }
            }
        }
    }
    
    func localService(localService: LocalService, didFailed: Any, type: LocalServiceType) {
        
    }
}
