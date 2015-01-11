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
class MapResponder: NSObject, MKMapViewDelegate, MKAnnotation {
    var viewControl: MapControl
    var coordinate: CLLocationCoordinate2D
    
    init(mapCtrl: MapControl, coord: CLLocationCoordinate2D) {
        self.viewControl = mapCtrl
        self.coordinate = coord
    }
    
    init(mapCtrl: MapControl) {
        self.viewControl = mapCtrl
        self.coordinate = CLLocationCoordinate2DMake(0, 0)
    }
    
    func mapViewDidFailLoadingMap(mapView: MKMapView!, withError error: NSError!) {
        println("Error loading map")
    }
    
    func mapView(mapView: MKMapView!, didFailToLocateUserWithError error: NSError!) {
        println("Error finding current location 😰")
    }
    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
        var pointAnn = view.annotation as PAnnotation?
        let writer = ListWriter(annotation: pointAnn!)
        
        
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        let identifier = "CustomAnnotation"
        let annView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        
        if (annotation.isKindOfClass(PAnnotation)) {
            let pointAnn = annotation as PAnnotation?
            var returnedImg = UIImage()
            
            if (pointAnn != nil) {
                returnedImg = pointAnn!.thumbnail
            }
            
            let style = Styling(manipulate: UIButton())
            var pushButton = style.encircleButton(returnedImg)
            
            annView.draggable = false
            annView.canShowCallout = true
            annView.leftCalloutAccessoryView = pushButton
        } else {
            annView.annotation = annotation
        }
        
        return annView
    }
}