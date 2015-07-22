//
//  RecordingView.swift
//  Pinsit
//
//  Created by Walker Christie on 3/11/15.
//  Copyright (c) 2015 Walker Christie. All rights reserved.
//

import UIKit
import AVFoundation

class RecordingView: VideoProjectionView {
    ///MARK: Initialization    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    ///End the recording session
    func endRecordingSession() {
        super.deviceOutput.stopRecording()
    }
    
    ///MARK: Previewing
    ///Stop video playback, transition back to default video preview
    func stopPlayback() {
        if player != nil {
            player.pause()
        }
    }
        
    ///Flip between front and back camera
    func switchCameraPositions() {
        session.beginConfiguration()
        
        let oldPosition = self.videoDevice.position
        var newPosition: AVCaptureDevicePosition
        
        if (oldPosition == AVCaptureDevicePosition.Back) {
            newPosition = AVCaptureDevicePosition.Front
        } else {
            newPosition = AVCaptureDevicePosition.Back
        }
        
        session.removeInput(videoInput)
        
        if newPosition == AVCaptureDevicePosition.Back {
            videoDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        } else {
            videoDevice = frontCamDevice()
        }
        
        if videoDevice != nil {
            do {
                try videoInput = AVCaptureDeviceInput(device: videoDevice)
                session.addInput(videoInput)
            } catch let error as NSError {
                print("Device Input error: \(error)")
            }
        }
        
        session.commitConfiguration()
    }
    
    ///MARK: Management
    ///Reset self CALayer's sublayers
    func resetRootLayer() {
        for layer in self.layer.sublayers! as [CALayer] {
            layer.removeFromSuperlayer()
        }
    }
    
    ///Remove Audio and Video inputs / outputs from the session, used while previewing video
    func removeCameraInputOutput() {
        for input in session.inputs as! [AVCaptureInput] {
            session.removeInput(input)
        }
        
        for output in session.outputs as! [AVCaptureOutput] {
            session.removeOutput(output)
        }
    }
    
    ///Exchanges all inputs or outputs with passed input or output
    ///
    ///- parameter type: input or output
    func exchangeInputOutput(type: AnyObject) {
        if type is AVCaptureInput {
            session.addInput(type as! AVCaptureInput)
            
            for input in session.inputs as! [AVCaptureInput] {
                if input != type as! AVCaptureInput {
                    session.removeInput(input)
                }
            }
        }; if type is AVCaptureOutput {
            session.addOutput(type as! AVCaptureOutput)
            
            for output in session.outputs as! [AVCaptureOutput] {
                if output != type as! AVCaptureOutput {
                    session.removeOutput(output)
                }
            }
        }
    }
    
    ///Flip camera light on / off
    func toggleTorch() {
        let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        
        if (device.hasTorch) {
            do {
                try device.lockForConfiguration()
            } catch _ { }
            
            let torchOn = device.torchActive
            device.torchMode = torchOn ? AVCaptureTorchMode.Off : AVCaptureTorchMode.On
            
            if (torchOn == false) {
                do {
                    try device.setTorchModeOnWithLevel(1.0)
                } catch _ { }
            }
            
            device.unlockForConfiguration()
        }
    }
    
    ///Toggle loading HUD shown over passed UIViewController
    func toggleHUD(enable: Bool) {
        //Load HUD
    }
    
    ///MARK: Private and Delegates
    private func printAllLayers() {
        for layer in self.layer.sublayers! as [CALayer] {
            print("Layer: \(layer.description) \n")
        }
    }
}