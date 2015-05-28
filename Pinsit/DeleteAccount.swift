//
//  DeleteAccount.swift
//  Pinsit
//
//  Created by Walker Christie on 4/26/15.
//  Copyright (c) 2015 Walker Christie. All rights reserved.
//

import Foundation

///Used for deleting the currentUser from the Pinsit database
class DeleteAccount {
    private var viewController: UIViewController!
    
    ///Initializes with view controller to act as a responder for alert controllers
    ///
    ///:param: viewController responder
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    ///Deletes currentUser in background
    ///
    ///:param: done(success: Bool) called when deletion has finished
    func beginDeletionInBackground(done: (success: Bool) -> Void) {
        var error: NSError?
        
        Async.background {
            let username = PFUser.currentUser()!.username!
            let likesQuery = PFQuery(className: "Likes").whereKey("username", equalTo: username)
            let videoQuery = PFQuery(className: "SentData").whereKey("username", equalTo: username)
            let verificationQuery = PFQuery(className: "Verification").whereKey("username", equalTo: username)
            let followerQuery = PFQuery(className: "Followers").whereKey("following", equalTo: username)
            let followingQuery = PFQuery(className: "Followers").whereKey("username", equalTo: username)
         
            PFUser.currentUser()?.delete(&error)
            likesQuery.findAndDeleteObjects(&error)
            videoQuery.findAndDeleteObjects(&error)
            verificationQuery.findAndDeleteObjects(&error)
            followingQuery.findAndDeleteObjects(&error)
            self.handleFollowerObjects(followerQuery.findObjects())
            }.main {
                if error != nil {
                    done(success: false)
                } else {
                    done(success: true)
                }
        }
    }
    
    ///Attempt to login the current user with passed username and password
    ///
    ///:param: username Username to compare
    ///:param: password Password to compare
    ///:param: done(success) Called when authentication has succeeded or failed
    func attemptAuthentication(username: String, password: String, done: (success: Bool) -> Void) {
        let session = PFUser.currentUser()!.sessionToken!
        var error: NSError?
        
        if username != PFUser.currentUser()!.username! {
            RegistrationAlerts(vc: self.viewController).usernameMismatch()
            done(success: false)
            return
        }
        
        Async.background {
            PFUser.logOut()
            PFUser.logInWithUsername(username, password: password, error: &error)

            if error != nil {
                if error!.code == PFErrorCode.ErrorConnectionFailed.rawValue {
                    RegistrationAlerts(vc: self.viewController).connectionIssue()
                } else {
                    RegistrationAlerts(vc: self.viewController).loginFailure()
                }
                
                PFUser.become(session)
                Async.main {
                    done(success: false)
                }
            } else {
                PFUser.logOut()
                PFUser.become(session)
                
                Async.main {
                    done(success: true)
                }
            }
        }
        
    }
    
    private func handleFollowerObjects(objects: [AnyObject]?) {
        var toSave = [PFObject]()
        
        if objects != nil {
            for obj in objects as! [PFObject]! {
                obj.removeObject(PFUser.currentUser()!.username!, forKey: "following")
                toSave.append(obj)
            }
        }
        
        if count(toSave) > 0 {
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

extension PFQuery {
    func findAndDeleteObjects(error: NSErrorPointer) {
        let objects = findObjects(error)
        
        if error == nil && count(objects!) > 0 {
            for obj in objects! {
                obj.delete()
            }
        }
    }
}