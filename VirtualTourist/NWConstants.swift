//
//  NWConstants.swift
//  VirtualTourist
//
//  Created by Christopher Johnson on 10/19/15.
//  Copyright © 2015 Christopher Johnson. All rights reserved.
//

import Foundation

extension NWFlickr {
    //constants needed for NWFlickr class to make API calls
    
    struct Base {
        static let apiKey = "08323d920a1d2c414f3e6ffb5cf07ed1"
        static let url = "https://api.flickr.com/services/rest/"
        static let format = "json"
        static let jsoncallback = "1"
    }
    
    struct APIFuncs {
        //used this rather than .getWithGeoData because that one appears to be broken on their site (never returns anything)
        //using search returns results for lat/long
        static let movieSearch = "flickr.photos.search"
    }
    
    struct Keys {
        static let apiKey = "api_key"
        static let bbox = "bbox"
        static let extras = "extras"
        static let method = "method"
        static let errorStatusMessage = "message"
        static let dataFormat = "format"
        static let nojsoncallback = "nojsoncallback"
    }
}