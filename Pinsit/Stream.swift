//
//  Stream.swift
//  Pinsit
//
//  Created by Walker Christie on 9/22/14.
//  Copyright (c) 2014 Walker Christie. All rights reserved.
//

import Foundation

class Stream {
    var videoPlaying: Bool!
    var vidURL: NSURL!
    var annotation: PAnnotation!
    
    init(vid: NSURL) {
        self.vidURL = vid
    }
    
    init(ann: PAnnotation) {
        self.annotation = ann
    }
    
    func writeVideo() {
        let vidPath = File.getVideoPathURL().path!
        let fManager = NSFileManager.defaultManager()
        
        if (fManager.fileExistsAtPath(vidPath as String)) {
            var error: NSError?
            do {
                try fManager.removeItemAtPath(vidPath as String)
            } catch let error1 as NSError {
                error = error1
            }
            
            if error != nil {
                print("Error removing video file \(error!.localizedDescription)", terminator: "")
            }
        }
        
        let vidData = NSData(contentsOfFile: vidPath as String)
        vidData?.writeToFile(vidPath as String, atomically: true)
    }
    
    func writeVideoFromCache() {
        let vidPath = File.getVideoPathURL().path!
        let fManager = NSFileManager.defaultManager()
        
        if (fManager.fileExistsAtPath(vidPath as String)) {
            do {
                try fManager.removeItemAtPath(vidPath as String)
            } catch let error {
                print("Could not remove file at path '\(vidPath) error: \(error)")
            }
        }
        
        do {
            try annotation.object.video.getData().writeToFile(vidPath as String, atomically: true)
        } catch let error {
            print("Failed to write video from cache: \(error)")
        }
    }
}