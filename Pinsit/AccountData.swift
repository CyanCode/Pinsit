//
//  AccountData.swift
//  Pinsit
//
//  Created by Walker Christie on 11/8/14.
//  Copyright (c) 2014 Walker Christie. All rights reserved.
//

import Foundation
import Parse

///Load all data associated with AccountViewController as fast as possible
public class AccountData {
    var userID: String
    var username: String
    var pulledText: [String]! //Contains Comments, Posted Vids, New Followers, in descending order
    var pulledImages: [UIImage]! //Contains images for UITableViewCell in same order
    var error: NSError?
    
    init(userId: String, username: String) {
        self.userID = userId
        self.username = username
    }
    
    ///Pulls required data from the server
    ///If successful, collect data from variables, if not, check error message
    func pullInformation(completionHandler: (success: Bool) -> Void) {
        let query = PFQuery(className: "AccountActivity")
        query.whereKey("userID", equalTo: userID)
        query.orderByAscending("updatedAt")
        query.cachePolicy = PFCachePolicy.CacheElseNetwork
        
        do {
            let objects = try query.findObjects()
            distributeObjectData(objects)
        } catch let error {
            print("Failed to find information objects: \(error)")
        }
    }
    
    private func distributeObjectData(objects: [PFObject]) {
        for object in objects {
            switch exchangeTypes(object["type"] as! String) {
            case TableViewCellOptions.Comment:
                pulledText.append(object["comment"] as! String)
                pulledImages.append(approveImages(object["profileImage"] as! UIImage?))
                break
            case TableViewCellOptions.NewVideoLocation:
                pulledText.append("\(username) has posted a new video")
                pulledImages.append(UIImage(named: "newvideo.png")!)
                break
            case TableViewCellOptions.NewFollower:
                let followerName = object["followerName"] as! String
                pulledText.append(followerName + "is now following \(username)")
                pulledImages.append(UIImage(named: "follower.png")!)
                break
            }
        }
    }
    
    private func approveImages(image: UIImage?) -> UIImage {
        if (image != nil) {
            return image!
        } else {
            return UIImage(named: "profile.png")!
        }
    }
    
    private func exchangeTypes(type: String) -> TableViewCellOptions {
        switch type {
        case "comment":
            return TableViewCellOptions.Comment
        case "newvideo":
            return TableViewCellOptions.NewVideoLocation
        case "newfollower":
            return TableViewCellOptions.NewFollower
        default:
            return TableViewCellOptions.Comment
        }
    }
}