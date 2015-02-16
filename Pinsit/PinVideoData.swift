//
//  SettingsData.swift
//  Pinsit
//
//  Created by Walker Christie on 2/16/15.
//  Copyright (c) 2015 Walker Christie. All rights reserved.
//

import Foundation

class PinVideoData {
    var viewController: TappedVideoViewController!
    
    init(viewController: TappedVideoViewController) {
        self.viewController = viewController
    }
    
    func reportUser(reportedUser: String, videoId: String) {
        let manager = GenerateReport(viewController: viewController, reportedUser: reportedUser, videoId: videoId)
        let report = manager.createReportObject()
        manager.presentPrompt { (answer) -> Void in
            if answer == true {
                manager.reportUserInBackground(report, completion: { (error) -> Void in
                    if error != nil {
                        self.reportError()
                    } else {
                        self.reportSucess()
                    }
                })
            }
        }
    }
    
    func downloadVideo() {
        let path = File.pulledVideoPath()
        
        if UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(path) {
            UISaveVideoAtPathToSavedPhotosAlbum(path, nil, nil, nil)
            self.videoSaveSuccess()
        } else {
            self.videoSaveError()
        }
    }
    
    func addLike(videoId: String, button: UIButton) {
        let query = PFQuery(className: "SentData")
        query.whereKey("objectId", equalTo: videoId)
        
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error == nil && countElements(objects) > 0 {
                let likes = objects[0]["likes"] as [String]
                
                if self.likesExist(PFUser.currentUser().username, likesList: likes) == false {
                    objects[0].addObject(PFUser.currentUser().username, forKey: "likes")
                    objects[0].saveInBackgroundWithBlock(nil)
                    button.userInteractionEnabled = false
                } else { button.userInteractionEnabled = false }
            }
        }
    }
    
    ///Add follower to list of following users
    func addFollower(name: String, button: UIButton) {
        let followerQuery = PFQuery(className: "Followers")
        followerQuery.whereKey("username", equalTo: PFUser.currentUser().username)
        
        followerQuery.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error == nil && countElements(objects) > 0 {
                let user = objects[0] as PFObject
                if self.followerExists(name, currentUserList: user["following"] as [String]) == false {
                    user.addObject(name, forKey: "following")
                    user.saveInBackgroundWithBlock(nil)
                    button.userInteractionEnabled = false
                }
            }
        }
    }
    
    ///Checks to see if the passed followers exist in current user's follower list
    private func followerExists(name: String, currentUserList: [String]) -> Bool {
        for follower in currentUserList {
            if name == follower {
                return true
            }
        }
        
        return false
    }
    
    private func likesExist(name: String, likesList: [String]) -> Bool {
        return followerExists(name, currentUserList: likesList)
    }
    
    ///MARK: Alert Controllers
    private func videoSaveError() {
        let controller = UIAlertController(title: "Uh-Oh", message: "Your video could not be saved to the camera roll, please try again!", preferredStyle: .Alert)
        controller.addAction(UIAlertAction(title: "Okay", style: .Cancel, handler: nil))
        self.viewController.presentViewController(controller, animated: true, completion: nil)
    }
    
    private func videoSaveSuccess() {
        let controller = UIAlertController(title: "Nice!", message: "Your video has been successfully saved to the camera roll!", preferredStyle: .Alert)
        controller.addAction(UIAlertAction(title: "Okay", style: .Cancel, handler: nil))
        self.viewController.presentViewController(controller, animated: true, completion: nil)
    }
    
    private func reportError() {
        let controller = UIAlertController(title: "Nope", message: "An error occured while posting your report, the video may have been deleted.", preferredStyle: .Alert)
        controller.addAction(UIAlertAction(title: "Okay", style: .Cancel, handler: nil))
        self.viewController.presentViewController(controller, animated: true, completion: nil)
    }
    
    private func reportSucess() {
        let controller = UIAlertController(title: "Done", message: "Thank you for your report, it has been submitted and will be reviewed shortly.", preferredStyle: .Alert)
        controller.addAction(UIAlertAction(title: "Okay", style: .Cancel, handler: nil))
        self.viewController.presentViewController(controller, animated: true, completion: nil)
    }
}