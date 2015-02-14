//
//  Scrubbing.swift
//  Pinsit
//
//  Created by Walker Christie on 2/9/15.
//  Copyright (c) 2015 Walker Christie. All rights reserved.
//

import Foundation
import AVFoundation

class Scrubbing: UIView {
    var videoLocation: NSURL!
    private var player: AVPlayer!
    
    ///Initializer without video location, default temporary directory used
    override init() {
        let file = File()
        self.videoLocation = file.getVideoPathURL()
        super.init()
    }

    ///Initializer without video location, default temporary directory used
    ///Used in Storyboard subclassing
    required init(coder aDecoder: NSCoder) {
        let file = File()
        self.videoLocation = file.getVideoPathURL()
        super.init(coder: aDecoder)
    }
    
    ///Initializer without video location, default temporary directory used
    ///Used in programmatically subclassing
    override init(frame: CGRect) {
        let file = File()
        self.videoLocation = file.getVideoPathURL()
        super.init(frame: frame)
    }
    
    ///Sets custom video location different from default
    ///
    ///:param: videoLocation location of Video to be loaded
    func setVideoLocation(url: NSURL) {
        self.videoLocation = url
    }
    
    ///MARK: Delegate
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        updateVideoLocation(touches)
    }
    
    ///Creates AVPlayerLayer inside current UIView
    func createVideoLayer() {
        let asset = AVAsset.assetWithURL(videoLocation) as AVAsset
        let item = AVPlayerItem(asset: asset)
        player = AVPlayer(playerItem: item)
        
        let layer = AVPlayerLayer(player: player)
        layer.frame = self.bounds
        layer.videoGravity = AVLayerVideoGravityResizeAspectFill
        
        self.layer.addSublayer(layer)
        player.play()
        
        println(self.frame.width)
    }
    
    ///Converts UITouch x value to seconds using time conversion
    ///
    ///:param: point UITouch point to be converted
    ///:returns: Newly created CMTime value
    private func calculateVideoTime(point: UITouch) -> CMTime {
        let viewWidth = self.frame.width
        let tappedPoint = point.locationInView(self).x
        let videoLength = CMTimeGetSeconds(player.currentItem.asset.duration)
        
        let time = Float(viewWidth) / (Float(tappedPoint) * Float(videoLength)) //Time Calculation
        return CMTimeMakeWithSeconds(Float64(time), 300)
    }
    
    ///Seeks AVPlayer video to calculated time
    ///
    ///:param: touches NSSet of touches created by UIView delegate method(s)
    private func updateVideoLocation(touches: NSSet) {
        let point = touches.anyObject() as UITouch
        player.seekToTime(calculateVideoTime(point))
    }
}