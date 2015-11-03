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

class PhotoAlbumViewController : UIViewController {
    
    var delegate : PhotoAlbumViewControllerDelegate! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    @IBAction func selectNewLocation(sender: UIBarButtonItem) {
        print("delegate call to return")
        self.delegate?.returnToMap(self)
    }
}
