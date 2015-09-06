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

@IBDesignable class FollowerQueryTableViewController: QueryTableViewController, QueryTableViewControllerDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    let identifier = "AccountQueryCell"
    var queryType: FollowerQuerySearchType = .Following
    var username = ""
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.emptyDataSetDelegate = self
        self.tableView.emptyDataSetSource = self
        
        self.tableView.separatorColor = UIColor.whiteColor()
        self.tableView.backgroundColor = UIColor(string: "#2F394E")
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        
        loadObjects()
    }
    
    override func queryForTableView() -> PFQuery {
        if queryType == .Following {
            super.loadFromArrayColumn = "following"
            let query = PFQuery(className: "Followers")
            query.whereKey("username", equalTo: username)
            
            return query
        } else {
            super.loadFromArrayColumn = nil
            let query = PFQuery(className: "Followers")
            query.whereKey("following", equalTo: username)
            
            return query
        }
    }
    
    override func objectsDidLoadSuccessfully() {
        tableView.reloadEmptyDataSet()
    }
    
    override func objectsDidFailToLoad(error: NSError?) {
        tableView.reloadEmptyDataSet()
    }
    
    override func objectsWillLoad() {
        tableView.reloadEmptyDataSet()
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, content: AnyObject) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier) as! AccountQueryCell
        let username = content as! String
        
        cell.usernameLabel.text = username
        cell.profileImage.username = username
        cell.profileImage.image = UIImage(named: "profile")
        cell.profileImage.loadUserImage()
        
        return cell
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier) as! AccountQueryCell
        let following = object as! PFFollowers
        
        cell.usernameLabel.text = following.username
        cell.profileImage.username = following.username
        cell.profileImage.image = UIImage(named: "profile")
        cell.profileImage.loadUserImage()
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 62
    }
    
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        (view as! UITableViewHeaderFooterView).contentView.backgroundColor = UIColor(string: "#35A5D4")
    }
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView(frame: CGRectZero)
    }
    
    //MARK: Empty dataset
    
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let text = queryType == .Following ? "\(username) isn't following anyone yet!" : "\(username) has no followers yet!  You could change that.."
        
        let attr = NSMutableAttributedString(string: "Sadly, \(username) has no followers yet!", attributes: [NSFontAttributeName : UIFont(name: "Helvetica", size: 16)!])
        attr.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor(), range: NSMakeRange(0, count(text)))
        
        return attr
    }
    
    func emptyDataSetShouldAllowScroll(scrollView: UIScrollView!) -> Bool {
        return true
    }
}

@IBDesignable class FollowerImageView: AsyncImageView {
    var username: String!
    var usernameURL: NSURL?
    
    @IBInspectable var cornerRadius: CGFloat = 3 {
        didSet {
            self.layer.cornerRadius = cornerRadius
            self.layer.masksToBounds = true
        }
    }
    @IBInspectable var borderColor: UIColor = UIColor.whiteColor() {
        didSet {
            self.layer.borderColor = borderColor.CGColor
        }
    }
    @IBInspectable var borderWidth: CGFloat = 1 {
        didSet {
            self.layer.borderWidth = borderWidth
        }
    }
    
    func loadUserImage() {
        if usernameURL == nil {
            let query = PFUser.query()!
            query.whereKey("username", equalTo: username)
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

enum FollowerQuerySearchType {
    case Followers
    case Following
}