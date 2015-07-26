//
//  SettingsData.swift
//  Pinsit
//
//  Created by Walker Christie on 2/16/15.
//  Copyright (c) 2015 Walker Christie. All rights reserved.
//

import Foundation
import Parse

class PinVideoData {
    var viewController: TappedVideoViewController!
    private var likeQuery: PFQuery {
        get {
            let query = PFQuery(className: "Likes")
            query.fromPin()
            
            return query
        }
    }
    
    init(viewController: TappedVideoViewController) {
        self.viewController = viewController
    }
    
    func reportUser(reportedUser: String, videoId: String) {
        let reporter = ReportManager(videoObject: viewController.videoObject, responder: viewController)
        reporter.reportCanBeSent { (sendable, incrementable) -> Void in
            if sendable == true {
                reporter.sendNewReport()
            } else if incrementable == true {
                reporter.incrementReport()
            } else {
                reporter.reportedUserMessage()
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
    
    ///Add follower to list of following users
    func addFollower(name: String, button: UIButton) {
        let followerQuery = PFQuery(className: "Followers")
        followerQuery.whereKey("username", equalTo: PFUser.currentUser()!.username!)
        
        followerQuery.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error == nil && (objects!).count > 0 {
                let user = objects![0] as! PFFollowers
                
                if self.followerExists(name, currentUserList: user.getFollowing()) == false {
                    user.addObject(name, forKey: "following")
                    user.saveInBackgroundWithBlock(nil)
                    button.userInteractionEnabled = false
                }
            }
        }
    }
    
    func isAlreadyLiked(videoId: String) -> Bool {
        let query = likeQuery.whereKey("videoId", equalTo: videoId)
        let objects = query.findObjects()
        
        if objects == nil || (objects!).count < 1 {
            return false
        } else {
            return true
        }
    }
    
    private func addLocalLiked(videoId: String) {
        let obj = PFObject(className: "Likes")
        obj["videoId"] = videoId
        obj.pin()
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
    
    private func videoStillActive(objectId: String, completion: (active: Bool) -> Void) {
        let query = PFQuery(className: "SentData")
        query.whereKey("objectId", equalTo: objectId)
        
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if (objects!).count > 0 {
                completion(active: true)
            } else {
                completion(active: false)
            }
        }
    }
    
    ///MARK: Alert Controllers
    private func videoSaveError() {
        let controller = UIAlertController(title: "Uh-Oh", message: "The video could not be saved to the camera roll, please try again!", preferredStyle: .Alert)
        controller.addAction(UIAlertAction(title: "Okay", style: .Cancel, handler: nil))
        self.viewController.presentViewController(controller, animated: true, completion: nil)
    }
    
    private func videoSaveSuccess() {
        let controller = UIAlertController(title: "Nice!", message: "Your video has been successfully saved to the camera roll!", preferredStyle: .Alert)
        controller.addAction(UIAlertAction(title: "Okay", style: .Cancel, handler: nil))
        self.viewController.presentViewController(controller, animated: true, completion: nil)
    }
}