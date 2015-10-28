//
//  SDCImport.swift
//  Drivecast
//
//  Created by Marc Rollin on 10/14/15.
//  Copyright © 2015 Safecast. All rights reserved.
//

import Foundation
import SwiftyJSON
import RealmSwift

final class SDCImport: Object {
    dynamic var id: Int                         = 0
    dynamic var userId: Int                     = 0
    dynamic var createdAt: NSDate               = NSDate()
    dynamic var updatedAt: NSDate               = NSDate()
    dynamic var name: String                    = ""
    dynamic var cities: String                  = ""
    dynamic var credits: String                 = ""
    dynamic var details: String                 = ""
    dynamic var height: String                  = ""
    dynamic var orientation: String             = ""
    dynamic var md5sum: String                  = ""
    dynamic var source: String                  = ""
    dynamic var mapId: Int                      = 0
    dynamic var lineCount: Int                  = 0
    dynamic var measurementCount: Int           = 0
    dynamic var approved: Bool                  = false
    dynamic var status: String                  = ""
    dynamic var statusDetails: StatusDetails    = StatusDetails()
    
    class StatusDetails: NSObject {
        dynamic var importLogs: Bool            = false
        dynamic var processFile: Bool           = false
        dynamic var computeLocation: Bool       = false
        dynamic var createMap: Bool             = false
        dynamic var measurementsAdded: Bool     = false
    }
    
    enum ProgressStatus {
        case Uploaded
        case Processed
        case MetadataAdded
        case Submitted
        case Approved
        case Rejected
        case Live
    }
    
    var progress:ProgressStatus {
        if (!statusDetails.processFile || !statusDetails.importLogs) {
            return .Uploaded
        } else if (cities != "" || credits != "") {
            return .Processed
        } else if status == "processed" {
            return .MetadataAdded
        } else if status == "submitted" {
            return .Submitted
        } else if (approved && !statusDetails.measurementsAdded) {
            return .Approved
        } else if !approved {
            return .Rejected
        }
        
        return .Live
    }
}

extension SDCImport: JSONDecodable {
    
    static func json(json: JSON) -> SDCImport {
        let statusJson          = json["status_details"]
        let utcFormatter        = NSDateFormatter()
        utcFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        utcFormatter.timeZone   = NSTimeZone(name: "UTC")
        
        let statusDetails               = StatusDetails()
        statusDetails.importLogs        = statusJson["import_bgeigie_logs"].boolValue
        statusDetails.processFile       = statusJson["process_file"].boolValue
        statusDetails.computeLocation   = statusJson["compute_latlng"].boolValue
        statusDetails.createMap         = statusJson["create_map"].boolValue
        statusDetails.measurementsAdded = statusJson["measurements_added"].boolValue
        
        var value: Dictionary<String, AnyObject> = [:]
        
        value["id"]                 = json["id"].intValue
        value["userId"]             = json["userId"].intValue
        value["createdAt"]          = utcFormatter.dateFromString(json["created_at"].stringValue)!
        value["updatedAt"]          = utcFormatter.dateFromString(json["updated_at"].stringValue)!
        value["name"]               = json["name"].stringValue
        value["cities"]             = json["cities"].stringValue
        value["credits"]            = json["credits"].stringValue
        value["details"]            = json["description"].stringValue
        value["height"]             = json["height"].stringValue
        value["orientation"]        = json["orientation"].stringValue
        value["md5sum"]             = json["md5sum"].stringValue
        value["source"]             = json["source"]["url"].stringValue
        value["mapId"]              = json["map_id"].intValue
        value["lineCount"]          = json["line_count"].intValue
        value["measurementCount"]   = json["measurements_count"].intValue
        value["approved"]           = json["approved"].boolValue
        value["statusDetails"]          = statusDetails
        
        return SDCImport(value: value)
    }
}

// MARK - Realm
extension SDCImport {
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    override static func indexedProperties() -> [String] {
        return ["createdAt", "updatedAt"]
    }
}

// MARK - Equatable
// Comparision method betweee two SDCImport
func ==(lhs: SDCImport, rhs: SDCImport) -> Bool {
    return lhs.id == rhs.id
}
