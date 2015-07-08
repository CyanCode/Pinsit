//
//  ZoomMap.swift
//  Pinsit
//
//  Created by Walker Christie on 12/22/14.
//  Copyright (c) 2014 Walker Christie. All rights reserved.
//

import Foundation
import MapKit
import CoreLocation

class ZoomMap: NSObject, MKMapViewDelegate, CLLocationManagerDelegate {
    var map: MKMapView!
    var currentlyBlurred: Bool!
    private var location: CLLocationManager!
    private var cover: UIView!
    private var covered: Bool!
    
    ///Initializes Map view with or without view covering
    init(map: MKMapView, covered: Bool) {
        super.init()
        
        self.currentlyBlurred = false
        self.map = map
        self.covered = covered
        map.userInteractionEnabled = false
        map.delegate = self
    }
    
    ///Zoom the map to the user's current location
    func zoomToCurrentLocation() {
        if (covered == true) {
            coverMap()
        }
        
        location = CLLocationManager()
        location.delegate = self
        location.distanceFilter = kCLDistanceFilterNone
        location.desiredAccuracy = kCLLocationAccuracyHundredMeters
        
        if (self.location.respondsToSelector("requestWhenInUseAuthorization")) {
            self.location.requestWhenInUseAuthorization()
        }
        
        location.startMonitoringSignificantLocationChanges()
        location.startUpdatingLocation()
    }
    
    private func coverMap() {
        cover = UIView(frame: map.bounds)
        cover.backgroundColor = UIColor.whiteColor()
        cover.alpha = 0.6
        
        map.insertSubview(cover, aboveSubview: map)
    }
    
    ///MARK: Location Stuff
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last! as CLLocation
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegionMake(location.coordinate, span)
        
        map.setRegion(region, animated: true)
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.NotDetermined && manager.respondsToSelector("requestAlwaysAuthorization") {
            manager.requestAlwaysAuthorization()
        }
    }
}