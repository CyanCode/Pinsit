//
//  VideoCache.swift
//  Pinsit
//
//  Created by Walker Christie on 4/5/15.
//  Copyright (c) 2015 Walker Christie. All rights reserved.
//

import Foundation

class VideoCache {
    let className = "PinnedVideos"
    
    func pinExistsInCache(id: String) -> Bool {
        let query = PFQuery(className: className)
        query.whereKey("objectId", equalTo: id)
        query.fromLocalDatastore()
        
        return count(query.findObjects()!) > 0 ? true : false
    }
    
    func getPinWithId(id: String) -> PFObject {
        let query = PFQuery(className: className)
        query.whereKey("objectId", equalTo: id)
        query.fromLocalDatastore()
        
        return (query.findObjects()![0] as! PFObject) as PFObject
    }
    
    func cachePin(pin: PFObject) {
        pin.pin()
    }
    
    ///Downloads the NSData for the provided NSURL then caches the data
    ///
    ///:param: id objectId for the PFObject to be cached
    ///:param: url NSURL of the video to be downloaded
    ///:param: completion() called when data has beend downloaded from the server
    func cacheDataFromServer(id: String, url: NSURL, completion: (data: NSData?) -> Void) {
        var data: NSData?
        
        Async.background {
            let pin = PFObject(className: self.className)
            pin["objectId"] = id
            pin["videoURL"] = url.absoluteString
            
            data = NSData(contentsOfURL: url)
            pin["videoData"] = PFFile(data: data!)
            
            pin.pin()
            }.main {
                completion(data: data)
        }
    }
    
    func objectFromAnnotation(ann: PAnnotation) -> PFObject {
        var object = PFObject(className: className)
        object["title"] = ann.title
        object["location"] = PFGeoPoint(latitude: ann.coord.latitude, longitude: ann.coord.longitude)
        object["downloading"] = NSNumber(bool: ann.allowsDownloading)
        object["thumbnail"] = PFFile(data: UIImagePNGRepresentation(ann.thumbnail))
        object["video"] = ann.videoURL.absoluteString
        object["objectId"] = ann.dataID
        
        return object
    }
}