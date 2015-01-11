//
//  AccountDetails.swift
//  Pinsit
//
//  Created by Walker Christie on 11/8/14.
//  Copyright (c) 2014 Walker Christie. All rights reserved.
//

import Foundation

class AccountDetails {
    var path: NSString!
    
    init() {
        let fm = NSFileManager.defaultManager()
        path = File().documentsPath().stringByAppendingPathComponent("account.plist")
        
        if (!fm.fileExistsAtPath(path)) {
            fm.createFileAtPath(path, contents: nil, attributes: nil)
        }
    }
    
    func setDetails(karma: NSNumber, followers: NSNumber, following: NSNumber) {
        let keys = NSArray(objects: "karma", "followers", "following")
        let values = NSArray(objects: karma, followers, following)
        let dict = NSDictionary(objects: values, forKeys: keys)

        dict.writeToFile(path, atomically: true)
    }
    
    func loadDetails() -> (karma: NSNumber, followers: NSNumber, following: NSNumber) {
        let details = NSDictionary(contentsOfFile: path)
        
        let karma = details?.valueForKey("karma") as NSNumber
        let followers = details?.valueForKey("followers") as NSNumber
        let following = details?.valueForKey("following") as NSNumber
        
        return (karma, followers, following)
    }
    
    func loadImage() -> UIImage {
        let imgLoc = File().documentsPath().stringByAppendingPathComponent("profilePicture.png")
        let img = UIImage(contentsOfFile: imgLoc)
        
        if (img == nil) {
            let newImage = UIImage(named: "profile.png")!
            setImage(newImage)
            
            return newImage
        }
        
        return img!
    }
    
    func setImage(img: UIImage) {
        let imgLoc = File().documentsPath().stringByAppendingPathComponent("profilePicture.png")
        UIImagePNGRepresentation(img).writeToFile(imgLoc, atomically: true)
    }
}