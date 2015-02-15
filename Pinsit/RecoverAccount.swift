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
        
        email.isEmailVerified({ (confirmed) -> Void in
            if confirmed == true {
                Email.emailVerifiedMessage()
                completion()
            }
            
            email.resendVerification ({ (error) -> Void in
                if error != nil {
                    completion()
                } else {
                    let controller = UIAlertController(title: "Success", message: "Your recovery email has been sent, please check your email!", preferredStyle: .Alert)
                    controller.addAction(UIAlertAction(title: "Okay", style: .Cancel, handler: nil))
                    self.viewController.presentViewController(controller, animated: true, completion: nil)
                    completion()
                }
            })
        })
    }
    
    func recoverPassword(email: String, completion: (error: NSError?) -> Void) {
        PFUser.requestPasswordResetForEmailInBackground(email, block: { (success, error) -> Void in
            completion(error: error)
        })
    }
}