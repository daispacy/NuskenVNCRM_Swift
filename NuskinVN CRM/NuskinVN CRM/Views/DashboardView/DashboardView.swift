//
//  DashboardView.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 9/22/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import UIKit

protocol DashboardViewDelegate: class {
    
}

class DashboardView: UIView {

    
    @IBOutlet var stackView: UIStackView!
    
    weak var delegate_: DashboardViewDelegate?
    
}
