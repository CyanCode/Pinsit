//
//  VideoPreview.swift
//  Pinsit
//
//  Created by Walker Christie on 8/1/15.
//  Copyright © 2015 Walker Christie. All rights reserved.
//

import UIKit
import AVFoundation

@IBDesignable class VideoPreview: UIView {
    var preview: AVCaptureVideoPreviewLayer?
    var session: AVCaptureSession?
    
    func startPreviewingVideo() {
        if session == nil { prepareCaptureSession() }
        
        preview = AVCaptureVideoPreviewLayer(session: session!)
        preview!.videoGravity = AVLayerVideoGravityResizeAspectFill
        preview!.frame = self.bounds
        self.layer.masksToBounds = true
        self.layer.addSublayer(preview!)
        self.sendSublayerToBack(preview!)
        
        session!.startRunning()
    }
    
    func stopPreviewingVideo() {
        if preview != nil {
            preview!.removeFromSuperlayer()
        }; if session != nil {
            session!.stopRunning()
            session = nil
        }
    }
    
    private func prepareCaptureSession() {
        session = AVCaptureSession()
        session!.sessionPreset = AVCaptureSessionPresetLow
        
        for device in AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo) {
            if device.position == .Back {
                var error: NSError?
                let device = AVCaptureDeviceInput(device: device as! AVCaptureDevice, error: &error)
                if error == nil {
                    if session!.canAddInput(device){
                        session!.addInput(device)
                        print("Session camera input added successfully")
                    }
                }
            }
        }
    }
}
