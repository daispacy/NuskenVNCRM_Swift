//
//  PopupController.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 10/2/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import UIKit

struct OptionGroup {
    var name:String!
    var icon:String!
    var tag:Int!
    
    init(name:String,icon:String,tag:Int) {
        self.name = name
        self.icon = icon
        self.tag = tag
    }
}

class PopupOptionGroupController: UIViewController{

    var onSelect:((OptionGroup) -> Void)?
    var onDismiss:(() -> Void)?
    
    var tableView:UIStackView!
    var containerTable:UIView!
    @IBOutlet var vwOverlay: UIView!
    var tapGesture:UITapGestureRecognizer!
    var hostView: UIView?
    
    var listData:Array<OptionGroup>!
    
    let maxHeight:CGFloat = {
        return 250
    }()
    
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
        let point:CGPoint = hostView!.superview!.convert(hostView!.frame.origin, to: nil)
        
        hostView?.superview?.setNeedsDisplay()
        
        var newframe:CGRect = hostView!.frame
        newframe.origin.x = hostView!.superview!.frame.origin.x
        newframe.origin.y = point.y + hostView!.frame.maxY
        newframe.size.width = hostView!.superview!.frame.size.width
        newframe.size.height = 1
        containerTable.frame = newframe
        var oldframe = newframe
        oldframe.size.width = hostView!.superview!.frame.size.width
        if CGFloat(listData!.count*40) + 20 + CGFloat((listData!.count-1)*5) > maxHeight {
            oldframe.size.height = maxHeight
        } else {
            oldframe.size.height = CGFloat(listData!.count*40) + 20 + CGFloat((listData!.count-1)*5)
        }
      
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.containerTable.frame = oldframe
        }) { (_) -> Void in
            
        }
    }
    
    // MARK: - event
    func optionPress(_ sender:UIButton) {
        dissMissView()
        var option: OptionGroup!
        _ = self.listData.map({
            if $0.tag == sender.tag {
                option = $0
            }
        })
        
        if option != nil {
            self.onSelect?(option)
        }
    }
    
    // MARK:  - INTERFACE
    func show(data:Array<OptionGroup>? = nil, fromView:UIView) {
        if let dt = data {
            listData = dt
            hostView = fromView
            
            let point:CGPoint = fromView.superview!.convert(fromView.frame.origin, to: nil)
            addTableView()
            
            // add data
            _ = dt.map({
                let btn:UIButton = UIButton(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 1, height: 1)))
                btn.setTitle($0.name, for: .normal)
                btn.setTitleColor(UIColor(hex:Theme.color.customer.titleGroup), for: .normal)
                btn.titleLabel?.font = UIFont(name: Theme.font.normal, size: Theme.fontSize.normal)
                btn.setImage(UIImage(named:$0.icon), for: .normal)
                btn.tag = $0.tag
                btn.contentHorizontalAlignment = .left
                btn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
                btn.addTarget(self, action: #selector(self.optionPress(_:)), for: .touchUpInside)
                tableView.insertArrangedSubview(btn, at: tableView.arrangedSubviews.count)
                btn.translatesAutoresizingMaskIntoConstraints = false
                btn.heightAnchor.constraint(equalToConstant: 40)
            })
            
            var newframe:CGRect = fromView.frame
            newframe.origin.x = fromView.superview!.frame.origin.x
            newframe.origin.y = point.y + fromView.frame.maxY
            newframe.size.width = fromView.superview!.frame.size.width
            newframe.size.height = 1
            containerTable.frame = newframe
            var oldframe = newframe
            oldframe.size.width = fromView.superview!.frame.size.width
            if CGFloat(listData!.count*40) + 20 + CGFloat((listData!.count-1)*5) > maxHeight {
                oldframe.size.height = maxHeight
            } else {
                oldframe.size.height = CGFloat(listData!.count*40) + 20 + CGFloat((listData!.count-1)*5)
            }
 
            self.view.layoutIfNeeded()
            UIView.animate(withDuration:0.5, animations: { () -> Void in
                self.containerTable.frame = oldframe
            }) { (_) -> Void in
            }
        }
    }
    
    // MARK: - PRIVATE
    func addTableView() {
        containerTable = UIView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 1, height: 1)))
        tableView = UIStackView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 1, height: 1)))
        tableView.axis = .vertical
        tableView.spacing = 10
        containerTable.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: containerTable.topAnchor,constant: 40).isActive = true
//        tableView.bottomAnchor.constraint(equalTo: containerTable.bottomAnchor,constant: 20).isActive = true
        tableView.leadingAnchor.constraint(equalTo: containerTable.leadingAnchor,constant: 10).isActive = true
        tableView.trailingAnchor.constraint(equalTo: containerTable.trailingAnchor,constant: 10).isActive = true
        view.addSubview(containerTable)
        
        let btnDissmiss = UIButton(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 1, height: 1)))
        btnDissmiss.addTarget(self, action: #selector(self.dissMissView), for: .touchUpInside)
        containerTable.addSubview(btnDissmiss)
        btnDissmiss.translatesAutoresizingMaskIntoConstraints = false
        btnDissmiss.widthAnchor.constraint(equalToConstant: 40).isActive = true
        btnDissmiss.heightAnchor.constraint(equalToConstant: 30).isActive = true
        btnDissmiss.topAnchor.constraint(equalTo: containerTable.topAnchor, constant: 5).isActive = true
        btnDissmiss.trailingAnchor.constraint(equalTo: containerTable.trailingAnchor).isActive = true
        btnDissmiss.setImage(UIImage(named: "ic_close_36"), for: .normal)
        
        containerTable.backgroundColor = UIColor.white
        //shadow view also need cornerRadius
        containerTable.layer.cornerRadius = 5
        containerTable.layer.shadowColor = UIColor.lightGray.cgColor
        containerTable.layer.shadowOffset = CGSize(width:0, height:2); //Left-Bottom shadow
        //containerView.layer.shadowOffset = CGSizeMake(10, 10); //Right-Bottom shadow
        containerTable.layer.shadowOpacity = 1.0
        containerTable.layer.shadowRadius = 3
//        containerTable.clipsToBounds = true
        
    }
    
    func dissMissView () {
        onDismiss?()
        dismiss(animated: false, completion: nil)
    }
}
