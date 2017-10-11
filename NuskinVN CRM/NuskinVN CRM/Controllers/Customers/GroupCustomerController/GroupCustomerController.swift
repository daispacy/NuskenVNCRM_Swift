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
LocalServiceDelegate {
    
    @IBOutlet var vwOverlay: UIView!
    @IBOutlet var collectView: UICollectionView!
    
    var onSelectGroup:((GroupCustomer)->Void)?
    var localService:LocalService!
    
    var listGroups:[GroupCustomer]!
    let defaultItem:GroupCustomer = {
        var group = GroupCustomer(id: 0, distributor_id: 0, store_id: 0)
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
        
        localService = LocalService.init()
        localService.delegate_ = self
        localService.getAllGroup()
    }

    override func configText() {
        title = "group_customer".localized().uppercased()
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        collectView.reloadData()
    }
    
    // MARK: - private
    func showPopupGroup(object:GroupCustomer? = nil) {
        let vc = AddGroupController(nibName: "AddGroupController", bundle: Bundle.main)
        
        present(vc, animated: false, completion: {done in
            if object != nil {
                vc.setEditGroup(gr: object!)
            }
        })
        vc.onAddGroup = { group in
            if object != nil {
                _ = self.localService.updateGroup(object: group)
            } else {
                _ = self.localService.addGroup(obj: group)
            }
            LocalService.shared().startSyncData()
            self.localService.getAllGroup()
        }
    }
}

// MARK: - COLLECTVIEW DELEGATE & DATASOURCE
extension GroupCustomerController {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:GroupCollectCustomerCell = collectView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! GroupCollectCustomerCell
        
        cell.show(data: listGroups[indexPath.row])
        cell.onSelectOption = {
            sender, group in
            let popup = PopupOptionGroupController(nibName: "PopupOptionGroupController", bundle: Bundle.main)
            popup.onSelect = {
                option in
                switch option.tag {
                case 2:
                    Support.popup.showAlert(message: "would_you_like_delete_group".localized(), buttons: ["cancel".localized(),"ok".localized()], vc: self, onAction: {
                        i in
                        if i == 1 {
                            var gr = group
                            gr.status = 0
                            if self.localService.updateGroup(object: gr) {
                                LocalService.shared().startSyncData()
                                self.localService.getAllGroup()
                            }
                        }
                    })
                    
                default:
                    self.showPopupGroup(object: group)
                }
            }
            popup.show(data: [OptionGroup(name: "edit_group".localized(),
                                          icon: "ic_edit_gradient_36",
                                          tag: 1),
                              OptionGroup(name: "delete_group".localized(),
                                          icon: "ic_delete_gradient_36",
                                          tag: 2),
                              ],
                       fromView: sender as! UIButton)
            self.present(popup, animated: false, completion: nil)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listGroups.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let obj:GroupCustomer = listGroups![indexPath.row]
        if obj.id == 0 {
            showPopupGroup()
        } else {
            onSelectGroup?(obj)
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

// MARK: - Local Services
extension GroupCustomerController {
    
    func localService(localService: LocalService, didFailed: Any, type:LocalServiceType) {
        print("Cant get Group Customer")
    }
    
    func localService(localService: LocalService, didReceiveData: Any, type:LocalServiceType) {
        DispatchQueue.main.async {
            self.listGroups.removeAll()
            let list:[GroupCustomer] = didReceiveData as! [GroupCustomer]
            self.listGroups.append(contentsOf: list)
            self.listGroups.append(self.defaultItem)
            self.collectView.reloadData()
        }
    }
}
