//
//  SimpleListController.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 10/12/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import UIKit

class SimpleListController: RootViewController,
UITableViewDelegate,
UITableViewDataSource,
UISearchBarDelegate{

    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var tableView: UITableView!
    
    var onSelectData:((String)->Void)?
    var listData:[String] = []
    var listFiltered:[String] = []
    var searchText:String = ""
    var tapGesture:UITapGestureRecognizer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dissmissKeyboard(_:)))
        tapGesture?.cancelsTouchesInView = false
        tableView.addGestureRecognizer(tapGesture!)
    }
    
    // MARK: - interface
    func showData(data:[String]) {
        listData = data
        listFiltered = listData
        tableView.reloadData()
    }
    
    deinit {
        self.tableView.removeGestureRecognizer(tapGesture!)
    }
    
    // MARK: - private
    func dissmissKeyboard(_ sender:UITapGestureRecognizer) {
        searchBar.resignFirstResponder()
    }
    
    func refreshList() {
        if self.searchText.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines).characters.count > 0 {
            listFiltered = listData.filter{$0.range(of: self.searchText, options: .caseInsensitive) != nil}
        } else {
            listFiltered = listData
        }
        self.tableView.reloadData()
    }
}

extension SimpleListController {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listFiltered.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.font = UIFont(name: Theme.font.normal, size: Theme.fontSize.normal)
        cell.textLabel?.textColor = UIColor(hex:Theme.color.customer.subGroup)
        cell.textLabel?.text = listFiltered[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        onSelectData?(listFiltered[indexPath.row])
        self.navigationController?.popViewController(animated: true)
    }
}

extension SimpleListController {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
        refreshList()
    }
}
