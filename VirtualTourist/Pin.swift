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

class Pin : NSManagedObject, MKMapViewDelegate {
    
    //used for core data, pin location derived from MKAnnotationView -> annonation : MKAnnotation -> coordinate : CLCoordinate2D
    
    //copied this from previous udacity core data code...I think this is here to receive
    //the super.init call in the regular init function to insert the named entity into the MOC
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(latitude : Double, longitude : Double, context : NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)!
        
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        //now update pin data :
        self.latitude = latitude
        self.longitude = longitude
        
        //createID function exists as a protocol extension in the project file Location.swift
        self.id = createID(latitude, longitude: longitude)
    }
}

