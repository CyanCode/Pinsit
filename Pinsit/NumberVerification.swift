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

class NumberVerification {
    var responder: UIViewController!
    var manager: MoreManager!
    var moreVc: MoreTableViewController {
        get {
            return manager.moreVc
        }
    }
    
    var generatedCode: String!
    var phone: String!
    
    init(responder: UIViewController, manager: MoreManager) {
        self.responder = responder
        self.manager = manager
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
        
        moreVc.cell(moreVc.phoneNumberEntryCell, setHidden: false)
        moreVc.cell(moreVc.sendTextCell, setHidden: false)
        moreVc.reloadDataAnimated(true)
    }
    
    func numberEntered() {
        let text = moreVc.phoneNumberField.text!
        startNumberVerification(text) { (success) -> Void in
            if success == true {
                let controller = UIAlertController(title: "Verification Sent!", message: "Your verification code has been sent to \(text) and will arrive shortly.  Enter the received code below.", preferredStyle: .Alert)
                controller.addAction(UIAlertAction(title: "Okay", style: .Cancel, handler: nil))
                self.responder.presentViewController(controller, animated: true, completion: nil)
                
                self.moreVc.cell(self.moreVc.receivedCodeCell, setHidden: false)
                self.moreVc.cell(self.moreVc.checkCodeCell, setHidden: false)
            }
            
            self.moreVc.cell(self.moreVc.phoneNumberEntryCell, setHidden: true)
            self.moreVc.cell(self.moreVc.sendTextCell, setHidden: true)
            self.moreVc.reloadDataAnimated(true)
        }
    }
    
    func codeEntered() {
        let text = moreVc.receivedCodeField.text!
        if text == generatedCode {
            PFUser.currentUser()!["phone"] = phone
            PFUser.currentUser()!.saveEventually({ (success, error) -> Void in })
            
            moreVc.cell(moreVc.checkCodeCell, setHidden: true)
            moreVc.cell(moreVc.receivedCodeCell, setHidden: true)
            moreVc.cell(moreVc.verifyPhoneCell, setHidden: true)
            
            ErrorReport(viewController: responder).presentError("Success!", message: "Your phone number has been successfully verified!", type: .Success)
        } else {
            let controller = UIAlertController(title: "Not Quite..", message: "The code you entered does not match the one we sent you, care to try again?", preferredStyle: .Alert)
            controller.addAction(UIAlertAction(title: "Okay", style: .Cancel, handler: nil))
            controller.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action) -> Void in
                self.moreVc.cell(self.moreVc.receivedCodeCell, setHidden: true)
                self.moreVc.cell(self.moreVc.checkCodeCell, setHidden: true)
            }))
            
            responder.presentViewController(controller, animated: true, completion: nil)
        }
        
        moreVc.reloadDataAnimated(true)
    }
    
    private func generateCode() -> String {
        let alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let generation: NSMutableString = "";
        
        for _ in 1...5 {
            let random = 0 + Int(arc4random_uniform(UInt32(count(alphabet) + 1)))
            let c = Array(alphabet)[random]
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