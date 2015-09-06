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
        
        followerController.searchQuery = false
        followerController.loadObjects()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        followerController.query = PFQuery(className: "Followers")
        followerController.query?.whereKey("username", containsString: searchBar.text)
        followerController.searchQuery = true
        followerController.awaitingReload = false
        followerController.loadObjects()
        
        searchBar.resignFirstResponder()
    }
}

class FollowingQueryTableViewController: QueryTableViewController, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {
    let identifier = "FollowingTableViewCell"
    var followerCache = FollowerCache()
    var query: PFQuery?
    var searchQuery: Bool = false
    var awaitingReload: Bool = false
    var tappedUser = ""
    
    //MARK: Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        followerCache.updateCache()
        loadObjects()
        
        tableView.tableFooterView = UIView(frame: CGRectZero)
        tableView.emptyDataSetDelegate = self
        tableView.emptyDataSetSource = self
    }
    
    override func objectsDidFailToLoad(error: NSError?) {
        tableView.reloadEmptyDataSet()
    }
    
    override func objectsDidLoadSuccessfully() {
        tableView.reloadEmptyDataSet()
    }
    
    override func queryForTableView() -> PFQuery {
        if !searchQuery {
            super.loadFromArrayColumn = "following"
            
            query = PFQuery(className: "Followers")
            query?.whereKey("username", equalTo: PFUser.currentUser()!.username!)
        } else {
            super.loadFromArrayColumn = nil
        }
        
        return query!
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
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, content: AnyObject) -> UITableViewCell {
        let username = content as! String
        var cell = tableView.dequeueReusableCellWithIdentifier(identifier) as! FollowingTableViewCell
        
        cell.usernameLabel.text = username
        cell.profileImage.username = username
        cell.addFollowerButton.hidden = FollowerCache().isFollowing(username)
        
        self.finishPreparingCell(&cell)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(identifier) as! FollowingTableViewCell
        let followerObject = object as! PFFollowers
        
        cell.usernameLabel.text = followerObject.username
        cell.profileImage.username = followerObject.username
        cell.addFollowerButton.hidden = followerCache.isFollowing(followerObject.username)
        
        FollowerCache() //Refresh cache
        self.finishPreparingCell(&cell)
        
        return cell
    }
    
    private func finishPreparingCell(inout cell: FollowingTableViewCell) {
        //Add gesture recognizers
        if cell.gestureRecognizers == nil || cell.gestureRecognizers!.count == 0 {
            let press = UITapGestureRecognizer(target: self, action: "cellPressed:")
            let longPress = UILongPressGestureRecognizer(target: self, action: "cellLongPress:")
            
            cell.addGestureRecognizer(longPress)
            cell.addGestureRecognizer(press)
        }
        
        cell.profileImage.image = UIImage(named: "profile")
        cell.profileImage.loadUserImage()
        cell.separatorInset = UIEdgeInsetsZero
    }
    
    //MARK: ViewController override
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "account" {
            (segue.destinationViewController as! AccountViewController).user = tappedUser
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    //MARK: Empty dataset
    
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        var text: NSMutableAttributedString!
        
        if searchQuery {
            text = NSMutableAttributedString(string: "Your search didn't return any users.", attributes: [NSFontAttributeName : UIFont(name: "Helvetica", size: 15)!])
        } else {
            text = NSMutableAttributedString(string: "You aren't following any users!", attributes: [NSFontAttributeName : UIFont(name: "Helvetica", size: 15)!])
        }
        
        text.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor(), range: NSMakeRange(0, count(text.string)))
        
        return text
    }
    
    func emptyDataSetShouldAllowScroll(scrollView: UIScrollView!) -> Bool {
        return true
    }
    
    //MARK: Cell gestures
    
    func cellPressed(gesture: UIGestureRecognizer) {
        self.tappedUser = (gesture.view as! FollowingTableViewCell).usernameLabel.text!
        self.performSegueWithIdentifier("account", sender: self)
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
    
    //MARK: Buttons
    
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