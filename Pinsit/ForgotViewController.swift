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
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            let button = sender as! UIButton
            let alert = RegistrationAlerts(vc: self)
            button.enabled = false
            
            do {
                try PFUser.requestPasswordResetForEmail(self.email.text!, error: ())
                alert.passwordRecoverSuccess()
            } catch let error as NSError {
                if error.code == PFErrorCode.ErrorConnectionFailed.rawValue {
                    alert.passwordRecoverError()
                } else if error.code == PFErrorCode.ErrorUserWithEmailNotFound.rawValue {
                    alert.emailNotFound()
                } else {
                    alert.unknownError()
                }
            } catch {
                fatalError()
            }
        })
    }
}
