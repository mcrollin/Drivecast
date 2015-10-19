//
//  SDCMeasurement.swift
//  Drivecast
//
//  Created by Marc Rollin on 10/19/15.
//  Copyright © 2015 Safecast. All rights reserved.
//

import Foundation
import CoreLocation

struct SDCMeasurement {
    let data: String
    let dataValidity: Bool
    let deviceId: String
    let cpm: Int
    let date: NSDate
    let location: CLLocation
    let altitude: CLLocationDistance
    let hdop: Int
    let gpsValidity: Bool
    
    var usvh:Double { return Double(cpm) / 334 }
}

extension SDCMeasurement {
    init (dictionary: Dictionary<String, AnyObject>) {
        data            = dictionary["data"] as! String
        dataValidity    = dictionary["dataValidity"] as! Bool
        deviceId        = dictionary["deviceId"] as! String
        cpm             = dictionary["CPM"] as! Int
        date            = dictionary["date"] as! NSDate
        location        = CLLocation(
            latitude:   dictionary["latitude"] as! Double,
            longitude:  dictionary["longitude"] as! Double)
        altitude        = dictionary["altitude"] as! CLLocationDistance
        hdop            = dictionary["HDOP"] as! Int
        gpsValidity     = dictionary["GPSValidity"] as! Bool
    }
}