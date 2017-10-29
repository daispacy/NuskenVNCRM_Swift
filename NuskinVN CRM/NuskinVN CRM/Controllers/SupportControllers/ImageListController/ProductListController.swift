//
//  SimpleListController.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 10/12/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import UIKit

class ProductListController: RootViewController,
UITableViewDelegate,
UITableViewDataSource,
UISearchBarDelegate{

    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var btnGroupProduct: CButtonWithImageRight!
    
    var onSelectData:((ProductDO)->Void)?
    var listData:[ProductDO] = []
    var listGroup:[GroupProductDO] = []
    var searchText:String = ""
    var tapGesture:UITapGestureRecognizer?
    var groupSelected:GroupProductDO?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "product".localized().uppercased()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshList), name: Notification.Name("SyncData:Group&Product"), object: nil)
        
        searchBar.delegate = self
        searchBar.placeholder = "search_product".localized()
        
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dissmissKeyboard(_:)))//
        tapGesture?.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGesture!)
        tableView.register(UINib(nibName: "ProductListCell", bundle: Bundle.main), forCellReuseIdentifier: "cell")
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        
        btnGroupProduct.layer.borderWidth = 1.0
        btnGroupProduct.layer.masksToBounds = true
        btnGroupProduct.layer.cornerRadius = 7
        btnGroupProduct.layer.borderColor = UIColor(hex:Theme.colorDBBackgroundDashboard).cgColor
        btnGroupProduct.titleLabel?.font = UIFont(name: Theme.font.normal, size: Theme.fontSize.normal)
        btnGroupProduct.setTitleColor(UIColor(hex:Theme.color.customer.titleGroup), for: .normal)
        btnGroupProduct.setTitle("all".localized(), for: .normal)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardDidHide, object: nil)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        tapGesture?.cancelsTouchesInView = true
        refreshList()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.preventSyncData()
    }
    
    deinit {        
        self.view.removeGestureRecognizer(tapGesture!)
        NotificationCenter.default.removeObserver(self)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        tapGesture?.cancelsTouchesInView = true
    }
    
    func keyboardWillHide(notification: NSNotification) {
        //Once keyboard disappears, restore original positions
        tapGesture?.cancelsTouchesInView = false
    }
    
    
    @IBAction func chooseGroupProduct(_ sender: UIButton) {
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
            _self.btnGroupProduct.setTitle(item, for: .normal)
            _self.refreshList()
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
                if let name = $0.name {
                    listData.append(name)
                }
            })
        }
        popupC.show(data: listData, fromView: sender)
        popupC.ondeinitial = {
            [weak self] in
            guard let _self = self else {return}
            _self.preventSyncData()
        }
    }
    
    // MARK: - private
    func dissmissKeyboard(_ sender:UITapGestureRecognizer) {
        searchBar.resignFirstResponder()
    }
    
    func refreshList() {
        var groupID:Int64 = 0
        if let gr = self.groupSelected {
            groupID = gr.id
        }
        ProductManager.getAllProducts(search: self.searchText,groupID: groupID) {[weak self] list in
            if let _self = self {
                _self.listData.removeAll()
                _self.listData.append(contentsOf: list)
                _self.tableView.reloadData()
            }
        }
        
        ProductManager.getAllGroups({[weak self] list in
            guard let _self = self else {return}
            _self.listGroup = list
        })
    }
}

extension ProductListController {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! ProductListCell
        cell.show(listData[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        onSelectData?(listData[indexPath.row])
    }
}

extension ProductListController {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
        refreshList()
    }
}
