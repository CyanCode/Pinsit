//
//  Followers.swift
//  Pinsit
//
//  Created by Walker Christie on 2/22/15.
//  Copyright (c) 2015 Walker Christie. All rights reserved.
//

import Foundation

class Followers {
    var followers: [String]?
    
    init() {
        self.followers = nil
    }
    
    func findFollowersInBackground(completion: (success: Bool) -> Void) {
        let query = PFQuery(className: "Followers")
        query.whereKey("username", equalTo: PFUser.currentUser().username)
        
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error != nil {
                completion(success: false)
            } else if countElements(objects) > 0 {
                self.followers = objects[0]["following"] as? [String]
                completion(success: true)
            } else {
                self.followers = [String]()
                completion(success: true)
            }
        }
    }
    
    func followerExists(username: String) -> Bool {
        if followers != nil {
            for follower in followers! {
                if username == follower {
                    return true
                }
            }
            
            return false
        } else {
            return false
        }
    }
}