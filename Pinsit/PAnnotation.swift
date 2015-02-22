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
    
    private var viewController: PostDetailsView!
    
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
    func postAnnotation(vc: PostDetailsView, completion: (error: NSError?) -> Void) {
        self.viewController = vc
        var ann = PAnnotation()
        
        self.confirmCredentials { (valid, error) -> Void in
            if error != nil {
                completion(error: error)
            } else if valid == true {
                INTULocationManager.sharedInstance().requestLocationWithDesiredAccuracy(.Block, timeout: 5) { (location, accuracy, status) -> Void in
                    if status == .Success || status == .TimedOut {
                        ann.subtitle = vc.descriptionView.text
                        ann.coord = Coordinate(lat: location.coordinate.latitude, lon: location.coordinate.longitude)
                        ann.allowsDownloading = vc.downloadSwitch.on
                        ann.thumbnail = Image().generateThumbnail()
                        ann.videoData = NSData(contentsOfURL: RecordingProgress.videoLocation())
                        
                        let send = ServerSend(ann: ann)
                        send.sendDataWithBlock({ (error) -> Void in
                            completion(error: error)
                        })
                    } else {
                        let error = PError()
                        completion(error: error.constructErrorWithCode(1004))
                    }
                }
            }
        }
        
    }
    
    func confirmCredentials(completion: (valid: Bool, error: NSError?) -> Void) {
        self.validPostAmount { (valid, error) -> Void in
            if error != nil {
                completion(valid: false, error: error)
            } else {
                let email = self.confirmEmail()
                let phone = self.confirmNumber()
                
                if email == false || phone == false {
                    completion(valid: false, error: nil)
                } else {
                    completion(valid: true, error: nil)
                }
            }
        }
    }
    
    func validPostAmount(completion: (valid: Bool, error: NSError?) -> Void) {
        PFUser.currentUser().fetchInBackgroundWithBlock { (object, error) -> Void in
            if error != nil {
                completion(valid: false, error: error)
            } else {
                let amt = object["postAmount"] as NSNumber
                
                if amt.integerValue >= 3 {
                    self.tooManyPosts()
                    completion(valid: false, error: nil)
                } else {
                    completion(valid: true, error: nil)
                }
            }
        }
    }
    
    func confirmEmail() -> Bool {
        if PFUser.currentUser()["emailVerified"] as Bool == true {
            return true
        } else {
            self.unverifiedEmailError()
            return false
        }
    }
    
    func confirmNumber() -> Bool {
        let number = PFUser.currentUser()["phone"] as String?
        if number == nil || number == "" {
            unverifiedNumber()
            return false
        } else {
            return true
        }
    }
    
    ///MARK: Posting errors
    func unverifiedEmailError() {
        let controller = UIAlertController(title: "Not So Fast", message: "Your email address has not been verified yet!  You can verify it in the Settings tab.", preferredStyle: .Alert)
        controller.addAction(UIAlertAction(title: "Okay", style: .Cancel, handler: nil))
        self.viewController.responder.presentViewController(controller, animated: true, completion: nil)
    }
    
    func tooManyPosts() {
        let controller = UIAlertController(title: "Slow Down There!", message: "It looks like you've already posted three videos within the last 24 hours, wait a bit and try again later.", preferredStyle: .Alert)
        controller.addAction(UIAlertAction(title: "Okay", style: .Cancel, handler: nil))
        self.viewController.responder.presentViewController(controller, animated: true, completion: nil)
    }
    
    func unverifiedNumber() {
        let controller = UIAlertController(title: "Something's Missing..", message: "Your phone number has not been verified!  Head over to the Settings tab to verify your number.", preferredStyle: .Alert)
        controller.addAction(UIAlertAction(title: "Okay", style: .Cancel, handler: nil))
    }
}