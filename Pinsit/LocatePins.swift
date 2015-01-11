//
//  LocatePins.swift
//  Pinsit
//
//  Created by Walker Christie on 10/13/14.
//  Copyright (c) 2014 Walker Christie. All rights reserved.
//

import Foundation

class LocatePins {
    var mapController: MapViewController
    var location: Coordinate!
    
    init(map: MapViewController) {
        self.mapController = map
    }
    
    init(map: MapViewController, loc: Coordinate) {
        self.mapController = map
        self.location = loc
    }
    
    
}