//
//  ExpandedVideoView.swift
//  Pinsit
//
//  Created by Walker Christie on 6/10/15.
//  Copyright (c) 2015 Walker Christie. All rights reserved.
//

import Foundation
import AVFoundation

class ExpandedVideoView: UIView {
    private var previousCoordinates: CGRect!
    var playerLayer: AVPlayerLayer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func adjustSublayers() {
        for layer in self.layer.sublayers! {
            layer.frame = self.frame
        }
    }
    
    ///MARK: Long Press Delegates
    func longPressGesture(gesture: UIPinchGestureRecognizer) {
        if (previousCoordinates == nil) {
            previousCoordinates = self.frame
            //previousCoordinates.origin.y = previousCoordinates.origin.y - 44
        }
        
        if (gesture.scale > 1) { //Expand
            if (playerLayer != nil) { playerLayer!.videoGravity = AVLayerVideoGravityResizeAspect }
            self.frame = UIApplication.sharedApplication().windows.last!.frame
        } else if (gesture.scale < 1) { //Contract
            if (playerLayer != nil) { playerLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill }
            self.frame = self.previousCoordinates
        }
        
        adjustSublayers()
    }
    
    func adjustGravityOnResize(layer: AVPlayerLayer?) {
        self.playerLayer = layer
    }
    
    private func addHoldGesture() {
        let gesture = UIPinchGestureRecognizer(target: self, action: "longPressGesture:")
        self.addGestureRecognizer(gesture)
    }
}