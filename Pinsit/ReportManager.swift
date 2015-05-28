//
//  PFReport.swift
//  Pinsit
//
//  Created by Walker Christie on 4/18/15.
//  Copyright (c) 2015 Walker Christie. All rights reserved.
//

import Foundation
import UIKit

class ReportManager {
    var videoObject: PFObject!
    var responder: UIViewController!
    
    init(videoObject: PFObject, responder: UIViewController) {
        self.videoObject = videoObject
        self.responder = responder
    }
    
    func reportExistsAlready(completion: (Bool) -> Void) {
        let query = PFQuery(className: "Reports")
        query.whereKey("videoId", equalTo: videoObject!.objectId!)
        
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error != nil || count(objects!) > 0 {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    func userAlreadyReported(completion: (Bool) -> Void) {
        let query = PFQuery(className: "Reports")
        query.whereKey("reporters", equalTo: PFUser.currentUser()!.username!)
        
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error != nil {
                self.reportFailedMessage()
            } else if count(objects!) > 0 {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    func reportCanBeSent(completion: (sendable: Bool, incrementable: Bool) -> Void) {
        self.reportExistsAlready { (exists) -> Void in
            if exists == false {
                completion(sendable: true, incrementable: false)
            } else {
                self.userAlreadyReported({ (reported) -> Void in
                    if reported == true {
                        completion(sendable: false, incrementable: false)
                    } else {
                        completion(sendable: false, incrementable: true)
                    }
                })
            }
        }
    }
    
    func sendNewReport() {
        let object = PFObject(className: "Reports")
        object["videoId"] = videoObject.objectId
        object["video"] = videoObject["video"] as! PFFile
        object["reportAmt"] = NSNumber(int: 1)
        object["reporters"] = ["\(PFUser.currentUser()!.username!)"]
        object["reportedUser"] = videoObject["username"] as! String
        object["location"] = videoObject["location"] as! PFGeoPoint
        
        object.saveInBackgroundWithBlock { (success, error) -> Void in
            if success == true {
                self.reportedUserMessage()
            } else {
                self.reportFailedMessage()
            }
        }
    }
    
    func incrementReport() {
        let query = PFQuery(className: "Reports")
        query.whereKey("videoId", equalTo: videoObject.objectId!)
        
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error != nil || count(objects!) <= 0 {
                self.reportFailedMessage()
            } else {
                let object = objects![0] as! PFObject
                object.incrementKey("reportAmt")
                object.addUniqueObject(PFUser.currentUser()!.username!, forKey: "reporters")
                
                object.saveInBackgroundWithBlock({ (success, error) -> Void in
                    if success != true {
                        self.reportFailedMessage()
                    } else {
                        self.reportedUserMessage()
                    }
                })
            }
        }
    }
    
    func reportedUserMessage() {
        let controller = UIAlertController(title: "Done", message: "Thank you for your report, it has been submitted and will be reviewed shortly.", preferredStyle: .Alert)
        controller.addAction(UIAlertAction(title: "Okay", style: .Cancel, handler: nil))
        responder.presentViewController(controller, animated: true, completion: nil)
    }
    
    private func reportFailedMessage() {
        let controller = UIAlertController(title: "Report Failed", message: "We were unable to process and save your report, feel free to try again.", preferredStyle: .Alert)
        controller.addAction(UIAlertAction(title: "Okay", style: .Cancel, handler: nil))
        responder.presentViewController(controller, animated: true, completion: nil)
    }
}