//
//  RefreshTimer.swift
//  Pinsit
//
//  Created by Walker Christie on 10/27/14.
//  Copyright (c) 2014 Walker Christie. All rights reserved.
//

import Foundation

class RefreshTimer {
    class func startTimer() {
        _ = NSTimer(timeInterval: 1, target: self, selector: Selector("fireUpdate"), userInfo: nil, repeats: true)
    }
    
    class func fireUpdate(timer: NSTimer) {
        RefreshTimerStruct.currentTime += 1
    }
    
    class func resetTime() {
        RefreshTimerStruct.currentTime = 0
    }
    
    class func getTime() -> Int {
        return RefreshTimerStruct.currentTime
    }
}

struct RefreshTimerStruct {
    static var currentTime = 0
    
    var time: Int {
        get { return RefreshTimerStruct.currentTime }
        set { RefreshTimerStruct.currentTime = newValue }
    }
}