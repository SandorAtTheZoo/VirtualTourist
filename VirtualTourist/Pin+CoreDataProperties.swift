//
//  Pin+CoreDataProperties.swift
//  VirtualTourist
//
//  Created by Christopher Johnson on 11/4/15.
//  Copyright © 2015 Christopher Johnson. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Pin {

    @NSManaged var bbox: NSObject?
    @NSManaged var bounds: NSNumber?
    @NSManaged var id: String?
    @NSManaged var latitude: NSNumber?
    @NSManaged var longitude: NSNumber?
    @NSManaged var photos: NSOrderedSet?

}
