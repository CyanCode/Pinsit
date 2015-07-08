//
//  Report.swift
//  Pinsit
//
//  Created by Walker Christie on 2/15/15.
//  Copyright (c) 2015 Walker Christie. All rights reserved.
//

import Foundation

class Report {
    var reportSender: String!
    var reportedUser: String!
    var videoId: String!
    private var videoObject: PFObject!
    
    init(reportSender: String, reportedUser: String, videoId: String) {
        self.reportSender = reportSender
        self.reportedUser = reportedUser
        self.videoId = videoId
    }
    
    ///Find the reported video PFObject in the database
    ///
    ///- parameter completion: Called when PFObject has been found, nil if not.
    func findVideoObject(completion: (object: PFObject?) -> Void) {
        let query = PFQuery(className: "SentData")
        query.whereKey("objectId", equalTo: self.videoId)
        
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error != nil {
                completion(object: nil)
            } else if (objects!).count > 0 {
                completion(object: objects![0] as? PFObject)
            } else {
                completion(object: nil)
            }
        }
    }
}