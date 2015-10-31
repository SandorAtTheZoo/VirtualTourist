//
//  TravelLocationViewController.swift
//  VirtualTourist
//
//  Created by Christopher Johnson on 10/18/15.
//  Copyright © 2015 Christopher Johnson. All rights reserved.
//

import UIKit
import MapKit

class TravelLocationViewController: UIViewController, MKMapViewDelegate {

    //need the ! because will have compile error of 'no initializers' which basically means (I think)
    //that without ! the variables start in an undetermined state (like declaring pointers without assignment in C, then run-time access would error out
    //due to the value that the pointer points to being initially garbage)
    @IBOutlet weak var mapView: MKMapView!
    var longPressRecognizer : UILongPressGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // add gesture recognizer programmatically (from apple docs on gesture recognizers)
        longPressRecognizer = UILongPressGestureRecognizer(target: self, action: "respondToLongTouch")
        //now configure recognizer
        longPressRecognizer.minimumPressDuration = CFTimeInterval(0.4)  //default 0.5 sec, but just to demo option
        //now add gesture recognizer to view
        self.view.addGestureRecognizer(longPressRecognizer)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: ADD GESTURE RECOGNIZER NEXT and attach to mapview
    //IBAction for gesture recognizer
    func respondToLongTouch() {
        switch (longPressRecognizer.state) {
        case .Began:
            //show map pin here
            print("long touch detected")
            return
        case .Ended:
            //place map pin when this is called
            //goal is to keep this function light, and do more in async_dispatch, but if user moves map, need to capture lat/long now
            let pressLocation : CGPoint = longPressRecognizer.locationInView(self.mapView)
            let mapLoc : CLLocationCoordinate2D = self.mapView.convertPoint(pressLocation, toCoordinateFromView: self.mapView)
            print ("long touch ended at : \(mapLoc)")
            self.updateMap(mapLoc)
        case .Failed:
            print("failure")
        case .Changed:
            //drag pin when this is happening
            print("changing...maybe map drag here?")
        default:
            print("gesture default message...did something else")
        }
    }
    
    // Here we create a view with a "right callout accessory view". You might choose to look into other
    // decoration alternatives. Notice the similarity between this method and the cellForRowAtIndexPath
    // method in TableViewDataSource.
    //used from PinSample project right before starting this project
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView! {
        let reuseID = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseID) as? MKPinAnnotationView
        
        if (pinView == nil) {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            pinView!.canShowCallout = true
            //pinView!.pinColor = .Purple   //deprecated in ios 9...don't know how to change yet
            pinView!.rightCalloutAccessoryView = UIButton(type: UIButtonType.DetailDisclosure)
        } else {
            pinView!.annotation = annotation
        }
        return pinView
        
    }
    
    //conform to MKAnnotation protocol
    
    
//MARK: change URL to call your collection of photos
    
    // This delegate method is implemented to respond to taps. It opens the system browser
    // to the URL specified in the annotationViews subtitle property.
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.sharedApplication()
            app.openURL(NSURL(string: view.annotation!.subtitle!!)!)
        }
    }
    //used this to find out how to get the coordinate point from the touch :
    //https://freshmob.com.au/mapkit-tap-and-hold-to-drop-a-pin-on-the-map/
    //place pin
    func updateMap(pinLoc : CLLocationCoordinate2D) {
        let newAnnotation = MKPointAnnotation()
        //annotations = MapData.sharedInstance().placePins(Array(MapData.allUserInformation))
        newAnnotation.coordinate = pinLoc
        
        dispatch_async(dispatch_get_main_queue(), {
            //self.mapView.removeAnnotations(self.mapView.annotations)
            self.mapView.addAnnotation(newAnnotation)
        })
        //print("number of users : \(MapData.allUserInformation.count)")
    }


}

