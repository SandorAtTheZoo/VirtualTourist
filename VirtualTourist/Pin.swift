//
//  Pin.swift
//  VirtualTourist
//
//  Created by Christopher Johnson on 10/19/15.
//  Copyright © 2015 Christopher Johnson. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class Pin : NSManagedObject, MKAnnotation {
    //used for network calls
    struct Keys {
        static let bbox = "bbox"
    }
    //used for core data, pin location derived from MKAnnotationView -> annonation : MKAnnotation -> coordinate : CLCoordinate2D
    @NSManaged var id : String
    @NSManaged var latitude : Double
    @NSManaged var longitude : Double
    @NSManaged var bounds : Double
    @NSManaged var bbox : NSMutableDictionary
    @NSManaged var photos : [Photo]
    
    //implement MKAnnotation protocol
    //https://bakyelli.wordpress.com/2013/10/13/creating-custom-map-annotations-using-mkannotation-protocol/
    var coordinate = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
    
}

