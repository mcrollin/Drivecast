//
//  SDCMultiMeasurementOverlay.swift
//  safecaster
//
//  Created by Marc Rollin on 10/16/15.
//  Copyright © 2015 Safecast. All rights reserved.
//

import UIKit
import MapKit

class SDCMultiMeasurementOverlay: NSObject, MKOverlay {
    var measurements: [SDCMeasurementOverlay!]!
    var bounds: MKMapRect!
    
    var coordinate: CLLocationCoordinate2D {
        get {
            return MKCoordinateForMapPoint(MKMapPointMake(MKMapRectGetMidX(boundingMapRect), MKMapRectGetMidY(boundingMapRect)))
        }
    }
    
    var boundingMapRect: MKMapRect {
        get {
            return self.bounds
        }
    }

    convenience required init(measurements: [SDCMeasurementOverlay!]) {
        self.init()
        
        self.measurements   = measurements
        self.bounds         = MKMapRectNull
        
        for measurement in measurements {
            bounds = MKMapRectUnion(bounds, measurement.boundingMapRect)
        }
    }
}
