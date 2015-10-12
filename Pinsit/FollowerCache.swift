//
//  FollowerCache.swift
//  Pinsit
//
//  Created by Walker Christie on 3/28/15.
//  Copyright (c) 2015 Walker Christie. All rights reserved.
//

import Foundation
import Parse

class FollowerCache {
    var following = [String]()
    
    init() {
        let cache = self.getCachedFollowers()
        self.following = cache == nil ? [String]() : cache!
    }
    
    ///Updates current cache with currentUser's follower list
    func updateCache() {
        updateCacheWithBlock { (error) -> Void in }
    }
    
    func updateCacheWithBlock(done: () -> Void) {
        let query = PFQuery(className: "Followers")
        query.whereKey("username", equalTo: PFUser.currentUser()!.username!)
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error != nil || objects == nil || objects!.count < 1 {
                done()
                return
            }
            
            let follow = (objects as! [PFFollowers])[0].getFollowing()
            let object = PFFollowers()
            
            object.username = PFUser.getSafeUsername()
            object.following = follow
            
            //Reset and Pin
            self.resetCache()
            object.pinInBackgroundWithBlock({ (success, error) -> Void in })
            print("Follower cache updated successfully")
            
            self.following = follow
            done()
        }
    }
    
    ///Get the date of the last follower update
    ///
    ///- returns: last update as NSDate, nil if it doesn't exist
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
    ///- returns: array of followers, nil if it doesn't exist
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
    ///- returns: true if existant, false if not
    func followersExist() -> Bool {
        let user = getUserObject()
        
        return user == nil ? false : true
    }
    
    ///Checks if currentUser is following specified user
    ///
    ///- parameter user: Username to compare
    ///- returns: true or false depending on result
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
        query.whereKey("username", equalTo: PFUser.currentUser()!.username!)
        query.fromLocalDatastore()
        
        do {
            let objects = try query.findObjects()
            for obj in objects as [PFObject] {
                do {
                    try obj.unpin()
                } catch let error {
                    print("Failed to unpin object: \(error)")
                }
            }
        } catch let error {
            print("Failed to query objects: \(error)")
        }
    }
    
    private func getUserObject() -> PFObject? {
        let query = PFQuery(className: "Followers")
        query.whereKey("username", equalTo: PFUser.currentUser()!.username!)
        query.fromLocalDatastore()
        
        do {
            let objects = try query.findObjects()
            return objects.count > 0 ? objects[0] as! PFObject : nil
        } catch {
            return nil
        }
    }
}