//
//  TextLimitTextField.swift
//  Pinsit
//
//  Created by Walker Christie on 8/21/15.
//  Copyright (c) 2015 Walker Christie. All rights reserved.
//

import Foundation

@IBDesignable class TextLimitTextField: UITextField, UITextFieldDelegate {
    @IBOutlet var limitLabel: UILabel!
    @IBInspectable var correctLengthColor: UIColor = UIColor.grayColor()
    @IBInspectable var incorrectLengthColor: UIColor = UIColor.redColor()
    @IBInspectable var characterLimit: Int = 200
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if range.length + range.location > count(textField.text) {
            return false
        }
        
        let length = count(textField.text) + count(string) - range.length
        limitLabel.text = "\(characterLimit - length)"
        
        if length > characterLimit {
            limitLabel.textColor = incorrectLengthColor
        } else {
            limitLabel.textColor = correctLengthColor
        }
        
        return true
    }
}