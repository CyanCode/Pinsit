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