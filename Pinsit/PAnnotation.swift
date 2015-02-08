//
//  PAnnotation.swift
//  Pinit
//
//  Created by Walker Christie on 9/19/14.
//  Copyright (c) 2014 Walker Christie. All rights reserved.
//

import Foundation
import MapKit

class PAnnotation: NSObject, MKAnnotation {
    var title: NSString!
    var subtitle: NSString!
    var coord: Coordinate!
    var coordinate: CLLocationCoordinate2D
    var thumbnail: UIImage!
    var allowsDownloading: Bool!
    var videoURL: NSURL!
    var videoData: NSData!
    var isFriend: NSNumber!
    var dataID: NSString!
    
    init(coord: CLLocationCoordinate2D) {
        self.coordinate = coord
    }
    
    override init() {
        self.coordinate = CLLocationCoordinate2DMake(0, 0)
    }
    
    class func constructAnnotation(vc: DetailsViewController) {
        var ann = PAnnotation()
        let loc = INTULocationManager.sharedInstance()
        
        loc.requestLocationWithDesiredAccuracy(INTULocationAccuracy.House, timeout: 5) { (location, accuracy, status) -> Void in
            if status == INTULocationStatus.Success || status == INTULocationStatus.TimedOut {
                ann.subtitle = vc.descriptionView.text
                ann.coord = Coordinate(lat: location.coordinate.latitude, lon: location.coordinate.longitude)
                ann.allowsDownloading = vc.downloadToggle.on
                ann.thumbnail = vc.thumbnail
                ann.videoData = NSData(contentsOfURL: RecordingProgress.videoLocation())
                
                let send = ServerSend(ann: ann, vc: vc)
                send.sendDataAsync()
            } else {
                let alert = Coordinate.locationError()
                alert.addAction(UIAlertAction(title: "Try Again", style: .Default, handler: { (action) in
                    PAnnotation.constructAnnotation(vc) }))
                vc.presentViewController(alert, animated: true, completion: nil)
            }
        }
    }
}