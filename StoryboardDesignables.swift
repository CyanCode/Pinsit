//
//  StoryboardDesignables.swift
//  Pinsit
//
//  Created by Walker Christie on 8/19/15.
//  Copyright (c) 2015 Walker Christie. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable class ExtendedButton: UIButton {
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
            self.layer.masksToBounds = true
        }
    }
    @IBInspectable var borderColor: UIColor = UIColor.whiteColor() {
        didSet {
            self.layer.borderColor = borderColor.CGColor
        }
    }
    @IBInspectable var borderWidth: CGFloat = 0.0 {
        didSet {
            self.layer.borderWidth = borderWidth
        }
    }
    @IBInspectable var imageTint: UIColor? {
        didSet {
            let img = self.imageView?.image?.imageWithRenderingMode(.AlwaysTemplate)
            self.setImage(img, forState: .Normal)
            self.tintColor = imageTint!
            self.imageView?.tintColor = imageTint
        }
    }
}

@IBDesignable class RegistrationViewDesign: UIView {
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
            self.layer.masksToBounds = true
        }
    }
    @IBInspectable var borderColor: UIColor = UIColor.whiteColor() {
        didSet {
            self.layer.borderColor = borderColor.CGColor
        }
    }
    @IBInspectable var borderWidth: CGFloat = 0.0 {
        didSet {
            self.layer.borderWidth = borderWidth
        }
    }
}

@IBDesignable class BlurredImageView: UIImageView {
    @IBInspectable var blurAmount: Int = 7
    @IBInspectable var blurView: Bool = true {
        didSet {
            if blurView && image != nil {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
                    let blurred = self.blurImage(self.blurAmount, image: self.image!)
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.image = blurred
                    })
                })
            }
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