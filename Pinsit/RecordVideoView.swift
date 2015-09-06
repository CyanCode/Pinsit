//
//  RecordVideoView.swift
//  Pinsit
//
//  Created by Walker Christie on 8/4/15.
//  Copyright © 2015 Walker Christie. All rights reserved.
//

import UIKit
import AVFoundation

class RecordVideoView: UIView, AVCaptureFileOutputRecordingDelegate {
    typealias RecordingSavedHandler = () -> Void
    var recordingSaved: RecordingSavedHandler?
    var recording: RecordingSession!
    var preview: AVCaptureVideoPreviewLayer?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        recording = RecordingSession()
        recording.startSession { (success) -> Void in }
    }
    
    func startCameraPreview() {
        recording.startSession { (success) -> Void in
            self.preview = AVCaptureVideoPreviewLayer(session: self.recording.session)
            self.preview!.videoGravity = AVLayerVideoGravityResizeAspectFill
            self.preview!.frame = self.bounds
            
            self.layer.masksToBounds = true
            self.layer.insertSublayer(self.preview!, atIndex: 0)
        }
    }
    
    func stopCameraPreview() {
        recording.endSession()
        
        if preview != nil {
            preview!.removeFromSuperlayer()
            preview = nil
        }
    }
    
    func startRecording() {
        recording.deviceOutput.startRecordingToOutputFileURL(File.getVideoPathURL(), recordingDelegate: self)
    }
    
    func stopRecording(ready: RecordingSavedHandler) {
        self.recordingSaved = ready
        recording.deviceOutput.stopRecording()
    }
    
    func captureOutput(captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAtURL outputFileURL: NSURL!, fromConnections connections: [AnyObject]!, error: NSError!) {
        if error != nil {
            print("Recording finished with errors: \(error.localizedDescription)")
        } else {
            print("Recording finished successfully")
        }
        
        recordingSaved!()
    }
}

class RecordingSession {
    var session: AVCaptureSession?
    var videoDevice: AVCaptureDevice!
    var audioDevice: AVCaptureDevice!
    
    var videoInput: AVCaptureDeviceInput!
    var audioInput: AVCaptureDeviceInput!
    
    var deviceOutput: AVCaptureMovieFileOutput!
    
    func startSession(ready: (success: Bool) -> Void) {
        var startSuccess: Bool = true
        
        if session == nil {
            session = AVCaptureSession()
            
            Async.background {
                var error: NSError?
                self.session!.sessionPreset = AVCaptureSessionPresetMedium
                self.videoDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
                self.audioDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeAudio)
                
                self.videoInput =  AVCaptureDeviceInput(device: self.videoDevice, error: &error)
                self.audioInput =  AVCaptureDeviceInput(device: self.audioDevice, error: &error)
                self.deviceOutput = AVCaptureMovieFileOutput()
                
                if error != nil {
                    println("Session unable to start.  Printing error description")
                    println(error!.localizedDescription)
                    
                    startSuccess = false
                } else {
                    if self.session!.canAddInput(self.videoInput) {
                        self.session!.addInput(self.videoInput)
                    }; if self.session!.canAddInput(self.audioInput) {
                        self.session!.addInput(self.audioInput)
                    }; if self.session!.canAddOutput(self.deviceOutput) {
                        self.session!.addOutput(self.deviceOutput)
                    }
                    
                    self.session!.startRunning()
                }
                }.main {
                    ready(success: startSuccess)
            }
        } else {
            ready(success: true)
        }
    }
    
    func endSession() {
        if session != nil {
            session!.stopRunning()
            session = nil
        }
    }
    
    func switchCamera() {
        session!.beginConfiguration()
        
        let oldPosition = self.videoDevice.position
        var newPosition: AVCaptureDevicePosition
        
        if (oldPosition == AVCaptureDevicePosition.Back) {
            newPosition = AVCaptureDevicePosition.Front
        } else {
            newPosition = AVCaptureDevicePosition.Back
        }
        
        session!.removeInput(videoInput)
        
        if newPosition == AVCaptureDevicePosition.Back {
            videoDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        } else {
            videoDevice = frontCamDevice()
        }
        
        if videoDevice != nil {
            var error: NSError?
            videoInput = AVCaptureDeviceInput(device: videoDevice, error: &error)
            
            if error == nil {
                session!.addInput(videoInput)
            } else {
                println("Could not add capture device: \(error!.localizedDescription)")
            }
        }
        
        session!.commitConfiguration()
    }
    
    func toggleTorch() {
        let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        
        if (device.hasTorch) {
            var error: NSError?
            device.lockForConfiguration(&error)
            
            if error != nil {
                return
            }
            
            let torchOn = device.torchActive
            device.torchMode = torchOn ? AVCaptureTorchMode.Off : AVCaptureTorchMode.On
            
            if (torchOn == false) {
                device.setTorchModeOnWithLevel(1.0, error: &error)
                
                if error != nil {
                    println("This device does not support torch")
                    return
                }
            }
            
            device.unlockForConfiguration()
        }
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
}