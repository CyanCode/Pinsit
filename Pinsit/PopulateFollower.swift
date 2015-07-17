//
//  PopulateFollower.swift
//  Pinsit
//
//  Created by Walker Christie on 7/8/15.
//  Copyright © 2015 Walker Christie. All rights reserved.
//

import Foundation

class PopulateFollower {
    var tableView: UITableView!
    var limit: Int = 25
    var offset: Int = 0
    
    init(tableView: UITableView) {
        self.tableView = tableView
    }
    
    func getFollowingResults(done: (values: [String]) -> Void) {
        let query = PFQuery(className: "Followers")
        query.whereKey("username", equalTo: PFUser.currentUser()!.username!)
        query.limit = limit
        query.skip = offset
        
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error != nil {
                self.reportPossibleError(error!)
                done(values: [String]())
            } else {
                done(values: objects![0]["following"] as! [String])
            }
        }
    }
    
    func getFollowersResults(done: (values: [String]) -> Void) {
        let query = PFQuery(className: "Followers")
        query.whereKey("following", equalTo: PFUser.currentUser()!.username!)
        query.limit = limit
        query.skip = offset
        
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error != nil {
                self.reportPossibleError(error!)
                done(values: [String]())
            } else {
                var users = [String]()
                
                for obj in objects! as! [PFObject] {
                    users.append(obj["username"] as! String)
                }
                
                done(values: users)
            }
        }
    }
    
    func getSearchResult(username: String, done: (results: [String]) -> Void) {
        let query = PFUser.query()
        query?.whereKey("username", containsString: username)
        query?.limit = limit
        query?.skip = offset
        
        query!.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
            if error != nil {
                self.reportPossibleError(error!)
                done(results: [String]())
            } else {
                var usernames = [String]()
                
                for user in objects! as! [PFUser] {
                    usernames.append(user.username!)
                }
                
                done(results: usernames)
            }
        })
    }
    
    private func reportPossibleError(error: NSError) {
        if error.code == PFErrorCode.ErrorConnectionFailed.rawValue {
            ErrorReport().presentWithType(.Network)
        }
    }
}