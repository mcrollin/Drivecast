//
//  SDCImport.swift
//  Drivecast
//
//  Created by Marc Rollin on 10/14/15.
//  Copyright © 2015 Safecast. All rights reserved.
//

import Foundation
import SwiftyJSON

enum SDCImportProgress {
    case Uploaded
    case Processed
    case MetadataAdded
    case Submitted
    case Approved
    case Rejected
    case Live
}

struct SDCImport {
    let id: Int
    let userId: Int
    let createdAt: NSDate
    let updatedAt: NSDate
    let name: String
    let cities: String
    let credits: String
    let details: String
    let height: String
    let orientation: String
    let md5sum: String
    let source: String
    let mapId: Int?
    let lineCount: Int
    let measurementCount: Int
    let approved: Bool
    let status: String
    let statusDetails: StatusDetails
    
    struct StatusDetails {
        let importLogs: Bool
        let processFile: Bool
        let computeLocation: Bool
        let createMap: Bool
        let measurementsAdded: Bool
    }
    
    var progress:SDCImportProgress {
        if (!statusDetails.processFile || !statusDetails.importLogs) {
            return .Uploaded
        } else if (cities != "" || credits != "") {
            return .Processed
        } else if (self.status == "processed") {
            return .MetadataAdded
        } else if (status == "submitted") {
            return .Submitted
        } else if (approved && !statusDetails.measurementsAdded) {
            return .Approved
        } else if (!approved) {
            return .Rejected
        }
        
        return .Live
    }
}

// MARK - JSONDecodable
extension SDCImport: JSONDecodable {
    
    // Initializing a SDCImport object based on a json object
    init(json: JSON) {
        let statusDetailsJson   = json["status_details"]
        let utcFormatter        = NSDateFormatter()
        utcFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        utcFormatter.timeZone   = NSTimeZone(name: "UTC")
        
        id                      = json["id"].intValue
        userId                  = json["user_id"].intValue
        createdAt               = utcFormatter.dateFromString(json["created_at"].stringValue)!
        updatedAt               = utcFormatter.dateFromString(json["updated_at"].stringValue)!
        name                    = json["name"].stringValue
        cities                  = json["cities"].stringValue
        credits                 = json["credits"].stringValue
        details                 = json["description"].stringValue
        height                  = json["height"].stringValue
        orientation             = json["orientation"].stringValue
        md5sum                  = json["md5sum"].stringValue
        source                  = json["source"]["url"].stringValue
        mapId                   = json["map_id"].int
        lineCount               = json["map_id"].intValue
        measurementCount        = json["measurements_count"].intValue
        approved                = json["approved"].boolValue
        status                  = json["status"].stringValue
        
        statusDetails   = StatusDetails(
            importLogs: statusDetailsJson["import_bgeigie_logs"].boolValue,
            processFile: statusDetailsJson["process_file"].boolValue,
            computeLocation: statusDetailsJson["compute_latlng"].boolValue,
            createMap: statusDetailsJson["create_map"].boolValue,
            measurementsAdded: statusDetailsJson["measurements_added"].boolValue)
    }
}
