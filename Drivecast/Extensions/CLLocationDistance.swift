//
//  CLLocationDistance.swift
//  Drivecast
//
//  Created by Marc Rollin on 10/20/15.
//  Copyright © 2015 Safecast. All rights reserved.
//

import Foundation
import CoreLocation

extension CLLocationDistance {
    // Retrieves the unit based on your device configuration
    static func distanceUnit() -> String {
        let metric:Bool = NSLocale.currentLocale().objectForKey(NSLocaleUsesMetricSystem)!.boolValue
        
        return metric ? "km" : "mi"
    }
    
    // Transforms the distance into a human readable string
    func stringWithUnit() -> String {
        let metric:Bool = NSLocale.currentLocale().objectForKey(NSLocaleUsesMetricSystem)!.boolValue
        let distance    = self / (metric ? 1000 : 1609.34)
        
        if distance >= 100 {
            return String(format:"%.0f", distance)
        }
        
        return String(format:"%.01f", distance) + " " + CLLocationDistance.distanceUnit()
    }
}