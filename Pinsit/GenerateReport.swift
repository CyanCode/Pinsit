//
//  GenerateReport.swift
//  Pinsit
//
//  Created by Walker Christie on 2/15/15.
//  Copyright (c) 2015 Walker Christie. All rights reserved.
//

import Foundation

class GenerateReport {
    var viewController: UIViewController!
    var reportedUser: String!
    var videoId: String!

    init(viewController: UIViewController, reportedUser: String, videoId: String!) {
        self.viewController = viewController
        self.reportedUser = reportedUser
        self.videoId = videoId
    }
    
    ///Ask user if they /really/ want to report this user
    ///
    ///:param: answer Did the user select Yes or No?
    func presentPrompt(completion: (answer: Bool) -> Void) {
        let controller = UIAlertController(title: "Report User", message: "Are you sure you would like to report user?  Sending false reports can have negative consequences.", preferredStyle: .Alert)
        controller.addAction(UIAlertAction(title: "Nevermind", style: .Cancel, handler: { (action) -> Void in
            completion(answer: false)
        }))
        controller.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { (action) -> Void in
            completion(answer: true)
        }))
        self.viewController.presentViewController(controller, animated: true, completion: nil)
    }
    
    ///Create Report object from init information
    ///
    ///:returns: Newly created report object
    func createReportObject() -> Report {
        let reportSender = PFUser.currentUser().username
        
        return Report(reportSender: reportSender, reportedUser: reportedUser, videoId: videoId)
    }
    
    ///Report user in background with completion block
    ///
    ///:param: report Report object, use 'createReportObject' to generate
    ///:param: completion Called when report has finished, error nil if successful
    func reportUserInBackground(report: Report, completion: (error: NSError?) -> Void) {
        report.findVideoObject { (object) -> Void in
            if object == nil {
                completion(error: NSError())
            }
            
            var reportObject = PFObject(className: "Reports")
            reportObject["location"] = object!["location"]
            reportObject["video"] = object!["video"]
            reportObject["reportedUser"] = report.reportSender
            reportObject["reporter"] = report.reportSender
            reportObject.incrementKey("reportAmt")
            
            reportObject.saveInBackgroundWithBlock({ (success, error) -> Void in
                if error != nil {
                    completion(error: error)
                } else {
                    completion(error: nil)
                }
            })
        }
    }
    
    ///Check whether a report exists or not
    ///
    ///:param: increment Increment the PFObject if it does in fact exist
    ///:param: completion Called when check has finished
    func reportAlreadyFiled(increment: Bool, completion: (exists: Bool) -> Void) {
        let query = PFQuery(className: "Reports")
        query.whereKey("reportedUser", equalTo: self.reportedUser)
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error != nil { completion(exists: false) } //If an error was thrown
            
            if countElements(objects) < 1 { //Less than one PFObject exists
                completion(exists: false)
            } else if increment == false { //Does exist, but don't increment
                completion(exists: true)
            } else {
                objects[0].incrementKey("reportAmt")
                objects[0].saveInBackgroundWithBlock({ (success, error) -> Void in
                    completion(exists: true)
                })
            }
        }
    }
}