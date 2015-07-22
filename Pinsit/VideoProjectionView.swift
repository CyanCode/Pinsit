//
//  VideoProjectionView.swift
//  Pinsit
//
//  Created by Walker Christie on 3/22/15.
//  Copyright (c) 2015 Walker Christie. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class VideoProjectionView: UIView, AVCaptureFileOutputRecordingDelegate {
    var recStatus: RecordingStatus = .NOT_STARTED
    var session: AVCaptureSession!
    var deviceOutput: AVCaptureMovieFileOutput!
    var videoInput: AVCaptureDeviceInput!
    var videoDevice: AVCaptureDevice!
    var viewActive = true
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    var player: AVPlayer!
    ///Plays back recorded video
    ///
    ///- parameter shouldRestart: Is the video restarting (true), or has it just begun (false)
    ///- parameter isLooping: Should the video loop over and over again
    func playbackRecording(shouldRestart: Bool, isLooping: Bool) {
        self.recStatus = .READY
        
        if shouldRestart == false {
            let item = AVPlayerItem(URL: File.getVideoPathURL())
            player = AVPlayer(playerItem: item)
            let playerLayer = AVPlayerLayer(player: player)
            
            playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
            playerLayer.frame = self.bounds
            insertLayerWithCheck(playerLayer)
            
            player.play()
            
            if isLooping == true {
                NSNotificationCenter.defaultCenter().addObserver(self, selector: "playerDidFinish:", name: AVPlayerItemDidPlayToEndTimeNotification, object: nil) //AVPlayer recording finished selection
            }
        } else {
            player.seekToTime(kCMTimeZero)
            player.play()
        }
    }
    
    ///Start recording from camera input
    ///
    ///- parameter output: URL for video save location, nil for default location
    func startRecordingVideo(output: NSURL?) {
        self.recStatus = .RECORDING
        
        let location = output == nil ? File.getVideoPathURL() : output
        deviceOutput.startRecordingToOutputFileURL(location, recordingDelegate: self)
    }
    
    ///Adds camera preview layer to self
    func previewCamera() {
        self.recStatus = .NOT_STARTED
        
        let preview = AVCaptureVideoPreviewLayer(session: self.session)
        preview.videoGravity = AVLayerVideoGravityResizeAspectFill
        preview.frame = self.bounds
        
        self.insertLayerWithCheck(preview)
    }
    
    ///Creates default capture session for recording / playing back video.
    ///This does create a global capture session, therefore you must remove
    ///the session before calling this method again
    ///
    ///- parameter loaded: called when the sessions have been successfully created
    func createSessions(loaded: () -> Void) {
        Async.background {
            self.session = AVCaptureSession()
            self.session.sessionPreset = AVCaptureSessionPresetMedium
            self.videoDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
            let audioDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeAudio)
        
            do {
                self.videoInput = try AVCaptureDeviceInput(device: self.videoDevice)
                let audioInput = try AVCaptureDeviceInput(device: audioDevice)
                self.deviceOutput = AVCaptureMovieFileOutput()
                
                if self.session.canAddInput(self.videoInput) { //Video input
                    self.session.addInput(self.videoInput)
                }; if self.session.canAddInput(audioInput) { //Audio input
                    self.session.addInput(audioInput)
                }; if self.session.canAddOutput(self.deviceOutput) { //Video output
                    self.session.addOutput(self.deviceOutput)
                }
                
                //Monitor focus area changes
                try self.videoDevice.lockForConfiguration()
                self.videoDevice.subjectAreaChangeMonitoringEnabled = true
                self.videoDevice.unlockForConfiguration()
            
                self.session.startRunning()
            } catch let error as NSError {
                fatalError("Could not load capture device: \(error.localizedDescription)")
            } catch {
                fatalError("Could not load capture device")
            }
            
            Async.main { loaded() }
        }
    }
    
    ///Get the front camera's AVCaptureDevice object
    func frontCamDevice() -> AVCaptureDevice {
        let devices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
        
        for device in devices {
            if device.position == AVCaptureDevicePosition.Front {
                return device as! AVCaptureDevice
            }
        }
        
        return AVCaptureDevice()
    }
    
    func trackFocusPointChanges() {
        NSNotificationCenter.defaultCenter().addObserverForName(AVCaptureDeviceSubjectAreaDidChangeNotification, object: nil, queue: nil) { (notification) -> Void in //Called when subject area changed
            print("Subject area changed")
        }
    }
    
    func setFocusPoint(point: CGPoint) {
        do {
            try videoDevice.lockForConfiguration()
            videoDevice.focusPointOfInterest = point
            videoDevice.unlockForConfiguration()
        } catch {
            print("Could not lock device for configuration")
        }
    }
    
    ///Video did finish recording delegate
    func captureOutput(captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAtURL outputFileURL: NSURL!, fromConnections connections: [AnyObject]!, error: NSError!) {
        if error != nil {
            print("Recording Finished, error status: \(error.localizedDescription)")
        } else {
            print("Video recording successful")
            self.playbackRecording(false, isLooping: true)
        }
    }
    
    ///Called when AVPlayer has finished playing
    func playerDidFinish(notification: NSNotification) {
        if viewActive == true {
            self.playbackRecording(true, isLooping: false)
        }
    }
}

enum RecordingStatus {
    case DONE_RECORDING
    case RECORDING
    case NOT_STARTED
    case READY
}