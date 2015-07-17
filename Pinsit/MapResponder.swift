//
//  MapResponder.swift
//  Pinsit
//
//  Created by Walker Christie on 10/13/14.
//  Copyright (c) 2014 Walker Christie. All rights reserved.
//

import Foundation
import MapKit
import UIKit

///MapViewController MKMapViewDelegate responder class
class MapResponder: NSObject, MKMapViewDelegate, MKAnnotation, UIGestureRecognizerDelegate {
    var viewControl: MapControl
    var coordinate: CLLocationCoordinate2D
    var followerCache = FollowerCache()
    
    init(mapCtrl: MapControl, coord: CLLocationCoordinate2D) {
        followerCache.updateCache()
        self.viewControl = mapCtrl
        self.coordinate = coord
    }
    
    init(mapCtrl: MapControl) {
        followerCache.updateCache()
        self.viewControl = mapCtrl
        self.coordinate = CLLocationCoordinate2DMake(0, 0)
    }
    
    ///MARK: Delegate methods
    func mapViewDidFailLoadingMap(mapView: MKMapView, withError error: NSError) {
        print("Error loading map")
    }
    
    func mapView(mapView: MKMapView, didFailToLocateUserWithError error: NSError) {
        print("Error finding current location 😰")
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let ann = view.annotation as! PAnnotation
        viewControl.currentMap.performSegueWithIdentifier("video", sender: ann)
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "CustomAnnotation"
        let annView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        
        if (annotation.isKindOfClass(PAnnotation)) {
            let pointAnn = annotation as! PAnnotation
            var returnedImg = UIImage()
            
            pointAnn.subtitle = ""
            
            returnedImg = pointAnn.thumbnail
            
            let following = followerCache.isFollowing(pointAnn.title! as String)
            annView.pinColor = following ? .Green : .Red //If user is following, make pin green
            
            let style = Styling(manipulate: UIButton())
            let pushButton = style.encircleButton(returnedImg)
            
            annView.draggable = false
            annView.canShowCallout = true
            annView.leftCalloutAccessoryView = pushButton
        } else {
            annView.annotation = annotation
        }
        
        return annView
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    ///MARK: Responder
    func mapTapped(tap: UITapGestureRecognizer) {
        self.viewControl.currentMap.toggleToolbar()
    }
    
    ///MARK: Methods
    func removeAnnotations() {
        let map = self.viewControl.currentMap.mapView
        map.removeAnnotations(map.annotations)
    }
    
    func zoomCurrentLocation() {
        INTULocationManager.sharedInstance().requestLocationWithDesiredAccuracy(.House, timeout: 5) { (location, accuracy, status) -> Void in
            if status != .Error {
                let region = MKCoordinateRegionMake(location.coordinate, MKCoordinateSpanMake(0.05, 0.05))
                self.viewControl.currentMap.mapView.setRegion(region, animated: true)
            } else {
                print("Location error")
            }
        }
    }
}