//
//  SDCUser.swift
//  Drivecast
//
//  Created by Marc Rollin on 10/16/15.
//  Copyright © 2015 Safecast. All rights reserved.
//

import Foundation
import SwiftyJSON

struct SDCUser {
    let id: Int
    let name: String
    let email: String
    let key: String
    let approvedMeasurementCount: Int
}

// MARK - JSONDecodable
extension SDCUser: JSONDecodable {
    
    // Initializing a SDCImport object based on a json object
    init(json: JSON) {
        id                          = json["id"].intValue
        name                        = json["name"].stringValue
        email                       = json["email"].stringValue
        key                         = json["authentication_token"].stringValue
        approvedMeasurementCount    = json["measurements_count"].intValue
    }
}