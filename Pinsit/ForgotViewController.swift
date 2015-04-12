//
//  ForgotViewController.swift
//  Pinsit
//
//  Created by Walker Christie on 1/15/15.
//  Copyright (c) 2015 Walker Christie. All rights reserved.
//

import UIKit

class ForgotViewController: UIViewController {
    @IBOutlet var email: UITextField!
    
    @IBAction func resetButton(sender: AnyObject) {
        var error: NSError?
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            let button = sender as! UIButton
            button.enabled = false
            let user = PFUser.requestPasswordResetForEmail(self.email.text, error: &error)
            let alert = RegistrationAlerts(vc: self)

            if error != nil {
                if error!.code == PFErrorCode.ErrorConnectionFailed.rawValue {
                    alert.passwordRecoverError()
                } else if error!.code == PFErrorCode.ErrorUserWithEmailNotFound.rawValue {
                    alert.emailNotFound()
                } else {
                    alert.unknownError()
                }
            } else {
                alert.passwordRecoverSuccess()
            }
        })
    }
}
