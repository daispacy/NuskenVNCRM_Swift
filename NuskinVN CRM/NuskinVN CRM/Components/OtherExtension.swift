//
//  OtherExtension.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 11/3/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import Foundation
import UIKit

class CButtonWithImageRight1: UIButton {
    override func layoutSubviews() {
        super.layoutSubviews()
        imageEdgeInsets = UIEdgeInsetsMake(0, frame.size.width-5, 0, 25)
        titleEdgeInsets = UIEdgeInsetsMake(0, -15, 0, 0)
    }
}

class CButtonWithImageRight2: UIButton {
    override func layoutSubviews() {
        super.layoutSubviews()
        imageEdgeInsets = UIEdgeInsetsMake(0, frame.size.width - 10, 0, 20)
        titleEdgeInsets = UIEdgeInsetsMake(0, -13, 0, 0)
    }
}

extension UIImagePickerController {
    open override func viewDidLoad() {
        super.viewDidLoad()
        // prevent sync data while working with order
        print("REMOVE LOOP SYNC WHEN UIImagePickerController OPENED")
        LocalService.shared.timerSyncToServer?.invalidate()
    }
}

extension UIView {
    func takeSnapshotOfView() -> UIImage? {
        UIGraphicsBeginImageContext(CGSize(width: self.frame.size.width, height: self.frame.size.height))
        self.drawHierarchy(in: CGRect(x: 0.0, y: 0.0, width: self.frame.size.width, height: self.frame.size.height), afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    func startLoading(activityIndicatorStyle:UIActivityIndicatorViewStyle) {
        stopLoading()
        
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: activityIndicatorStyle)
        self.addSubview(indicator)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        indicator.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        indicator.startAnimating()
    }
    
    func stopLoading() {
        _ = self.subviews.map({
            if $0.isKind(of:UIActivityIndicatorView.self) {
                $0.removeFromSuperview()
            }
        })
    }
    
    func getWindowCenter(to containerView: UIView) -> CGPoint {
        let targetRect = self.convert(self.bounds , to: containerView)
        return targetRect.center
    }
    
    func getWindowTop(to containerView: UIView) -> CGPoint {
        let targetRect = self.convert(self.bounds , to: containerView)
        return targetRect.origin
    }
}

extension Bundle {
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    var buildVersionNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
}

extension UINavigationController {
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.providesPresentationContextTransitionStyle = true
        self.definesPresentationContext = true
        self.modalPresentationStyle=UIModalPresentationStyle.overCurrentContext
    }
}

// MARK: - Timer
final class TimerInvocation: NSObject {
    
    var callback: () -> ()
    
    init(callback: @escaping () -> ()) {
        self.callback = callback
    }
    
    func invoke(timer:Timer) {
        callback()
    }
}

extension Timer {
    
    static func scheduleTimer(timeInterval: TimeInterval, repeats: Bool, invocation: TimerInvocation) {
        
        Timer.scheduledTimer(
            timeInterval: timeInterval,
            target: invocation,
            selector: #selector(TimerInvocation.invoke(timer:)),
            userInfo: nil,
            repeats: repeats)
    }
}
