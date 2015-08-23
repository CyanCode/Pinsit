//
//  SignUpUserViewController.swift
//  Pinsit
//
//  Created by Walker Christie on 8/22/15.
//  Copyright (c) 2015 Walker Christie. All rights reserved.
//

import UIKit
import Parse

class SignUpUserViewController: UIViewController {
    @IBOutlet var usernameField: UITextField!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet var emailField: UITextField!
    @IBOutlet var containerView: RegistrationViewDesign!
    
    var tosAgreed: Bool = false
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        containerView.alpha = 1.0
    }
    
    @IBAction func signUpButton(sender: UIButton) {
        if tosAgreed {
            if checkValid(usernameField.text, password: passwordField.text) {
                startSignUp()
            }
        } else {
            let controller = TOSViewController.conditionsConfirmation("By registering with Pinsit you agree to the Terms of Conditions and the Privacy Policy.", vc: self)
            controller.addAction(UIAlertAction(title: "Agree", style: .Cancel, handler: { (action) -> Void in
                self.tosAgreed = true
                ErrorReport(viewController: self).presentError("Great!", message: "After agreeing, you may now continue signing up.", type: .Success)
            }))
            
            self.presentViewController(controller, animated: true, completion: nil)
        }
    }
    
    func startSignUp() {
        let user = PFUser()
        user.username = usernameField.text
        user.password = passwordField.text
        user.email = emailField.text
        
        user.signUpInBackgroundWithBlock { (success, error) -> Void in
            if error != nil {
                self.reportSignUpError(error!)
            } else {
                StoryboardManager.segueMain(self)
            }
        }
    }
    
    private func checkValid(username: String?, password: String?) -> Bool {
        let user = username == nil ? "" : username!
        let pass = password == nil ? "" : password!
        
        if count(user) <= 4 {
            ErrorReport(viewController: self).presentWithType(.Username)
            return false
        }; if count(pass) <= 5 {
            ErrorReport(viewController: self).presentWithType(.Password)
            return false
        }; if user.containsAny([" ", "*", "%", "/", "\\", ":", ";", "\""]) {
            ErrorReport(viewController: self).presentError("Invalid Characters", message: "Sorry!  Your username cannot contain any spaces or alphanumeric characters", type: .Warning)
            return false
        }
        
        return true
    }
    
    private func reportSignUpError(error: NSError) {
        let rep = ErrorReport(viewController: self)
        
        if error.code == PFErrorCode.ErrorUsernameTaken.rawValue {
            rep.presentError("Username Taken", message: "Sorry, that username is already registered with us!", type: .Warning)
        } else if error.code == PFErrorCode.ErrorUserEmailTaken.rawValue {
            rep.presentError("Email Taken", message: "Sorry, that email is already registered with us!", type: .Warning)
        } else if error.code == PFErrorCode.ErrorInvalidEmailAddress.rawValue {
            rep.presentError("Invalid Email", message: "Sorry, we cannot accept the email address you entered, try another one!", type: .Warning)
        } else {
            rep.presentWithType(.Network)
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
