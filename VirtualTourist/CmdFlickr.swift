//
//  CmdFlickr.swift
//  VirtualTourist
//
//  Created by Christopher Johnson on 10/31/15.
//  Copyright © 2015 Christopher Johnson. All rights reserved.
//

import Foundation

class CmdFlickr {
    let nw = NWFlickr()
    
    //add lat/long for parameters
    //add completionHandler to account for asynchronous network data return so that
    //will wait for network return without using notifier
    func getPhotosForLocation(latitude: Double, longitude: Double)-> NSMutableSet {
        var photoSet = NSMutableSet()
        let location = [
            "method":NWFlickr.APIFuncs.movieSearch,
            "lat":latitude,
            "lon":longitude
        ]
        nw.nwGetJSON(location as! [String:AnyObject]) { (result, error) -> Void in
            //if JSON object is valid, then
            //1) segue to next view
            //2) while downloading each image into its own entity
            //3) pass Pin information and show those photos from that entity WITH PLACEHOLDERS WHILE DOWNLOAD COMPLETES
            photoSet = self.returnPhotoURLSet(result, completionHandler: { (success, errorString) -> Void in
                if success {
                    
                }
            })
            print("PHOTO URLS : \(photoSet)")
        }
        return photoSet
    }
    
    //parse json object from flickr using method flickr.photos.search
    //sample return looks like :
    /*
    {
        photos =     {
        page = 1;
        pages = 17;
        perpage = 250;
        photo =         (
            {
            farm = 6;
            "height_m" = 500;
            id = 22428283170;
            isfamily = 0;
            isfriend = 0;
            ispublic = 1;
            owner = "100782916@N07";
            secret = f7ff59fd9d;
            server = 5669;
            title = "Thomas Hill Standpipe";
            "url_m" = "https://farm6.staticflickr.com/5669/22428283170_f7ff59fd9d.jpg";
            "width_m" = 334;
        },
    ...
    }
    */
    //chose to return a set vs an array so that perhaps the 'order doesn't matter' effect will help
    //provide a degree of 'randomness' to the photo list without explicitly adding that functionality
    func returnPhotoURLSet(jsonObject:AnyObject, completionHandler:(success:Bool, errorString:String?)->Void) -> NSMutableSet {
        let photoURLSet = NSMutableSet()
        let jsonData = jsonObject as! NSDictionary
        if let jsonPhotos = jsonData.valueForKey("photos") as? [String:AnyObject] {
            if let jsonPhotoArr = jsonPhotos["photo"] as? [[String:AnyObject]] {
                for item in jsonPhotoArr {
                    if let photoURL = item["url_m"] {
                        photoURLSet.addObject(photoURL)
                    }
                }
            }
            completionHandler(success: true, errorString: nil )
            return photoURLSet
        } else {
            completionHandler(success: false, errorString: "no photos available")
            return photoURLSet
        }
    }
}