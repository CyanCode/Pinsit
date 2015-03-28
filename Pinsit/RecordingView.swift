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
        
    }
    
    ///MARK: Management
    ///Reset self CALayer's sublayers
    func resetRootLayer() {
        for layer in self.layer.sublayers as [CALayer] {
            layer.removeFromSuperlayer()
        }
    }
    
    ///Remove Audio and Video inputs / outputs from the session, used while previewing video
    func removeCameraInputOutput() {
        for input in session.inputs as [AVCaptureInput] {
            session.removeInput(input)
        }
        
        for output in session.outputs as [AVCaptureOutput] {
            session.removeOutput(output)
        }
    }
    
    ///Exchanges all inputs or outputs with passed input or output
    ///
    ///:param: type input or output
    func exchangeInputOutput(type: AnyObject) {
        if type is AVCaptureInput {
            session.addInput(type as AVCaptureInput)
            
            for input in session.inputs as [AVCaptureInput] {
                if input != type as AVCaptureInput {
                    session.removeInput(input)
                }
            }
        }; if type is AVCaptureOutput {
            session.addOutput(type as AVCaptureOutput)
            
            for output in session.outputs as [AVCaptureOutput] {
                if output != type as AVCaptureOutput {
                    session.removeOutput(output)
                }
            }
        }
    }
    
    ///Toggle loading HUD shown over passed UIViewController
    func toggleHUD(enable: Bool) {
        //Load HUD
    }
    
    ///MARK: Private and Delegates
    private func printAllLayers() {
        for layer in self.layer.sublayers as [CALayer] {
            println("Layer: \(layer.description) \n")
        }
    }
}