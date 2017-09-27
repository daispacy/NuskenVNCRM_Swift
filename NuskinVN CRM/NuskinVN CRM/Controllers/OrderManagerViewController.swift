//
//  OrderListViewController.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 9/22/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import UIKit

class OrderManagerViewController: RootViewController {

    var orderManageView:OrderManageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func loadView() {
        orderManageView = Bundle.main.loadNibNamed("OrderManageView", owner: self, options: nil)?.first as! OrderManageView        
        self.view = orderManageView
    }

}
