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

class Pin : NSManagedObject {
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
    
}

