//
//  KeyboardManager.swift
//  Pinsit
//
//  Created by Walker Christie on 10/30/14.
//  Copyright (c) 2014 Walker Christie. All rights reserved.
//

import Foundation
import UIKit

///Manages view animation when keyboard is activated
class KeyboardManager: NSObject, UITextViewDelegate {
    var adjustedViewController: UIViewController!
    var swipedUp: Bool!
    var keyboardFrame: CGRect!
    let slideDur = 0.3
    
    init(controller: UIViewController) {
        adjustedViewController = controller
        swipedUp = false
        keyboardFrame = CGRectMake(0, 0, 0, 216)
        
        super.init()
        
        //Register Keyboard notifications
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
        //Register swipe notifications
        var recognizer = UISwipeGestureRecognizer(target: self, action: "handleSwipeDown:")
        recognizer.direction = UISwipeGestureRecognizerDirection.Down
        adjustedViewController.view.addGestureRecognizer(recognizer)
    }
    
    @objc func handleSwipeDown(gesture: UITapGestureRecognizer) {
        if swipedUp == true {
            toggleViewMoving(false, frame: keyboardFrame)
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let info = notification.userInfo {
            keyboardFrame = (info[UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue()
        }
        
        toggleViewMoving(true, frame: keyboardFrame)
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let info = notification.userInfo {
            keyboardFrame = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        }
        
        toggleViewMoving(false, frame: keyboardFrame)
    }
    
    private func toggleViewMoving(moveUp: Bool, frame: CGRect) {
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(slideDur)
        
        var rect = adjustedViewController.view.frame
        
        if (moveUp) {
            rect.origin.y -= frame.height
            rect.size.height += frame.height
            swipedUp = true
        } else {
            rect.origin.y += frame.height
            rect.origin.y -= frame.height
            swipedUp = false
        }
        
        UIView.commitAnimations()
    }
}