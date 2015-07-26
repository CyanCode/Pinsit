//
//  MapControl.swift
//  Pinsit
//
//  Created by Walker Christie on 10/13/14.
//  Copyright (c) 2014 Walker Christie. All rights reserved.
//

import UIKit
import MapKit
import Parse

class MapControl: NSObject {
    var currentMap: MapViewController!
    
    init(map: MapViewController) {
        super.init()
        self.currentMap = map
        
        let press = UILongPressGestureRecognizer(target: self, action: "mapLongPress:")
        map.mapView.addGestureRecognizer(press)
    }
    
    override init() { }
    
    ///Starts populating mapView with default pins
    func startMapPopulation() {
        self.searchWithSortQuery(nil) //Pass nil to search with default query
    }
    
    ///Pulls pins with specified sort query
    ///
    ///* If query is nil default pins are pulled
    ///* Else queried pins are pulled
    ///
    ///- parameter query: PFQuery that is to be searched for and added
    func searchWithSortQuery(query: PFQuery?) {
        var control: PinController?
        
        Async.background {
            control = query == nil ? PinController() : PinController(query: query!)
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
    
    ///Get individual friend queries
    private func getFriendQueries(completion: (queries: [PFQuery]?) -> Void) {
        var allQueries: [PFQuery]?
        
        Async.background {
            let following = PFQuery(className: "Followers")
            following.whereKey("username", equalTo: PFUser.currentUser()!.username!)
            let user = following.findObjects()
            
            if user == nil || (user!).count <= 0 {
                allQueries = nil
            } else {
                var userQueries = [PFQuery]()
                let followers = (user![0] as! PFFollowers).getFollowing()
                
                for follower in followers {
                    let userQuery = PFQuery(className: "SentData")
                    userQuery.whereKey("username", equalTo: follower)
                    userQueries.append(userQuery)
                }
                
                allQueries = userQueries
            }
            }.main {
                completion(queries: allQueries)
        }
    }
    
    ///Gets the default query from the server, does not remove private pins
    func getDefaultQuery(location: PFGeoPoint) -> PFQuery {
        let query = PFQuery(className: "SentData")
        query.whereKey("location", nearGeoPoint: location)
        
        return query
    }
    
    ///MARK: Private query methods
    ///Pulls follower's pins from server
    private func getFriendQuery(completion: (query: PFQuery?) -> Void) {
        self.getFriendQueries { (queries) -> Void in
            if queries == nil {
                completion(query: nil)
            } else {
                completion(query: PFQuery.orQueryWithSubqueries(queries!))
            }
        }
    }
    
    ///Pulls pins with the highest view count from the server
    private func getTrendingPins() -> PFQuery {
        let query = PFQuery(className: "SentData")
        query.orderByDescending("viewCount")
        
        return query
    }
    
    ///Pulls newest pins from the server using createdAt
    private func getNewestPins() -> PFQuery {
        let query = PFQuery(className: "SentData")
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
