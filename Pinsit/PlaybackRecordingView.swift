//
//  PlaybackRecordingView.swift
//  Pinsit
//
//  Created by Walker Christie on 8/4/15.
//  Copyright © 2015 Walker Christie. All rights reserved.
//

import UIKit
import VIMVideoPlayer

class PlaybackRecordingView: VIMVideoPlayerView, VIMVideoPlayerDelegate {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        player.delegate = self
        setVideoFillMode(AVLayerVideoGravityResizeAspectFill)
    }
    
    func playbackRecordedVideo() {
        player.setURL(File.getVideoPathURL())
        player.play()
    }
    
    func endPlayback() {
        player.pause()
    }
    
    func videoPlayerDidReachEnd(videoPlayer: VIMVideoPlayer!) {
        videoPlayer.seekToTime(0.0)
        videoPlayer.play()
    }
}
