//
//  APIService.swift
//  IntelIOSChallenge
//
//  Created by Matej Decky on 08.08.16.
//  Copyright © 2016 Inloop, s.r.o. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

struct APIService {
    enum Router: URLRequestConvertible {
        static let baseURL = "https://www.googleapis.com/books/v1"
        case volumes(query: String)
        
        var URLRequest: NSMutableURLRequest {
            let url: NSURL
            switch self {
            case .volumes(let query):
                url = NSURL(string: Router.baseURL + "/volumes?q=\(query)")!
            }
            return NSMutableURLRequest(URL: url)
        }
    }
    
    static func volumes(query: String, completion: Result<[Book], BackendError> -> ()) -> Request {
        return Alamofire.request(Router.volumes(query: query)).validate().responseGoogleObjectArray { (response: Response<[Book], BackendError>) in
            switch response.result {
            case .Success(let value):
                let sorted = value.sort({$0.0.pageCount < $0.1.pageCount})
                completion(Result.Success(sorted))
            case .Failure(let error):
                completion(Result.Failure(error))
            }
        }
    }
    
    //Not a nice approach - preferably use method above 
    static func volumes(query: String) -> [Book] {
        let semaphore = dispatch_semaphore_create(0)
        var books = [Book]()
        NSURLSession.sharedSession().dataTaskWithRequest(Router.volumes(query: query).URLRequest) { (responseData, response, _) -> Void in
            if let responseData = responseData,
            json = try? NSJSONSerialization.JSONObjectWithData(responseData, options: NSJSONReadingOptions.AllowFragments),
            items = json["items"] as? [AnyObject] {
                let objects = items.flatMap({Book(json: JSON($0))})
                let sorted = objects.sort({$0.0.pageCount < $0.1.pageCount})
                books = sorted
            }
            dispatch_semaphore_signal(semaphore)
        }.resume()
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        return books
    }
}

