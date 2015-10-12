//
//  Styling.swift
//  Pinsit
//
//  Created by Walker Christie on 9/30/14.
//  Copyright (c) 2014 Walker Christie. All rights reserved.
//

import Foundation
import UIKit

class Styling {
    var obj: AnyObject!
    
    init(manipulate: UIView) {
        self.obj = manipulate
    }
    
    func smoothButton() -> UIButton {
        let btn = obj as! UIButton
        
        btn.layer.cornerRadius = 5.0
        btn.layer.borderColor = UIColor.whiteColor().CGColor
        btn.layer.borderWidth = 1.5
        btn.layer.shadowColor = UIColor.lightGrayColor().CGColor
        btn.layer.opacity = 0.8
        btn.layer.shadowRadius = 3.0
        btn.layer.shadowOffset = CGSizeMake(2.0, 2.0)
        
        return btn
    }
    
    func constructView() -> UIView {
        let view = obj as! UIView
        
        view.layer.cornerRadius = 5.0
        view.layer.borderColor = UIColor.whiteColor().CGColor
        view.layer.borderWidth = 1.5
        view.layer.shadowColor = UIColor.lightGrayColor().CGColor
        view.layer.shadowOpacity = 0.8
        view.layer.shadowRadius = 3.0
        view.layer.shadowOffset = CGSizeMake(2.0, 2.0)
        
        return view
    }
    
    func encircleButton(img: UIImage) -> UIButton {
        let btn = UIButton(frame: CGRectMake(0, 0, 37, 37))
        btn.setImage(img, forState: UIControlState.Normal)
        
        let frameSize = btn.imageView?.frame.size.height
        btn.imageView?.layer.cornerRadius = frameSize! / 2
        btn.imageView?.layer.masksToBounds = true
        btn.imageView?.layer.borderWidth = 0
        
        return btn
    }
    
    func gradientBackground() {
        let view = obj as! UIView
        let gradient = CAGradientLayer()

        gradient.frame = view.bounds
        gradient.colors = [UIColor(string: "#50C9C3").CGColor, UIColor(string: "#96DEDA").CGColor, 1]

        view.layer.insertSublayer(gradient, atIndex: 0)
    }
    
    ///Creates a pattern on sent view's background
    class func patternView(view: UIView) {
        let image = UIImage(named: "pattern.png")
        view.backgroundColor = UIColor(patternImage: image!)
        view.opaque = false
        view.layer.opaque = false
    }
}