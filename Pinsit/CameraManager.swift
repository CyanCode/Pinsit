//
//  CameraManager.swift
//  Pinsit
//
//  Created by Walker Christie on 9/20/14.
//  Copyright (c) 2014 Walker Christie. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

///Controls camera flipping, video status, and stop / start
class CameraManager: NSObject, AVCaptureFileOutputRecordingDelegate {
    var view: UIView
    var vidInput: VideoFactory
    
    init(responseView v: UIView, vidCapture: VideoFactory) {
        self.view = v
        self.vidInput = vidCapture
    }
    
    func switchCamPosition() {
        vidInput.session.beginConfiguration()
        
        var input: AVCaptureDeviceInput
        let oldPosition = vidInput.input.device.position
        var newPosition: AVCaptureDevicePosition
        
        if (oldPosition == AVCaptureDevicePosition.Back) {
            newPosition = AVCaptureDevicePosition.Front
        } else {
            newPosition = AVCaptureDevicePosition.Back
        }
        
        vidInput.session.removeInput(vidInput.input)
        
        if newPosition == AVCaptureDevicePosition.Back {
            vidInput.recDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        } else {
            vidInput.recDevice = frontCamDevice()
        }
        
        var error: NSError?
        if vidInput.recDevice != nil {
            vidInput.input = AVCaptureDeviceInput.deviceInputWithDevice(vidInput.recDevice, error: &error) as! AVCaptureDeviceInput
            
            if (error == nil) {
                vidInput.session.addInput(vidInput.input)
            }
        }
        
        vidInput.session.commitConfiguration()
    }
    
    private func frontCamDevice() -> AVCaptureDevice {
        let devices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
        
        for device in devices {
            if device.position == AVCaptureDevicePosition.Front {
                return device as! AVCaptureDevice
            }
        }
        
        return AVCaptureDevice()
    }
    
    class func toggleTorch() {
        var device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        
        if (device.hasTorch) {
            device.lockForConfiguration(nil)
            
            let torchOn = device.torchActive
            device.torchMode = torchOn ? AVCaptureTorchMode.Off : AVCaptureTorchMode.On
            
            if (torchOn == false) {
                device.setTorchModeOnWithLevel(1.0, error: nil)
            }
            
            device.unlockForConfiguration()
        }
    }
    
    //MARK: Delegate
    func captureOutput(captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAtURL outputFileURL: NSURL!, fromConnections connections: [AnyObject]!, error: NSError!) {
        if error != nil {
            println("Recording issue: \(error.localizedDescription)")
            
            var dict: NSDictionary = error.userInfo!
            var value: AnyObject? = dict.objectForKey(AVErrorRecordingSuccessfullyFinishedKey)
            
            if (value != nil) {
                println("Recording successful")
            }
        }
    }
    
    func captureOutput(captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAtURL fileURL: NSURL!, fromConnections connections: [AnyObject]!) {
        println("Started recording")
    }
}