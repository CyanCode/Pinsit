//
//  AnimatedGalleryImageView.swift
//  Pinsit
//
//  Created by Walker Christie on 8/22/15.
//  Copyright (c) 2015 Walker Christie. All rights reserved.
//

import UIKit
import Foundation

class AnimatedGalleryImageView: UIImageView {
    var images: [UIImage]?
    var blurImages: Bool = true
    
    private var stopped: Bool = false
    private var currentImage: Int?
    private var transitionSpeed: NSTimeInterval!
    
    func startImageGallery(speed: NSTimeInterval, transitionSpeed: NSTimeInterval) {
        stopped = false
        self.transitionSpeed = transitionSpeed
        
        if images != nil {
            NSTimer.scheduledTimerWithTimeInterval(speed, target: self, selector: "imageSwitch:", userInfo: nil, repeats: true)
        }
    }
    
    func imageSwitch(timer: NSTimer) {
        if currentImage == nil {
            currentImage = 0
        }; if stopped {
            timer.invalidate()
        }
        
        UIView.transitionWithView(self, duration: 0.5, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
            self.image = self.blurImages ? self.blurImage(8, image: self.images![self.currentImage!]) : self.images![self.currentImage!]
        }) { (done) -> Void in
            println("Transitioned to image \(self.currentImage)")
        }
        
        currentImage!++
    }
    
    func stopGallery() {
        stopped = true
    }
    
    func getDefaultImages() -> [UIImage] {
        var images = [UIImage]()
        
        for i in 1...6 {
            images.append(UIImage(named: "gal\(i).jpg")!)
        }
        
        return images
    }
    
    func blurDefaultImage() {
        if self.image != nil {
            self.image = blurImage(8, image: self.image!)
        }
    }
    
    private func blurImage(amount: Int, image: UIImage) -> UIImage {
        let filter = CIFilter(name: "CIGaussianBlur")
        filter.setDefaults()
        
        let input = CIImage(image: image)
        filter.setValue(input, forKey: kCIInputImageKey)
        filter.setValue(amount, forKey: kCIInputRadiusKey)
        
        let output = filter.outputImage
        let context = CIContext(options: nil)
        let ref = context.createCGImage(output, fromRect: input.extent())
        
        return UIImage(CGImage: ref)!
    }
}
