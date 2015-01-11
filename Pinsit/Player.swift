//
//  Player.swift
//  Pinsit
//
//  Created by Walker Christie on 9/20/14.
//  Copyright (c) 2014 Walker Christie. All rights reserved.
//

import Foundation
import AVFoundation
import QuartzCore
import MediaPlayer

class Player: NSObject {
    var playerLayer: AVPlayerLayer!
    var item: AVPlayerItem!
    var player: AVPlayer?
    var view: UIView
    var videoURL: NSURL!
    
    init (view: UIView) {
        self.view = view
        super.init()

        self.assignVideoPath()
    }
    
    func startRecPlayer() {
        player = AVPlayer(URL: videoURL)
        self.createLayer()
        
        if (player?.rate == 0.0) {
            self.player?.play()
        }
    }
    
    func stopVideo() {
        player?.pause()
        playerLayer.removeFromSuperlayer()
    }
    
    func createLayer() {
        if (player != nil) {
            playerLayer.removeFromSuperlayer()
        }
        
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = view.bounds
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        
        self.view.layer.insertSublayer(playerLayer, atIndex: 1)
    }
    
    func assignVideoPath() {
        let filePath = NSTemporaryDirectory().stringByAppendingPathComponent("output.mov")
        self.videoURL = NSURL(fileURLWithPath: filePath)
    }
}