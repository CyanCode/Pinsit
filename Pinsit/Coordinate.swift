//
//  Coordinate.swift
//  Pinsit
//
//  Created by Walker Christie on 9/23/14.
//  Copyright (c) 2014 Walker Christie. All rights reserved.
//

import Foundation
import MapKit

class Coordinate {
    var latitude: Double
    var longitude: Double
    private var responder: UIViewController!
    
    init(lat: Double, lon: Double) {
        self.latitude = lat
        self.longitude = lon
    }
    
    init(responder: UIViewController) {
        self.responder = responder
        self.latitude = 0
        self.longitude = 0
    }
    
    init() {
        self.latitude = 0
        self.longitude = 0
    }
    
    class func locationError() -> UIAlertController {
        let alertView = UIAlertController(title: "My Bad", message: "We ran into an issue while publishing your video, care to try again?", preferredStyle: UIAlertControllerStyle.Alert)
        let cancel = UIAlertAction(title: "No Thanks", style: .Cancel, handler: nil)
        alertView.addAction(cancel)
        
        return alertView
    }
    
    
}