//
//  DeleteAccount.swift
//  Pinsit
//
//  Created by Walker Christie on 4/26/15.
//  Copyright (c) 2015 Walker Christie. All rights reserved.
//

import Foundation
import Parse

///Used for deleting the currentUser from the Pinsit database
class DeleteAccount {
    private var viewController: UIViewController!
    
    ///Initializes with view controller to act as a responder for alert controllers
    ///
    ///- parameter viewController: responder
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    ///Deletes currentUser in background
    ///
    ///- parameter done(success:: Bool) called when deletion has finished
    func beginDeletionInBackground(done: (success: Bool) -> Void) {
        Async.background {
            let username = PFUser.getSafeUsername()
            let likesQuery = PFQuery(className: "Likes").whereKey("username", equalTo: username)
            let videoQuery = PFQuery(className: "SentData").whereKey("username", equalTo: username)
            let verificationQuery = PFQuery(className: "Verification").whereKey("username", equalTo: username)
            let followerQuery = PFQuery(className: "Followers").whereKey("following", equalTo: username)
            let followingQuery = PFQuery(className: "Followers").whereKey("username", equalTo: username)
         
            do {
                try PFUser.currentUser()!.deleteWithError()
                try likesQuery.findAndDeleteObjects()
                try videoQuery.findAndDeleteObjects()
                try verificationQuery.findAndDeleteObjects()
                try followingQuery.findAndDeleteObjects()
                self.handleFollowerObjects(followerQuery.findObjects() as? [PFFollowers])
                
                Async.main { done(success: true) }
            } catch  {
                Async.main { done(success: false) }
            }
        }
    }
    
    ///Attempt to login the current user with passed username and password
    ///
    ///- parameter username: Username to compare
    ///- parameter password: Password to compare
    ///- parameter done(success): Called when authentication has succeeded or failed
    func attemptAuthentication(username: String, password: String, done: (success: Bool) -> Void) {
        let session = PFUser.currentUser()!.sessionToken!
        
        if username != PFUser.currentUser()!.username! {
            RegistrationAlerts(vc: self.viewController).usernameMismatch()
            done(success: false)
            return
        }
        
        Async.background {
            PFUser.logOut()
            do {
                try PFUser.logInWithUsername(username, password: password, error: ())
                PFUser.logOut()
                try PFUser.become(session, error: ())
                
                Async.main { done(success: true) }
            } catch let error as NSError {
                if error.code == PFErrorCode.ErrorConnectionFailed.rawValue {
                    RegistrationAlerts(vc: self.viewController).connectionIssue()
                } else {
                    RegistrationAlerts(vc: self.viewController).loginFailure()
                }
                
                PFUser.become(session)
                Async.main { done(success: false) }
            } catch {
                fatalError()
            }
        }
        
    }
    
    private func handleFollowerObjects(objects: [PFFollowers]?) {
        var toSave = [PFObject]()
        
        if objects != nil {
            for obj in objects! {
                obj.removeObject(PFUser.currentUser()!.username!, forKey: "following")
                toSave.append(obj)
            }
        }
        
        if toSave.count > 0 {
            PFObject.saveAll(toSave)
        }
    }
    
    private func displayAlert() {
        let controller = UIAlertController(title: "Account Failed to Delete", message: "Your Pinsit account could not be deleted, please check your connection and try again.", preferredStyle: .Alert)
        controller.addAction(UIAlertAction(title: "Okay", style: .Cancel, handler: nil))
        viewController.presentViewController(controller, animated: true, completion: nil)
    }
    
    private func loginFailure() {
        
    }
}