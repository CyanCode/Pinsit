//
//  PinVideoTableView.swift
//  Pinsit
//
//  Created by Walker Christie on 2/18/15.
//  Copyright (c) 2015 Walker Christie. All rights reserved.
//

import UIKit

class PinVideoTableView: UITableView, UITableViewDataSource, UITableViewDelegate {
    var pinObject: PFObject!
    var tableUsernames: [String]!
    var tableProfiles: [NSURL?]!
    
    private var offset: Int!
    
    init(pinObject: PFObject) {
        super.init()

        self.pinObject = pinObject
        self.offset = 0
        
        self.pullToRefresh()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countElements(tableUsernames)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier = "cell"
        var cell = self.dequeueReusableCellWithIdentifier(identifier) as TappedPinLikesCell?
        
        if cell == nil {
            cell = TappedPinLikesCell(style: .Default, reuseIdentifier: identifier)
        }
        
        cell?.profileImage.sd_setImageWithURL(tableProfiles[indexPath.row], placeholderImage: UIImage(named: "profile"))
        cell?.username.text = tableUsernames[indexPath.row]
        
        return cell!
    }
    
    private func pullToRefresh() {
        self.addPullToRefreshWithActionHandler { () -> Void in
            self.fillTableArrays(true, completion: { () -> Void in
                self.reloadData()
            })
        }
        
        self.addInfiniteScrollingWithActionHandler { () -> Void in
            if self.offset == 0 { self.offset = 15 } //Increment first time
            
            self.fillTableArrays(false, completion: { () -> Void in
                self.offset = self.offset + 15 //+= doesn't work??
                self.reloadData()
            })
        }
    }
    
    ///Sets both tableView arrays to content from the server with respect to the offset
    ///
    ///:param: resetFirst Should the tableView arrays be reset before being filled with new values
    ///:param: completion Called when the values have been added
    private func fillTableArrays(resetFirst: Bool, completion: () -> Void) {
        let likesQuery = PFQuery(className: "Likes")
        likesQuery.whereKey("videoId", equalTo: pinObject.objectId)
        likesQuery.skip = offset
        likesQuery.limit = offset + 15 //Find next 15 likes
        
        likesQuery.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if countElements(objects) > 0 {
                if resetFirst == true {
                    self.tableUsernames = [String]()
                    self.tableProfiles = [NSURL]()
                }
                
                for like in objects {
                    self.tableUsernames.append(like["username"] as String)
                    self.tableProfiles.append(like["profileURL"] != nil ? NSURL(string: like["profileURL"] as String) : NSURL(fileURLWithPath: "profile.png")!)
                }
            } else {
                completion()
            }
        }
    }
}
