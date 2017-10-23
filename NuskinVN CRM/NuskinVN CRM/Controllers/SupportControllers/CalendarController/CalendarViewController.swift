//
//  CalendarViewController.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 9/30/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import UIKit
import Daysquare

class CalendarViewController: UIViewController {

    
    var onSelectDate:((String)->Void)?
    
    var tapGesture:UITapGestureRecognizer?
    @IBOutlet var calendarView: DAYCalendarView!
    @IBOutlet var vwBackGround: UIView!
    
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
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dissmissView))
        vwBackGround.addGestureRecognizer(tapGesture!)
        
        calendarView.addTarget(self, action: #selector(didChangeValue(calendar:)), for: .valueChanged)
        
        calendarView.selectedIndicatorColor = UIColor(_gradient: Theme.colorGradient.reversed(), frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 40.0, height: 40.0)), isReverse: true)
        calendarView.navigationBarColor = UIColor(_gradient: Theme.colorGradient, frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 320.0, height: 80.0)), isReverse: true)
 
        self.calendarView.reload(animated: true)
    }
    
    deinit {
        print("\(String(describing: CalendarViewController.self)) dealloc")
        if(tapGesture != nil) {
            vwBackGround.removeGestureRecognizer(tapGesture!)
        }
    }

    func didChangeValue (calendar:DAYCalendarView) {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY/MM/dd"
        onSelectDate?("\(formatter.string(from: calendar.selectedDate))")        
    }
    
    
    
    func dissmissView() {
        dismiss(animated: false, completion: nil)
    }
}
