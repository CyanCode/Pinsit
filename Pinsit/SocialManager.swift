//
//  SocialManager.swift
//  Pinsit
//
//  Created by Walker Christie on 2/10/15.
//  Copyright (c) 2015 Walker Christie. All rights reserved.
//

import Foundation
import Social
import Parse

class SocialManager {
    var viewController: UIViewController!
    
    init(vc: UIViewController) {
        self.viewController = vc
    }
    
    func displayShareDialog(type: SocialType) {
        let compose = getDialog(type)
        
        if compose != nil {
            viewController.presentViewController(compose!, animated: true, completion: nil)
        }
    }
    
    private func getDialog(type: SocialType) -> SLComposeViewController? {
        if type == .Facebook && confirmFacebookAvailable() == true {
            let compose = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            compose.setInitialText("Follow me on Pinsit @\(PFUser.currentUser()!.username!)")
            
            return compose
        } else if type == .Twitter && confirmTwitterAvailable() == true {
            let compose = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            compose.setInitialText("Follow me on Pinsit @\(PFUser.currentUser()!.username!)")
            
            return compose
        }
        
        return nil
    }
    
    private func confirmFacebookAvailable() -> Bool {
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook) {
            return true
        } else {
            let alert = UIAlertController(title: "Somethings Missing", message: "Make sure you have Facebook setup in your iOS settings", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .Cancel, handler: nil))
            viewController.presentViewController(alert, animated: true, completion: nil)
            
            return false
        }
    }
    
    private func confirmTwitterAvailable() -> Bool {
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter) {
            return true
        } else {
            let alert = UIAlertController(title: "Somethings Missing", message: "Make sure you have Twitter setup in your iOS settings", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .Cancel, handler: nil))
            viewController.presentViewController(alert, animated: true, completion: nil)
            
            return false
        }
    }
}

enum SocialType {
    case Twitter
    case Facebook
}