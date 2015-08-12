//
//  FollowerTableViewController.swift
//  Pinsit
//
//  Created by Walker Christie on 7/8/15.
//  Copyright © 2015 Walker Christie. All rights reserved.
//

import UIKit
import Parse
import DZNEmptyDataSet

class FollowerTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITableViewDragLoadDelegate {
    @IBOutlet var tableView: UITableView!
    let identifier = "FollowersCell"
    var type: FollowerType = .Following
    var search: String = ""
    var names = [String]()
    var cellTags = [FollowersCell() : ""]
    var followerCache = FollowerCache()
    var followerNet: FollowerManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView(frame: CGRectZero)
        
        followerCache.updateCache()
        followerNet = FollowerManager(user: PFUser.currentUser()!.username!, responder: self)
        
        let gesture = UILongPressGestureRecognizer(target: self, action: "cellLongPress:")
        self.tableView.addGestureRecognizer(gesture)
    }
    
    // MARK: - Table view data source
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return names.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier) as! FollowersCell
        
        print("row: \(indexPath.row)")
        cell.userLabel.text = names[indexPath.row]
        
        if type == .Followers || type == .Search {
            if followerCache.followersExist() {
                let isFollowing = followerCache.isFollowing(names[indexPath.row])
                cell.followerButton.imageView?.image = UIImage(named: "add")
                cell.followerButton.hidden = isFollowing
                cell.followerButton.enabled = !isFollowing
            }
        } else {
            cell.followerButton.hidden = true
            cell.followerButton.enabled = false
        }
        
        if cell.gestureRecognizers == nil {
            let gesture = UILongPressGestureRecognizer(target: self, action: "cellLongPress:")
            cell.addGestureRecognizer(gesture)
        }
        
        return cell
    }
    
    func dragTableDidTriggerRefresh(tableView: UITableView!) {
        updateTableWithType()
    }
    
    @IBAction func cellButtonPressed(sender: UIButton) {
        let indexPath = tableView.indexPathForRowAtPoint(sender.center)
        let cell = tableView.cellForRowAtIndexPath(indexPath!) as! FollowersCell
        cell.followerButton.hidden = true
        
        followerNet.addFollower(cell.userLabel.text!)
    }
    
    func updateTableWithType() {
        let populate = PopulateFollower(tableView: self.tableView)
        
        switch type {
        case .Following:
            populate.getFollowingResults({ (values) -> Void in
                if values.count > 0 {
                    self.names = values
                    self.tableView.reloadData()
                }
            })
        case .Followers:
            populate.getFollowersResults({ (values) -> Void in
                if values.count > 0 {
                    self.names = values
                    self.tableView.reloadData()
                }
            })
        case .Search:
            populate.getSearchResult(search, done: { (results) -> Void in
                if results.count > 0 {
                    self.names = results
                    self.tableView.reloadData()
                }
            })
        }
    }
    
    func cellLongPress(gesture: UILongPressGestureRecognizer) {
        let cell = gesture.view as! FollowersCell
        
        if type == .Following && gesture.state == .Began {
            let confirmation = UIAlertController(title: "Really?", message: "Are you sure you would like to remove \(cell.userLabel.text!) from your following list?", preferredStyle: .Alert)
            confirmation.addAction(UIAlertAction(title: "Nevermind", style: .Cancel, handler: nil))
            confirmation.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { (action) -> Void in
                self.followerNet.removeFollower(cell.userLabel.text!)
            }))
            
            self.presentViewController(confirmation, animated: true, completion: nil)
        }
    }
}

enum FollowerType {
    case Search
    case Followers
    case Following
}