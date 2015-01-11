//
//  AudioFactory.swift
//  Pinsit
//
//  Created by Walker Christie on 9/20/14.
//  Copyright (c) 2014 Walker Christie. All rights reserved.
//

import Foundation
import AVFoundation

///Adds audio input
class AudioFactory {
    var recDevice: AVCaptureDevice!
    var session: AVCaptureSession
    var input: AVCaptureDeviceInput!
    
    init(sess: AVCaptureSession) {
        self.session = sess
        createInput()
    }
    
    func createInput() {
        recDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeAudio)
        
        var error: NSError?
        input = AVCaptureDeviceInput.deviceInputWithDevice(recDevice, error: &error) as AVCaptureDeviceInput
        
        if (error == nil) {
            session.addInput(input)
        } else {
            println("Audio input initialization error: \(error?.localizedDescription)")
        }
    }
}

