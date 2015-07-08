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
        let vidPath = File.getVideoPathString()
        let fManager = NSFileManager.defaultManager()
        
        if (fManager.fileExistsAtPath(vidPath as String)) {
            do {
                try fManager.removeItemAtPath(vidPath as String)
            } catch let error as NSError {
                print("Error removing video file \(error.localizedDescription)")
            }
        }
        
        let vidData = NSData(contentsOfFile: vidPath as String)
        vidData?.writeToFile(vidPath as String, atomically: true)
    }
    
    func writeVideoFromCache() {
        let vidPath = File.getVideoPathString()
        let fManager = NSFileManager.defaultManager()
        
        if (fManager.fileExistsAtPath(vidPath as String)) {
            do {
                try fManager.removeItemAtPath(vidPath as String)
            } catch let error as NSError {
                print("Error removing video file \(error.localizedDescription)")
            }
        }
        
        annotation.videoData?.writeToFile(vidPath as String, atomically: true)
    }
}