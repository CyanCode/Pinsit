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
        
        if (fManager.fileExistsAtPath(vidPath)) {
            var error: NSError?
            fManager.removeItemAtPath(vidPath, error: &error)
        }
        
        let vidData = NSData(contentsOfFile: vidPath)
        vidData?.writeToFile(vidPath, atomically: true)
    }
    
    func writeVideoFromCache() {
        let vidPath = File.getVideoPathString()
        let fManager = NSFileManager.defaultManager()
        
        if (fManager.fileExistsAtPath(vidPath)) {
            var error: NSError?
            fManager.removeItemAtPath(vidPath, error: &error)
        }
        
        annotation.videoData?.writeToFile(vidPath, atomically: true)
    }
}