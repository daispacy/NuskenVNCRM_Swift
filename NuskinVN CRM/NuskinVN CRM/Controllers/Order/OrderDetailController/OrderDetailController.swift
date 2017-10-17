//
//  OrderDetailController.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 10/18/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import UIKit

class OrderDetailController: RootViewController {

    
    @IBOutlet var stackViewContainer: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configView()
        configText()
    }
    
    
    override func configText() {
        
    }
    
    func configView() {
        let orderCustomerView = Bundle.main.loadNibNamed("OrderCustomerView", owner: self, options: [:])?.first as! OrderCustomerView
        orderCustomerView.navigationController = self.navigationController
        stackViewContainer.insertArrangedSubview(orderCustomerView, at: stackViewContainer.arrangedSubviews.count)
    }
}
