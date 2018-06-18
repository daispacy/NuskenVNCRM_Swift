//
//  TempController.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 11/28/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import UIKit

class TempController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.pushViewController(DashboardViewController(), animated: false)
    }
}

extension TempController {
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        if(self.presentedViewController != nil) {
            return false
        }
        
        if tabBarController.tabBar.selectedItem?.tag == 1 {
            let itemTabbar = UITabBarItem(title: "dashboard".localized().uppercased(), image: UIImage(named: "tabbar_dashboard"), selectedImage: UIImage(named: "tabbar_dashboard")?.withRenderingMode(.alwaysOriginal))
            itemTabbar.tag = 9
            tabBarItem  = itemTabbar
            let nv = self.tabBarController?.viewControllers![1] as! UINavigationController
            nv.popToRootViewController(animated: true)
        } else {
            if tabBarItem.tag == 10 {
                self.navigationController?.pushViewController(CustomerListController(nibName: "CustomerListController", bundle: Bundle.main), animated: false)
            } else if tabBarItem.tag == 9 {
                self.navigationController?.pushViewController(DashboardViewController(), animated: false)
            }
        }
        return true
    }
    
}
