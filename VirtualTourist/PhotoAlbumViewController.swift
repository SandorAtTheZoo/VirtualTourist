//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Christopher Johnson on 10/19/15.
//  Copyright © 2015 Christopher Johnson. All rights reserved.
//

import UIKit

//worked with 
//http://stackoverflow.com/questions/24099230/delegates-in-swift
//to include delegate for return segue

protocol PhotoAlbumViewControllerDelegate {
    func returnToMap(controller : PhotoAlbumViewController)
}

class PhotoAlbumViewController : UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var delegate : PhotoAlbumViewControllerDelegate! = nil
    var photos : [Photo] = [Photo]()
    var photoURLs : NSMutableArray? = nil
    @IBOutlet weak var collView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        print("passed photos : \(photos)")
        //same deal as table...delegates don't fire (numberOfItemsInSection...and that propagates) because the change in meme array size is
        //not recognized without this call
        collView.reloadData()
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
        return photoURLs!.count
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("photoCell", forIndexPath: indexPath) as! PhotoCollectionCell
        
        //now attach real information from my data to the cell
        let pic = photoURLs![indexPath.row] as! String
        
        let testPhoto = NSURL(string: pic)
        let collPhoto = NSData(contentsOfURL: testPhoto!)
        cell.flickrImage.image = UIImage(data: collPhoto!)
        //update cell with data
        //need to update to core data, but for testing...
        
        return cell
    }
}
