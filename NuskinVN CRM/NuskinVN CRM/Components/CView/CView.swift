//
//  CView.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 9/30/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import Foundation
import UIKit
import Localize_Swift

class CView:UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        configView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configView()
    }
    
    func configView() {
        self.layer.cornerRadius = 4;
        self.clipsToBounds = false;
    }
}

class CViewSwitchLanguage:UIView, ReloadedUIView {
    open override func awakeFromNib() {
        super.awakeFromNib()
        registerSwitchLanguage()
    }
    
    deinit {
        afterDeinit()
    }
    
    func registerSwitchLanguage() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadTexts), name: NSNotification.Name( LCLLanguageChangeNotification), object: nil)
    }
    
    func afterDeinit() {
        NotificationCenter.default.removeObserver(self)
        print("remove LCLLanguageChangeNotification")
    }
    
    func reloadTexts() {
        // override
        fatalError("Override this method")
    }
}
