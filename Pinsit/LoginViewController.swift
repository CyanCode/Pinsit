//
//  LoginViewController.swift
//  Pinsit
//
//  Created by Walker Christie on 1/11/15.
//  Copyright (c) 2015 Walker Christie. All rights reserved.
//

import UIKit
import Parse
import JGProgressHUD

class LoginViewController: UIViewController {
    @IBOutlet var usernameField: UITextField!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet var policyButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        policyButton.titleLabel?.lineBreakMode = .ByWordWrapping
        policyButton.titleLabel?.textAlignment = .Center
        policyButton.titleLabel?.numberOfLines = 0
    }
    
    @IBAction func loginButton(sender: AnyObject) {
        let button = sender as! UIButton
        let progress = JGProgressHUD(style: .Light)
        
        progress.textLabel.text = "Logging In"
        progress.showInView(self.view)
        self.view.bringSubviewToFront(progress)
        
        button.enabled = false
        PFUser.logInWithUsernameInBackground(usernameField.text!, password: passwordField.text!) { (user, error) -> Void in
            button.enabled = true
            progress.dismiss()
            
            if error != nil {
                let alert = RegistrationAlerts(vc: self)
                
                if error!.code == PFErrorCode.ErrorConnectionFailed.rawValue {
                    alert.connectionIssue()
                } else if error!.code == PFErrorCode.ErrorUsernameTaken.rawValue {
                    alert.accountExistsAlready()
                } else if error!.code == PFErrorCode.ErrorObjectNotFound.rawValue {
                    alert.loginFailure()
                } else {
                    alert.unknownError()
                }
            } else {
                StoryboardManager.segueMain(self)
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.destinationViewController is TOSViewController {
            let vc = segue.destinationViewController as! TOSViewController
            vc.identifier = "login"
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
