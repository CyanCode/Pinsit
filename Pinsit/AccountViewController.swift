//
//  AccountViewController.swift
//  Pinsit
//
//  Created by Walker Christie on 11/8/14.
//  Copyright (c) 2014 Walker Christie. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class AccountViewController: UIViewController, UIGestureRecognizerDelegate {
    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var map: MKMapView!
    @IBOutlet var karmaLabel: UILabel!
    @IBOutlet var followingLabel: UILabel!
    @IBOutlet var postAmountLabel: UILabel!
    @IBOutlet var usernameLabel: UILabel!
    var locationManager: CLLocationManager!
    var detailManager: AccountDetails!
    
    override func viewDidLoad() {
        self.detailManager = AccountDetails(viewController: self)
        
        super.viewDidLoad()
        AppDelegate.loginCheck(self)

        map.userInteractionEnabled = false
        loadInformation()
        toggleHiddenLabels(true)
        readyButtons()
        startLocating()
        prepareInterface()
    }
    
    override func viewDidAppear(animated: Bool) {
        AppDelegate.loginCheck(self)
    }
    
    override func viewDidLayoutSubviews() {
        //        let cover = UIVisualEffectView(effect: UIBlurEffect(style: .Light))
        //        cover.frame = map.frame
        //        map.addSubview(cover)
    }
    
    func toggleHiddenLabels(hidden: Bool) {
        for label in [followingLabel, karmaLabel, postAmountLabel] {
            label.hidden = hidden
        }
    }
    
    func readyButtons() {
        for label in [followingLabel, karmaLabel, postAmountLabel] {
            label.backgroundColor = UIColor(red: 255/255, green: 41/255, blue: 81/255, alpha: 1)
            label.layer.cornerRadius = 3
            label.textColor = UIColor.whiteColor()
            label.layer.masksToBounds = true
            self.view.sendSubviewToBack(label)
        }
    }
    
    func prepareInterface() {
        profileImage.image = detailManager.loadImage()
        profileImage.layer.masksToBounds = true
        profileImage.layer.cornerRadius = 3
        profileImage.layer.borderWidth = 1
        profileImage.layer.borderColor = UIColor(string: "#FF2951").CGColor
        profileImage.alpha = 1.0
        
        var imageTap = UITapGestureRecognizer(target: self, action: Selector("profileTapped:"))
        profileImage.userInteractionEnabled = true
        profileImage.addGestureRecognizer(imageTap)
    }
    
    func loadInformation() {
        self.usernameLabel.text = PFUser.currentUser().username
        let progress = JGProgressHUD(style: .Dark)
        progress.textLabel.text = "Loading"
        progress.showInView(self.view, animated: true)
        self.view.bringSubviewToFront(progress)
        
        detailManager.setAccountDetails { () -> Void in
            progress.dismiss()
            self.toggleHiddenLabels(false)
        }
    }
    
    func startLocating() {
        INTULocationManager.sharedInstance().requestLocationWithDesiredAccuracy(.House, timeout: 5) { (location, accuracy, status) -> Void in
            let span = MKCoordinateSpanMake(0.05, 0.05)
            let region = MKCoordinateRegionMake(location.coordinate, span)
            self.map.setRegion(region, animated: true)
        }
    }
    
    func profileTapped(gesture: UITapGestureRecognizer) {
        
    }
}
