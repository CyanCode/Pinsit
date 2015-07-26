//
//  ErrorReport.swift
//  Pinsit
//
//  Created by Walker Christie on 7/16/15.
//  Copyright © 2015 Walker Christie. All rights reserved.
//

import Foundation
import PPTopMostController
import TSMessages

class ErrorReport {
    var viewController: UIViewController!
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    init() {
        viewController = UIViewController.topMostController()
    }
    
    func presentError(title: String, message: String, type: TSMessageNotificationType) {
        TSMessage.showNotificationInViewController(viewController, title: title, subtitle: message, type: type)
    }
    
    func presentWithType(type: ErrorReportType) {
        switch type {
        case .Network: presentError("Network Error", message: "Could not connect to the internet.  Check your network connection!", type: .Error)
        case .Email: presentError("Verify Email", message: "Your email must be verified before you can post videos, do so through Settings", type: .Error)
        case .Phone: presentError("Verify Phone", message: "Your phone number must be verified before you can post videos, do so through Settings", type: .Error)
        case .Username: presentError("Too Short", message: "Your username must be atleast 5 characters long!", type: .Warning)
        case .Password: presentError("Too Short", message: "Your password must be atleast 6 characters long!", type: .Warning)
        }
    }
}

enum ErrorReportType {
    case Network
    case Email
    case Phone
    
    case Username
    case Password
}