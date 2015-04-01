//
//  FormTextField.swift
//  Pinsit
//
//  Created by Walker Christie on 1/11/15.
//  Copyright (c) 2015 Walker Christie. All rights reserved.
//

import UIKit

class FormTextField: UITextField {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let color = UIColor.whiteColor()
        self.attributedPlaceholder = NSAttributedString(string: self.placeholder!, attributes: [NSForegroundColorAttributeName : color])
        self.layer.cornerRadius = 8
        self.layer.masksToBounds = true
        self.layer.borderColor = UIColor.whiteColor().CGColor
        self.layer.borderWidth = 1
    }
}
