//
//  TravelLocationViewController.swift
//  VirtualTourist
//
//  Created by Christopher Johnson on 10/18/15.
//  Copyright © 2015 Christopher Johnson. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class TravelLocationViewController: UIViewController, MKMapViewDelegate, PhotoAlbumViewControllerDelegate {

    //need the ! because will have compile error of 'no initializers' which basically means (I think)
    //that without ! the variables start in an undetermined state (like declaring pointers without assignment in C, then run-time access would error out
    //due to the value that the pointer points to being initially garbage)
    //referenced this a lot to get the annotation draggable
    //http://stackoverflow.com/questions/10733564/drag-an-annotation-pin-on-a-mapview
    

    @IBOutlet weak var mapView: MKMapView!
    
    var longPressRecognizer : UILongPressGestureRecognizer!
    var photoArray = NSMutableArray()
    var userLocations = [Pin]()
    
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
    
    //core data : add MOC reference
    var sharedContext : NSManagedObjectContext {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.managedObjectContext
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
            //after pin dropped, automatically fetch photos from flickr
            //save location pin to core data
            let locToBeAdded = Pin(latitude: mapLoc.latitude, longitude: mapLoc.longitude, context: sharedContext)
            self.userLocations.append(locToBeAdded)
            do {
                try sharedContext.save()
            } catch {
                print ("failed to save MOC for Pin")
            }
            
            let getLoc = CmdFlickr()
            //self.photoSet = getLoc.getPhotosForLocation(mapLoc.latitude, longitude: mapLoc.longitude)
            getLoc.getPhotosForLocation(mapLoc.latitude, longitude: mapLoc.longitude, completionHandler: { (nwData, success, errorStr) -> Void in
                if success {
                    //NEED THE IF/LET TO PERFORM THE CAST
                    if let newArr = nwData {
                        //self.photoArray.addObjectsFromArray(newArr as [AnyObject])
                        //now add each photo from the array in to the entity Photo and
                        //link that photo to a given Pin location
                        for pic in newArr {
                            let newPic = Photo(photoURL: pic as! String, context: self.sharedContext)
                            newPic.pin = locToBeAdded
                        }
                        //save context
                        do {
                            try self.sharedContext.save()
                        } catch {
                            print ("failed to save MOC for Photo")
                        }
                    }
                    print("PHOTOSQ!!!!! : \(self.photoArray)")
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.performSegueWithIdentifier("ToPhotoSegue", sender: self)
                    })
                    //MARK: TODO
                    //while the next view is loading, start downloading all photos and save in core data
                    
                    
                } else {
                    print("failed to get photos from locationViewController")
                }
            })
            return
        case .Ended:
            print("ENDED : HOPEFULLY A PIN WAS DROPPED")
        case .Failed:
            print("failure")
        default:
            print("gesture default message...did something else")
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ToPhotoSegue" {
            //helped with segue-ing to navigation controller
            //http://stackoverflow.com/questions/28788416/swift-prepareforsegue-with-navigation-controller
            let destNavCtrlr = segue.destinationViewController as! UINavigationController
            let vcDelegate = destNavCtrlr.topViewController as! PhotoAlbumViewController
            vcDelegate.delegate = self
            vcDelegate.photoURLs = self.photoArray
            print("going to show photo collection now...add data here")
        }
    }
    
    func returnToMap(controller: PhotoAlbumViewController) {
        print("return function called")
        //necessary to return across a navigation view controller, as many others just pop to
        //the top of the view controller stack...not desired result in this case.
        controller.dismissViewControllerAnimated(true, completion: nil)
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
            getLoc.getPhotosForLocation(lat, longitude: long, completionHandler: { (nwData, success, errorStr) -> Void in
                if success {
                    print("network data...........\(nwData)")
                    //NEED THE IF/LET TO PERFORM THE CAST
                    if let newArr = nwData {
                        self.photoArray.addObjectsFromArray(newArr as [AnyObject])
                    }
                    print("PHOTO_PIN MOVED!!!!! : \(self.photoArray)")
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.performSegueWithIdentifier("ToPhotoSegue", sender: self)
                    })
                } else {
                    print("failed to get photos from locationViewController")
                }
            })
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

