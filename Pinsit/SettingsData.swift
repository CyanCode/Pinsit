//
//  SettingsData.swift
//  Pinsit
//
//  Created by Walker Christie on 7/20/15.
//  Copyright © 2015 Walker Christie. All rights reserved.
//

import Foundation
import Parse

class SettingsData {
    var settings: SettingsViewController!
    var verify: NumberVerification!
    
    init(vc: SettingsViewController) {
        self.settings = vc
        self.verify = NumberVerification(responder: vc, form: vc.form)
    }
    
    ///MARK: Button Selectors
    func upgradeAccount() {
        Upgrade().startPurchase(settings)
    }
    
    func logoutUser() {
        PFUser.logOut()
        StoryboardManager.segueRegistration(settings)
    }
    
    func confirmPhone() {
        
    }
    
    func checkUpgraded() {
        let row = settings.form.formRowWithTag(Tags.Upgrade.rawValue)
        if row != nil && Upgrade().isUpgraded() == true {
            settings.form.removeFormRow(row)
        }
    }
    
    func deleteAccount() {
        let controller = UIAlertController(title: "Are You Sure..?", message: "We're sad to see you go, but if you must leave, please enter your login information below.", preferredStyle: .Alert)
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
            
            DeleteAccount(viewController: self.settings).attemptAuthentication(username.text!, password: password.text!, done: { (success) -> Void in if success == true {
                DeleteAccount(viewController: self.settings).beginDeletionInBackground { (success) -> Void in
                    if success == true {
                        self.logoutUser()
                        StoryboardManager.segueRegistration(self.settings)
                    } else {
                        let controller = UIAlertController(title: "Not Quite!", message: "The password you entered does not match the password attached to your account, feel free to try again.", preferredStyle: .Alert)
                        controller.addAction(UIAlertAction(title: "Okay", style: .Cancel, handler: nil))
                        
                        self.settings.presentViewController(controller, animated: true, completion: nil)
                    }
                }
                }
            })
        }))
        
        controller.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        settings.presentViewController(controller, animated: true, completion: nil)
    }
    
    func emailVerification() {
        let recover = RecoverAccount(vc: settings)
        recover.reverifyEmailAddress { () -> Void in
            print("Finished verifying email")
        }
    }
    
    func numberVerification() {
        let recover = RecoverAccount(vc: settings)
        recover.reverifyPhoneNumber { () -> Void in
            print("Finished verifying phone")
        }
    }
}