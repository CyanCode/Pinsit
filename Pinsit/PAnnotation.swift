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
    var title: String?
    var subtitle: String?
    var coord: Coordinate!
    var coordinate: CLLocationCoordinate2D
    var thumbnail: UIImage!
    var allowsDownloading: Bool!
    var isPrivate: Bool!
    var videoURL: NSURL!
    var videoData: NSData!
    var isFriend: NSNumber!
    var dataID: NSString!
    var object: PFObject!
    
    private var viewController: PostDetailsView!
    
    init(coord: CLLocationCoordinate2D) {
        self.coordinate = coord
    }
    
    override init() {
        self.coordinate = CLLocationCoordinate2DMake(0, 0)
    }
    
    ///Posts generated PAnnotation to server
    ///
    ///- parameter vc: DetailsViewController instance responsible for annotation creation
    ///- parameter completion: Called when video has finished attempting to post
    ///- parameter error: Error pointer if an issue occurs, nil if successful
    func postAnnotation(vc: PostDetailsView, completion: (error: NSError?) -> Void) {
        self.viewController = vc
        let ann = PAnnotation()
        
        self.confirmCredentials { (valid) -> Void in
            if valid == true {
                let geoCode = FCCurrentLocationGeocoder.sharedGeocoder()
                
                geoCode.geocode({ (success) -> Void in
                    if success == true {
                        ann.subtitle = vc.descriptionView.text
                        ann.coord = Coordinate(lat: geoCode.location.coordinate.latitude, lon: geoCode.location.coordinate.longitude)
                        ann.allowsDownloading = vc.downloadSwitch.on
                        ann.isPrivate = vc.privateSwitch.on
                        ann.thumbnail = Image().generateThumbnail()
                        ann.videoData = NSData(contentsOfURL: File.getVideoPathURL())
                        
                        let send = ServerSend(ann: ann)
                        send.sendDataWithBlock({ (error) -> Void in completion(error: error) })
                    } else {
                        print("Location Error: \(geoCode.error.localizedDescription)")
                        completion(error: geoCode.error)
                    }
                })
            } else {
                completion(error: NSError(domain: "com.walkerchristie.ConnectionError", code: PFErrorCode.ErrorConnectionFailed.rawValue, userInfo: nil))
            }
        }
        
    }
    
    func confirmCredentials(completion: (valid: Bool) -> Void) {
        self.validPostAmount { (valid) -> Void in
            if valid == false {
                completion(valid: false)
            } else {
                let email = self.confirmEmail()
                let phone = self.confirmNumber()
                
                if email == true && phone == true {
                    completion(valid: true)
                } else {
                    completion(valid: false)
                }
            }
        }
    }
    
    func validPostAmount(completion: (valid: Bool) -> Void) {
        AccountDetails.findPostAmount(PFUser.currentUser()!.username!) { (amount) -> Void in
            if amount != nil {
                if amount!.integerValue >= 3 {
                    self.tooManyPosts()
                    completion(valid: false)
                } else {
                    completion(valid: true)
                }
            } else {
                completion(valid: false)
            }
        }
    }
    
    func confirmEmail() -> Bool {
        if PFUser.currentUser()!["emailVerified"] as! Bool == true {
            return true
        } else {
            self.unverifiedEmailError()
            return false
        }
    }
    
    func confirmNumber() -> Bool {
        let number = PFUser.currentUser()!["phone"] as! String?
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