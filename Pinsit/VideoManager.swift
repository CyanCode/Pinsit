//
//  VideoManager.swift
//  Pinsit
//
//  Created by Walker Christie on 4/12/15.
//  Copyright (c) 2015 Walker Christie. All rights reserved.
//

import Foundation

class VideoManager {
    var object: PFObject!
    
    init(object: PFObject) {
        self.object = object
    }
    
    ///Attempts to pull NSData from server video
    ///
    ///completion(NSData?) called when NSData has been collected
    func pullVideoData(completion: (NSData?) -> Void) {
        if existsInCache() == true {
            completion(getCachedData()); return
        }
        
        let file = object["video"] as! PFFile
        file.getDataInBackgroundWithBlock { (data, error) -> Void in
            if error != nil {
                println("Error: \(error!.localizedDescription)")
            }
            
            completion(data)
        }
    }
    
    ///Checks if object is cached
    ///
    ///:returns: true if found, otherwise false
    func existsInCache() -> Bool {
        let query = PFQuery(className: "SentData")
        query.whereKey("objectId", equalTo: object.objectId!)
        query.fromLocalDatastore()
        
        let objects = query.findObjects()
        
        return objects != nil && count(objects!) > 0 ? true : false
    }
    
    ///Pull video data from cache, assumes data actually exists
    ///
    ///:returns: video NSData
    func getCachedData() -> NSData? {
        let query = PFQuery(className: "SentData")
        query.whereKey("objectId", equalTo: object["objectId"] as! String)
        query.fromLocalDatastore()
        
        let file = query.findObjects()![0]["video"] as! PFFile
        return file.getData()
    }
    
    ///Writes passed NSData to initialized PFObject
    ///
    ///:param: data NSData to be written
    func cacheData(data: NSData) {
        object["video"] = PFFile(data: data)
        object.pin()
    }
}