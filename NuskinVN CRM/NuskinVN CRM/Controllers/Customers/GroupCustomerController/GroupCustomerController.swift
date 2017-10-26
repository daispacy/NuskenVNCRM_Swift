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
    
    var onSelectGroup:((GroupDO)->Void)?
    var gotoFromCustomerList:Bool = false
    
    var listGroups:[GroupDO]!
    let defaultItem:GroupDO = {
        let group = GroupDO(needSave: false, context: CoreDataStack.sharedInstance.persistentContainer.viewContext)
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
    
    func showPopupGroup(object:GroupDO? = nil) {
        let vc = AddGroupController(nibName: "AddGroupController", bundle: Bundle.main)
        
        present(vc, animated: false, completion: {done in
            if let obj = object {
                vc.setEditGroup(gr: obj)
            }
        })
        vc.onAddGroup = {[weak self] group in
            if let _self = self {
                group.synced = false
                GroupManager.updateGroupEntity(group, onComplete: {
                    _self.refreshList()
                })
            }
        }
    }
}

// MARK: - COLLECTVIEW DELEGATE & DATASOURCE
extension GroupCustomerController {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:GroupCollectCustomerCell = collectView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! GroupCollectCustomerCell
        
        cell.show(data: listGroups[indexPath.row])
        cell.onSelectOption = { [weak self]
            sender, group in
            guard let _self = self else { return }
            let popup = PopupOptionGroupController(nibName: "PopupOptionGroupController", bundle: Bundle.main)
            popup.onSelect = {[weak self]
                option in
                guard let _self = self else { return }
                switch option.tag {
                case 2:
                    Support.popup.showAlert(message: "would_you_like_delete_group".localized(), buttons: ["cancel".localized(),"ok".localized()], vc: _self, onAction: { [weak self]
                        i in
                        if let _self = self {
                            if i == 1 {
                                let gr = group
                                gr.status = 0
                                gr.synced = false
                                // delete if group not synced
                                if gr.id == 0 {
                                    GroupManager.deleteGroupEntity(gr, onComplete: {
                                        _self.refreshList()
                                    })
                                } else {
                                    GroupManager.updateGroupEntity(gr, onComplete: {
                                        _self.refreshList()
                                    })
                                }
                            }
                        }
                    })
                        print("test")
                default:
                    _self.showPopupGroup(object: group)
                    break
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
            _self.present(popup, animated: false, completion: nil)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listGroups.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let obj:GroupDO = listGroups[indexPath.row]
        if obj.isTemp == true {
            showPopupGroup()
        } else {
            if gotoFromCustomerList {
                let vc = CustomerDetailController(nibName: "CustomerDetailController", bundle: Bundle.main)
                self.navigationController?.pushViewController(vc, animated: true)
                vc.setGroupSelected(group: obj)
            } else {
                onSelectGroup?(obj)
                self.navigationController?.popViewController(animated: true)
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
