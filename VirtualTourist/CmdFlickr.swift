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
    func getPhotosForLocation(latitude: Double, longitude: Double, completionHandler:(nwData : NSMutableArray?, success:Bool, errorStr:String?)->Void) {
        var photoArr = NSMutableArray()
        var flickrPage = 1
        
        var dictMod : [String:AnyObject] = [
            "page":flickrPage,
            "extras":"url_m"
        ]
        
        var location : [String:AnyObject] = [
            "method":NWFlickr.APIFuncs.movieSearch,
            "lat":latitude,
            "lon":longitude
        ]
        
        //get a list of photos from a location
        self.nw.nwGetJSON(location) { (result, success, error) -> Void in
            if (success) {
                //get number of pages of pictures from this location for randomization
                print("flickr pages : \(flickrPage)")
                print("parameters : \(location)")
                self.returnNumOfPages(result, completionHandler: { (numPages, success, errorString) -> Void in
                    if (success) {
                        print("flickr pages 2 : \(numPages)")
                        //pick random picture page, append dictionaries from SequenceType
                        flickrPage = Int(arc4random_uniform(UInt32(numPages))+1)
                        print("RANDOM PAGE : \(flickrPage)")
                        dictMod.updateValue(flickrPage, forKey: "page")
                        //http://austinzheng.com/2015/01/24/swift-seq/
                        //with some mucking about in the playground...I need to read up more on this...and yeah, it's way
                        //more complicated than it needs to be to move 2 values across, but I'm trying something new
                        dictMod.forEach({ (k,v) -> () in
                            location.updateValue(v , forKey: k )
                        })
                        print("location 2 : \(dictMod)")
                        //now get list of photos from page #random
                        self.nw.nwGetJSON(location) { (result, success, error) -> Void in
                            //if JSON object is valid, then
                            //1) segue to next view
                            //2) while downloading each image into its own entity
                            //3) pass Pin information and show those photos from that entity WITH PLACEHOLDERS WHILE DOWNLOAD COMPLETES
                            photoArr = self.returnPhotoURLSet(result, completionHandler: { (success, errorString) -> Void in
                                if !success {
                                    completionHandler(nwData: nil, success: false, errorStr: "failed to get photo data")
                                    return
                                }
                            })
                            completionHandler(nwData: photoArr, success: true, errorStr: nil)
                            
                            print("PHOTO URLS : \(photoArr)")
                        }
                    } else {
                        print("error string : \(errorString)")
                    }
                })
            }
        }
        
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
    func returnPhotoURLSet(jsonObject:AnyObject, completionHandler:(success:Bool, errorString:String?)->Void) -> NSMutableArray {
        let photoURLSet = NSMutableArray()
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
    
    func returnNumOfPages(jsonObject: AnyObject, completionHandler:(pages:Int, success:Bool, errorString:String?)->Void) {
        let jsonData = jsonObject as! NSDictionary
        if let jsonPhotos = jsonData.valueForKey("photos") as? [String:AnyObject] {
            if let photoPages = jsonPhotos["pages"] as? Int {
                completionHandler(pages:photoPages, success: true, errorString: nil )
            }
            else {
                completionHandler(pages:0, success: false, errorString: "no pages exist")
            }
            
        } else {
            completionHandler(pages:0, success: false, errorString: "no photo dictionary existed...bad return from flickr")
        }
    }
}