//
//  RegisterViewController.swift
//  Pinsit
//
//  Created by Walker Christie on 1/15/15.
//  Copyright (c) 2015 Walker Christie. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController {
    @IBOutlet var number: UITextField!
    @IBOutlet var username: UITextField!
    @IBOutlet var password: UITextField!
    @IBOutlet var email: UITextField!

    @IBAction func infoPressed(sender: AnyObject) {
        let explain = "We ask for your phone number in order to verify your account before you can post.  Your email is required so that we can help reset your password if you ever forget it!"
        let alert = UIAlertController(title: "What's This?", message: explain, preferredStyle: .Alert)
        let action = UIAlertAction(title: "Okay", style: .Cancel, handler: nil)
        alert.addAction(action)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func registerPressed(sender: AnyObject) {
        let cred = Credentials(username: username.text, password: password.text)
        
        if cred.confirmUsername() != true || cred.confirmPassword() != true {
            let alert = UIAlertController(title: "Almost", message: "Your username and password must both contain atleast 6 characters", preferredStyle: .Alert)
            let action = UIAlertAction(title: "Okay", style: .Cancel, handler: nil)
            alert.addAction(action)
            
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            if cred.usernameAvailable(self) {
                var error: NSError?
                PFUser.logInWithUsername(self.username.text, password: self.password.text, error: &error)
                
                if error == nil {
                    //segue
                }
            }
        })
    }
}