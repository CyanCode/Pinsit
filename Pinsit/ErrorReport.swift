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
        }
    }
}

enum ErrorReportType {
    case Network
}