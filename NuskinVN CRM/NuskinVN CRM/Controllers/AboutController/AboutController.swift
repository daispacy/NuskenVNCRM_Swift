//
//  PopupController.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 10/2/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import UIKit

class AboutController: UIViewController {

    @IBOutlet var vwOverlay: UIView!
    @IBOutlet weak var btnUpdate: UIButton!
    @IBOutlet weak var lblVersion: UILabel!
    @IBOutlet weak var lblNewVersion: UILabel!
    @IBOutlet weak var lblDev: UILabel!
    @IBOutlet weak var lblAppName: CLabelGradient!
    @IBOutlet weak var vwInformation: UIView!
    
    var tapGesture:UITapGestureRecognizer!
    var linkItunes:String?
    
    // MARK: - INIT
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        self.providesPresentationContextTransitionStyle = true
        self.definesPresentationContext = true
        self.modalPresentationStyle=UIModalPresentationStyle.overCurrentContext
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dissMissView))
        vwOverlay.addGestureRecognizer(tapGesture)
        
        configText()
        configView()
    }
   
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        vwInformation.transform = CGAffineTransform(scaleX: 0, y: 0.5)
        let server = SyncService.self
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: [], animations: {
            self.vwInformation.transform = .identity // get back to original scale in an animated way
        }, completion: {[weak self] done in
            guard let _self = self else {return}
            _self.btnUpdate.startAnimation(activityIndicatorStyle: .gray)
            server.shared.getVersion { ver, link in
                _self.btnUpdate.stopAnimation()
                _self.linkItunes = link
                if let verApp = Bundle.main.releaseVersionNumber {
                    if ver != verApp {
                        _self.lblNewVersion.isHidden = false
                        _self.lblNewVersion.text = "\("version_newest".localized()): \(ver)"
                    } else {
                        _self.btnUpdate.isHidden = true
                        _self.lblNewVersion.isHidden = true
                    }
                }
            }
        })
    }
    
    deinit {
        vwOverlay.removeGestureRecognizer(tapGesture)
        print("deinit PopupCustomerFunctionController")
    }
    
    @IBAction func update(_ sender: Any) {
        guard let linkI = self.linkItunes else { return }
        self.openDeepLink(linkItunes: linkI)
    }
    
    
    // MARK: - PRIVATE
    func openDeepLink(linkItunes:String) {
        if let url = URL(string:linkItunes) {
            let installed = UIApplication.shared.canOpenURL(url)
            if installed {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                if let urlLink = URL(string: linkItunes) {
                    if UIApplication.shared.canOpenURL(urlLink) {
                        UIApplication.shared.open(urlLink, options: [:], completionHandler: nil)
                    }
                }
            }
        }
    }
    
    func configView() {
        lblAppName.font = UIFont(name: Theme.font.bold, size: Theme.fontSize.medium)
        
        lblVersion.textColor = UIColor(hex:Theme.colorAlertTextNormal)
        lblVersion.font = UIFont(name: Theme.font.normal, size: Theme.fontSize.normal)
        
        lblNewVersion.textColor = UIColor(hex:Theme.colorAlertTextNormal)
        lblNewVersion.font = UIFont(name: Theme.font.normal, size: Theme.fontSize.normal)
        
        lblDev.textColor = UIColor(hex:Theme.colorAlertTextNormal)
        lblDev.font = UIFont(name: Theme.font.normal, size: Theme.fontSize.normal)
        
        vwInformation.layer.cornerRadius = 10;
        vwInformation.clipsToBounds      = true;
    }
    
    func configText() {
        lblAppName.text = "NuskinVN CRM"
        lblVersion.text = "\("version".localized()): \(Bundle.main.releaseVersionNumber ?? "???")"
        lblDev.text = "\("develop_by_dera".localized()) ©\(Date().currentYear)"
        btnUpdate.setTitle("update".localized(), for: UIControlState())
    }
    
    func dissMissView () {
        dismiss(animated: false, completion: nil)
    }
}
