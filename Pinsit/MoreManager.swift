//
//  MoreManager.swift
//  Pinsit
//
//  Created by Walker Christie on 8/2/15.
//  Copyright © 2015 Walker Christie. All rights reserved.
//

import UIKit
import Parse

class MoreManager {
    var moreVc: MoreTableViewController
    var numberVerify: NumberVerification!
    
    init(vc: MoreTableViewController) {
        self.moreVc = vc
        self.numberVerify = NumberVerification(responder: moreVc, manager: self)
    }
    
    func enableRequiredCells() {
        if Upgrade().isUpgraded() {
            moreVc.cell(moreVc.upgradeCell, setHidden: true)
        }; if PFUser.currentUser()!["phone"] != nil && PFUser.currentUser()!["phone"] as! String != "" {
            moreVc.cell(moreVc.verifyPhoneCell, setHidden: true)
            moreVc.cell(moreVc.phoneNumberEntryCell, setHidden: true)
            moreVc.cell(moreVc.sendTextCell, setHidden: true)
            moreVc.cell(moreVc.receivedCodeCell, setHidden: true)
            moreVc.cell(moreVc.checkCodeCell, setHidden: true)
        } else {
            moreVc.cell(moreVc.phoneNumberEntryCell, setHidden: true)
            moreVc.cell(moreVc.sendTextCell, setHidden: true)
            moreVc.cell(moreVc.receivedCodeCell, setHidden: true)
            moreVc.cell(moreVc.checkCodeCell, setHidden: true)
        }; if PFUser.currentUser()!["emailVerified"] as? Bool == true {
            moreVc.cell(moreVc.resendEmailCell, setHidden: true)
        }
        
        moreVc.reloadDataAnimated(false)
    }
    
    func emailVerification() {
        let recover = RecoverAccount(vc: moreVc)
        recover.reverifyEmailAddress { () -> Void in
            print("Finished verifying email")
        }
    }
    
    func logoutUser() {
        PFUser.logOut()
        StoryboardManager.segueRegistration(moreVc)
    }
    
    func deleteAccount() {
        let controller = UIAlertController(title: "Are You Sure..?", message: "We're sad to see you go.  But if you must leave, please enter your login information below.", preferredStyle: .Alert)
        controller.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = "Username"
        }
        controller.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.secureTextEntry = true
            textField.placeholder = "Password"
        }
        controller.addAction(UIAlertAction(title: "Continue", style: .Default, handler: { (action) -> Void in
            let username = controller.textFields![0] as UITextField
            let password = controller.textFields![1] as UITextField
            
            DeleteAccount(viewController: self.moreVc).attemptAuthentication(username.text!, password: password.text!, done: { (success) -> Void in if success == true {
                DeleteAccount(viewController: self.moreVc).beginDeletionInBackground { (success) -> Void in
                    if success == true {
                        self.logoutUser()
                        StoryboardManager.segueRegistration(self.moreVc)
                    } else {
                        let controller = UIAlertController(title: "Not Quite!", message: "The password you entered does not match the password attached to your account, feel free to try again.", preferredStyle: .Alert)
                        controller.addAction(UIAlertAction(title: "Okay", style: .Cancel, handler: nil))
                        
                        self.moreVc.presentViewController(controller, animated: true, completion: nil)
                    }
                }
                }
            })
        }))
        
        controller.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        moreVc.presentViewController(controller, animated: true, completion: nil)
    }
}
