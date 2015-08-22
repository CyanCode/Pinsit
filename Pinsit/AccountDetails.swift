//
//  AccountDetails.swift
//  Pinsit
//
//  Created by Walker Christie on 11/8/14.
//  Copyright (c) 2014 Walker Christie. All rights reserved.
//

import Foundation
import Parse

class AccountDetails {
    let profilePic = PFUser.currentUser()!.username! + ".png"
    let path = File.documentsPath().stringByAppendingPathComponent("account.plist")
    var viewController: AccountViewController!
    var user: String!
    
    ///Only used for setting profile picture information
    init() {
        viewController = AccountViewController()
        user = ""
    }
    
    init(viewController: AccountViewController, user: String) {
        self.viewController = viewController
        self.user = user
        
        let fm = NSFileManager.defaultManager()
        if (fm.fileExistsAtPath(path) == false) {
            fm.createFileAtPath(path, contents: nil, attributes: nil)
        }
    }
    
    ///Sets following, followers, and karma level from the server
    ///
    ///:params: completion Called when account details have been updated
    func setAccountDetails(completion: () -> Void) {
        var completionCount = 0
        
        let followingQuery = PFQuery(className: "Followers")
        let followerQuery = PFQuery(className: "Followers")
        let karmaQuery = PFUser.query()!
        
        followingQuery.whereKey("username", equalTo: user)
        followerQuery.whereKey("following", equalTo: user)
        karmaQuery.whereKey("username", equalTo: user)
        
        followingQuery.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error == nil && objects!.count > 0 {
                let count = (objects! as! [PFFollowers])[0].getFollowing().count
                self.viewController.followingLabel.text = "Following \(count)"
            } else {
                self.viewController.followingLabel.text = "Following 0"
            }
            
            if ++completionCount == 3 { completion() }
        }
        followerQuery.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error == nil && objects!.count > 0 {
                let count = (objects! as! [PFFollowers]).count
                self.viewController.followerLabel.text = count == 1 ? "1 Follower" : "\(count) Followers"
            } else {
                self.viewController.followerLabel.text = "0 Followers"
            }
            
            if ++completionCount == 3 { completion() }
        }
        karmaQuery.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error == nil && objects!.count > 0 {
                let count = (objects! as! [PFUser])[0]["karma"] as! NSNumber
                self.viewController.karmaLabel.text = "\(count) Karma"
            } else {
                self.viewController.karmaLabel.text = "0 Karma"
            }
            
            if ++completionCount == 3 { completion() }
        }
    }
    
    let defaultProfile = UIImage(named: "profile.png")!
    func loadProfileImage(completion: (img: UIImage) -> Void) {
        if user == PFUser.currentUser()!.username! {
            let imgLoc = File.documentsPath().stringByAppendingPathComponent(profilePic)
            let img = UIImage(contentsOfFile: imgLoc) == nil ? defaultProfile : UIImage(contentsOfFile: imgLoc)
            
            if (img == nil) {
                setImage(defaultProfile)
                completion(img: defaultProfile)
            }
            
            return completion(img: img!)
        } else {
            PFUser.query()?.whereKey("username", equalTo: user).findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                if error != nil {
                    self.setImage(self.defaultProfile)
                    completion(img: self.defaultProfile)
                } else {
                    let file = objects![0]["profileImage"] as? PFFile
                    completion(img: file == nil ? self.defaultProfile : UIImage(data: file!.getData()!)!)
                }
            })
            
        }
    }
    
    func setImage(img: UIImage) {
        let imgLoc = File.documentsPath().stringByAppendingPathComponent(profilePic)
        UIImagePNGRepresentation(img)!.writeToFile(imgLoc, atomically: true)
    }
    
    ///Locates the amount of posts currently on the server
    ///
    ///- parameter amount: Amount of posts currently active, nil if error occurs
    class func findPostAmount(user: String, completion: (amount: NSNumber?) -> Void) {
        let query = PFQuery(className: "SentData")
        query.whereKey("username", equalTo: user)
        
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error != nil {
                completion(amount: nil)
            } else {
                completion(amount: NSNumber(integer: (objects!).count))
            }
        }
    }
}