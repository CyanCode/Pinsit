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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    var player: AVPlayer!
    ///Plays back recorded video
    ///
    ///:param: shouldRestart Is the video restarting (true), or has it just begun (false)
    ///:param: isLooping Should the video loop over and over again
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
    ///:param: output URL for video save location, nil for default location
    func startRecordingVideo(output: NSURL?) {
        self.recStatus = .RECORDING
        
        var location = output == nil ? File.getVideoPathURL() : output
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
    ///:param: loaded called when the sessions have been successfully created
    func createSessions(loaded: () -> Void) {
        Async.background {
            self.session = AVCaptureSession()
            self.session.sessionPreset = AVCaptureSessionPresetMedium
            self.videoDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
            let audioDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeAudio)
            
            var error: NSError?
            self.videoInput = AVCaptureDeviceInput.deviceInputWithDevice(self.videoDevice, error: &error) as! AVCaptureDeviceInput
            let audioInput = AVCaptureDeviceInput.deviceInputWithDevice(audioDevice, error: &error) as! AVCaptureDeviceInput
            self.deviceOutput = AVCaptureMovieFileOutput()
            
            if self.session.canAddInput(self.videoInput) { //Video input
                self.session.addInput(self.videoInput)
            }; if self.session.canAddInput(audioInput) { //Audio input
                self.session.addInput(audioInput)
            }; if self.session.canAddOutput(self.deviceOutput) { //Video output
                self.session.addOutput(self.deviceOutput)
            }
            
            self.session.startRunning()
            }.main {
                loaded()
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
    
    ///Video did finish recording delegate
    func captureOutput(captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAtURL outputFileURL: NSURL!, fromConnections connections: [AnyObject]!, error: NSError!) {
        if error != nil {
            println("Recording Finished, error status: \(error.localizedDescription)")
        } else {
            println("Video recording successful")
            self.playbackRecording(false, isLooping: true)
        }
    }
    
    ///Called when AVPlayer has finished playing
    func playerDidFinish(notification: NSNotification) {
        self.playbackRecording(true, isLooping: false)
    }
    
    enum RecordingStatus {
        case DONE_RECORDING
        case RECORDING
        case NOT_STARTED
        case READY
    }
}

extension UIView {
    ///Inserts layer into view, checking if others exist and deleting them
    ///
    ///:param: toInsert layer to insert
    func insertLayerWithCheck(toInsert: CALayer) {
        let sublayers = self.layer.sublayers
        
        if sublayers != nil && count(sublayers!) > 0 {
            sublayers![0].removeFromSuperlayer()
        }
        
        self.layer.insertSublayer(toInsert, atIndex: 0)
    }
    
    func insertLayerAtTop(toInsert: CALayer) {
        let index = self.layer.sublayers != nil ? count(self.layer.sublayers) + 1 : 0
        
        self.layer.insertSublayer(toInsert, atIndex: UInt32(index))
    }
}