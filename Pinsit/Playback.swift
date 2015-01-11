//
//  Playback.swift
//  Pinsit
//
//  Created by Walker Christie on 12/20/14.
//  Copyright (c) 2014 Walker Christie. All rights reserved.
//

import Foundation
import MediaPlayer
import AVFoundation

class Playback {
    var view: UIView!
    var playing: Bool!
    var donePlaying: Bool!
    
    private var player: AVPlayer!
    private var layer: AVPlayerLayer!
    
    init(view: UIView) {
        self.view = view
        
        let item = AVPlayerItem(URL: RecordingProgress.videoLocation())
        
        //Initialize player / layer
        player = AVPlayer(playerItem: item)
        layer = AVPlayerLayer(player: player)
        layer.videoGravity = AVLayerVideoGravityResizeAspectFill
        
        //Setup frame
        layer.frame = view.bounds
        view.layer.addSublayer(layer)
        playing = false
        
        //Create done playing notification
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "itemFinishedPlaying:", name: AVPlayerItemDidPlayToEndTimeNotification, object: nil)
    }
    
    func startPlayback() {
        donePlaying = false
        
        if (player.rate == 0.0) {
            player.play()
            playing = true
        } else {
            player.pause()
            playing = false
        }
    }
    
    func pausePlayback() {
        player.pause()
        playing = false
    }
    
    func deconstructPlayback() {
        playing = false
        player.pause()
        layer.removeFromSuperlayer()
    }
    
    @objc func itemFinishedPlaying(notification: NSNotification) {
        player.seekToTime(CMTimeMakeWithSeconds(0, 5))
        donePlaying = true
    }
}