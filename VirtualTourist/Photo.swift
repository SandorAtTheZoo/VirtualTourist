//
//  Photo.swift
//  VirtualTourist
//
//  Created by Christopher Johnson on 10/19/15.
//  Copyright © 2015 Christopher Johnson. All rights reserved.
//

import UIKit
import CoreData

class Photo : NSManagedObject {
    struct Keys {
        static let id = "id"
        static let title = "title"
        static let url = "url_m"
    }
    
    @NSManaged var id : String
    @NSManaged var title : String
    @NSManaged var url : NSURL
    @NSManaged var pin : Pin?
}
