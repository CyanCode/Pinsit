//
//  RegistrationAlerts.swift
//  Pinsit
//
//  Created by Walker Christie on 4/3/15.
//  Copyright (c) 2015 Walker Christie. All rights reserved.
//

import Foundation
import UIKit

class RegistrationAlerts {
    let vc: UIViewController
    
    init(vc: UIViewController) {
        self.vc = vc
    }
    
    ///Alert for incorrectly entered password
    ///
    ///- parameter recover(): called if user chooses to recover their password
    func wrongPassword(recover: () -> Void) {
        let alert = createAlert("The password you've entered is incorrect, would you like to recover it?", title: "Wrong Password")
        alert.addAction(UIAlertAction(title: "Yes", style: .Default) { (action) -> Void in
            recover()
        })
        
        vc.presentViewController(alert, animated: true, completion: nil)
    }
    
    ///Generic cannot connect to the internet error alert
    func connectionIssue() {
        let alert = createAlert("Uh Oh!", title: "It looks like you're not connected to the internet, check your connection and try again.")
        
        vc.presentViewController(alert, animated: true, completion: nil)
    }
    
    ///Alert for TOS connection failure
    func tosConnection() {
        let alert = createAlert("The Terms of Service cannot be approved without a valid internet connection!", title: "No Connection")
        
        vc.presentViewController(alert, animated: true, completion: nil)
    }
    
    ///Alert for account networking errors
    func accountCreation() {
        let alert = createAlert("We were not able to create your account, are you sure you're connected to the internet?", title: "Couldn't Sign Up")
        
        vc.presentViewController(alert, animated: true, completion: nil)
    }
    
    ///Alert for account names that are already taken
    func accountExistsAlready() {
        let alert = createAlert("This account name already exists, sorry!  Why not try using a different one?", title: "Just Missed It!")
        
        vc.presentViewController(alert, animated: true, completion: nil)
    }
    
    ///Alert for fields which were left blank
    func blankFields() {
        let alert = createAlert("It looks like you've left some fields blank!  Please fill those in first.", title: "Woah!")
        
        vc.presentViewController(alert, animated: true, completion: nil)
    }
    
    ///Alert for too little characters used
    func moreCharacters() {
        let alert = createAlert("Both your username and password must contain atleast 5 characters.", title: "Almost There")
        
        vc.presentViewController(alert, animated: true, completion: nil)
    }
    
    ///Alert for explaining why account verification exists
    func explainRequirements() {
        let message = "We ask for your phone number in order to verify your account before you can post.  Your email is required so that we can help reset your password if you ever forget it!"
        let alert = createAlert(message, title: "What's This?")
        
        vc.presentViewController(alert, animated: true, completion: nil)
    }
    
    ///Alert for password recovery email errors
    func passwordRecoverError() {
        let alert = createAlert("We could not send a password recovery request.  Make sure you are connected to the internet first!", title: "Hmm..")
        
        vc.presentViewController(alert, animated: true, completion: nil)
    }
    
    ///Alert for successful recovery email sending
    func passwordRecoverSuccess() {
        let alert = createAlert("Your password recovery email has been sent!", title: "Great!")
        
        vc.presentViewController(alert, animated: true, completion: nil)
    }
    
    ///If something unknown happens while trying to do any network operations
    func unknownError() {
        let alert = createAlert("An unknown error occurred while processing your request!  If the problem continues, please contact us.", title: "Oops")
        
        vc.presentViewController(alert, animated: true, completion: nil)
    }
    
    ///Alert for the possiblity of an unassociated email / username
    func emailNotFound() {
        let alert = createAlert("An account was not found for the email address specified", title: "Not Quite")
        
        vc.presentViewController(alert, animated: true, completion: nil)
    }
    
    ///If the attempted login failed
    func loginFailure() {
        let alert = createAlert("Your account could not be verified as either your username or password was incorrect.", title: "Login Failed")
        
        vc.presentViewController(alert, animated: true, completion: nil)
    }
    
    ///If the username that was entered does not match the currently logged in user
    func usernameMismatch() {
        let alert = createAlert("The username you entered does not match the account that is currently logged in.", title: "Authentication Failed")
        
        vc.presentViewController(alert, animated: true, completion: nil)
    }
    
    private func createAlert(message: String, title: String) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .Cancel, handler: nil))

        return alert
    }
}
