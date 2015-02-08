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
    
    var yPos: CGFloat!
    func mapTapped(tap: UITapGestureRecognizer) {
        let toolbar = self.viewControl.currentMap.toolbar
        
        if toolbar.hidden == true {
            yPos = 0.0
            toolbar.hidden = false
        } else {
            yPos = -77.0
        }
        
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            toolbar.frame = CGRectMake(0, self.yPos, toolbar.frame.width, toolbar.frame.height)
            }) { (finished) -> Void in
                if self.yPos == -77 { toolbar.hidden = true }
        }
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func addAnnotations(annotations: [PAnnotation]) {
        self.viewControl.currentMap.mapView.addAnnotations(annotations)
    }
    
    func removeAnnotations() {
        self.viewControl.currentMap.mapView.removeAnnotations(self.viewControl.currentMap.mapView.annotations)
    }
}