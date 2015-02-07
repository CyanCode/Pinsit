//
//  MapControl.swift
//  Pinsit
//
//  Created by Walker Christie on 10/13/14.
//  Copyright (c) 2014 Walker Christie. All rights reserved.
//

import UIKit
import MapKit

class MapControl {
    var currentMap: MapViewController
    
    init(map: MapViewController) {
        self.currentMap = map
        
        let press = UILongPressGestureRecognizer(target: self, action: "mapLongPress:")
        map.mapView.addGestureRecognizer(press)
    }
    
    func zoomCurrentLocation() {
        
    }
    
    ///Populates map view with default pins
    func startMapPopulation() {
        
    }
    
    ///Pulls pins with specified sort query
    func searchWithSortQuery(query: PFQuery?) {
        dispatch_async(dispatch_get_main_queue()) { //Return to the main queue
            if query != nil {
                query?.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                    //Pins
                })
            }
        }
    }
    
    ///MARK: Gesture Delegate
    func mapLongPress(gesture: UILongPressGestureRecognizer) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            let sheet = UIAlertController(title: "Sorting", message: "Use the power of sorting to find great pins!  Feel free to choose one of the options below.", preferredStyle: .ActionSheet)
            sheet.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
            sheet.addAction(UIAlertAction(title: "Friends", style: .Default, handler: { (action) -> Void in
                self.searchWithSortQuery(self.getFriendQuery())
            }))
            sheet.addAction(UIAlertAction(title: "Trending", style: .Default, handler: { (action) -> Void in
                self.searchWithSortQuery(self.getTrendingPins())
            }))
            sheet.addAction(UIAlertAction(title: "Newest", style: .Default, handler: { (action) -> Void in
                self.searchWithSortQuery(self.getNewestPins())
            }))
            self.currentMap.presentViewController(sheet, animated: true, completion: nil)
        })
    }
    
    ///MARK: Private query methods
    ///Pulls follower's pins from server
    private func getFriendQuery() -> PFQuery? {
        var following = PFQuery(className: "Followers")
        following.whereKey("username", equalTo: PFUser.currentUser())
        let list = following.findObjects()
        
        if countElements(list) <= 0 {
            return nil
        } else {
            let usersArray = list as [AnyObject]
            var userQueries = [PFQuery]()
            
            for obj in list { //Every Object
                for user in obj["following"] as [String] { //Followers INSIDE obj
                    var userQuery = PFQuery(className: "SentData")
                    userQuery.whereKey("username", equalTo: user)
                    userQueries.append(userQuery)
                }
            }
            
            return PFQuery.orQueryWithSubqueries(userQueries) //Master query returned
        }
    }
    
    ///Pulls pins with the highest view count from the server
    private func getTrendingPins() -> PFQuery {
        var query = PFQuery(className: "SentData")
        query.orderByDescending("viewCount")
        
        return query
    }
    
    ///Pulls newest pins from the server using createdAt
    private func getNewestPins() -> PFQuery {
        var query = PFQuery(className: "SentData")
        query.orderByDescending("createdAt")
        
        return query
    }
}

enum SortPins {
    case Random
    case Friends
    case Trending
    case Newest
}

extension NSNumber {
    func randomNumberInRange(min: Int, max: Int) -> Int {
        return min + Int(arc4random_uniform(UInt32(min - max + 1)))
    }
}
