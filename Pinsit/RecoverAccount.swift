//
//  RecoverAccount.swift
//  Pinsit
//
//  Created by Walker Christie on 2/10/15.
//  Copyright (c) 2015 Walker Christie. All rights reserved.
//

import Foundation
import Parse

class RecoverAccount {
    var viewController: UIViewController!
    
    init(vc: UIViewController) {
        self.viewController = vc
    }
    
    func reverifyPhoneNumber(completion: () -> Void) {
        let verify = VerifyNumber()
        verify.resendNumber(viewController)
    }
    
    func reverifyEmailAddress(completion: () -> Void) {
        let controller = UIAlertController(title: "Verify Email Address", message: "What email would you like to verify?", preferredStyle: .Alert)
        controller.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = "Email Address"
            textField.keyboardType = .EmailAddress
        }
        controller.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        controller.addAction(UIAlertAction(title: "Verify", style: .Default, handler: { (action) -> Void in
            let text = (controller.textFields![0] as! UITextField).text
            PFUser.currentUser()!.email = text
            
            var regex = ".+@([A-Za-z0-9]+\\.)+[A-Za-z]{2}[A-Za-z]*";
            var test = NSPredicate(format:"SELF MATCHES \(regex)");
            
            if test.evaluateWithObject(text) {
                self.sendRecoveryEmail(text, done: { (error) -> Void in
                    if error != nil {
                        ErrorReport(viewController: self.viewController).presentError("Uh Oh..", message: "We were unable to send you a verification email, check your connection and try again!", type: .Error)
                    } else {
                        ErrorReport(viewController: self.viewController).presentError("Great!", message: "Your verification email has been sent to \(text)", type: .Error)
                    }
                })
            } else {
                ErrorReport(viewController: self.viewController).presentError("Something's Missing", message: "The email you entered is not valid, try entering a different one!", type: .Warning)
            }
        }))
    }
    
    func sendRecoveryEmail(email: String, done: (error: NSError?) -> Void) {
        PFUser.currentUser()!.email = email
        PFUser.currentUser()!.saveInBackgroundWithBlock { (success, error) -> Void in
            done(error: error)
        }
    }
    
    func recoverPassword(email: String, completion: (error: NSError?) -> Void) {
        PFUser.requestPasswordResetForEmailInBackground(email, block: { (success, error) -> Void in
            completion(error: error)
        })
    }
}