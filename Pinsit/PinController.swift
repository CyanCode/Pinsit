//
//  PinController.swift
//  Pinsit
//
//  Created by Walker Christie on 2/6/15.
//  Copyright (c) 2015 Walker Christie. All rights reserved.
//

import Foundation
import Parse
import INTULocationManager

class PinController {
    let name = "SentData"
    var query: PFQuery?
    
    init(query: PFQuery) {
        self.query = query
    }
    
    init() { query = nil }
    
    ///Creates PAnnotation array from query variable
    ///
    ///- parameter completion: function called when all annotations have been found
    func annotationsFromQuery(completion: (annotations: [PAnnotation]) -> Void) {
        var annotations = [PAnnotation]()
        
        if query == nil { //Handles default initialization
            INTULocationManager.sharedInstance().requestLocationWithDesiredAccuracy(INTULocationAccuracy.Block, timeout: 5) { (location, accuracy, status) -> Void in
                if status == .Success || status == .TimedOut {
                    self.defaultQueryAnnotations(PFGeoPoint(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude), done: { (annotations) -> Void in
                        completion(annotations: annotations)
                    })
                } else {
                    ErrorReport().presentWithType(.Network)
                }
            }
        } else {
            query!.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                if error != nil {
                    ErrorReport().presentWithType(.Network)
                    completion(annotations: [PAnnotation]())
                    return
                }
                
                for obj in objects as! [PFSentData] {
                    let ann = PAnnotation()
                    ann.object = obj
                    
                    annotations.append(ann)
                }
                
                completion(annotations: annotations)
            })
        }
    }
    
    ///Caches the passed annotation using Parse LocalDatastore
    ///Annotation is cached by its dataId (id)
    ///
    ///- parameter ann: PAnnotation to cache
    func cacheAnnotation(ann: PAnnotation) {
        do {
        try ann.object.pin()
        } catch let error {
            print("Unable to cache annotation: \(error)")
        }
    }
    
    ///Creates an annotation that has been cached in Parse LocalDatastore
    ///
    ///- parameter id: cached PAnnotation's dataId
    ///- returns: Cached PAnnotation, object is nil if it does not exist
    func annotationFromCache(id: String) -> PAnnotation? {
        let query = PFQuery(className: name)
        query.fromLocalDatastore()
        query.whereKey("id", equalTo: id)
        
        do {
            let objects = try query.findObjects()
            if objects.count < 1 {
                return nil
            }
            
            let obj = objects[0] as! PFSentData
            let annotation = PAnnotation()
            
            annotation.object = obj
            return annotation
        } catch {
            return nil
        }
    }
    
    ///Get the default annotations from the map refresh, removing private objects
    ///
    ///- parameter location: the PFGeoPoint to query from
    ///- parameter done: called when annotations have been found, returns array of PAnnotations
    func defaultQueryAnnotations(location: PFGeoPoint, done: (annotations: [PAnnotation]) -> Void) {
        let manager = MapControl()
        let followerManager = FollowerCache()
        var annotations = [PAnnotation]()
        
        let query = manager.getDefaultQuery(location)
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error != nil {
                ErrorReport().presentWithType(.Network)
                done(annotations: [PAnnotation]()); return
            }
            
            for obj in objects as! [PFSentData] { //Only add if video isn't private OR we are following them
                if obj.`private` == false || followerManager.isFollowing(obj.username) {
                    let ann = PAnnotation()
                    ann.object = obj
                    
                    annotations.append(ann)
               }
            }
            
            done(annotations: annotations)
        }
    }
}