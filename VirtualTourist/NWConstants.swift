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
        static let apiKey = "8661efd575cd7500db839ca630e446d5"
        static let url = "https://api.flickr.com/services/rest/"
    }
    
    struct APIFuncs {
        static let movieSearch = "flickr.photos.search"
    }
    
    struct Keys {
        static let apiKey = "api_key"
        static let bbox = "bbox"
        static let extras = "extras"
        static let method = "method"
        static let errorStatusMessage = "message"
    }
}