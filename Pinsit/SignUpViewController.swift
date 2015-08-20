//
//  SignUpViewController.swift
//  Pinsit
//
//  Created by Walker Christie on 7/24/15.
//  Copyright © 2015 Walker Christie. All rights reserved.
//

import UIKit
import ParseUI
import Parse

class SignUpViewController: PFSignUpViewController, PFSignUpViewControllerDelegate {
    var tosAgreed = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        super.delegate = self
        
        self.signUpView?.signUpButton?.setBackgroundImage(nil, forState: .Normal)
        
        self.signUpView?.logo = UIImageView(image: UIImage(named: "logo.png"))
        self.signUpView?.signUpButton?.backgroundColor = UIColor.pinsitWhiteBlue()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func signUpViewController(signUpController: PFSignUpViewController, shouldBeginSignUp info: [NSObject : AnyObject]) -> Bool {
        if tosAgreed {
            return checkValid(info["username"] as? String, password: info["password"] as? String)
        } else {
            let controller = TOSViewController.conditionsConfirmation("By registering with Pinsit you agree to the Terms of Conditions and the Privacy Policy.", vc: self)
            controller.addAction(UIAlertAction(title: "Agree", style: .Cancel, handler: { (action) -> Void in
                self.tosAgreed = true
                ErrorReport(viewController: self).presentError("Great!", message: "After agreeing, you may now continue signing up.", type: .Success)
            }))
            self.presentViewController(controller, animated: true, completion: nil)
            
            return false
        }
    }
    
    func signUpViewController(signUpController: PFSignUpViewController, didFailToSignUpWithError error: NSError?) {
        if error != nil {
            reportSignUpError(error!)
        }
    }
    
    func signUpViewController(signUpController: PFSignUpViewController, didSignUpUser user: PFUser) {
        StoryboardManager.segueMain(self)
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
