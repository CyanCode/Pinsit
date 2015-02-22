//
//  PinController.swift
//  Pinsit
//
//  Created by Walker Christie on 2/6/15.
//  Copyright (c) 2015 Walker Christie. All rights reserved.
//

import Foundation

class PinController {
    var query: PFQuery?
    
    init(query: PFQuery) {
        self.query = query
    }
    
    init() { query = nil }
    
    ///Creates PAnnotation array from query variable
    ///
    ///:returns: Array of PAnnotations pulled from query
    func annotationsFromQuery(completion: (annotations: [PAnnotation]) -> Void) {
        var annotations = [PAnnotation]()
        
        if query == nil { //Handles default initialization
            INTULocationManager.sharedInstance().requestLocationWithDesiredAccuracy(INTULocationAccuracy.House, timeout: 5) { (location, accuracy, status) -> Void in
                if status == .Success {
                    self.query = PFQuery(className: "SentData")
                    self.query!.whereKey("location", nearGeoPoint: PFGeoPoint(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude))
                    self.query!.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                        for obj in objects as [PFObject] {
                            annotations.append(self.objectToAnnotation(obj))
                        }
                        
                        completion(annotations: annotations)
                    })
                }
            }
        } else {
            query!.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                for obj in objects as [PFObject] {
                    annotations.append(self.objectToAnnotation(obj))
                }
                
                completion(annotations: annotations)
            })
        }
    }
    
    ///Creates a PAnnotation object from passed PFObject
    ///
    ///:param: obj PFObject to convert to PAnnotation
    ///:returns: Converted PAnnotation
    func objectToAnnotation(obj: PFObject) -> PAnnotation {
        var annotation = PAnnotation()
        let point = obj["location"] as PFGeoPoint
        let downloading = obj["downloading"] as NSNumber
        let thumbnail = obj["thumbnail"] as PFFile
        annotation.subtitle = obj["description"] as String
        annotation.coord = Coordinate(lat: point.latitude, lon: point.longitude)
        annotation.allowsDownloading = downloading.boolValue
        annotation.thumbnail = UIImage(data: NSData(contentsOfURL: NSURL(string: thumbnail.url)!)!)
        annotation.videoURL = NSURL(string: thumbnail.url)
        annotation.dataID = obj.objectId
        
        return annotation
    }
    
    ///Caches the passed annotation using Parse LocalDatastore
    ///Annotation is cached by its dataId (id)
    ///
    ///:param: ann PAnnotation to cache
    func cacheAnnotation(ann: PAnnotation) {
        var object = PFObject(className: "CachedPins")
        object["location"] = PFGeoPoint(latitude: ann.coord.latitude, longitude: ann.coord.longitude)
        object["downloading"] = NSNumber(bool: ann.allowsDownloading)
        object["thumbnail"] = PFFile(data: UIImagePNGRepresentation(ann.thumbnail))
        object["videoData"] = PFFile(data: ann.videoData)
        object["id"] = ann.dataID
        
        object.pin()
    }
    
    ///Creates an annotation that has been cached in Parse LocalDatastore
    ///
    ///:param: id cached PAnnotation's dataId
    ///:returns: Cached PAnnotation, object is nil if it does not exist
    func annotationFromCache(id: String) -> PAnnotation? {
        var query = PFQuery(className: "CachedPins")
        query.fromLocalDatastore()
        query.whereKey("id", equalTo: id)
        
        let objects = query.findObjects()
        if countElements(objects) > 0 {
            let obj = objects[0] as PFObject
            return self.objectToAnnotation(obj)
        } else { return nil }
    }
}