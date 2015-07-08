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
    var tableUsernames = [String]()
    var tableProfiles: [NSURL?]!
    
    private var offset: Int!
    
    func readyTableView(pinObject: PFObject) {
        self.pinObject = pinObject
        self.offset = 0
        
        self.delegate = self
        self.dataSource = self
        self.pullToRefresh()
    }
    
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableUsernames.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier = "TappedPinLikesCell"
        var cell = self.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as? TappedPinLikesCell
        
        if cell == nil {
            cell = TappedPinLikesCell(style: .Default, reuseIdentifier: identifier)
        }
        
        if tableProfiles[indexPath.row] as NSURL? == nil {
            cell!.profileImage.image = UIImage(named: "profile.png")!
        } else {
            let url = tableProfiles[indexPath.row]!
            cell!.profileImage.sd_setImageWithURL(url, placeholderImage: UIImage(named: "profile.png")!)
        }
        
        cell!.username.text = tableUsernames[indexPath.row]
        
        return cell!
    }
    
    private func pullToRefresh() {
        self.addPullToRefreshWithAction { () -> () in
            self.fillTableArrays(true, completion: { () -> Void in
                self.stopPullToRefresh()
                self.reloadData()
            })
        }
    }
    
    ///Sets both tableView arrays to content from the server with respect to the offset
    ///
    ///- parameter resetFirst: Should the tableView arrays be reset before being filled with new values
    ///- parameter completion: Called when the values have been added
    private func fillTableArrays(resetFirst: Bool, completion: () -> Void) {
        let likesQuery = PFQuery(className: "Likes")
        likesQuery.whereKey("videoId", equalTo: pinObject.objectId!)
        likesQuery.skip = offset
        likesQuery.limit = offset + 15 //Find next 15 likes
        
        likesQuery.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error == nil && (objects!).count > 0 {
                if resetFirst == true {
                    self.tableUsernames = [String]()
                    self.tableProfiles = [NSURL]()
                }
                
                for like in objects! {
                    self.tableUsernames.append(like["username"] as! String)
                    
                    var url: NSURL?
                    if like["profileURL"] as? String == nil {
                        url = nil
                    } else {
                        url = NSURL(string: like["profileURL"] as! String)
                    }
                    
                    self.tableProfiles.append(url)
                }
                
                completion()
            } else {
                completion()
            }
        }
    }
}
