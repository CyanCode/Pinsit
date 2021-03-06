//
//  PinVideoManager.swift
//  Pinsit
//
//  Created by Walker Christie on 2/15/15.
//  Copyright (c) 2015 Walker Christie. All rights reserved.
//

import Foundation
import AVFoundation
import Async

class PinVideoManager: NSObject {
    var videoView: UIView!
    var videoData: NSData!
    var player: AVPlayer!
    var layer: AVPlayerLayer!
    var videoEnded: Bool!
    var forceVideoDeallocate = false
    
    init(videoView: UIView) {
        self.videoView = videoView
        self.videoEnded = false
    }
    
    ///Loads video from cache then server, plays it
    ///
    ///- parameter videoData: NSData of the video to be played
    ///- parameter completion: Called when the video has been rendered and began playing
    func startPlayingWithVideoData(videoData: NSData, completion: () -> Void) {
        Async.background {
            self.videoData = videoData
            self.player = self.playerFromData(self.videoData)
            
            Async.main {
                self.layer = AVPlayerLayer(player: self.player)
                
                self.layer.videoGravity = AVLayerVideoGravityResizeAspectFill
                self.layer.frame = self.videoView.bounds
                self.videoView.layer.insertSublayer(self.layer, atIndex: 1)
                
                self.player.play()
                NSNotificationCenter.defaultCenter().addObserver(self, selector: "playerDidFinish:", name: AVPlayerItemDidPlayToEndTimeNotification, object: nil) //AVPlayer recording finished selection
                
                completion()
            }
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
    
    func playerDidFinish(notification: NSNotification) {
        if forceVideoDeallocate == false {
            player.seekToTime(kCMTimeZero)
            player.play()
        }
    }
    
    private func playerFromData(data: NSData) -> AVPlayer {
        let directory = File.pulledVideoPath()
        data.writeToFile(directory.path!, atomically: true)
        
        return AVPlayer(URL: directory)
    }
    
    func endVideo() {
        forceVideoDeallocate = true
        
        if player != nil {
            player.pause()
        }
    }
    
    func recoverVideo() {
        if player != nil && forceVideoDeallocate {
            forceVideoDeallocate = false
            player.play()
        }
    }
}