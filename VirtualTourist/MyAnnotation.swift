//
//  MyAnnotation.swift
//  VirtualTourist
//
//  Created by Christopher Johnson on 10/31/15.
//  Copyright © 2015 Christopher Johnson. All rights reserved.
//

import MapKit

class MyAnnotation: NSObject, MKAnnotation {
    var coordinate : CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 2.0, longitude: 0.2)
    var title : String?
    var subtitle : String?

}
