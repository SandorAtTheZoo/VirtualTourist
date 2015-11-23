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
        
        //improve transition response while pictures load
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            //get pictures from network
            let testPhoto = NSURL(string: pic)
            let collPhoto = NSData(contentsOfURL: testPhoto!)
            cell.flickrImage.image = UIImage(data: collPhoto!)
        }
        
        //update cell with data
        //need to update to core data, but for testing...
        
        return cell
    }
}
