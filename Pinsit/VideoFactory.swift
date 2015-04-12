//
//  VideoFactory.swift
//  Pinsit
//
//  Created by Walker Christie on 9/20/14.
//  Copyright (c) 2014 Walker Christie. All rights reserved.
//

import Foundation
import AVFoundation

///Adds video input and output to provided capture session
class VideoFactory {
    var recDevice: AVCaptureDevice?
    var session: AVCaptureSession!
    var input: AVCaptureDeviceInput!
    var output: AVCaptureMovieFileOutput!
    
    init() {
        createSession()
        createInput()
        createOutput()
    }
    
    func createPreview(view: UIView) {
        dispatch_async(dispatch_get_main_queue(), {
            var previewLayer = AVCaptureVideoPreviewLayer(session: self.session)
            let v = view.bounds
            previewLayer.frame = view.bounds
            previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
            
            view.layer.insertSublayer(previewLayer, atIndex: 0)
        })
    }
    
    func createSession() {
        session = AVCaptureSession()
        session.beginConfiguration()
        session.sessionPreset = AVCaptureSessionPresetHigh
    }
    
    func endSession() {
        session.stopRunning()
        
        for input in session.inputs {
            session.removeInput(input as! AVCaptureInput)
        }
        
        for output in session.outputs {
            session.removeOutput(output as! AVCaptureOutput)
        }
    }
    
    func createInput() {
        recDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        
        if (recDevice != nil) {
            var error: NSError?
            input = AVCaptureDeviceInput.deviceInputWithDevice(recDevice, error: &error) as! AVCaptureDeviceInput
            
            if (error == nil) {
                if (session.canAddInput(input)) {
                    session.addInput(input)
                } else {
                    println("Could not add video input: \(error?.localizedDescription)")
                }
            }
        }
    }
    
    func createOutput() {
        output = AVCaptureMovieFileOutput()
        
        if (session.canAddOutput(output)) {
            session.addOutput(output)
        }
    }
    
    class func removePreview(view: UIView) {
        for layer in view.layer.sublayers {
            if layer is AVCaptureVideoPreviewLayer {
                layer.removeFromSuperlayer()
            }
        }
    }
}