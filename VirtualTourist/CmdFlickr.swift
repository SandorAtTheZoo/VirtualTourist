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
    func getPhotosForLocation(latitude: Double, longitude: Double) {
        let location = [
            "method":NWFlickr.APIFuncs.movieSearch,
            "lat":latitude,
            "lon":longitude
        ]
        nw.nwGetJSON(location as! [String:AnyObject]) { (result, error) -> Void in
        print("RESULT : \(result)")
        }
    }
}