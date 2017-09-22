//
//  DashboardViewController.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 9/22/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import UIKit

class DashboardViewController: RootViewController, DashboardViewDelegate {
    
    private var dashboardView:DashboardView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }

    override func loadView() {
        dashboardView = Bundle.main.loadNibNamed(String(describing: DashboardView.self), owner: self, options: nil)?.first as! DashboardView
        dashboardView.delegate_ = self
        self.view = dashboardView
    }
}
