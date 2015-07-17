//
//  FollowingViewController.swift
//  Pinsit
//
//  Created by Walker Christie on 11/5/14.
//  Copyright (c) 2014 Walker Christie. All rights reserved.
//

import UIKit

class FollowingViewController: UIViewController, UISearchBarDelegate {
    @IBOutlet var userSearch: UISearchBar!
    @IBOutlet var segmentControl: UISegmentedControl!
    var tableData: [String] = [String]()
    var followingValues: [Bool] = [Bool]()
    var userFollowing: [String] = [String]()
    var followerController: FollowerTableViewController {
        get {
            return self.childViewControllers[0] as! FollowerTableViewController
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidLoad()
        AppDelegate.loginCheck(self)
        
        userSearch.delegate = self
        segmentControl.layer.cornerRadius = 4.0
        segmentControl.clipsToBounds = true
        userSearch.backgroundImage = UIImage()
        
        followerController.type = .Following
        followerController.updateTableWithType()
        let gesture = UITapGestureRecognizer(target: self, action: "tableTapped:")
        followerController.tableView.addGestureRecognizer(gesture)
    }
    
    ///MARK: SearchBar Delegates
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        followerController.type = .Search
        followerController.search = searchBar.text!
        followerController.updateTableWithType()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        followerController.type = .Search
        followerController.search = searchBar.text!
        followerController.updateTableWithType()
    }
    
    ///MARK: SegmentedController action
    @IBAction func segmentController(sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 { //Following
            followerController.type = .Following
        } else { //Followers
            followerController.type = .Followers
        }
        
        followerController.updateTableWithType()
    }
    
    ///Called when UITableView is tapped
    func tableTapped(gesture: UITapGestureRecognizer) {
        userSearch.resignFirstResponder()
        userSearch.text = ""
        
        followerController.type = .Following
        followerController.updateTableWithType()
    }
}