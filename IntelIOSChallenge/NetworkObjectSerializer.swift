//
//  NetworkObjectSerializer.swift
//  IntelIOSChallenge
//
//  Created by Matej Decky on 08.08.16.
//  Copyright © 2016 Inloop, s.r.o. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

public protocol ResponseObjectSerializable {
    init?(json: JSON)
}

extension Request {
    public func responseGoogleObjectArray<T: ResponseObjectSerializable>(completionHandler: Response<[T], BackendError> -> Void) -> Self {
        let responseSerializer = ResponseSerializer<[T], BackendError> { request, response, data, error in
            guard let response = response where error == nil else { return .Failure(.Network(error: error!)) }
            
            let JSONResponseSerializer = Request.JSONResponseSerializer(options: .AllowFragments)
            let result = JSONResponseSerializer.serializeResponse(request, response, data, error)
            
            switch result {
            case .Success(let value):
                guard let items = value["items"] as? [AnyObject] else {
                    return .Failure(.ObjectSerialization(reason: "Response JSON is not array"))
                }
                let responseObject = items.map({T(json: JSON($0))})
                if responseObject.contains({$0 == nil}) {
                    return .Failure(.ObjectSerialization(reason: "Response json does not confirm object model!"))
                } else {
                    return .Success(responseObject.flatMap({$0}))
                }
            case .Failure(let error):
                return .Failure(.JSONSerialization(error: error))
            }
            
        }
        
        return response(responseSerializer: responseSerializer, completionHandler: completionHandler)
    }
}

public enum BackendError: ErrorType {
    case Network(error: NSError)
    case JSONSerialization(error: NSError)
    case ObjectSerialization(reason: String)
}