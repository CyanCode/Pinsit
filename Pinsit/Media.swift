//
//  Media.swift
//  Pinsit
//
//  Created by Walker Christie on 9/21/14.
//  Copyright (c) 2014 Walker Christie. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

///Manager for all things recording.  Loadpreview to view camera
class Media {
    var video: VideoFactory!
    var camera: CameraManager!
    var audio: AudioFactory!
    var progress: RecordingProgress!
    var view: UIView!
    
    init(resView: UIView) {
        view = resView
        loadResources() //Load required resources
    }
    
    func createPreview() {
        video.session.commitConfiguration()
        video.session.startRunning()
        
        video.createPreview(view)
    }
    
    func toggleLoading(progress: UIActivityIndicatorView, enable: Bool) {
        dispatch_async(dispatch_get_main_queue(), {
            progress.hidesWhenStopped = true
            if (enable == true) {
                progress.startAnimating()
                progress.hidden = false
            } else {
                progress.stopAnimating()
            }
        })
    }
    
    func removeLayers() {
        for layer in view.layer.sublayers {
            if layer is AVCaptureVideoPreviewLayer {
                layer.removeFromSuperlayer()
            }
        }
    }
    
    private func loadResources() {
        video = VideoFactory()
        audio = AudioFactory(sess: video.session)
        camera = CameraManager(responseView: view, vidCapture: video)
        progress = RecordingProgress(vid: video, cam: camera)
    }
}