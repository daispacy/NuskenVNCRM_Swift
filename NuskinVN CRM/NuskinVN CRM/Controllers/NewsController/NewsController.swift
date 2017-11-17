//
//  NewsController.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 11/15/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import UIKit

class NewsController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stackContainer: UIStackView!
    
    
    // MARK: - INIT
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
//        self.providesPresentationContextTransitionStyle = true
//        self.definesPresentationContext = true
//        self.modalPresentationStyle=UIModalPresentationStyle.overCurrentContext
        title = "news".localized().uppercased()
        
        let btnClose = UIButton(type: .custom)
        btnClose.addTarget(self, action: #selector(self.close(_:)), for: .touchUpInside)
        btnClose.setTitle("close".localized().uppercased(), for: UIControlState())
        let itemNotification = UIBarButtonItem(customView: btnClose)
        
        self.navigationItem.rightBarButtonItems  = [itemNotification]
    }
    
    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SyncService.shared.getNews {[weak self] list in
            guard let _self = self else {return}
            for json in list {
                if let properties = json["properties"] as? JSON {
                    if let photos = properties["photos"] as? [String] {
                        for image in photos {
                            let imv = _self.createImageView()
                            _self.stackContainer.addArrangedSubview(imv)
                            imv.loadImageUsingCacheWithURLString("\(Server.domainImage.rawValue)/upload/1/resources/l_\(image.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)",size: CGSize(width:_self.stackContainer.frame.size.width,height:0), placeHolder: nil)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - private
    func configView() {
        
    }
    
    func createImageView() -> UIImageView {
        let imv = UIImageView(frame: CGRect.zero)
        imv.contentMode = .scaleAspectFill
        return imv
    }
}
