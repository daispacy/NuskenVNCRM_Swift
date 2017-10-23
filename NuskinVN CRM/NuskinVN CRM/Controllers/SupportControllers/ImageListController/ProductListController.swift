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
    
    var onSelectData:((ProductDO)->Void)?
    var listData:[ProductDO] = []
    var searchText:String = ""
    var tapGesture:UITapGestureRecognizer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dissmissKeyboard(_:)))
        tapGesture?.cancelsTouchesInView = false
        tableView.addGestureRecognizer(tapGesture!)
        tableView.register(UINib(nibName: "ProductListCell", bundle: Bundle.main), forCellReuseIdentifier: "cell")
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshList()
    }
    
    deinit {
        self.tableView.removeGestureRecognizer(tapGesture!)
    }
    
    // MARK: - private
    func dissmissKeyboard(_ sender:UITapGestureRecognizer) {
        searchBar.resignFirstResponder()
    }
    
    func refreshList() {
        ProductManager.getAllProducts(search: self.searchText) {[weak self] list in
            if let _self = self {
                DispatchQueue.main.async {
                    _self.listData.removeAll()
                    _self.listData.append(contentsOf: list)
                    _self.tableView.reloadData()
                }
            }
        }
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
