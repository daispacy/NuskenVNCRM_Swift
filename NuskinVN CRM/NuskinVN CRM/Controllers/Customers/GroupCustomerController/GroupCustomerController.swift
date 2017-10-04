//
//  GroupCustomerController.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 10/3/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import UIKit

class GroupCustomerController: RootViewController,
UICollectionViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout,
UITabBarControllerDelegate,
LocalServiceDelegate {
    
    @IBOutlet var vwOverlay: UIView!
    @IBOutlet var collectView: UICollectionView!
    
    var localService:LocalService!
    
    var listGroups:[GroupCustomer]!
    let defaultItem:GroupCustomer = {
        var group = GroupCustomer(id: 0)
        group.name = "add_group".localized()
        group.color = "0xbec2c5"
        return group
    }()
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
         configText()
        
        listGroups = []
        
        // Do any additional setup after loading the view.
        collectView.register(UINib(nibName: "GroupCollectCustomerCell", bundle: Bundle.main), forCellWithReuseIdentifier: "cell")
        
        tabBarController?.delegate = self
        
        localService = LocalService.init()
        localService.delegate_ = self
        localService.getAllGroup()
    }

    override func configText() {
        title = "group_customer".localized().uppercased()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let itemTabbar = UITabBarItem(title: "title_tabbar_button_dashboard".localized(), image: UIImage(named: "tabbar_dashboard"), selectedImage: UIImage(named: "tabbar_dashboard")?.withRenderingMode(.alwaysOriginal))
        itemTabbar.tag = 9
        tabBarItem  = itemTabbar
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        collectView.reloadData()
    }
}

// MARK: - COLLECTVIEW DELEGATE & DATASOURCE
extension GroupCustomerController {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:GroupCollectCustomerCell = collectView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! GroupCollectCustomerCell
        
        cell.show(data: listGroups[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listGroups.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let obj:GroupCustomer = listGroups![indexPath.row]
            if obj.id == 0 {
                let vc = AddGroupController(nibName: "AddGroupController", bundle: Bundle.main)
                present(vc, animated: false, completion: nil)
                vc.onAddGroup = { group in
                    if self.localService.addGroup(obj: group) {
                        self.localService.getAllGroup()
                    }                    
                }
            }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let widthCollect = self.collectView.frame.size.width
        var width = round(((widthCollect-2) / 2))
        if(self.collectView.frame.size.height < self.collectView.frame.size.width) {
//            widthCollect = self.collectView.frame.size.height
            width = round(((widthCollect-4) / 4))
        }
        
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
}

// MARK: - Local Services
extension GroupCustomerController {
    
    func localService(localService: LocalService, didFailed: Any) {
        print("Cant get Group Customer")
    }
    
    func localService(localService: LocalService, didReceiveData: Any) {
        listGroups.removeAll()
        let list:[GroupCustomer] = didReceiveData as! [GroupCustomer]
        listGroups.append(contentsOf: list)
        listGroups.append(defaultItem)
        collectView.reloadData()
    }
}

// MARK: - tabbar delegate
extension GroupCustomerController {
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        if(self.presentedViewController != nil) {
            return false
        }
        
        if tabBarController.tabBar.selectedItem?.tag == 1 {
            let itemTabbar = UITabBarItem(title: "title_tabbar_button_customer".localized(), image: UIImage(named: "tabbar_customer"), selectedImage: UIImage(named: "tabbar_customer")?.withRenderingMode(.alwaysOriginal))
            itemTabbar.tag = 10
            tabBarItem  = itemTabbar
        } else {
            if tabBarItem.tag == 9 {
                AppConfig.navigation.changeController(to: DashboardViewController(), on: tabBarController, index: 0)
            }
        }
        return true
    }
}
