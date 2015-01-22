//
//  TOSViewController.swift
//  Pinsit
//
//  Created by Walker Christie on 1/15/15.
//  Copyright (c) 2015 Walker Christie. All rights reserved.
//

import UIKit

class TOSViewController: UIViewController {
    @IBAction func agreePressed(sender: AnyObject) {
        let user = PFUser.currentUser()
        user["tosverified"] = NSNumber(bool: true)
        user.saveInBackgroundWithBlock { (success, error) -> Void in
            if error != nil {
                let control = UIAlertController(title: "Something went wrong", message: "You must be connected to the internet in order to approve the terms of service!", preferredStyle: .Alert)
                let cancel = UIAlertAction(title: "Dismiss", style: .Cancel, handler: nil)
                control.addAction(cancel)
                self.presentViewController(control, animated: true, completion: nil)
            } else {
                StoryboardManager.segueMain(self)
            }
        }
    }
}
