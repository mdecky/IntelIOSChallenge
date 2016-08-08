//
//  Book.swift
//  IntelIOSChallenge
//
//  Created by Matej Decky on 08.08.16.
//  Copyright © 2016 Inloop, s.r.o. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Book: ResponseObjectSerializable {
    let title: String
    let pageCount: UInt
    
    init?(json: JSON) {
        guard let title = json["volumeInfo"]["title"].string else {
                return nil
        }
        self.pageCount = json["volumeInfo"]["pageCount"].uInt ?? 0
        self.title = title
    }
}