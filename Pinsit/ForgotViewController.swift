//
//  ForgotViewController.swift
//  Pinsit
//
//  Created by Walker Christie on 1/15/15.
//  Copyright (c) 2015 Walker Christie. All rights reserved.
//

import UIKit

class ForgotViewController: UIViewController {
    @IBOutlet var email: UITextField!
    
    @IBAction func resetButton(sender: AnyObject) {
        var error: NSError?
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            let user = PFUser.requestPasswordResetForEmail(self.email.text, error: &error)
            
            if error == nil {
                let alert = UIAlertController(title: "Great!", message: "Your password reset request has been sent.", preferredStyle: .Alert)
                let action = UIAlertAction(title: "Okay", style: .Cancel, handler: nil)
                alert.addAction(action)
                
                self.presentViewController(alert, animated: true, completion: nil)
            } else {
                let alert = UIAlertController(title: "Nope..", message: "An error occured while trying to reset your email, are you connected to the internet?", preferredStyle: .Alert)
                let action = UIAlertAction(title: "Okay", style: .Cancel, handler: nil)
                alert.addAction(action)
                
                self.presentViewController(alert, animated: true, completion: nil)
            }
        })
    }
}
