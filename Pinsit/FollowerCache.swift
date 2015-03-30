//
//  FollowerCache.swift
//  Pinsit
//
//  Created by Walker Christie on 3/28/15.
//  Copyright (c) 2015 Walker Christie. All rights reserved.
//

import Foundation

class FollowerCache {
    var following = [String]()
    
    init() {
        let cache = self.getCachedFollowers()
        self.following = cache == nil ? [String]() : cache!
    }
    
    ///Updates current cache with currentUser's follower list
    func updateCache() {
        let query = PFQuery(className: "Followers")
        query.whereKey("username", equalTo: PFUser.currentUser().username)
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error != nil {
                return
            }
            
            let followers = countElements(objects) > 0 ? objects[0]["following"] as [String] : [String]()
            let object = PFObject(className: "Followers")
            
            object["username"] = PFUser.currentUser().username
            object["following"] = followers
            
            //Reset and Pin
            self.resetCache()
            object.pinInBackgroundWithBlock({ (success, error) -> Void in })
            println("Follower cache updated successfully")
            
            self.following = followers
        }
    }
    
    ///Get the date of the last follower update
    ///
    ///:returns: last update as NSDate, nil if it doesn't exist
    func getLastPinDate() -> NSDate? {
        let user = getUserObject()
        
        if user == nil {
            return nil
        } else {
            return user!["updatedAt"] as? NSDate
        }
    }
    
    ///Get the last cached list of followers
    ///
    ///:returns: array of followers, nil if it doesn't exist
    func getCachedFollowers() -> [String]? {
        let user = getUserObject()
        
        if user == nil {
            return nil
        } else {
            return user!["following"] as? [String]
        }
    }
    
    ///Checks if the array of followers exists in the cache
    ///
    ///:returns: true if existant, false if not
    func followersExist() -> Bool {
        let user = getUserObject()
        
        return user == nil ? false : true
    }
    
    ///Checks if currentUser is following specified user
    ///
    ///:param: user Username to compare
    ///:returns: true or false depending on result
    func isFollowing(user: String) -> Bool {   
        for follower in self.following {
            if user == follower {
                return true
            }
        }
        
        return false
    }
    
    ///Reset all cached follower objects (if they exist)
    func resetCache() {
        let query = PFQuery(className: "Followers")
        query.whereKey("username", equalTo: PFUser.currentUser().username)
        query.fromLocalDatastore()
        
        let objects = query.findObjects()
        
        for obj in objects as [PFObject] {
            obj.unpin()
        }
    }
    
    private func getUserObject() -> PFObject? {
        let query = PFQuery(className: "Followers")
        query.whereKey("username", equalTo: PFUser.currentUser().username)
        query.fromLocalDatastore()
        let objects = query.findObjects()
        
        if countElements(objects) <= 0 {
            return nil
        } else {
            return objects[0] as? PFObject
        }
    }
}