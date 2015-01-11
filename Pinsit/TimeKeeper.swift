//
//  TimeKeeper.swift
//  Pinsit
//
//  Created by Walker Christie on 10/8/14.
//  Copyright (c) 2014 Walker Christie. All rights reserved.
//

import Foundation

class TimeKeeper {
    var interTime: NSTimer!
    var progress: UIProgressView!
    var currentProgress: Float!
    var max: Float!
    var responder: UIViewController!
    
    var paused: Bool!
    
    init(progress: UIProgressView, responder: UIViewController) {
        self.responder = responder
        self.progress = progress
        self.currentProgress = 0.0
        self.paused = false
        self.progress.setProgress(0.0, animated: false)
        
        NSNotificationCenter.defaultCenter().addObserver(responder, selector: "timeUp:", name: "TimeFinishedNotification", object: nil)
        
        setMax()
    }
    
    func startTime() {
        interTime = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "fireUpdate:", userInfo: nil, repeats: true)
    }
    
    @objc func fireUpdate(timer: NSTimer) {
        currentProgress = currentProgress + 0.1
        progress!.setProgress(currentProgress / max, animated: true)
        println("Time: \(currentProgress / max)")
        
        if (currentProgress >= max) {
            dispatch_async(dispatch_get_main_queue()) {
                NSNotificationCenter.defaultCenter().postNotificationName("TimeFinishedNotification", object: nil)
            }
        }
    }
    
    func endTime() {
        interTime.invalidate()
        currentProgress = 0.0
    }
    
    func togglePause() {
        if (!paused) {
            self.startTime()
        } else {
            interTime.invalidate()
        }
    }
    
    func setMax() {
        let fm = File()
        if (fm.isUpgraded()) {
            max = 10
        } else {
            max = 7
        }
    }
}