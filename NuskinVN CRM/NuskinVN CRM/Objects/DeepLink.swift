//
//  DeepLink.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 10/13/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import Foundation
import UIKit

enum DeeplinkType {
    enum Messages {
        case root
        case details(id: String)
    }
    case messages(Messages)
    case activity
    case newListing
    case request(id: String)
}

let Deeplinker = DeepLinkManager()
class DeepLinkManager {
    fileprivate init() {}
    private var deeplinkType: DeeplinkType?
    // check existing deepling and perform action
    func checkDeepLink() {
        guard let deeplinkType = deeplinkType else {
            return
        }
        
        DeeplinkNavigator().proceedToDeeplink(deeplinkType)
        // reset deeplink after handling
        self.deeplinkType = nil // (1)
    }
    
    @discardableResult
    func handleDeeplink(url: URL) -> Bool {
        deeplinkType = DeeplinkParser.shared.parseDeepLink(url)
        return deeplinkType != nil
    }
}

class DeeplinkNavigator {
    static let shared = DeeplinkNavigator()
    init() { }
    
    func proceedToDeeplink(_ type: DeeplinkType) {
        switch type {
        case .activity:
//            displayAlert(title: "Activity")
            break
        case .messages(.root):
//            displayAlert(title: "Messages Root")
            break
        case .messages(.details(id: let id)):
//            displayAlert(title: "Messages Details \(id)")
            break
        case .newListing:
//            displayAlert(title: "New Listing")
            break
        case .request(id: let id):
            displayAlert(title: "Request Details \(id)")
            break
        }
    }
}

class DeeplinkParser {
    static let shared = DeeplinkParser()
    private var deeplinkType: DeeplinkType?
    private init() { }
    
    func parseDeepLink(_ url: URL) -> DeeplinkType? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true), let host = components.host else {
            return nil
        }
        var pathComponents = components.path.components(separatedBy: "/")
        // the first component is empty
        pathComponents.removeFirst()
        switch host {
        case "messages":
            if let messageId = pathComponents.first {
                return DeeplinkType.messages(.details(id: messageId))
            }
        case "request":
            if let requestId = pathComponents.first {
                return DeeplinkType.request(id: requestId)
            }
        default:
            break
        }
        return nil
    }
}

private var alertController = UIAlertController()
private func displayAlert(title: String) {
    alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
    let okButton = UIAlertAction(title: "Ok", style: .default, handler: nil)
    alertController.addAction(okButton)
    if let vc = UIApplication.shared.keyWindow?.rootViewController {
        if vc.presentedViewController != nil {
            alertController.dismiss(animated: false, completion: {
                vc.present(alertController, animated: true, completion: nil)
            })
        } else {
            vc.present(alertController, animated: true, completion: nil)
        }
    }
}
