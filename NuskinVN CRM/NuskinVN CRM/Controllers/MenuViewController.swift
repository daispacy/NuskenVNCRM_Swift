//
//  MenuViewController.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 9/22/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import UIKit

class MenuViewController: RootViewController,MenuListViewDelegate {

    var menuView:MenuListView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func loadView() {
        let menuView = Bundle.main.loadNibNamed(String(describing: MenuListView.self), owner: self, options: nil)?.first as! MenuListView
        menuView.delegate_ = self
        self.view = menuView
    }

}

extension MenuViewController {
    func MenuListView(didSelectMenu: MenuListView, type: MenuType) {
        switch type {
        case .customer:
            
            break
        case .order:
            
            break
        case .customer_service:
            
            break
        case .informationApp:
            
            break
        case .setting:
            
            break        
        }
    }
}
