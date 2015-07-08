//
//  AccountDetails.swift
//  Pinsit
//
//  Created by Walker Christie on 11/8/14.
//  Copyright (c) 2014 Walker Christie. All rights reserved.
//

import Foundation

class AccountDetails {
    let profilePic = PFUser.currentUser()!.username! + ".png"
    var viewController: AccountViewController!
    var path: String

    init(viewController: AccountViewController) {
        self.viewController = viewController
        let fm = NSFileManager.defaultManager()
        path = File.documentsPath().stringByAppendingPathComponent("account.plist")

        if (fm.fileExistsAtPath(path) == false) {
            fm.createFileAtPath(path, contents: nil, attributes: nil)
        }
    }
    
    ///Sets following, active posts, and karma level from the server
    ///
    ///:params: completion Called when account details have been updated
    func setAccountDetails(completion: () -> Void) {
        let followQuery = PFQuery(className: "Followers")
        followQuery.whereKey("username", equalTo: PFUser.currentUser()!.username!)

        followQuery.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if (objects!).count > 0 {
                let amount = (objects![0]["following"] as! [String]).count
                self.viewController.followingLabel.text = amount == 1 ? "Following \(amount) User" : "Following \(amount) Users"
            } else {
                self.viewController.followingLabel.text = "Following 0 Users"
            }
            
            PFUser.currentUser()!.fetchInBackgroundWithBlock({ (object, error) -> Void in
                AccountDetails.findPostAmount({ (amount) -> Void in
                    let postAmt = amount == nil ?  0 : amount!
                    var karma = object?["karma"] as? NSNumber
                    karma = karma == nil ? 0 : karma

                    self.viewController.postAmountLabel.text = postAmt == 1 ? "\(postAmt) Active Post" : "\(postAmt) Active Posts"
                    self.viewController.karmaLabel.text = "Karma Level \(karma!)"
                    completion()
                })
            })
        }
    }
    
    func loadImage() -> UIImage {
        let imgLoc = File.documentsPath().stringByAppendingPathComponent(profilePic)
        let img = UIImage(contentsOfFile: imgLoc)
        
        if (img == nil) {
            let newImage = UIImage(named: "profile.png")!
            setImage(newImage)
            
            return newImage
        }
        
        return img!
    }
    
    func setImage(img: UIImage) {
        let imgLoc = File.documentsPath().stringByAppendingPathComponent(profilePic)
        UIImagePNGRepresentation(img)!.writeToFile(imgLoc, atomically: true)
    }
    
    ///Locates the amount of posts currently on the server
    ///
    ///- parameter amount: Amount of posts currently active, nil if error occurs
    class func findPostAmount(completion: (amount: NSNumber?) -> Void) {
        let query = PFQuery(className: "SentData")
        query.whereKey("username", equalTo: PFUser.currentUser()!.username!)
        
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error != nil {
                completion(amount: nil)
            } else {
                completion(amount: NSNumber(integer: (objects!).count))
            }
        }
    }
}