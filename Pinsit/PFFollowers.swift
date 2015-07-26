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