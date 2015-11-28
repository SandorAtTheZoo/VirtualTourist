//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Christopher Johnson on 10/19/15.
//  Copyright © 2015 Christopher Johnson. All rights reserved.
//

import UIKit
import CoreData
import MapKit

//worked with 
//http://stackoverflow.com/questions/24099230/delegates-in-swift
//to include delegate for return segue

protocol PhotoAlbumViewControllerDelegate {
    func returnToMap(controller : PhotoAlbumViewController)
}

class PhotoAlbumViewController : UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, MKMapViewDelegate {
    
    var delegate : PhotoAlbumViewControllerDelegate! = nil
    //OLD_WORKING
    //var photoURLs : NSMutableArray? = nil
    var currID : String?
    var currPin : Pin?
    @IBOutlet weak var collView: UICollectionView!
    @IBOutlet weak var getNewCollButt: UIButton!

    var context : NSManagedObjectContext {
        return appDelegate.managedObjectContext
    }
    
    var appDelegate : AppDelegate {
        return UIApplication.sharedApplication().delegate as! AppDelegate
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //i think these need to persist outside of the photo collection view
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "enableNewCollButton", name: "enableNewCollButt", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "disableNewCollButton", name: "disableNewCollButt", object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        //same deal as table...delegates don't fire (numberOfItemsInSection...and that propagates) because the change in meme array size is
        //not recognized without this call
        if let id = currID {
            currPin = self.getCurrPin(id)
        } else {
            print("failed to get selected Pin in photo controller")
        }
        //start notification listener
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateDisplay", name: "updatePhotoCollection", object: nil)
        updateDisplay()
        
    }

    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    @IBAction func selectNewLocation(sender: UIBarButtonItem) {
        print("delegate call to return")
        self.delegate?.returnToMap(self)
    }
    @IBAction func getNewCollection(sender: UIButton) {
        //on get new collection, new photos will be downloaded, so disable button until call complete
        NSNotificationCenter.defaultCenter().postNotificationName("disableNewCollButt", object: self)
        //remove all previous photos
        print("NUM OF PHOTOS TO DELETE \(currPin?.photos.count)")
        var count = 0
        for _ in (currPin?.photos)! {
            print("deleting : \(count)")
            deletePhoto(count)
            count++
        }
        //save context, refresh collection
        do {
            try context.save()
        } catch {
            print("failed to save context")
        }
        print("CURRRRRRR : \(currPin?.photos.count)")
        SaveHelper.getNewPhotos(Double(currPin!.latitude!), newLong: Double(currPin!.longitude!), newPin: currPin!)
        //save context, refresh collection
        do {
            try context.save()
        } catch {
            print("failed to save context")
        }
        //collection should be updated here, but threads to get URLs and save photos to documents directory haven't returned yet
        //so add notifier to call updateDisplay() when network and I/O threads return

        print("CURRRR333333333333RRR : \(currPin?.photos.count)")
    }
    
    func fetchPhotoToDelete(withURL : String) -> Photo? {
        let request = NSFetchRequest(entityName: "Photo")
        request.predicate = NSPredicate(format: "url == %@", withURL)
        
        do {
            //should only ever be one to delete associated with a given pin
            if let results = try context.executeFetchRequest(request) as? [Photo] {
                return results.first!
            } else {
                return nil
            }
        } catch {
            print("failed to find photo to delete from core data")
            return nil
        }
    }
    
//    //this fixes a glitch where collection view doesn't display content correctly first time
//    //(too high in nav bar)...upon navigating away and returning, it worked, but this resolves that
//    //http://stackoverflow.com/questions/18896210/ios7-uicollectionview-appearing-under-uinavigationbar
//    override func viewDidLayoutSubviews() {
//        let top = self.topLayoutGuide.length
//        let bottom = self.bottomLayoutGuide.length
//        let newInsets = UIEdgeInsetsMake(top, 0, bottom, 0)
//        self.collView.contentInset = newInsets
//    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currPin!.photos.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("photoCell", forIndexPath: indexPath) as! PhotoCollectionCell
        
        let pic = currPin!.photos[indexPath.row].url!
        
        //populate collection from photos that have been downloaded
        cell.flickrImage.image = SaveHelper.loadSavedPhoto(pic)
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        //deletePhoto(indexPath.row)
        deletePhoto(indexPath.row)
        //save context
        do {
            try context.save()
        } catch {
            print("failed to save context")
        }
    }
    
    func deletePhoto(idx : Int) {
        //get url of pic from core data
        let pic = currPin!.photos[idx].url!

        let photoToDelete = currPin?.photos[idx]
        context.deleteObject(photoToDelete!)
        
        //delete pic from Documents directory
        SaveHelper.deletePhoto(pic)
        
        //refresh the collection view
        updateDisplay()
    }
    
    func updateDisplay() {
        //run the update in GCD main thread to avoid delays
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.collView.reloadData()
        }
    }
    
    //was not greying out...turns out forgot about dispatch_async...
    
    func disableNewCollButton() {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.getNewCollButt.enabled = false
        }
    }
    
    func enableNewCollButton() {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.getNewCollButt.enabled = true
        }
    }
}
