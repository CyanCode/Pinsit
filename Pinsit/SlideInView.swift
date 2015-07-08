//
//  SlideUpView.swift
//  Pinsit
//
//  Created by Walker Christie on 5/25/15.
//  Copyright (c) 2015 Walker Christie. All rights reserved.
//

import Foundation

class SlideInView: UIView {
    private let screenHeight = UIScreen.mainScreen().bounds.height - 49 //height - tabbar height
    var slideSpeed: NSTimeInterval = 0.5
    var inDisplay: Bool = false
    
    func slideIn(doneAnimating: (() -> Void)?) {
        if inDisplay == true {
            doneAnimating!()
            return
        }

        self.frame.origin.y = screenHeight
        UIView.animateWithDuration(slideSpeed, animations: { () -> Void in
            self.frame.origin.y = self.screenHeight - self.bounds.size.height
        }) { (done) -> Void in
            self.inDisplay = true
            
            if doneAnimating != nil {
                doneAnimating!()
            }
        }
    }
    
    func dismissSlide() {
        if inDisplay == false {
            return
        }
        
        UIView.animateWithDuration(slideSpeed, animations: { () -> Void in
            self.frame.origin.y = self.screenHeight
        }, completion: nil)
    }
}