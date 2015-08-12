//
//  FollowerManager.swift
//  Pinsit
//
//  Created by Walker Christie on 7/9/15.
//  Copyright © 2015 Walker Christie. All rights reserved.
//

import Foundation
import Parse

/**
Manager for NET based follower operations.
Use FollowerCache for caching operations

All operations are performed async
*/
class FollowerManager {
    var user: String!
    var responder: UIViewController?
    var shouldUpdateCacheAfterwards = false
    
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
                let obj = objects![0] as! PFFollowers
                obj.removeFollower(named)
                
                obj.saveInBackgroundWithBlock({ (success, error) -> Void in
                    if !success {
                        self.handleError("Unable to unfollow \(named), check your network connection and try again!")
                    } else if self.shouldUpdateCacheAfterwards {
                        FollowerCache().updateCache()
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
                let obj = objects![0] as! PFFollowers
                obj.addFollower(named)
                
                obj.saveInBackgroundWithBlock({ (success, error) -> Void in
                    if success == false {
                        self.handleError("Unable to follow \(named), check your network connection and try again!")
                    } else {
                        if self.responder != nil {
                            ErrorReport(viewController: self.responder!).presentError("Great!", message: "You are now following \(named); nice work!", type: .Success)
                        }; if self.responder != nil && self.shouldUpdateCacheAfterwards {
                            FollowerCache().updateCache()
                        }
                    }
                })
            }
        }
    }
    
    private func handleError(message: String) {
        if responder != nil {
            ErrorReport(viewController: responder!).presentError("Uh Oh!", message: message, type: .Error)
        }
    }
}