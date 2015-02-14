//
//  RecoverAccount.swift
//  Pinsit
//
//  Created by Walker Christie on 2/10/15.
//  Copyright (c) 2015 Walker Christie. All rights reserved.
//

import Foundation

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
        let email = Email()
        email.resendVerification { (error) -> Void in
            completion()
        }
    }
    
    func recoverPassword(email: String, completion: (error: NSError?) -> Void) {
        PFUser.requestPasswordResetForEmailInBackground(email, block: { (success, error) -> Void in
            completion(error: error)
        })
    }
    
    private func phoneCodePrompt() {
        let controller = UIAlertController(title: "Almost There", message: "Your text has been sent, please enter your received verification code below!", preferredStyle: .Alert)
        controller.addTextFieldWithConfigurationHandler { (textField) -> Void in
            
        }
    }
}