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
    @IBOutlet weak var inProgress: UIActivityIndicatorView!
    
    var longPressRecognizer : UILongPressGestureRecognizer!
    var photoArray = NSMutableArray()
    var userLocations = [Pin]()
    var selectedID : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // add gesture recognizer programmatically (from apple docs on gesture recognizers)
        longPressRecognizer = UILongPressGestureRecognizer(target: self, action: "respondToLongTouch")
        //now configure recognizer
        longPressRecognizer.minimumPressDuration = CFTimeInterval(1.0)  //default 0.5 sec, but just to demo option
        //now add gesture recognizer to view
        self.view.addGestureRecognizer(longPressRecognizer)
    }
    
    override func viewWillAppear(animated: Bool) {
        //parse pins as annotations to populate map
        self.updateMap()
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
    
    func fetchAllPins() -> [Pin] {
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        
        do {
            return try sharedContext.executeFetchRequest(fetchRequest) as! [Pin]
        } catch let error as NSError {
            print("Error in fetchAllPins \(error)")
            return [Pin]()
        }
    }
    
    //update map with old pins on app launch
    func updateMap() {
        var annotations = [MyAnnotation]()
        //now load pins from previous sessions for display
        userLocations = fetchAllPins()
        print("userLocations : \(userLocations.count)")

        //createAnnosFromPins function exists as a protocol extension in the project file Location.swift
        annotations = createAnnosFromPins(userLocations, currMapView: self.mapView)
        print("number of annotations : \(annotations.count)")
        
        //now update map on GCD thread
        //NEED TO REMOVE self.mapview.annotations so that you don't get shadows...just 'annotations' there isn't enough
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.mapView.removeAnnotations(self.mapView.annotations)
            self.mapView.addAnnotations(annotations)
        }
        
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
            //returns CGPoint
            pressLocation = longPressRecognizer.locationInView(self.mapView)
            //returns CLLocationCoordinate2D
            mapLoc = self.mapView.convertPoint(pressLocation, toCoordinateFromView: self.mapView)
            let aPin = MyAnnotation()
            aPin.coordinate = mapLoc
            
            //add annotation to the map...need to update this to many pins, pulled from core data and added on viewDidLoad
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
            //retrieve photo URLs from this location and save to Pin entity...auto start downloading photos as well
            SaveHelper.getNewPhotos(mapLoc.latitude, newLong: mapLoc.longitude, newPin: locToBeAdded)
            //downloading photos, so disable 'new collection' button in next view
            NSNotificationCenter.defaultCenter().postNotificationName("disableNewCollButt", object: self)
    
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
            
            vcDelegate.currID = self.selectedID
            print("going to show photo collection now...add data here")
        }
    }
    
    func returnToMap(controller: PhotoAlbumViewController) {
        print("return function called")
        self.inProgress.stopAnimating()
        //necessary to return across a navigation view controller, as many others just pop to
        //the top of the view controller stack...not desired result in this case.
        controller.dismissViewControllerAnimated(true, completion: nil)
    }

    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseID = "myPin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseID) as? MKPinAnnotationView
        
        if (pinView == nil) {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            let myAnnotation = annotation as! MyAnnotation
            pinView?.canShowCallout = false
            pinView?.animatesDrop = false
            pinView?.draggable = true
            pinView?.pinTintColor = myAnnotation.color
        }
        return pinView
        
    }
    
    
    //conform to MKAnnotation protocol
    //support pin dragging
    //update annotation colors :
    //http://stackoverflow.com/questions/33532883/add-different-pin-color-with-mapkit-in-swift-2-1
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, didChangeDragState newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        print("DRAAAAAAGING")
        if newState == .Ending {
            let droppedAt : CLLocationCoordinate2D = (view.annotation?.coordinate)!
            let lat = droppedAt.latitude
            let long = droppedAt.longitude
            print("pin dropped at : \(lat), \(long)")
            //let getLoc = CmdFlickr()
            //retrieve photos from this location and save to Pin entity
            
            //check that pin is not dragged on to another pin's location (highly unlikely)
            let newPin = getCurrPin(createID(lat, longitude: long))
            if  newPin == nil {
                print("PPPPPPPPPPPPPPP>>>>>>>>Making new pin on drag")
                //need to create new Pin with this new location, and delete old pin with old location (and photos...)
                let locToBeAdded = Pin(latitude: lat, longitude: long, context: sharedContext)
                self.userLocations.append(locToBeAdded)
                do {
                    try sharedContext.save()
                } catch {
                    print ("failed to save MOC for Pin")
                }
                SaveHelper.getNewPhotos(lat, newLong: long, newPin: locToBeAdded)
                
                //now delete old pin
                let oldPinLoc = getCurrPin(createID(lat, longitude: long))
            }
        }
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        self.inProgress.startAnimating()
        if let lat = view.annotation?.coordinate.latitude {
            if let long = view.annotation?.coordinate.longitude {
                //createID function exists as a protocol extension in the project file Location.swift
                selectedID = createID(lat, longitude: long)
                
                //if the pin actually exists in core data
                if let selectedPin = getCurrPin(selectedID!) {
                    //change color of annotation when selected...may not know how many photos there are initially...
                    let updateAnnotation = view.annotation as! MyAnnotation
                    if selectedPin.photos.count == 0 {
                        updateAnnotation.color = MKPinAnnotationView.redPinColor()
                    }
                    //now segue to photoView with Pin
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.performSegueWithIdentifier("ToPhotoSegue", sender: self)
                    })
                    //need to deselect annotation after selection so that if the user decides
                    //to select it again directly after segue, he can...otherwise it stays selected
                    //and the user needs to select something else first
                    mapView.deselectAnnotation(view.annotation, animated: false)
                }
            }
        }
        
    }

}

