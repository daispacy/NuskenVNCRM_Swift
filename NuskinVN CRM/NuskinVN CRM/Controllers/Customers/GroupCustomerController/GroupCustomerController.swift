//
//  GroupCustomerController.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 10/3/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import UIKit
import CoreData
import RxSwift
import RxCocoa

class GroupCustomerController: RootViewController,
    UICollectionViewDelegate,
    UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout {
    
    @IBOutlet var vwOverlay: UIView!
    @IBOutlet var collectView: UICollectionView!
    
    var onSelectGroup:((Group)->Void)?
    var gotoFromCustomerList:Bool = false
    
    var listGroups:[Group]!
    let defaultItem:Group = {
        var group = Group()
        group.isTemp = true
        group.group_name = "add_group".localized()
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: ["color":"0xbec2c5"])
            if let pro = String(data: jsonData, encoding: .utf8) {
                group.properties = pro
            }
        }catch{}
        return group
    }()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.didSyncedGroup(notification:)), name: Notification.Name("SyncData:Group"), object: nil)
        
        configText()
        
        listGroups = []
        
        // Do any additional setup after loading the view.
        collectView.register(UINib(nibName: "GroupCollectCustomerCell", bundle: Bundle.main), forCellWithReuseIdentifier: "cell")
        
        refreshList()
        
        if gotoFromCustomerList {
            let rightButtonMenu:UIButton = UIButton(type: .custom)
            rightButtonMenu.setTitle("skip".localized(), for: .normal)
            rightButtonMenu.titleLabel?.font = UIFont(name: Theme.font.normal, size: Theme.fontSize.normal)
            rightButtonMenu.setTitleColor(UIColor.white, for: .normal)
            rightButtonMenu.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            rightButtonMenu.rx.tap.subscribe(onNext: {[weak self] in
                if let _self = self {
                    let vc = CustomerDetailController(nibName: "CustomerDetailController", bundle: Bundle.main)
                    _self.navigationController?.pushViewController(vc, animated: true)
                }
            }).disposed(by: disposeBag)
            let item2 = UIBarButtonItem(customView: rightButtonMenu)
            self.navigationItem.rightBarButtonItem  = item2
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func configText() {
        title = "group_customer".localized().uppercased()
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        collectView.reloadData()
    }
    
    func didSyncedGroup(notification:Notification) {
        refreshList()
    }
    
    // MARK: - private
    func refreshList() {
        GroupManager.getAllGroup(onComplete: {[weak self] list in
            if let _self = self {
                _self.listGroups.removeAll()
                _self.listGroups = list
                _self.listGroups.append(_self.defaultItem)
                _self.collectView.reloadData()
            }
        })
    }
    
    func showPopupGroup(object:Group? = nil) {
        let vc = AddGroupController(nibName: "AddGroupController", bundle: Bundle.main)
        
        present(vc, animated: false, completion: {done in
            if let obj = object {
                vc.setEditGroup(gr: obj)
            }
        })
        vc.onAddGroup = {[weak self] group in
            if let _self = self {
                var obj = group
                obj.synced = false
                GroupManager.update([obj.toDO]) {
                    _self.refreshList()
                }
            }
        }
    }
    
    func selectAction(obj:Group) {
        
        if obj.isTemp == true {
            showPopupGroup()
            return
        }
        
        let alertController = UIAlertController(title: nil, message: "\("group".localized().uppercased()): \(obj.group_name.uppercased())", preferredStyle: UIAlertControllerStyle.actionSheet)
        let cancelAction = UIAlertAction(title: "cancel".localized(), style: UIAlertActionStyle.cancel) { (result : UIAlertAction) -> Void in
            alertController.dismiss(animated: true, completion: nil)
        }
        
        let okAction = UIAlertAction(title: "add_user".localized(), style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
            let vc = CustomerDetailController(nibName: "CustomerDetailController", bundle: Bundle.main)
            self.navigationController?.pushViewController(vc, animated: true)
            vc.setGroupSelected(group: obj)
        }
        
        let editAction = UIAlertAction(title: "edit_group".localized(), style: UIAlertActionStyle.destructive) { (result : UIAlertAction) -> Void in
            self.showPopupGroup(object: obj)
        }
        
        let deleteAction = UIAlertAction(title: "delete_group".localized(), style: UIAlertActionStyle.destructive) { (result : UIAlertAction) -> Void in
            Support.popup.showAlert(message: "would_you_like_delete_group".localized(), buttons: ["cancel".localized(),"ok".localized()], vc: self.navigationController!, onAction: { [weak self]
                i in
                if let _self = self {
                    if i == 1 {
                        var gr = obj
                        gr.status = 0
                        gr.synced = false
                        GroupManager.update([gr.toDictionary]){
                            _self.refreshList()
                        }
//                        // delete if group not synced
//                        if gr.id == 0 {
//                            GroupManager.update([gr.toDictionary]){
//                                _self.refreshList()
//                            }
//                        } else {
//                            GroupManager.update(gr, onComplete: {
//                                _self.refreshList()
//                            })
//                        }
                    }
                }
                },nil)
        }
        
        let emailAction = UIAlertAction(title: "send_email".localized(), style: UIAlertActionStyle.destructive) { (result : UIAlertAction) -> Void in
            if let user = UserManager.currentUser() {
                let vc1 = EmailController(nibName: "EmailController", bundle: Bundle.main)
                let nv = UINavigationController(rootViewController: vc1)
                vc1.navigationController?.setNavigationBarHidden(true, animated: false)
                Support.topVC!.present(nv, animated: true, completion: {
                    vc1.show(from: user.email!, to: obj.getListEmailCustomers())
                })
            }
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        alertController.addAction(emailAction)
        
        if ((obj.distributor_id == 0 && obj.id > 0) || obj.isTemp) {
            
        } else {
            alertController.addAction(editAction)
            alertController.addAction(deleteAction)
        }
        Support.topVC?.present(alertController, animated: true, completion: nil)
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
        
        let obj:Group = listGroups[indexPath.row]
        if self.gotoFromCustomerList {
            self.selectAction(obj: obj)
        } else {
            self.onSelectGroup?(obj)
            self.navigationController?.popViewController(animated: true)
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
