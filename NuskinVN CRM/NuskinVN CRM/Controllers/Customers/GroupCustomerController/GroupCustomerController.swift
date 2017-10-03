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
UITabBarControllerDelegate {

    @IBOutlet var vwOverlay: UIView!
    @IBOutlet var collectView: UICollectionView!
    
    var listGroups:Array<Any>!
    let defaultItem:Any = {
        return ["title":"add_group".localized(),"iconfont":"\u{f067}"]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
         configText()
        
        listGroups = []
        listGroups.append(defaultItem)
        listGroups.append(defaultItem)
        listGroups.append(defaultItem)
        listGroups.append(defaultItem)
        listGroups.append(defaultItem)
        
        // Do any additional setup after loading the view.
        collectView.register(UINib(nibName: "GroupCollectCustomerCell", bundle: Bundle.main), forCellWithReuseIdentifier: "cell")
        
        tabBarController?.delegate = self
        
        collectView.reloadData()
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
        cell.show(data: listGroups![indexPath.row] as! [String : Any])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listGroups.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
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

extension GroupCustomerController {
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
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
