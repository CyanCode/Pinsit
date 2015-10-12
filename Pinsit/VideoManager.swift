//
//  VideoManager.swift
//  Pinsit
//
//  Created by Walker Christie on 4/12/15.
//  Copyright (c) 2015 Walker Christie. All rights reserved.
//

import Foundation
import Parse

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
                print("Error: \(error!.localizedDescription)")
            }
            
            completion(data)
        }
    }
    
    ///Checks if object is cached
    ///
    ///- returns: true if found, otherwise false
    func existsInCache() -> Bool {
        let query = PFQuery(className: "SentData")
        query.whereKey("objectId", equalTo: object.objectId!)
        query.fromLocalDatastore()
        
        do {
            let objects = try query.findObjects()
            return objects.count > 0
        } catch {
            return false
        }
    }
    
    ///Pull video data from cache, assumes data actually exists
    ///
    ///- returns: video NSData
    func getCachedData() -> NSData? {
        let query = PFQuery(className: "SentData")
        query.whereKey("objectId", equalTo: object["objectId"] as! String)
        query.fromLocalDatastore()
        
        do {
            let file = try query.findObjects()[0]["video"] as! PFFile
            return try file.getData()
        } catch {
            return nil
        }
    }
    
    ///Writes passed NSData to initialized PFObject
    ///
    ///- parameter data: NSData to be written
    func cacheData(data: NSData) {
        do {
            object["video"] = PFFile(data: data)
            try object.pin()
        } catch let error{
            print("Failed to pin NSData: \(error)")
        }
    }
}