//
//  MapControl.swift
//  Pinsit
//
//  Created by Walker Christie on 10/13/14.
//  Copyright (c) 2014 Walker Christie. All rights reserved.
//

import UIKit
import MapKit

class MapControl: NSObject {
    var currentMap: MapViewController!
    var followerTracker: Followers!
    
    init(map: MapViewController) {
        super.init()
        self.currentMap = map
        
        let press = UILongPressGestureRecognizer(target: self, action: "mapLongPress:")
        map.mapView.addGestureRecognizer(press)
    }
    
    ///Starts populating mapView with default pins
    func startMapPopulation() {
        self.searchWithSortQuery(nil) //Pass nil to search with default query
    }
    
    ///Pulls pins with specified sort query
    ///
    ///* If query is nil default pins are pulled
    ///* Else queried pins are pulled
    ///
    ///:param: query PFQuery that is to be searched for and added
    func searchWithSortQuery(query: PFQuery?) {
        var control: PinController?
        
        Async.background {
            if query == nil {
                control = PinController()
            } else {
                control = PinController(query: query!)
            }
        }.main { //Return to the main thread
            control!.annotationsFromQuery({ (annotations) -> Void in
                self.currentMap.mapView.removeAnnotations(self.currentMap.mapView.annotations)
                self.currentMap.mapView.addAnnotations(annotations)
            })
        }
    }
    
    ///MARK: Gesture Delegate
    func mapLongPress(gesture: UILongPressGestureRecognizer) {
        let sheet = UIAlertController(title: "Sorting", message: "Use the power of sorting to find great pins!  Feel free to choose one of the options below.", preferredStyle: .ActionSheet)
        
        sheet.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        sheet.addAction(UIAlertAction(title: "Following", style: .Default, handler: { (action) -> Void in
            self.getFriendQuery({ (query) -> Void in self.searchWithSortQuery(query) })
        }))
        sheet.addAction(UIAlertAction(title: "Trending", style: .Default, handler: { (action) -> Void in
            self.searchWithSortQuery(self.getTrendingPins())
        }))
        sheet.addAction(UIAlertAction(title: "Newest", style: .Default, handler: { (action) -> Void in
            self.searchWithSortQuery(self.getNewestPins())
        }))
        
        self.currentMap.presentViewController(sheet, animated: true, completion: nil)
    }
    
    ///MARK: Private query methods
    ///Pulls follower's pins from server
    private func getFriendQuery(completion: (query: PFQuery?) -> Void) {
        var chosenQuery: PFQuery?
        
        Async.background {
            var following = PFQuery(className: "Followers")
            following.whereKey("username", equalTo: PFUser.currentUser().username)
            let user = following.findObjects()
            
            if countElements(user) <= 0 {
                chosenQuery = nil
            } else {
                var userQueries = [PFQuery]()
                
                for follower in user[0]["following"] as [String] {
                    var userQuery = PFQuery(className: "SentData")
                    userQuery.whereKey("username", equalTo: follower)
                    userQueries.append(userQuery)
                }
                
                chosenQuery = PFQuery.orQueryWithSubqueries(userQueries)
            }
        }.main {
                completion(query: chosenQuery) //Master query returned
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
