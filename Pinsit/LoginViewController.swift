//
//  LoginViewController.swift
//  Pinsit
//
//  Created by Walker Christie on 7/24/15.
//  Copyright © 2015 Walker Christie. All rights reserved.
//

import UIKit
import ParseUI
import Parse
import JGProgressHUD

class LoginViewController: PFLogInViewController, PFLogInViewControllerDelegate {
    var progress: JGProgressHUD!
    var tosAgreed = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        super.delegate = self

        self.logInView?.dismissButton?.removeFromSuperview()
        self.logInView?.logo = UIImageView(image: UIImage(named: "logo.png"))
        
        self.logInView?.logInButton?.setBackgroundImage(nil, forState: .Normal)
        self.logInView?.signUpButton?.setBackgroundImage(nil, forState: .Normal)
        
        self.logInView?.logInButton?.backgroundColor = UIColor.pinsitWhiteBlue()
        self.logInView?.signUpButton?.backgroundColor = UIColor.pinsitWhiteBlue()
    }
    
    func logInViewController(logInController: PFLogInViewController, shouldBeginLogInWithUsername username:
        String, password: String) -> Bool {
            if tosAgreed {
                if username != "" && password != "" {
                    self.progress = JGProgressHUD(style: .Dark)
                    self.progress.textLabel.text = "Logging In"
                    self.progress.showInView(self.view, animated: true)
                    
                    return true
                } else {
                    ErrorReport(viewController: self).presentError("Missing Something", message: "Make sure the username and password fields are filled!", type: .Warning)
                    
                    return false
                }
            } else {
                let controller = TOSViewController.conditionsConfirmation("By logging into Pinsit you agree to the Terms of Conditions and the Privacy Policy.", vc: self)
                controller.addAction(UIAlertAction(title: "Agree", style: .Cancel, handler: { (action) -> Void in
                    self.tosAgreed = true
                    ErrorReport(viewController: self).presentError("Great!", message: "After agreeing, you may now continue logging in.", type: .Success)
                }))
                self.presentViewController(controller, animated: true, completion: nil)
                
                return false
            }
    }
    
    func logInViewController(logInController: PFLogInViewController, didFailToLogInWithError error: NSError?) {
        progress.dismiss()
        
        if error != nil {
            reportLoginError(error!)
        }
    }
    
    func logInViewController(logInController: PFLogInViewController, didLogInUser user: PFUser) {
        progress.dismiss()
        StoryboardManager.segueMain(self)
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
