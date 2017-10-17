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
UITableViewDataSource{

    @IBOutlet var tableView: UITableView!
    
    var onSelectData:((String)->Void)?
    var listData:[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    // MARK: - interface
    func showData(data:[String]) {
        listData = data
        tableView.reloadData()
    }
}

extension SimpleListController {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.font = UIFont(name: Theme.font.normal, size: Theme.fontSize.normal)
        cell.textLabel?.textColor = UIColor(hex:Theme.color.customer.subGroup)
        cell.textLabel?.text = listData[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        onSelectData?(listData[indexPath.row])
        self.navigationController?.popViewController(animated: true)
    }
}
