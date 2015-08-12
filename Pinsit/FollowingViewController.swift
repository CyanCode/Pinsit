//
//  FollowingViewController.swift
//  Pinsit
//
//  Created by Walker Christie on 11/5/14.
//  Copyright (c) 2014 Walker Christie. All rights reserved.
//

import UIKit
import ParseUI
import Parse
import DZNEmptyDataSet

class FollowingViewController: UIViewController, UISearchBarDelegate {
    @IBOutlet var searchBar: UISearchBar!
    var followerController: FollowingQueryTableViewController {
        get {
            return self.childViewControllers[0] as! FollowingQueryTableViewController
        }
    }
    
    override func viewDidLoad() {
        searchBar.delegate = self
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        followerController.query = PFUser.query()!
        followerController.query?.whereKey("username", equalTo: PFUser.currentUser()!.username!)
        followerController.searchQuery = true
        followerController.awaitingReload = false
        followerController.loadObjects()
        
        searchBar.resignFirstResponder()
    }
}

class FollowingQueryTableViewController: PFQueryTableViewController, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {
    let identifier = "FollowingTableViewCell"
    var followerCache = FollowerCache()
    var query: PFQuery?
    var searchQuery: Bool = false
    var awaitingReload: Bool = false
    
    override func viewDidLoad() {
        followerCache.updateCache()
        loadObjects()
        
        tableView.tableFooterView = UIView(frame: CGRectZero)
        tableView.emptyDataSetDelegate = self
        tableView.emptyDataSetSource = self
    }
    
    override func queryForTable() -> PFQuery {
        if query == nil {
            query = PFQuery(className: "Followers")
            query?.whereKey("username", equalTo: PFUser.currentUser()!.username!)
            query?.whereKeyExists("following")
            query?.includeKey("following")
        }
        
        return query!
    }
    
    override func objectsDidLoad(error: NSError?) {
        super.objectsDidLoad(error)
        tableView.reloadEmptyDataSet()
    }
    
    override func objectsWillLoad() {
        tableView.reloadEmptyDataSet()
        
        if awaitingReload == true {
            awaitingReload = false
            searchQuery = false
            query = nil
        }
        
        super.objectsWillLoad()
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 62
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFTableViewCell? {
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier) as! FollowingTableViewCell
        followerCache = FollowerCache() //Refresh cache each time
        
        if searchQuery {
            let followerObject = object as! PFUser
            
            cell.usernameLabel.text = followerObject.username
            cell.profileImage.username = followerObject.username!
            cell.addFollowerButton.hidden = followerCache.isFollowing(followerObject.username!)
            
            awaitingReload = true
        } else {
            let followerObject = object as! PFFollowers
            
            cell.usernameLabel.text = followerObject.following![indexPath.row] as? String
            cell.profileImage.username = followerObject.following![indexPath.row] as? String
            cell.addFollowerButton.hidden = followerCache.isFollowing(followerObject.following![indexPath.row] as! String)
        }
        
        //Add gesture recognizer
        if cell.gestureRecognizers == nil || cell.gestureRecognizers!.count == 0 {
            let press = UILongPressGestureRecognizer(target: self, action: "cellLongPress:")
            cell.addGestureRecognizer(press)
        }
        
        cell.profileImage.image = UIImage(named: "profile")
        cell.profileImage.loadUserImage()
        cell.separatorInset = UIEdgeInsetsZero
        
        return cell
    }
    
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let text = NSMutableAttributedString(string: "You aren't following any users!", attributes: [NSFontAttributeName : UIFont(name: "Helvetica", size: 15)!])
        text.addAttribute(NSForegroundColorAttributeName, value: UIColor.pinsitWhiteBlue(), range: NSMakeRange(0, text.string.characters.count))
        
        return text
    }
    
    func emptyDataSetShouldAllowScroll(scrollView: UIScrollView!) -> Bool {
        return true
    }
    
    func cellLongPress(gesture: UIGestureRecognizer) {
        let cell = gesture.view as! FollowingTableViewCell
        
        if gesture.state == .Began {
            let confirmation = UIAlertController(title: "Really?", message: "Are you sure you would like to remove \(cell.usernameLabel.text!) from your following list?", preferredStyle: .Alert)
            confirmation.addAction(UIAlertAction(title: "Nevermind", style: .Cancel, handler: nil))
            confirmation.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { (action) -> Void in
                FollowerManager(user: PFUser.currentUser()!.username!, responder: self).removeFollower(cell.usernameLabel.text!)
                self.loadObjects()
            }))
            
            self.presentViewController(confirmation, animated: true, completion: nil)
        }
    }
    
    @IBAction func addButtonPressed(sender: UIButton) {
        let path = tableView.indexPathForRowAtPoint(sender.convertPoint(CGPointZero, toView: tableView))
        let cell = tableView.cellForRowAtIndexPath(path!) as! FollowingTableViewCell
        cell.addFollowerButton.hidden = true
        
        let manager = FollowerManager(user: PFUser.currentUser()!.username!, responder: self)
        manager.shouldUpdateCacheAfterwards = true
        manager.addFollower(cell.usernameLabel.text!)
    }
}

class FollowingTableViewCell: PFTableViewCell {
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var profileImage: FollowerImageView!
    @IBOutlet var addFollowerButton: UIButton!
}