//
//  UIVerticalAlignLabel.swift
//  Pinsit
//
//  Created by Walker Christie on 8/21/15.
//  Copyright (c) 2015 Walker Christie. All rights reserved.
//

import Foundation
import UIKit

class UIVerticalAlignLabel: UILabel {
    
    enum VerticalAlignment : Int {
        case VerticalAlignmentTop = 0
        case VerticalAlignmentMiddle = 1
        case VerticalAlignmentBottom = 2
    }
    
    var verticalAlignment : VerticalAlignment = .VerticalAlignmentTop {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func textRectForBounds(bounds: CGRect, limitedToNumberOfLines: Int) -> CGRect {
        let rect = super.textRectForBounds(bounds, limitedToNumberOfLines: limitedToNumberOfLines)
        
        switch(verticalAlignment) {
        case .VerticalAlignmentTop:
            return CGRectMake(bounds.origin.x, bounds.origin.y, rect.size.width, rect.size.height)
        case .VerticalAlignmentMiddle:
            return CGRectMake(bounds.origin.x, bounds.origin.y + (bounds.size.height - rect.size.height) / 2, rect.size.width, rect.size.height)
        case .VerticalAlignmentBottom:
            return CGRectMake(bounds.origin.x, bounds.origin.y + (bounds.size.height - rect.size.height), rect.size.width, rect.size.height)
        default:
            return bounds
        }
    }
    
    override func drawTextInRect(rect: CGRect) {
        let r = self.textRectForBounds(rect, limitedToNumberOfLines: self.numberOfLines)
        super.drawTextInRect(r)
    }
}
