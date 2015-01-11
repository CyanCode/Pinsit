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

class AccountViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate {
    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var map: MKMapView!
    @IBOutlet var karmaLabel: UILabel!
    @IBOutlet var followingLabel: UILabel!
    @IBOutlet var followersLabel: UILabel!
    var locationManager: CLLocationManager!
    
    override func viewDidLoad() {
        prepareInterface()
        Styling.patternView(self.view)
        
        super.viewDidLoad()
        
        map.delegate = self
        map.userInteractionEnabled = false
        startLocating()
    }
    
    func prepareInterface() {
        let details = AccountDetails()
        profileImage.image = details.loadImage()
        profileImage.layer.masksToBounds = true
        profileImage.layer.cornerRadius = 3
        profileImage.layer.borderWidth = 1
        profileImage.layer.borderColor = UIColor(string: "#E6E5E7").CGColor
        profileImage.alpha = 1.0
        
        var imageTap = UITapGestureRecognizer(target: self, action: Selector("profileTapped:"))
        imageTap.numberOfTapsRequired = 1
        profileImage.userInteractionEnabled = true
        profileImage.addGestureRecognizer(imageTap)
    }
    
    func startLocating() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        let location = locations.last as CLLocation
        
        //.05 = all of nahant
        //.005 = our street
        var span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        var region = MKCoordinateRegionMake(location.coordinate, span)
        map.setRegion(region, animated: true)
    }
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.NotDetermined && manager.respondsToSelector("requestAlwaysAuthorization") {
            manager.requestAlwaysAuthorization()
        }
    }
    
    //MARK: Toggle Menu
    func addGesture() {
        var edge = UIScreenEdgePanGestureRecognizer(target: self, action: "toggleMenu:")
        edge.edges = UIRectEdge.Right
        edge.delegate = self
        self.view.addGestureRecognizer(edge)
    }
    
    func toggleMenu(sender: UIGestureRecognizer) {
        let control = tabBarController
        (tabBarController as SidebarController).sidebar.showInViewController(self, animated: true)
    }
}
