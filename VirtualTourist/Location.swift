//
//  Location.swift
//  VirtualTourist
//
//  Created by Christopher Johnson on 11/21/15.
//  Copyright © 2015 Christopher Johnson. All rights reserved.
//

import Foundation
import MapKit

//handle location conversions for map view updates to return annotations for viewing
class Location: NSObject {
    
    
    class func createAnnoFromPoint(locPoint : CGPoint, currMapView : MKMapView)->MyAnnotation {
        let myAnno = MyAnnotation()
        let mapLoc = currMapView.convertPoint(locPoint, toCoordinateFromView: currMapView)
        myAnno.coordinate = mapLoc

        return myAnno
    }
    
    class func createAnnoFromLatLong(lat : Double, long : Double, currMapView : MKMapView) -> MyAnnotation {
        let myAnno = MyAnnotation()
        let mapLoc = CLLocationCoordinate2D(latitude: lat, longitude: long)
        myAnno.coordinate = mapLoc
        
        return myAnno
    }
    
    class func createAnnosFromPins(pins : [Pin], currMapView : MKMapView) -> [MyAnnotation] {
        var annos = [MyAnnotation]()
        for item in pins {
            if let latitude = item.latitude as Double? {
                if let longitude = item.longitude as Double? {
                    let mapLoc = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                    //must create new annotation object for each annotation, otherwise only the last
                    //annotation shows up...hence the instance being in the loop rather than at the top
                    let myAnno = MyAnnotation()
                    myAnno.coordinate = mapLoc
                    annos.append(myAnno)
                }
            }
        }
        return annos
    }
    
    //generate annotation id from current Pin coordinates
    //this will be used to associate selected annotation with its data when
    //segueing to the photo view
    class func createID(latitude : Double, longitude : Double) -> String {
        var id = String(format: "%f", latitude)
        id.appendContentsOf(String(format: "%f", longitude))
        print("OBBBBBBBBject ID : \(id)")
        return id
    }
}