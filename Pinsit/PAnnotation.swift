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
    
    ///Posts generated PAnnotation to server
    ///
    ///:param: vc DetailsViewController instance responsible for annotation creation
    ///:param: completion Called when video has finished attempting to post
    ///:param: error Error pointer if an issue occurs, nil if successful
    class func postAnnotation(vc: DetailsViewController, completion: (error: NSError?) -> Void) {
        var ann = PAnnotation()
        
        INTULocationManager.sharedInstance().requestLocationWithDesiredAccuracy(.House, timeout: 5) { (location, accuracy, status) -> Void in
            if status == .Success {
                ann.subtitle = vc.descriptionView.text
                ann.coord = Coordinate(lat: location.coordinate.latitude, lon: location.coordinate.longitude)
                ann.allowsDownloading = vc.downloadToggle.on
                ann.thumbnail = vc.thumbnail
                ann.videoData = NSData(contentsOfURL: RecordingProgress.videoLocation())
                
                let send = ServerSend(ann: ann, vc: vc)
                send.sendDataWithBlock({ (error) -> Void in
                    completion(error: error)
                })
            } else {
                let error = PError()
                completion(error: error.constructErrorWithCode(1004))
            }
        }
    }
    
    ///MARK: Posting errors
    class func unverifiedEmailError() -> UIAlertController {
        let controller = UIAlertController(title: "Not So Fast", message: "Your email address is not verified, would you like us to resend your verification email?", preferredStyle: .Alert)
        controller.addAction(UIAlertAction(title: "Nope", style: .Cancel, handler: nil))
        controller.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { (action) -> Void in
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                let send = Email()
                send.resendVerification({ (error) -> Void in
                    if error != nil {
                        println("Sending error")
                    }
                })
            })
        }))
        
        return controller
    }
}