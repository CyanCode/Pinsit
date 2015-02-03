//
//  FollowingViewController.swift
//  Pinsit
//
//  Created by Walker Christie on 11/5/14.
//  Copyright (c) 2014 Walker Christie. All rights reserved.
//

import UIKit

class FollowingTableViewController: PFQueryTableViewController, UISearchBarDelegate {
    @IBOutlet var userSearch: UISearchBar!
    var searchCurrentUser: Bool!
    var userFollowing: [String]!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        userSearch.delegate = self
        
        self.parseClassName = "Followers"
        self.pullToRefreshEnabled = true
        self.paginationEnabled = true
        self.objectsPerPage = 25
        e
        //Default variables
        searchCurrentUser = true
        userFollowing = [""]
        
        updateUserFollowing()
    }
    
    override func queryForTable() -> PFQuery! {
        var query = PFQuery(className: self.parseClassName)
        
        if self.objects.count == 0 {
            query.cachePolicy = kPFCachePolicyCacheElseNetwork
        }
        
        if searchCurrentUser == true {
            query.whereKey("username", equalTo: PFUser.currentUser().username)
        } else {
            query.whereKey("username", containsString: userSearch.text)
        }
        
        return query
    }
    
    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!, object: PFObject!) -> PFTableViewCell! {
        let identifier = "FollowersCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(identifier) as FollowersCell?
        
        if cell == nil {
            cell = FollowersCell(style: .Default, reuseIdentifier: identifier)
        }
        
        if userSearch.text == "" { searchCurrentUser = true }
        
        if searchCurrentUser == false {
            //If we are searching for people TO follow
            let userIsFollowing = userFollowing(object["username"] as String)
            cell?.followerButton.imageView?.image = userIsFollowing ? UIImage(named: "remove") : UIImage(named: "add")
            cell?.followerButton.tag = indexPath.row
            cell?.followerButton.addTarget(self, action: "followUserPressed:", forControlEvents: UIControlEvents.TouchUpInside)
            cell?.isFollowing = userIsFollowing ? true : false
            cell?.userLabel.text = object["username"] as? String
        } else if countElements(userFollowing) != 0 {
            //If we are searching for those we already follow
            tableView.dataSource = object["followers"] as NSArray
        }
        
        return cell
    }
    
    func followUserPressed(sender: AnyObject) {
        let row = sender.tag
        let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: row, inSection: 0)) as FollowersCell
        var userObject = PFObject()
        
        if cell.isFollowing == true {
            //Unfollow User
            cell.followerButton.imageView?.image = UIImage(named: "add")
            cell.isFollowing = false
            
            userObject["following"] = self.removeFollower(cell.userLabel.text!)
        } else {
            //Follow User
            cell.followerButton.imageView?.image = UIImage(named: "remove")
            cell.isFollowing = true
            
            userObject["following"] = self.addFollower(cell.userLabel.text!)
        }
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        if searchBar.text == "" {
            searchCurrentUser = true
        } else {
            searchCurrentUser = false
        }
        
        self.loadObjects()
    }
    
    ///Requests an update of the followed users from the server
    private func updateUserFollowing() {
        var query = PFQuery(className: "Following")
        query.whereKey("username", equalTo: PFUser.currentUser().username)
        
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if countElements(objects) != 0 {
                self.userFollowing = objects[0]["following"] as [String]
            }
        }
    }
    
    ///Checks whether the current user is following specified user
    private func userFollowing(followingUser: String) -> Bool {
        for user in userFollowing {
            if user == followingUser {
                return true
            }
        }
        
        return false
    }
    
    ///Removes specified follower from userFollowing array, returns userFollowing
    private func removeFollower(user: String) -> [String] {
        var rmIndex: Int!
        
        for var i = 0; i < countElements(userFollowing); i++ {
            if userFollowing[i] == user {
                rmIndex = i
            }
        }
        
        userFollowing.removeAtIndex(rmIndex)
        return userFollowing
    }
    
    ///Adds specified follower to userFollowing array, returns userFollowing
    private func addFollower(user: String) -> [String] {
        userFollowing.append(user)
        return userFollowing
    }
}














