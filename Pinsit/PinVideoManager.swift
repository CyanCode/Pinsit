//
//  PinVideoManager.swift
//  Pinsit
//
//  Created by Walker Christie on 2/15/15.
//  Copyright (c) 2015 Walker Christie. All rights reserved.
//

import Foundation
import AVFoundation

class PinVideoManager {
    var videoView: UIView!
    private var videoEnded: Bool!
    private var videoData: NSData!
    private var player: AVPlayer!
    private var layer: AVPlayerLayer!
    
    init(videoView: UIView) {
        self.videoView = videoView
        self.videoEnded = false
    }
    
    ///Loads video from cache then server, plays it
    ///
    ///:param: videoData NSData of the video to be played
    ///:param: completion Called when the video has been rendered and began playing
    func startPlayingWithVideoData(videoData: NSData, completion: () -> Void) {
        Async.background {
            self.videoData = videoData
            self.player = self.playerFromData(self.videoData)
        }.main {
            var layer = self.layer
            let player = self.player
            let view = self.videoView
            
            layer = AVPlayerLayer(player: self.player)
            layer.videoGravity = AVLayerVideoGravityResizeAspectFill
            layer.frame = self.videoView.bounds
            
            view.layer.insertSublayer(layer, atIndex: 1)
            player.seekToTime(kCMTimeZero)
            player.play()
            
            completion()
        }
    }
    
    ///Adds tap gesture to videoView.  If tapped: pauses, plays, or restarts video based on status
    ///Also adds NSNotification to AVPlayer
    func monitorTaps() {
        let gesture = UITapGestureRecognizer(target: self, action: "viewTapped:")
        videoView.addGestureRecognizer(gesture)
        
        NSNotificationCenter.defaultCenter().addObserverForName(AVPlayerItemDidPlayToEndTimeNotification, object: player.currentItem, queue: nil) { (notification) -> Void in
            self.videoEnded = true
        }
    }
    
    ///Called when videoView is tapped
    func viewTapped(gesture: UITapGestureRecognizer) {
        if videoEnded == true { //Video ended: restart
            player.seekToTime(kCMTimeZero)
            player.play()
            videoEnded = false
            return
        }
        
        if player.rate == 0 { //Video paused: play
            player.play()
        } else { //Video playing: pause
            player.pause()
        }
    }
    
    private func playerFromData(data: NSData) -> AVPlayer {
        let directory = File.pulledVideoPath()
        data.writeToFile(directory, atomically: true)
        
        return AVPlayer(URL: NSURL(fileURLWithPath: directory))
    }
}

extension File {
    class func pulledVideoPath() -> String {
        return NSTemporaryDirectory().stringByAppendingPathComponent("pulledVideo.mp4")
    }
}