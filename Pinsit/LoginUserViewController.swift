//
//  LoginUserViewController.swift
//  Pinsit
//
//  Created by Walker Christie on 8/22/15.
//  Copyright (c) 2015 Walker Christie. All rights reserved.
//

import UIKit
import JGProgressHUD
import Parse

class LoginUserViewController: UIViewController {
    @IBOutlet var usernameField: UITextField!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet var containerView: RegistrationViewDesign!
    
    var tosAgreed = false
    var progress: JGProgressHUD!
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        containerView.alpha = 1.0
    }
    
    @IBAction func loginButton(sender: UIButton) {
        if tosAgreed {
            if usernameField.text != "" && passwordField.text != "" {
                self.progress = JGProgressHUD(style: .Dark)
                self.progress.textLabel.text = "Logging In"
                self.progress.showInView(self.view, animated: true)
                
                startLogin()
            } else {
                ErrorReport(viewController: self).presentError("Missing Something", message: "Make sure the username and password fields are filled!", type: .Warning)
            }
        } else {
            let controller = TOSViewController.conditionsConfirmation("By logging into Pinsit you agree to the Terms of Conditions and the Privacy Policy.", vc: self)
            controller.addAction(UIAlertAction(title: "Agree", style: .Cancel, handler: { (action) -> Void in
                self.tosAgreed = true
                ErrorReport(viewController: self).presentError("Great!", message: "After agreeing, you may now continue logging in.", type: .Success)
            }))
            self.presentViewController(controller, animated: true, completion: nil)
        }
    }
    
    func startLogin() {
        PFUser.logInWithUsernameInBackground(usernameField.text, password: passwordField.text) { (user, error) -> Void in
            self.progress.dismiss()
            
            if error != nil {
                self.reportLoginError(error!)
            } else {
                StoryboardManager.segueMain(self)
            }
        }
    }
    
    private func reportLoginError(error: NSError) {
        if error.code == PFErrorCode.ErrorObjectNotFound.rawValue {
            ErrorReport(viewController: self).presentError("Login Issue", message: "The username and password you entered do not match!", type: .Warning)
        } else {
            ErrorReport(viewController: self).presentWithType(.Network)
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
