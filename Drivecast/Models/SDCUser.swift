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

// MARK - JSONEncodable
extension SDCUser: JSONEncodable {

    // Converts the current user object into a json object
    func encode() -> JSON {
        var dict = Dictionary<String, AnyObject>()
        
        dict["id"]                      = id
        dict["name"]                    = name
        dict["email"]                   = email
        dict["authentication_token"]    = key
        dict["measurements_count"]      = approvedMeasurementCount
        
        return JSON(dict)
    }
}

// MARK - Equatable
// Comparision method betweee two SDCUser
func ==(lhs: SDCUser, rhs: SDCUser) -> Bool {
    return lhs.id == rhs.id
}

// MARK - Defaults
extension SDCUser  {
    private static let defaultsKey      = "authenticatedUser"
    private static let defaults         = NSUserDefaults.standardUserDefaults()
    
    static var authenticatedUser: SDCUser? {
        get {
            guard let object = defaults.objectForKey(defaultsKey) else {
                return nil
            }
        
            return SDCUser(json: JSON(object))
        } set {
            guard let user = newValue else {
                return defaults.removeObjectForKey(defaultsKey)
            }
            
            defaults.setObject(user.encodedObject, forKey: defaultsKey)
        }
    }
}