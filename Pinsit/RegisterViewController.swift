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
        let cred = Credentials(username: username.text!, password: password.text!)
        
        if cred.confirmUsername() != true || cred.confirmPassword() != true {
            let alert = UIAlertController(title: "Almost", message: "Your username and password must both contain atleast 6 characters", preferredStyle: .Alert)
            let action = UIAlertAction(title: "Okay", style: .Cancel, handler: nil)
            alert.addAction(action)
            
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
        
        if number.text == "" || email.text == "" {
            let alert = UIAlertController(title: "Almost", message: "It looks like you might have left some fields blank, care to try again?", preferredStyle: .Alert)
            let action = UIAlertAction(title: "Okay", style: .Cancel, handler: nil)
            alert.addAction(action)
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
        
        let button = sender as! UIButton
        button.enabled = false
        
        Async.background {
            if cred.usernameAvailable(self) {
                let newUser = PFUser()
                var error: NSError?
                newUser.username = self.username.text
                newUser.email = self.email.text
                newUser.password = self.password.text
                newUser["phone"] = self.number.text
                
                if newUser.signUp(&error) == true {
                    let f = File()
                    if f.tosConfirmed() == false {
                        self.performSegueWithIdentifier("tos", sender: self)
                    } else {
                        StoryboardManager.segueMain(self)
                    }
                } else {
                    let alert = RegistrationAlerts(vc: self)
                    
                    if error!.code == PFErrorCode.ErrorConnectionFailed.rawValue {
                        alert.connectionIssue()
                    } else if error!.code == PFErrorCode.ErrorUsernameTaken.rawValue {
                        alert.accountExistsAlready()
                    } else {
                        alert.unknownError()
                    }
                }
            }
            
            button.enabled = true
        }
    }
}
