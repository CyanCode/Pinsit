//
//  PFFollowers.swift
//  Pinsit
//
//  Created by Walker Christie on 7/24/15.
//  Copyright © 2015 Walker Christie. All rights reserved.
//

import Foundation
import Parse

class PFFollowers: PFObject, PFSubclassing {
    @NSManaged var username: String
    @NSManaged var following: [AnyObject]?
    
    func getFollowing() -> [String] {
        return following != nil ? following as! [String] : [String]()
    }
    
    func addFollower(name: String) {
        if !FollowerCache().isFollowing(name) {
            if following == nil {
                following = [String]()
                following!.append(name)
            } else {
                following!.append(name)
            }
        }
    }
    
    func removeFollower(name: String) {
        for var i = 0; i < following!.count; i++ {
            if following![i] as! String == name {
                self.following!.removeAtIndex(i)
            }
        }
        
        if following != nil && following!.count == 0 {
            following = nil
        }
    }
    
    override class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0
        }
        
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }
    
    static func parseClassName() -> String {
        return "Followers"
    }
}