//
//  Protocols.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 10/2/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import Foundation
import SQLite

@objc protocol ReloadedUIView {
    @objc optional func registerSwitchLanguage()
    @objc optional func reloadTexts()
    @objc optional func afterDeinit()    
}
