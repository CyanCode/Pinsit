//
//  RegisterViewController.swift
//  Pinsit
//
//  Created by Walker Christie on 1/15/15.
//  Copyright (c) 2015 Walker Christie. All rights reserved.
//

import UIKit
import Parse
import JGProgressHUD

class RegisterViewController: UIViewController {
    @IBOutlet var username: UITextField!
    @IBOutlet var password: UITextField!
    @IBOutlet var email: UITextField!
    @IBOutlet var policyButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        policyButton.titleLabel?.lineBreakMode = .ByWordWrapping
        policyButton.titleLabel?.textAlignment = .Center
        policyButton.titleLabel?.numberOfLines = 0
    }

    @IBAction func infoPressed(sender: AnyObject) {
        let explain = "We ask for your email address in order to recover your account in the event that you forget your password."
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
        
        if email.text == "" {
            let alert = UIAlertController(title: "Almost", message: "It looks like you might have left some fields blank, care to try again?", preferredStyle: .Alert)
            let action = UIAlertAction(title: "Okay", style: .Cancel, handler: nil)
            alert.addAction(action)
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
        
        let button = sender as! UIButton
        button.enabled = false
        let progress = JGProgressHUD(style: .Light)
        progress.textLabel.text = "Signing Up"
        progress.showInView(self.view)
        self.view.bringSubviewToFront(progress)
        
        Async.background {
            if cred.usernameAvailable(self) {
                let newUser = PFUser()
                var error: NSError?
                newUser.username = self.username.text
                newUser.email = self.email.text
                newUser.password = self.password.text
                
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
                
                progress.dismiss()
            }
            
            button.enabled = true
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.destinationViewController is TOSViewController {
            let vc = segue.destinationViewController as! TOSViewController
            vc.identifier = "register"
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
