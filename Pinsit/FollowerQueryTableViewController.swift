//
//  FollowerQueryTableViewController.swift
//  Pinsit
//
//  Created by Walker Christie on 8/2/15.
//  Copyright © 2015 Walker Christie. All rights reserved.
//

import UIKit
import Parse
import ParseUI
import AsyncImageView
import DZNEmptyDataSet

@IBDesignable class FollowerQueryTableViewController: PFQueryTableViewController, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    let identifier = "AccountQueryCell"
    var username = ""
    
    override convenience init(style: UITableViewStyle, className: String?) {
        self.init(style: style, className: className)
        self.tableView.emptyDataSetDelegate = self
        self.tableView.emptyDataSetSource = self
        
        self.tableView.separatorColor = UIColor.pinsitWhiteBlue()
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
    }
    
    override func queryForTable() -> PFQuery {
        let query = PFQuery(className: "Followers")
        query.whereKey("following", equalTo: username)
        
        return query
    }
    
    override func objectsDidLoad(error: NSError?) {
        super.objectsDidLoad(error)
        tableView.reloadEmptyDataSet()
    }
    
    override func objectsWillLoad() {
        super.objectsWillLoad()
        tableView.reloadEmptyDataSet()
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFTableViewCell? {
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier) as! AccountQueryCell
        let followerObject = object as! PFFollowers
        
        cell.usernameLabel.text = followerObject.username
        cell.profileImage.image = UIImage(named: "profile")
        cell.profileImage.username = followerObject.username
        cell.profileImage.loadUserImage()
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 62
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return username == "" ? "Followers" : "\(username)'s Followers"
    }
    
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView

        header.textLabel?.textColor = UIColor.pinsitWhiteBlue()
        header.contentView.backgroundColor = UIColor.whiteColor()
        header.textLabel?.font = UIFont(name: "Helvetica", size: (header.textLabel?.font.pointSize)!)
    }
    
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let text = NSMutableAttributedString(string: "Sadly, \(username) has no followers yet!", attributes: [NSFontAttributeName : UIFont(name: "Helvetica", size: 15)!])
        text.addAttribute(NSForegroundColorAttributeName, value: UIColor.pinsitWhiteBlue(), range: NSMakeRange(0, text.string.characters.count))

        return text
    }
    
    func emptyDataSetShouldAllowScroll(scrollView: UIScrollView!) -> Bool {
        return true
    }
}

@IBDesignable class FollowerImageView: AsyncImageView {
    var username: String?
    var usernameURL: NSURL?
    @IBInspectable var cornerRadius: CGFloat = 3 {
        didSet {
            self.layer.cornerRadius = cornerRadius
            self.layer.masksToBounds = true
        }
    }
    
    func loadUserImage() {
        if usernameURL == nil {
            let query = PFUser.query()!
            query.whereKey("username", equalTo: username!)
            query.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                if error == nil && objects!.count > 0 {
                    let file = objects![0]["profileImage"] as? PFFile
                    if file != nil { self.imageURL = NSURL(string: file!.url!) }
                }
            })
        } else {
            self.imageURL = usernameURL!
        }
    }
}
