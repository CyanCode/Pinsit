//
//  NumberVerification.swift
//  Pinsit
//
//  Created by Walker Christie on 7/20/15.
//  Copyright © 2015 Walker Christie. All rights reserved.
//

import Foundation
import UIKit
import Parse
import XLForm

class NumberVerification {
    var responder: UIViewController!
    var form: XLFormDescriptor!
    
    var generatedCode: String!
    var phone: String!
    
    //Textfields
    var numberRow: XLFormRowDescriptor {
        get { return form.formRowWithTag(Tags.PhoneNum.rawValue) }
    }
    var codeRow: XLFormRowDescriptor {
        get { return form.formRowWithTag(Tags.PhoneCode.rawValue) }
    }
    
    //Buttons
    var numButtonRow: XLFormRowDescriptor {
        get { return form.formRowWithTag(Tags.PhoneNumDone.rawValue) }
    }
    var codeButtonRow: XLFormRowDescriptor {
        get { return form.formRowWithTag(Tags.PhoneCodeDone.rawValue) }
    }
    var verifyButtonRow: XLFormRowDescriptor {
        get { return form.formRowWithTag(Tags.Phone.rawValue) }
    }
    
    //Section
    var section: XLFormSectionDescriptor?
    
    init(responder: UIViewController, form: XLFormDescriptor) {
        self.responder = responder
        self.form = form
    }
    
    func startNumberVerification(number: String, done: (success: Bool) -> Void) {
        self.phone = number
        
        PFCloud.callFunctionInBackground("verifyNumber", withParameters: ["number" : number, "verification" : generateCode()], block: { (object, error) -> Void in
            if error == nil {
                done(success: true)
            } else {
                ErrorReport(viewController: self.responder).presentWithType(.Network)
                done(success: false)
            }
        })
    }
    
    func verificationPressed() {
        let controller = UIAlertController(title: "Verify Phone Number", message: "Before you can post videos to Pinsit you must verify your phone number!  You may do so in the form below.", preferredStyle: .Alert)
        controller.addAction(UIAlertAction(title: "Okay", style: .Cancel, handler: nil))
        responder.presentViewController(controller, animated: true, completion: nil)
        
        numberRow.hidden = false
        numButtonRow.hidden = false
    }
    
    func numberEntered() {
        let text = numberRow.value as! String
        startNumberVerification(text) { (success) -> Void in
            if success == true {
                let controller = UIAlertController(title: "Verification Sent!", message: "Your verification code has been sent and will arrive shortly.  Enter the received code below.", preferredStyle: .Alert)
                controller.addAction(UIAlertAction(title: "Okay", style: .Cancel, handler: nil))
                self.responder.presentViewController(controller, animated: true, completion: nil)
                
                self.codeButtonRow.hidden = false
                self.codeRow.hidden = false
            }
            
            self.numberRow.hidden = true
            self.numButtonRow.hidden = true
        }
    }
    
    func codeEntered() {
        let text = codeRow.value as! String
        if text == generatedCode {
            PFUser.currentUser()!["phone"] = phone
            PFUser.currentUser()!.saveEventually({ (success, error) -> Void in })
            
            self.verifyButtonRow.hidden = true
            self.codeButtonRow.hidden = true
            self.codeRow.hidden = true
            if self.section != nil { self.section!.hidden = true }
            
            ErrorReport(viewController: responder).presentError("Success!", message: "Your phone number has been successfully verified, you may now post.", type: .Success)
        } else {
            let controller = UIAlertController(title: "Not Quite..", message: "The code you entered does not match the one we sent you, care to try again?", preferredStyle: .Alert)
            controller.addAction(UIAlertAction(title: "Okay", style: .Cancel, handler: nil))
            controller.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action) -> Void in
                self.codeButtonRow.hidden = true
                self.codeRow.hidden = true
            }))
            responder.presentViewController(controller, animated: true, completion: nil)
        }
    }
    
    private func generateCode() -> String {
        let alphabet = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let generation: NSMutableString = "";
        
        for _ in 1...5 {
            var random = Int(arc4random())
            random %= alphabet.characters.count
            
            let c = Array(alphabet.characters)[random]
            generation.appendString(String(c))
        }
        
        let query = PFQuery(className: "Verification")
        query.whereKey("verificationCode", equalTo: generation)
        let total = query.countObjects()
        
        if (total > 0) {
            return generateCode()
        } else {
            self.generatedCode = generation as String
            return generation as String
        }
    }
}