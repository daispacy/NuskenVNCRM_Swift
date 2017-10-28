//
//  PopupController.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 10/2/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import UIKit

class PopupController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var onSelect:((String,Int) -> Void)?
    var onDismiss:(() -> Void)?
    
    var tableView:UITableView!
    var containerTable:UIView!
    @IBOutlet var vwOverlay: UIView!
    var tapGesture:UITapGestureRecognizer!
    var hostView: UIView?
    
    var listData:Array<String>?
    
    let maxHeight:CGFloat = 250
    
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
    }
    
    deinit {
        vwOverlay.removeGestureRecognizer(tapGesture)
        print("deinit PopupController")
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        
        tableView.layoutIfNeeded()
        self.view.layoutIfNeeded()
        
        let point:CGPoint = hostView!.superview!.convert(hostView!.frame.origin, to: nil)
        
        var newframe:CGRect = hostView!.frame
        newframe.origin.x = hostView!.superview!.frame.origin.x
        newframe.origin.y = point.y + hostView!.frame.maxY
        newframe.size.width = hostView!.superview!.frame.size.width
        newframe.size.height = 1
        containerTable.frame = newframe
        var oldframe = newframe
        oldframe.size.width = hostView!.superview!.frame.size.width
        if tableView.contentSize.height > maxHeight {
            oldframe.size.height = maxHeight
        } else {
            oldframe.size.height = tableView.contentSize.height
        }
        
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.containerTable.frame = oldframe
        }) { (_) -> Void in
            
        }
    }
    
    override func viewDidLayoutSubviews() {
        
        let point:CGPoint = hostView!.superview!.convert(hostView!.frame.origin, to: nil)
        
        var newframe:CGRect = hostView!.frame
        newframe.origin.x = hostView!.superview!.frame.origin.x
        newframe.origin.y = point.y + hostView!.frame.maxY
        newframe.size.width = hostView!.superview!.frame.size.width
        newframe.size.height = 1
        containerTable.frame = newframe
        var oldframe = newframe
        oldframe.size.width = hostView!.superview!.frame.size.width
        if tableView.contentSize.height > maxHeight {
            oldframe.size.height = maxHeight
        } else {
            oldframe.size.height = tableView.contentSize.height
        }
        
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.containerTable.frame = oldframe
        }) { (_) -> Void in
            
        }
    }
    
    // MARK:  - INTERFACE
    func show(data:Array<String>? = nil, fromView:UIView) {
        if let dt = data {
            listData = dt
            hostView = fromView
            
            let point:CGPoint = fromView.superview!.convert(fromView.frame.origin, to: nil)
        
            addTableView()
            tableView.reloadSections(IndexSet(integersIn: 0...0), with: UITableViewRowAnimation.top)
            tableView.layoutIfNeeded()
            self.view.layoutIfNeeded()
            
            var newframe:CGRect = fromView.frame
            newframe.origin.x = fromView.superview!.frame.origin.x
            newframe.origin.y = point.y + fromView.frame.maxY
            newframe.size.width = fromView.superview!.frame.size.width
            newframe.size.height = 1
            containerTable.frame = newframe
            var oldframe = newframe
            oldframe.size.width = fromView.superview!.frame.size.width
            if tableView.contentSize.height > maxHeight {
                oldframe.size.height = maxHeight
            } else {
                oldframe.size.height = tableView.contentSize.height
            }
            self.containerTable.frame = oldframe
        }
    }
    
    
    
    // MARK: - PRIVATE
    func addTableView() {
        containerTable = UIView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 1, height: 1)))
        tableView = UITableView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 1, height: 1)), style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 50
        containerTable.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: containerTable.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: containerTable.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: containerTable.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: containerTable.trailingAnchor).isActive = true
        view.addSubview(containerTable)
        
        containerTable.backgroundColor = UIColor.white
        //shadow view also need cornerRadius
        containerTable.layer.cornerRadius = 0
        containerTable.layer.shadowColor = UIColor.lightGray.cgColor
        containerTable.layer.shadowOffset = CGSize(width:0, height:2); //Left-Bottom shadow
        //containerView.layer.shadowOffset = CGSizeMake(10, 10); //Right-Bottom shadow
        containerTable.layer.shadowOpacity = 1.0
        containerTable.layer.shadowRadius = 3
        
    }
    
    func dissMissView () {
        onDismiss?()
        dismiss(animated: false, completion: nil)
    }
}

extension PopupController {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listData!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.text = listData![indexPath.row]
        cell.textLabel?.numberOfLines = 0
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        onSelect?(listData![indexPath.row],indexPath.row)
        self.dissMissView()
    }
}
