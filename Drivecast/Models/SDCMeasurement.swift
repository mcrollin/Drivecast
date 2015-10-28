//
//  SDCMeasurement.swift
//  Drivecast
//
//  Created by Marc Rollin on 10/19/15.
//  Copyright © 2015 Safecast. All rights reserved.
//

import Foundation
import CoreLocation
import RealmSwift

class SDCMeasurement: Object {
    dynamic var data: String                    = ""
    dynamic var dataValidity: Bool              = false
    dynamic var deviceId: String                = ""
    dynamic var cpm: Int                        = 0
    dynamic var date: NSDate                    = NSDate()
    dynamic var latitude: Double                = 0.0
    dynamic var longitude: Double               = 0.0
    dynamic var altitude: CLLocationDistance    = 0.0
    dynamic var hdop: Int                       = 0
    dynamic var gpsValidity: Bool               = false

    var location: CLLocation { return CLLocation(latitude: latitude, longitude: longitude) }
    var coordinate: CLLocationCoordinate2D { return CLLocationCoordinate2DMake(latitude, longitude) }
    
    var usvh: Double { return Double(cpm) / 334 }
}

// MARK - Realm
extension SDCMeasurement {

    override static func indexedProperties() -> [String] {
        return ["date"]
    }
}

// MARK - RealmPersists
extension SDCMeasurement: RealmPersistable {
}

// MARK - Equatable
// Comparision method betweee two SDCMeasurement
func ==(lhs: SDCMeasurement, rhs: SDCMeasurement) -> Bool {
    return lhs.data == rhs.data
}