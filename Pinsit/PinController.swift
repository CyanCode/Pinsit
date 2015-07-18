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
                
                for obj in objects as! [PFObject] {
                    annotations.append(self.objectToAnnotation(obj))
                }
                
                completion(annotations: annotations)
            })
        }
    }
    
    ///Creates a PAnnotation object from passed PFObject
    ///
    ///- parameter obj: PFObject to convert to PAnnotation
    ///- returns: Converted PAnnotation
    func objectToAnnotation(obj: PFObject) -> PAnnotation {
        let annotation = PAnnotation()
        let point = obj["location"] as! PFGeoPoint
        let downloading = obj["downloading"] as! NSNumber
        let thumbnail = obj["thumbnail"] as! PFFile
        
        annotation.title = (obj["username"] as! String)
        annotation.subtitle = (obj["description"] as! String)
        annotation.coordinate = CLLocationCoordinate2DMake(point.latitude, point.longitude)
        annotation.coord = Coordinate(lat: point.latitude, lon: point.longitude)
        annotation.allowsDownloading = downloading.boolValue
        annotation.thumbnail = UIImage(data: NSData(contentsOfURL: NSURL(string: thumbnail.url!)!)!)
        annotation.videoURL = NSURL(string: thumbnail.url!)
        annotation.dataID = obj.objectId
        annotation.object = obj
        
        return annotation
    }
    
    ///Caches the passed annotation using Parse LocalDatastore
    ///Annotation is cached by its dataId (id)
    ///
    ///- parameter ann: PAnnotation to cache
    func cacheAnnotation(ann: PAnnotation) {
        let object = PFObject(className: "CachedPins")
        object["title"] = ann.title
        object["location"] = PFGeoPoint(latitude: ann.coord.latitude, longitude: ann.coord.longitude)
        object["downloading"] = NSNumber(bool: ann.allowsDownloading)
        object["thumbnail"] = PFFile(data: UIImagePNGRepresentation(ann.thumbnail)!)
        object["videoData"] = PFFile(data: ann.videoData)
        object["id"] = ann.dataID
        
        object.pin()
    }
    
    ///Creates an annotation that has been cached in Parse LocalDatastore
    ///
    ///- parameter id: cached PAnnotation's dataId
    ///- returns: Cached PAnnotation, object is nil if it does not exist
    func annotationFromCache(id: String) -> PAnnotation? {
        let query = PFQuery(className: "CachedPins")
        query.fromLocalDatastore()
        query.whereKey("id", equalTo: id)
        
        let objects = query.findObjects()
        if (objects!).count > 0 {
            let obj = objects![0] as! PFObject
            return self.objectToAnnotation(obj)
        } else { return nil }
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
            
            for obj in objects as! [PFObject] { //Only add if video isn't private OR we are following them
                if obj["private"] as! NSNumber == false || followerManager.isFollowing(obj["username"] as! String) {
                    annotations.append(self.objectToAnnotation(obj))
               }
            }
            
            done(annotations: annotations)
        }
    }
}