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
    //referenced this a lot to get the annotation draggable
    //http://stackoverflow.com/questions/10733564/drag-an-annotation-pin-on-a-mapview
    

    @IBOutlet weak var mapView: MKMapView!
    
    var longPressRecognizer : UILongPressGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // add gesture recognizer programmatically (from apple docs on gesture recognizers)
        longPressRecognizer = UILongPressGestureRecognizer(target: self, action: "respondToLongTouch")
        //now configure recognizer
        longPressRecognizer.minimumPressDuration = CFTimeInterval(1.0)  //default 0.5 sec, but just to demo option
        //now add gesture recognizer to view
        self.view.addGestureRecognizer(longPressRecognizer)
        //don't forget to set delegates in storyboard (both)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: ADD GESTURE RECOGNIZER NEXT and attach to mapview
    //http://stackoverflow.com/questions/3959994/how-to-add-a-push-pin-to-a-mkmapviewios-when-touching/3960754#3960754
    //IBAction for gesture recognizer
    func respondToLongTouch() {
        var pressLocation : CGPoint
        var mapLoc : CLLocationCoordinate2D
        switch (longPressRecognizer.state) {
        case .Began:
            //show map pin here
            print("long touch detected")
            //place map pin when this is called
            //goal is to keep this function light, and do more in async_dispatch, but if user moves map, need to capture lat/long now
            pressLocation = longPressRecognizer.locationInView(self.mapView)
            mapLoc = self.mapView.convertPoint(pressLocation, toCoordinateFromView: self.mapView)
            let aPin = MyAnnotation()
            aPin.coordinate = mapLoc
            self.mapView.addAnnotation(aPin)
            let getLoc = CmdFlickr()
            getLoc.getPhotosForLocation(mapLoc.latitude, longitude: mapLoc.longitude)
            return
        case .Ended:
            print("ENDED : HOPEFULLY A PIN WAS DROPPED")
        case .Failed:
            print("failure")
        default:
            print("gesture default message...did something else")
        }
    }
    
    // Here we create a view with a "right callout accessory view". You might choose to look into other
    // decoration alternatives. Notice the similarity between this method and the cellForRowAtIndexPath
    // method in TableViewDataSource.
    //used from PinSample project right before starting this project
//    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
//        let reuseID = "pin"
//        let pinView = MKAnnotationView.init(annotation: annotation, reuseIdentifier: reuseID)
//        
//    }
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseID = "myPin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseID) as? MKPinAnnotationView
        
        if (pinView == nil) {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            pinView!.canShowCallout = false
            pinView!.animatesDrop = true
            pinView!.draggable = true
            //pinView!.pinColor = .Purple   //deprecated in ios 9...don't know how to change yet
            //pinView!.rightCalloutAccessoryView = UIButton(type: UIButtonType.DetailDisclosure)
        }
        return pinView
        
    }
    
    
    //conform to MKAnnotation protocol
    //support pin dragging
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, didChangeDragState newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        print("DRAAAAAAGING")
        if newState == .Ending {
            let droppedAt : CLLocationCoordinate2D = (view.annotation?.coordinate)!
            let lat = droppedAt.latitude
            let long = droppedAt.longitude
            print("pin dropped at : \(lat), \(long)")
            let getLoc = CmdFlickr()
            getLoc.getPhotosForLocation(lat, longitude: long)
        }
    }
    
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

}
