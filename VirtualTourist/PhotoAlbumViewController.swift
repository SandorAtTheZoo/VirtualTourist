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

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        //same deal as table...delegates don't fire (numberOfItemsInSection...and that propagates) because the change in meme array size is
        //not recognized without this call
        if let id = currID {
            currPin = self.getCurrPin(id)
        } else {
            print("failed to get selected Pin in photo controller")
        }
        
        collView.reloadData()
        
        //perform fetchRequest with predicate on currID, and return that Pin entity
        
    }
    
    @IBAction func selectNewLocation(sender: UIBarButtonItem) {
        print("delegate call to return")
        self.delegate?.returnToMap(self)
    }
    @IBAction func getNewCollection(sender: UIButton) {
        
    }
    
    var context : NSManagedObjectContext {
        return appDelegate.managedObjectContext
    }
    
    var appDelegate : AppDelegate {
        return UIApplication.sharedApplication().delegate as! AppDelegate
    }
    
    func fetchPhotoToDelete(withURL : String) -> Photo? {
        let request = NSFetchRequest(entityName: "Photo")
        request.predicate = NSPredicate(format: "url == %@", withURL)
        
        do {
            //should only ever be one to delete associated with a given pin
            let results = try context.executeFetchRequest(request) as! [Photo]
            return results.first!
        } catch {
            print("failed to find photo to delete from core data")
            return nil
        }
    }
    
    //this fixes a glitch where collection view doesn't display content correctly first time
    //(too high in nav bar)...upon navigating away and returning, it worked, but this resolves that
    //http://stackoverflow.com/questions/18896210/ios7-uicollectionview-appearing-under-uinavigationbar
    override func viewDidLayoutSubviews() {
        let top = self.topLayoutGuide.length
        let bottom = self.bottomLayoutGuide.length
        let newInsets = UIEdgeInsetsMake(top, 0, bottom, 0)
        self.collView.contentInset = newInsets
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //OLD_WORKING
        //return photoURLs!.count
        return currPin!.photos.count
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("photoCell", forIndexPath: indexPath) as! PhotoCollectionCell
        
        //now attach real information from my data to the cell
        //OLD_WORKING
        //let pic = photoURLs![indexPath.row] as! String
        let pic = currPin!.photos[indexPath.row].url!
        
        //populate collection from photos that have been downloaded
        cell.flickrImage.image = SaveHelper.loadSavedPhoto(pic)
        
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        //get url of pic from core data
        let pic = currPin!.photos[indexPath.row].url!
        
        //delete pic from Documents directory
        SaveHelper.deletePhoto(pic)
        
        //now delete Photo from core data, and it should propogate
        //run fetch request to find the object to delete based on pin?
        if let photoToDelete = fetchPhotoToDelete(pic) {
            context.deleteObject(photoToDelete)
            do {
            try context.save()
            } catch {
                print("failed to save context")
            }
        }
        
        //refresh the collection view
        collView.reloadData()
        
    }
}
