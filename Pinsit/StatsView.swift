//
//  StatsView.swift
//  Pinsit
//
//  Created by Walker Christie on 11/10/14.
//  Copyright (c) 2014 Walker Christie. All rights reserved.
//

import UIKit

class StatsView: UIView {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.backgroundColor = UIColor.whiteColor()
        self.layer.masksToBounds = false
        self.layer.cornerRadius = 3
        self.layer.borderWidth = 0.5
        self.layer.borderColor = UIColor(string: "#E6E5E7").CGColor
        self.layer.shadowOffset = CGSizeMake(0.5, 0.5)
        self.layer.shadowRadius = 1
        self.layer.shadowOpacity = 0.7
        self.layer.shadowColor = UIColor.blackColor().CGColor
    }
}
