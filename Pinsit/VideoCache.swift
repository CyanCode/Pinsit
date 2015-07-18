//
//  VideoCache.swift
//  Pinsit
//
//  Created by Walker Christie on 4/5/15.
//  Copyright (c) 2015 Walker Christie. All rights reserved.
//

import Foundation
import Parse

class VideoCache {
    let className = "PinnedVideos"
    
    func pinExistsInCache(id: String) -> Bool {
        let query = PFQuery(className: className)
        query.whereKey("objectId", equalTo: id)
        query.fromLocalDatastore()
        
        return (query.findObjects()!).count > 0 ? true : false
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
    ///- parameter id: objectId for the PFObject to be cached
    ///- parameter url: NSURL of the video to be downloaded
    ///- parameter completion(): called when data has beend downloaded from the server
    func cacheDataFromServer(id: String, file: PFFile, completion: (data: NSData?) -> Void) {
        var data: NSData?
        
        Async.background {
            let pin = PFObject(className: self.className)
            pin["objectId"] = id
            pin["videoURL"] = file.url!
            
            do {
                data = try file.getDataWithError()
                pin["videoData"] = PFFile(data: data!)
                pin.pin()
            } catch let error as NSError {
                print("data error: \(error.localizedDescription)")
            } catch {
                fatalError()
            }
        }.main {
            completion(data: data)
        }
    }
}