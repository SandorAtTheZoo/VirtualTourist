//
//  UserSettings.swift
//  VirtualTourist
//
//  Created by Christopher Johnson on 11/28/15.
//  Copyright © 2015 Christopher Johnson. All rights reserved.
//

import Foundation
import MapKit

//not a terribly elegant solution...was just looking to try out userDefaults
class UserSettings : NSObject{
    //MKMapRect : origin : MKMapPoint (x:Double, y:Double), MKMapSize ( width : Double, height : Double)
    var mapRectOriginX : Double
    let keyOriginX = "keyOriginX"
    var mapRectOriginY : Double
    let keyOriginY = "keyOriginY"
    var mapRectSizeWidth : Double
    let keyWidth = "keyWidth"
    var mapRectSizeHeight : Double
    let keyHeight = "keyHeight"
    //CLLocationCoordinate2D : latitude : Double, longitude : Double
    var mapCoordsLat : Double
    let keyLat = "keyLat"
    var mapCoordsLong : Double
    let keyLong = "keyLong"
    
    init(currMapRect : MKMapRect, currMapCoords : CLLocationCoordinate2D) {
        self.mapRectOriginX = currMapRect.origin.x
        self.mapRectOriginY = currMapRect.origin.y
        self.mapRectSizeWidth = currMapRect.size.width
        self.mapRectSizeHeight = currMapRect.size.height
        
        self.mapCoordsLat = currMapCoords.latitude
        self.mapCoordsLong = currMapCoords.longitude
    }
    
    func saveMapDefaults() {
        //assumes you initialized the class to set
        NSUserDefaults.standardUserDefaults().setDouble(mapRectOriginX, forKey: keyOriginX)
        NSUserDefaults.standardUserDefaults().setDouble(mapRectOriginY, forKey: keyOriginY)
        NSUserDefaults.standardUserDefaults().setDouble(mapRectSizeWidth, forKey: keyWidth)
        NSUserDefaults.standardUserDefaults().setDouble(mapRectSizeHeight, forKey: keyHeight)
        
        NSUserDefaults.standardUserDefaults().setDouble(mapCoordsLat, forKey: keyLat)
        NSUserDefaults.standardUserDefaults().setDouble(mapCoordsLong, forKey: keyLong)
    }
    
    static func loadMapRect()->MKMapRect? {
        var newMapRect = MKMapRect()
        
        newMapRect.origin.x = NSUserDefaults.standardUserDefaults().doubleForKey("keyOriginX")
        newMapRect.origin.y = NSUserDefaults.standardUserDefaults().doubleForKey("keyOriginY")
        newMapRect.size.width = NSUserDefaults.standardUserDefaults().doubleForKey("keyWidth")
        newMapRect.size.height = NSUserDefaults.standardUserDefaults().doubleForKey("keyHeight")

        //the point is that if width and height of the map are too small, it hasn't been initialized
        //I think this is better than != 0, depending on how the compiler handles floating point numbers 0 != 0
        if newMapRect.size.width < 0.01 && newMapRect.size.height < 0.01 {
            return nil
        } else {
            return newMapRect
        }
    }
    
    static func loadMapCoords()->CLLocationCoordinate2D {
        var newCoords = CLLocationCoordinate2D()
        
        newCoords.latitude = NSUserDefaults.standardUserDefaults().doubleForKey("keyLat")
        newCoords.longitude = NSUserDefaults.standardUserDefaults().doubleForKey("keyLong")
        
        return newCoords
    }
}