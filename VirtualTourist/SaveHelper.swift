//
//  SaveThings.swift
//  VirtualTourist
//
//  Created by Christopher Johnson on 11/25/15.
//  Copyright © 2015 Christopher Johnson. All rights reserved.
//

import UIKit
import CoreData

//http://stackoverflow.com/questions/30633408/where-to-put-reusable-functions-in-ios-swift
//require functions specific to saving and getting files/photos
//1.  return path to documents
//2.  display where your save path is in the simulator

class SaveHelper : NSObject {
    
    //core data : add MOC reference
    static var sharedContext : NSManagedObjectContext {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.managedObjectContext
    }
    
    //download image from URL and return UIImage
    //recommend running this in background thread
    static func getImageFromURL(imagePath : String) -> UIImage {
        //get pictures from network
        let testPhoto = NSURL(string: imagePath)
        let collPhoto = NSData(contentsOfURL: testPhoto!)
        return UIImage(data: collPhoto!)!
    }
    
    //get path to Document directory (from Udacity)
    //returns something like /var/folders/.../FlickrPhotos in playground
    static var locFilePath : String {
        let manager = NSFileManager.defaultManager()
        let url = manager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first! as NSURL
        let dataPath = url.URLByAppendingPathComponent("FlickrPhotos").path!
        
        if !NSFileManager.defaultManager().fileExistsAtPath(dataPath) {
            do {
                try NSFileManager().createDirectoryAtPath(dataPath, withIntermediateDirectories: false, attributes: nil)
            } catch let error as NSError {
                print(error.localizedDescription)
                return ""
            }
        }
        return dataPath
    }
    
    //get path to a file in Documents folder (from Udacity)
    //returns something like /var/folders/...FlickrPhotos.aPhoto.jpg (if that's your image file, for instance)
    static func setLocImagePath(fileName : String) ->  NSURL {
        let dirPath = locFilePath
        let pathArray = [dirPath, fileName]
        let fileURL =  NSURL.fileURLWithPathComponents(pathArray)
        
        return fileURL!
    }
    
    //http://stackoverflow.com/questions/2499176/ios-download-image-from-url-and-save-in-device
    //save an item (photo) to a set in the Documents folder
    static func savePhoto(image : UIImage, withDocPathLoc : String, imageURL : String) {
        //parse filename string for extension
        let item : NSString = imageURL
        let fileExtension = item.pathExtension
        //check if png or jpeg and save appropriately
        if fileExtension.lowercaseString == "png" {
            UIImagePNGRepresentation(image)?.writeToFile(withDocPathLoc, atomically: false)
        } else if fileExtension.lowercaseString == "jpg" || fileExtension.lowercaseString == "jpeg" {
            UIImageJPEGRepresentation(image, 1.0)?.writeToFile(withDocPathLoc, atomically: false)
        } else {
            print("failed to write photo image to documents directory")
        }
        
    }
    
    //these are the primary functions save and load
    static func savePhotoFromURL(photoURL : String) {
        let photo = getImageFromURL(photoURL)
        let photoName = NSString(string: photoURL).lastPathComponent
        let newPathArr = [locFilePath, photoName]
        let newPath = NSURL.fileURLWithPathComponents(newPathArr)!
        //check to see if it already exists...if not, save it
        let photoString = NSString(string: photoURL).lastPathComponent
        if NSFileManager.defaultManager().fileExistsAtPath(setLocImagePath(photoString).path!){
            print("photo exists")
        } else {
            savePhoto(photo , withDocPathLoc: newPath.path!, imageURL: photoURL)
        }
    }
    
    static func loadSavedPhoto(withURL : String)->UIImage? {
        let photoName = NSString(string: withURL).lastPathComponent
        let localImagePath = setLocImagePath(photoName).path!
        if let newImage = UIImage(contentsOfFile: localImagePath) {
            return newImage
        } else {
            print("failed to retrieve saved image")
            return nil
        }
    }
    
    static func deletePhoto(photoURL : String) {
        let photoName = NSString(string: photoURL).lastPathComponent
        let locPath = setLocImagePath(photoName).path!
        if NSFileManager.defaultManager().fileExistsAtPath(locPath) {
            do {
            try NSFileManager.defaultManager().removeItemAtPath(locPath)
            } catch {
                print("failed to delete photo from Documents directory")
            }
        }
    }
    
    static func getNewPhotos(newLat: Double, newLong: Double, newPin : Pin) {
        let getLoc = CmdFlickr()

        getLoc.getPhotosForLocation(newLat, longitude: newLong, completionHandler: { (nwData, success, errorStr) -> Void in
            if success {
                //NEED THE IF/LET TO PERFORM THE CAST
                if let newArr = nwData {
                    //now add each photo from the array in to the entity Photo and
                    //associate that photo to a given Pin location
                    for pic in newArr {
                        let newPic = Photo(photoURL: pic as! String, context: self.sharedContext)
                        newPic.pin = newPin
                        let locPath = setLocImagePath(pic.lastPathComponent as String).path!
                        newPic.localPath = locPath
                        print("................local path \(locPath)")
                    }
                    //save context
                    do {
                        try self.sharedContext.save()
                        //notify after context saved (URLs) to update collection view
                        NSNotificationCenter.defaultCenter().postNotificationName("updatePhotoCollection", object: self)
                        
                        
                    } catch {
                        print ("failed to save MOC for Photo")
                    }
                    
                    //while the next view is loading, start downloading all photos and save in core data
                    //make this a separate thread
                    //http://www.raywenderlich.com/79149/grand-central-dispatch-tutorial-swift-part-1
                    //chose QoS utility thread
                    dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY, 0), { () -> Void in
                        print("local file path : \(SaveHelper.locFilePath)")
                        for image in newArr {
                            SaveHelper.savePhotoFromURL(image as! String)
                            //after each save, notify that a new photo exists to update collection
                            NSNotificationCenter.defaultCenter().postNotificationName("updatePhotoCollection", object: self)
                        }
                        print("saved all images")
                        //saved all images, enable new collection button on photoCollectionView
                        NSNotificationCenter.defaultCenter().postNotificationName("enableNewCollButt", object: self)
                    })
                }
                
            } else {
                print("failed to get photos from locationViewController")
            }
        })
    }
    
}