//
//  DatePickerController.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 10/11/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import UIKit

class DatePickerController: UIViewController {

    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet var vwOveray: UIView!
    @IBOutlet var lblTitle: CLabelGradient!
    
    var onSelectDate:((String)->Void)?
    var tapGesture:UITapGestureRecognizer?
    
    // MARK: - INIT
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        self.providesPresentationContextTransitionStyle = true
        self.definesPresentationContext = true
        self.modalPresentationStyle=UIModalPresentationStyle.overCurrentContext
        restoresFocusAfterTransition = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dissmissView))
        vwOveray.addGestureRecognizer(tapGesture!)
        
        configView()
    }

    deinit {
        vwOveray.removeGestureRecognizer(tapGesture!)
    }
    
    // MARK: - interface
    func setTitle(title:String) {
        lblTitle.text = title
        lblTitle.setNeedsDisplay()
    }
    
    func setDate(date:Date) {
        self.datePicker.setDate(date, animated: true)
    }
    
    // MARK: - event
    @IBAction func selectDate(_ sender: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/YYYY"
        onSelectDate?("\(formatter.string(from: sender.date))")
    }
    
    func dissmissView() {
        dismiss(animated: false, completion: nil)
    }
    
    // MARK: - private
    private func configView() {
        lblTitle.font = UIFont(name: Theme.font.bold, size: Theme.fontSize.medium)
    }
}
