//
//  FollowerManager.swift
//  Pinsit
//
//  Created by Walker Christie on 7/9/15.
//  Copyright © 2015 Walker Christie. All rights reserved.
//

import Foundation

/**
Manager for NET based follower operations.
Use FollowerCache for caching operations

All operations are performed async
*/
class FollowerManager {
    var user: String!
    var responder: UIViewController?
    
    ///User to perform follower operations on
    ///
    ///parameter: Optional responder for network errors
    init(user: String, responder: UIViewController?) {
        self.user = user
        self.responder = responder
    }
    
    ///Remove follower from 'user' following list
    func removeFollower(named: String) {
        let query = PFQuery(className: "Followers")
        query.whereKey("username", equalTo: user)
        
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error != nil {
                self.handleError("Unable to unfollow \(named), check your network connection and try again!")
            } else {
                let obj = objects![0] as! PFObject
                var following = obj["following"] as! [String]
                
                for var i = 0; i < following.count; i++ {
                    if following[i] == named {
                        following.removeAtIndex(i)
                    }
                }
                
                obj["following"] = following
                obj.saveInBackgroundWithBlock({ (success, error) -> Void in
                    if success == false {
                        self.handleError("Unable to unfollow \(named), check your network connection and try again!")
                    }
                })
            }
        }
    }
    
    ///Add follower to 'user' following list
    func addFollower(named: String) {
        let query = PFQuery(className: "Followers")
        query.whereKey("username", equalTo: user)
        
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error != nil {
                self.handleError("Unable to follow \(named), check your network connection and try again!")
            } else {
                let obj = objects![0] as! PFObject
                var following = obj["following"] as! [String]
                
                following.append(named)
                obj["following"] = following
                
                obj.saveInBackgroundWithBlock({ (success, error) -> Void in
                    if success == false {
                        self.handleError("Unable to follow \(named), check your network connection and try again!")
                    }
                })
            }
        }
    }
    
    private func handleError(message: String) {
        let controller = UIAlertController(title: "Hmm..", message: message, preferredStyle: .Alert)
        controller.addAction(UIAlertAction(title: "Dismiss", style: .Cancel, handler: nil))
        
        if responder != nil {
            responder!.presentViewController(controller, animated: true, completion: nil)
        }
    }
}