//
//  TOSViewController.swift
//  Pinsit
//
//  Created by Walker Christie on 1/15/15.
//  Copyright (c) 2015 Walker Christie. All rights reserved.
//

import UIKit
import Parse

class TOSViewController: UIViewController {
    @IBAction func agreePressed(sender: AnyObject) {
        let user = PFUser.currentUser()
        user!["tosverified"] = NSNumber(bool: true)
        user!.saveInBackgroundWithBlock { (success, error) -> Void in
            
            if error != nil {
                let alert = RegistrationAlerts(vc: self)
                
                if error!.code == PFErrorCode.ErrorConnectionFailed.rawValue {
                    alert.tosConnection()
                } else {
                    alert.unknownError()
                }
            } else {
                StoryboardManager.segueMain(self)
            }
        }
    }
}
