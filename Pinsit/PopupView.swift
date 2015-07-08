//
//  PopupView.swift
//  Pinsit
//
//  Created by Walker Christie on 2/21/15.
//  Copyright (c) 2015 Walker Christie. All rights reserved.
//

import Foundation
import UIKit

class PopupView {
    private var presentedView: UIView!
    private var viewController: UIViewController!
    private var container: UIView!
    
    ///Default initialization
    ///
    ///- parameter presentedView: The UIView that will be presented inside the popover
    init(presentedView: UIView) {
        self.presentedView = presentedView
        constructContainer()
    }
    
    func showWithViewController(viewController: UIViewController) {
        self.viewController = viewController
        
        container.addSubview(presentedView)
        presentedView.center = container.convertPoint(container.center, fromView: container.superview)
        
        let vcView = viewController.view
        vcView.addSubview(container)
        container.center = vcView.convertPoint(vcView.center, fromView: vcView.superview)

        self.animateIn()
    }
    
    func closePopup() {
        self.animateOut()
    }
    
    private func animateIn() {
        container.transform = CGAffineTransformMakeScale(1.3, 1.3)
        container.alpha = 0
        
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            self.container.alpha = 1
            self.container.transform = CGAffineTransformMakeScale(1, 1)
        })
    }
    
    private func animateOut() {
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            self.container.transform = CGAffineTransformMakeScale(1.3, 1.3)
            self.container.alpha = 0
        }) { (finished) -> Void in
            if finished == true {
                self.container.removeFromSuperview()
            }
        }
    }
    
    private func constructContainer() {
        container = UIView(frame: CGRectMake(0, 0, presentedView.frame.width + 5, presentedView.frame.height + 5))
        container.layer.cornerRadius = 5
        container.layer.shadowOpacity = 0.5
        container.layer.shadowOffset = CGSizeMake(0.0, 0.0)
        container.layer.masksToBounds = true
    }
}