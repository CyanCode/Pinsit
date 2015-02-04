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
    var tableData: [String]!
    var followingValues: [Bool]!
    var userFollowing: [String]!
    
    override func viewDidAppear(animated: Bool) {
        tableData = [String]() //Default value
        userFollowing = [String]() //Default value
        followingValues = [Bool]()

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
        var cell = tableView.dequeueReusableCellWithIdentifier(identifier) as FollowersCell?
        
        if cell == nil {
            cell = FollowersCell(style: .Default, reuseIdentifier: identifier)
        }
        
        cell?.userLabel.text = tableData[indexPath.row]
        cell?.isFollowing = followingValues[indexPath.row]
        
        if followingValues[indexPath.row] == true {
            cell?.followerButton.imageView?.image = UIImage(named: "remove")
        } else { cell?.followerButton.imageView?.image = UIImage(named: "add") }
        
        return cell!
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countElements(tableData)
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
        query.whereKey("username", equalTo: PFUser.currentUser().username)
        
        query.findObjectsInBackgroundWithBlock { (object, error) -> Void in
            if countElements(object) > 0 {
                self.userFollowing = object[0]["following"] as [String]
                self.tableData = object[0]["following"] as [String]
                self.followingValues = [Bool]()
                
                for user in object[0]["following"] as [String] {
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
            
            for obj in objects { //Loop through each returned object
                if self.userIsFollowing(obj["username"] as String) == true {
                    self.followingValues.append(true)
                } else { self.followingValues.append(false) }
                
                self.tableData.append(obj["username"] as String) //Pull each username
                self.tableView.reloadData()
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
    
    
    func tableTapped(gesture: UITapGestureRecognizer) {
        userSearch.resignFirstResponder()
        userSearch.text = ""
        self.updateWithUserFollowing()
    }
}