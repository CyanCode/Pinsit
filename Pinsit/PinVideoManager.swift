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
    
    ///Loads video from server with data
    ///
    ///:param: videoURL The url of the video to be played
    ///:param: completion Called when the video has been rendered and began playing
    func startPlayingWithVideoData(videoURL: NSURL, completion: () -> Void) {
        Async.background {
            self.videoData = NSData(contentsOfURL: videoURL)
            
            self.player = self.playerFromData(self.videoData)
            self.layer = AVPlayerLayer(player: self.player)
            
            self.layer.frame = self.videoView.frame
            self.videoView.layer.addSublayer(self.layer)
            self.player.seekToTime(kCMTimeZero)
            self.player.play()
        }.main {
            completion()
        }
    }
    
    ///Adds tap gesture to videoView.  If tapped: pauses, plays, or restarts video based on status
    ///Also adds NSNotification to AVPlayer
    func monitorTaps() {
        let gesture = UITapGestureRecognizer(target: self, action: "viewTapped:")
        videoView.addGestureRecognizer(gesture)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "itemFinished:", name: AVPlayerItemDidPlayToEndTimeNotification, object: player.currentItem)
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
    
    func itemFinished(notification: NSNotification) {
        videoEnded = true
    }
    
    private func playerFromData(data: NSData) -> AVPlayer {
        let directory = NSTemporaryDirectory().stringByAppendingPathComponent("pulledVideo.mp4")
        data.writeToFile(directory, atomically: true)
        
        return AVPlayer(URL: NSURL(fileURLWithPath: directory))
    }
}