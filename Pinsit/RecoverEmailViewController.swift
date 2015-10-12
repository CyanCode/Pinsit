//
//  RecoverEmailViewController.swift
//  Pinsit
//
//  Created by Walker Christie on 8/22/15.
//  Copyright (c) 2015 Walker Christie. All rights reserved.
//

import UIKit
import Parse
import JGProgressHUD

class RecoverEmailViewController: UIViewController {
    @IBOutlet var emailField: UITextField!
    @IBOutlet var containerView: RegistrationViewDesign!
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        containerView.alpha = 1.0
    }
    
    @IBAction func sendEmailButton(sender: UIImage) {
        let progress = JGProgressHUD(style: .Dark)
        progress.textLabel.text = "Sending Email"
        progress.showInView(self.view)
        
        PFUser.requestPasswordResetForEmailInBackground(emailField.text!, block: { (success, error) -> Void in
            progress.dismiss()
            
            if error != nil {
                self.reportError(error!)
            } else {
                ErrorReport(viewController: self).presentError("Email Sent", message: "A password reset email has been successfully sent!", type: .Success)
            }
        })
    }
    
    private func reportError(error: NSError) {
        var message: String!
        
        if error.code == PFErrorCode.ErrorInvalidEmailAddress.rawValue {
            message = "The email you entered was invalid and we could not send a password reset."
        } else {
            message = "An error occured while sending your email, check your connection and try again!"
        }
        
        ErrorReport(viewController: self).presentError("Uh Oh..", message: message, type: .Error)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
