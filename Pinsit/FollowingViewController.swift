//
//  FollowingViewController.swift
//  Pinsit
//
//  Created by Walker Christie on 11/5/14.
//  Copyright (c) 2014 Walker Christie. All rights reserved.
//

import UIKit

class FollowingViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var userSearch: UISearchBar!
    @IBOutlet var tableView: UITableView!
    var tableData: [String] = [String]()
    var followingValues: [Bool] = [Bool]()
    var userFollowing: [String] = [String]()
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidLoad()
        AppDelegate.loginCheck(self)
        
        userSearch.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
        self.updateWithUserFollowing()
        let gesture = UITapGestureRecognizer(target: self, action: "tableTapped:")
        self.tableView.addGestureRecognizer(gesture)
    }
    
    ///MARK: TableView Delegates
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier = "FollowersCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(identifier) as! FollowersCell?
        
        if cell == nil {
            cell = FollowersCell(style: .Default, reuseIdentifier: identifier)
        }
        
        cell?.userLabel.text = tableData[indexPath.row]
        cell?.isFollowing = followingValues[indexPath.row]
        cell?.followerButton.tag = indexPath.row
        cell?.followerButton.addTarget(self, action: "cellButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        
        if followingValues[indexPath.row] == true {
            cell?.followerButton.imageView?.image = UIImage(named: "remove")
        } else { cell?.followerButton.imageView?.image = UIImage(named: "add") }
        
        return cell!
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return count(tableData)
    }
    
    ///MARK: SearchBar Delegates
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        sendUpdateRequest(searchBar.text)
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        sendUpdateRequest(searchBar.text)
    }
    
    ///MARK: Private Functions
    ///Updates tableData and userFollowing with the current user's following list
    private func updateWithUserFollowing() {
        let query = PFQuery(className: "Followers")
        query.whereKey("username", equalTo: PFUser.currentUser()!.username!)
        
        query.findObjectsInBackgroundWithBlock { (object, error) -> Void in
            if error == nil && count(object!) > 0 {
                self.userFollowing = object![0]["following"] as! [String]
                self.tableData = object![0]["following"] as! [String]
                self.followingValues = [Bool]()
                
                for user in object![0]["following"] as! [String] {
                    self.followingValues.append(true)
                }
                
                self.tableView.reloadData()
            }
        }
    }
    
    ///Updates tableData with the search query that the user entered
    private func updateWithSearchQuery() {
        let query = PFQuery(className: "Followers")
        query.whereKey("username", containsString: userSearch.text)
        
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            self.tableData = [String]() //Clear old values
            self.followingValues = [Bool]()
            
            if error == nil {
                for obj in objects! { //Loop through each returned object
                    if self.userIsFollowing(obj["username"] as! String) == true {
                        self.followingValues.append(true)
                    } else { self.followingValues.append(false) }
                    
                    self.tableData.append(obj["username"] as! String) //Pull each username
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    ///Checks to see whether the current user is following the passed user, no networking required
    private func userIsFollowing(user: String) -> Bool {
        for following in userFollowing {
            if following == user {
                return true
            }
        }
        
        return false
    }
    
    ///Send an update request.  This is used so that I don't screw up with the logic
    private func sendUpdateRequest(searchText: String) {
        if searchText == "" {
            self.updateWithUserFollowing()
        } else {
            self.updateWithSearchQuery()
        }
    }
    
    ///Removes user from followers list, updates to server
    private func removeFollowing(user: String) {
        var index: Int!
        
        for var i = 0; i < count(userFollowing); i++ {
            if user == userFollowing[i] {
                index = i
                break
            }
        }
        
        userFollowing.removeAtIndex(index)
        
        var query = PFQuery(className: "Followers")
        query.whereKey("username", equalTo: PFUser.currentUser()!.username!)
        
        query.findObjectsInBackgroundWithBlock { (objects: [AnyObject]?, error: NSError?) -> Void in
            let object = objects![0] as! PFObject
            object["following"] = self.userFollowing
            object.saveInBackgroundWithBlock({ (success, error) -> Void in
                self.tableView.reloadData()
            })
        }
    }
    
    ///Adds user to followers list, updates to server
    private func addFollowing(user: String) {
        userFollowing.append(user)
        
        var query = PFQuery(className: "Followers")
        query.whereKey("username", equalTo: PFUser.currentUser()!.username!)
        query.findObjectsInBackgroundWithBlock { (objects: [AnyObject]?, error: NSError?) -> Void in
            if error == nil && count(objects!) > 0 {
                let object = objects![0] as! PFObject
                object["following"] = self.userFollowing
                object.saveInBackgroundWithBlock({ (success, error) -> Void in
                    self.tableView.reloadData()
                })
            } else if error == nil {
                let newFollow = PFObject(className: "Followers")
                newFollow["username"] = PFUser.currentUser()!.username!
                newFollow["following"] = self.userFollowing
                newFollow.saveInBackgroundWithBlock({ (success, error) -> Void in
                    self.tableView.reloadData()
                })
            }
        }
    }
    
    ///MARK: Selector methods
    ///Called when UITableView is tapped
    func tableTapped(gesture: UITapGestureRecognizer) {
        userSearch.resignFirstResponder()
        userSearch.text = ""
        self.updateWithUserFollowing()
    }
    
    ///Called when a specific FollowersCell is tapped
    func cellButtonTapped(sender: UIButton) {
        let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: sender.tag, inSection: 0)) as! FollowersCell
        let following = followingValues[sender.tag]
        cell.followerButton.imageView?.image = following ? UIImage(named: "add") : UIImage(named: "remove")
        
        if following == true {
            let confirmation = UIAlertController(title: "Really?", message: "Are you sure you would like to remove \(cell.userLabel.text!) from your following list?", preferredStyle: .Alert)
            let cancel = UIAlertAction(title: "Nevermind", style: .Cancel, handler: nil)
            let confirm = UIAlertAction(title: "Yes", style: .Default, handler: { (action) -> Void in
                self.followingValues[sender.tag] = false
                self.removeFollowing(cell.userLabel.text!)
            })
            confirmation.addAction(cancel); confirmation.addAction(confirm)
            self.presentViewController(confirmation, animated: true, completion: nil)
        } else {
            followingValues[sender.tag] = true
            self.addFollowing(cell.userLabel.text!)
        }
    }
}