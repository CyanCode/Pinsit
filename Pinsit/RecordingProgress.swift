//
//  RecordingProgress.swift
//  Pinsit
//
//  Created by Walker Christie on 9/21/14.
//  Copyright (c) 2014 Walker Christie. All rights reserved.
//

import Foundation
import AVFoundation

class RecordingProgress {
    var video: VideoFactory
    var camera: CameraManager
    
    init(vid: VideoFactory, cam: CameraManager) {
        self.video = vid
        self.camera = cam
    }
    
    func startRecording() {
        let outputPath: NSString = NSTemporaryDirectory() + "output.mov"
        let outputURL: NSURL = NSURL(fileURLWithPath: outputPath)!
        
        if NSFileManager.defaultManager().fileExistsAtPath(outputPath) {
            var error: NSError?
            NSFileManager.defaultManager().removeItemAtPath(outputPath, error: &error)
        }
        
        video.output.startRecordingToOutputFileURL(outputURL, recordingDelegate: camera)
    }
    
    func endRecording() {
        video.session.stopRunning()
        VideoFactory.removePreview(camera.view)
        
        let session = video.session
        
        //Remove inputs
        for var index = 0; index < session.inputs.count; index++ {
            session.removeInput(session.inputs[index] as AVCaptureInput)
        }
        
        //Remove outputs
        for var index = 0; index < session.outputs.count; index++ {
            session.removeOutput(session.outputs[index] as AVCaptureOutput)
        }
    }
    
    class func videoLocation() -> NSURL {
        let outputPath: NSString = NSTemporaryDirectory() + "output.mov"
        return NSURL(fileURLWithPath: outputPath)!
    }
}