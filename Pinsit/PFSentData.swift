//
//  PFSentData.swift
//  Pinsit
//
//  Created by Walker Christie on 7/19/15.
//  Copyright © 2015 Walker Christie. All rights reserved.
//

import Foundation
import Parse

class PFSentData: PFObject, PFSubclassing {
    @NSManaged var username: String
    @NSManaged var desc: String
    @NSManaged var downloading: NSNumber
    @NSManaged var `private`: NSNumber
    @NSManaged var viewCount: Int
    @NSManaged var location: PFGeoPoint
    @NSManaged var thumbnail: PFFile
    @NSManaged var video: PFFile
    
    override init() {
        super.init()
    }
    
    override init(className newClassName: String) {
        super.init(className: newClassName)
    }
    
    ///Constructs PFSentData instance from PostDetailsView instance
    init(view: PostDetailsView) {
        super.init()
        username = PFUser.currentUser()!.username!
        desc = view.descriptionView.text!
        downloading = NSNumber(booleanLiteral: view.downloadSwitch.on)
        `private` = NSNumber(booleanLiteral: view.privateSwitch.on)
        thumbnail = PFFile(image: Image().generateThumbnail())
        video = PFFile(data: NSData(contentsOfURL: File.getVideoPathURL())!)
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
        return "SentData"
    }
}