//
//  MenuListView.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 9/22/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import UIKit

enum MenuType:Int {
    case customer = 1
    case order = 2
    case customer_service = 3
    case informationApp = 4
    case setting = 5
}

protocol MenuListViewDelegate:class {
    func MenuListView(didSelectMenu:MenuListView,type:MenuType)
}

class MenuListView: UIView, UITableViewDelegate, UITableViewDataSource{

    @IBOutlet fileprivate var tableView: UITableView!
    
    weak var delegate_:MenuListViewDelegate?
    fileprivate var listMenu:Array<Dictionary<String, Any>>?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    func configText() {
        listMenu = [
            ["value":"customer".localized(),"type":MenuType.customer],
            ["value":"order".localized(),"type":MenuType.order],
            ["value":"customer_service".localized(),"type":MenuType.customer_service],
            ["value":"information".localized(),"type":MenuType.informationApp],
            ["value":"setting".localized(),"type":MenuType.setting]
        ]
        
        reload()
    }
    
    func reload() {
        tableView .reloadData()
    }
}

extension MenuListView{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (listMenu?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        
        let object = listMenu![indexPath.row]
        
        cell.textLabel?.text = object["value"] as? String
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let object = listMenu![indexPath.row]
        delegate_?.MenuListView(didSelectMenu: self, type: object["type"] as! MenuType)
    }
}
