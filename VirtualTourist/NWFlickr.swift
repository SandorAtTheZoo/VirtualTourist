//
//  NWFlickr.swift
//  VirtualTourist
//
//  Created by Christopher Johnson on 10/19/15.
//  Copyright © 2015 Christopher Johnson. All rights reserved.
//

import Foundation

class NWFlickr : NSObject {
    //will contain all network access functions to interface to Flickr
    
    //as I see it, creates a pointer for data result and errors that can be passed into a closure so results can bubble up without adding parameters to the network function
    typealias CompletionHandler = (result: AnyObject!, success : Bool, error: NSError?) -> Void
    
    var session : NSURLSession
    
    var defaultParams : [String:NSObject] = [
        Keys.apiKey:Base.apiKey,
        Keys.dataFormat:Base.format,
        Keys.nojsoncallback:Base.jsoncallback,
        Keys.resultsPerPage:"55"
    ]
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()    //oddly enough, this throws an error if these 2 items (super and session lines) are swapped
    }
    
    //generic network access call
    func nwGetJSON(parameters : [String:AnyObject], completionHandler: CompletionHandler) -> NSURLSessionDataTask {
        //nwMethod is the particular Flickr network method we're utilizing
        //parameters is a dictionary of parameters to be filled in as part of this api call
        let mutableParameters = addDefaultParams(parameters, oldParams: defaultParams)
        
        //MARK: don't forget to add bbox at some point
        
        //configure the request
        let urlString = Base.url + NWFlickr.escapedParameters(mutableParameters)
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
    //debug
        print(url)
        
        //initiate session with Flickr to download stuff
        let task = session.dataTaskWithRequest(request) { data, response, downloadError in
            if let error = downloadError {
                let newError = NWFlickr.errorForData(data, response: response, error: error)
                completionHandler(result: nil, success : false, error: newError)
            } else {
                print("got response from Flickr query SAT")
                NWFlickr.parseJSONWithCompletionHandler(data!, completionHandler: completionHandler)
            }
        }
        //start the network task
        task.resume()
        
        return task
    }
    
    //yeah, it's cut and paste out of the previous projects, but it's pretty damn handy
    // URL Encoding a dictionary into a parameter string
    
    class func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            // make sure that it is a string value
            let stringValue = "\(value)"
            
            // Escape it
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            // Append it
            
            if let unwrappedEscapedValue = escapedValue {
                urlVars += [key + "=" + "\(unwrappedEscapedValue)"]
            } else {
                print("Warning: trouble excaping string \"\(stringValue)\"")
            }
        }
        
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
    }
    
    //another cut and paste, but this seems like a good idea...
    // Try to make a better error, based on the status_message from TheMovieDB. If we cant then return the previous error
    
    class func errorForData(data: NSData?, response: NSURLResponse?, error: NSError) -> NSError {
        
        if data == nil {
            return error
        }
        
        do {
            let parsedResult = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)
            
            if let parsedResult = parsedResult as? [String : AnyObject], errorMessage = parsedResult[NWFlickr.Keys.errorStatusMessage] as? String {
                let userInfo = [NSLocalizedDescriptionKey : errorMessage]
                return NSError(domain: "Flickr Error", code: 1, userInfo: userInfo)
            }
            
        } catch _ {}
        
        return error
    }
    
    //trying to keep this generic, and another cut/paste with mods
    // Parsing the JSON
    
    class func parseJSONWithCompletionHandler(data: NSData, completionHandler: CompletionHandler) {
        var parsingError: NSError? = nil
        
        let parsedResult: AnyObject?
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)
        } catch let error as NSError {
            parsingError = error
            parsedResult = nil
        }
        
        if let error = parsingError {
            completionHandler(result: nil, success:false, error: error)
        } else {
            print("Step 4 - parseJSONWithCompletionHandler is invoked.")
            completionHandler(result: parsedResult, success:true, error: nil)
        }
        //there is no return because the data is passed in from the session closure, and the completion handler 'result' parameter returns the well, JSON result
    }
    
    func addDefaultParams(newParams : [String:AnyObject], oldParams:[String:AnyObject])-> [String:AnyObject] {
        var result : [String:AnyObject] = oldParams
        for (key,value) in newParams {
            result[key] = value
        }
        return result
    }

}