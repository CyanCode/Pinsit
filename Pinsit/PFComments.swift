//
//  PFComments.swift
//  Pinsit
//
//  Created by Walker Christie on 8/23/15.
//  Copyright (c) 2015 Walker Christie. All rights reserved.
//

import Foundation
import Parse

class PFComments: PFObject, PFSubclassing {
    @NSManaged var username: String!
    @NSManaged var videoId: String!
    @NSManaged var comment: String!
    
    override class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0
        }
        
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }
    
    static func parseClassName() -> String {
        return "Comments"
    }
}