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
        updateID(latitude, longitude: longitude)
    }

    //generate annotation id from current Pin coordinates
    //this will be used to associate selected annotation with its data when
    //segueing to the photo view
    func updateID(latitude : Double, longitude : Double) {
        self.id = String(format: "%f", latitude)
        self.id?.appendContentsOf(String(format: "%f", longitude))
        print("OBBBBBBBBject ID : \(self.id)")
    }
}

