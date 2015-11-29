//
//  Location.swift
//  VirtualTourist
//
//  Created by Christopher Johnson on 11/21/15.
//  Copyright © 2015 Christopher Johnson. All rights reserved.
//

import Foundation
import MapKit
import CoreData


//handle location conversions for map view updates to return annotations for viewing
//extended MKMapViewDelegate protocol as most classes that implement that protocol need these functions
//but more just to try out the Protocol Oriented Programming (WWDC 15 video from session 403 I think?)
//..need to check out the playground from that and work more in protocols
extension MKMapViewDelegate {
    
    
    func createAnnoFromPoint(locPoint : CGPoint, currMapView : MKMapView)->MyAnnotation {
        let myAnno = MyAnnotation()
        let mapLoc = currMapView.convertPoint(locPoint, toCoordinateFromView: currMapView)
        myAnno.coordinate = mapLoc

        return myAnno
    }
    
    func createAnnoFromLatLong(lat : Double, long : Double, currMapView : MKMapView) -> MyAnnotation {
        let myAnno = MyAnnotation()
        let mapLoc = CLLocationCoordinate2D(latitude: lat, longitude: long)
        myAnno.coordinate = mapLoc
        
        return myAnno
    }
    
    func createAnnosFromPins(pins : [Pin], currMapView : MKMapView) -> [MyAnnotation] {
        var annos = [MyAnnotation]()
        for item in pins {
            if let latitude = item.latitude as Double? {
                if let longitude = item.longitude as Double? {
                    let mapLoc = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                    //must create new annotation object for each annotation, otherwise only the last
                    //annotation shows up...hence the instance being in the loop rather than at the top
                    let myAnno = MyAnnotation()
                    myAnno.coordinate = mapLoc
                    //change pin color based on if there are any photos in that location
                    if item.photos.count == 0 {
                        myAnno.color = MKPinAnnotationView.redPinColor()
                    } else {
                        myAnno.color = MKPinAnnotationView.greenPinColor()
                    }
                    annos.append(myAnno)
                }
            }

        }
        return annos
    }
    
    //generate annotation id from current Pin coordinates
    //this will be used to associate selected annotation with its data when
    //segueing to the photo view
    func createID(latitude : Double, longitude : Double) -> String {
        var id = String(format: "%f", latitude)
        id.appendContentsOf(String(format: "%f", longitude))
        return id
    }
    
    var sharedContext : NSManagedObjectContext {
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return delegate.managedObjectContext
    }
    
    func getCurrPin(pinID : String) -> Pin? {
        //from apple docs 'Predicate Programmingn Guide'
        let request = NSFetchRequest()
        let entity = NSEntityDescription.entityForName("Pin", inManagedObjectContext: sharedContext)
        request.entity = entity
        
        let predicate = NSPredicate(format: "id == %@", pinID)
        request.predicate = predicate
        do {
            //returns an empty array if Pin not found, not nil
            let pinResult : [Pin] = try sharedContext.executeFetchRequest(request) as! [Pin]
            if pinResult.count > 0 {
                return pinResult[0]
            } else {
                return nil
            }
        }catch {
            print("failed to complete fetch request with predicate")
            return nil
        }
    }
}