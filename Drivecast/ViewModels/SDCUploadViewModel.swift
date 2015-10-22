//
//  SDCUploadViewModel.swift
//  Drivecast
//
//  Created by Marc Rollin on 10/15/15.
//  Copyright © 2015 Safecast. All rights reserved.
//

import Foundation
import ReactiveCocoa
import RealmSwift
import BEMSimpleLineGraph

class SDCUploadViewModel: NSObject {
    
    let allMeasurements     = MutableProperty<Results<SDCMeasurement>?>(nil)
    let validMeasurements   = MutableProperty<Results<SDCMeasurement>?>(nil)
    let measurementScaleCPM = MutableProperty<Int>(0)
    let cpmValueString      = MutableProperty<String>("")
    let usvhValueString     = MutableProperty<String>("")
    let mapCenterCoordinate = MutableProperty<CLLocationCoordinate2D?>(nil)
    let actionString        = MutableProperty<String>("?".uppercaseString)
}

// MARK - Measurements
extension SDCUploadViewModel {
    
    // Retrieves all and valid measurements
    func updateMeasurementData() {
        let realm           = try! Realm()
        
        allMeasurements.value   = realm.objects(SDCMeasurement)
        validMeasurements.value = allMeasurements.value?
            .sorted("date")
            .filter("dataValidity = true && gpsValidity = true")
        
        if let count = allMeasurements.value?.count {
            actionString.value = "You have \(count) measurements".uppercaseString
        }
    }
}

// MARK - BEMSimpleLineGraphDelegate
extension SDCUploadViewModel: BEMSimpleLineGraphDelegate {
    func minValueForLineGraph(graph: BEMSimpleLineGraphView) -> CGFloat {
        return 0
    }
    
    func lineGraph(graph: BEMSimpleLineGraphView, didTouchGraphWithClosestIndex index: Int) {
        guard let measurement = measurementForIndex(index) else {
            return
        }
        
        measurementScaleCPM.value   = measurement.cpm
        cpmValueString.value        = "\(measurement.cpm)"
        usvhValueString.value       = String(format: "%.3f", measurement.usvh)
        mapCenterCoordinate.value   = measurement.coordinate
    }
}

// MARK - BEMSimpleLineGraphDataSource
extension SDCUploadViewModel: BEMSimpleLineGraphDataSource {
    
    // Retrieves the measurement based on the number of displayed points
    private func measurementForIndex(var index: Int) -> SDCMeasurement? {
        guard let validMeasurements = validMeasurements.value else {
            return nil
        }
        
        let maxPoints   = SDCConfiguration.UI.lineGraphMaxPoints
        
        if validMeasurements.count > maxPoints {
            index = index * validMeasurements.count / maxPoints
        }
        
        return validMeasurements[index]
    }
    
    internal func numberOfPointsInLineGraph(graph: BEMSimpleLineGraphView) -> Int {
        guard let validMeasurements = validMeasurements.value else {
            return 0
        }
        
        let maxPoints   = SDCConfiguration.UI.lineGraphMaxPoints
        
        return validMeasurements.count > maxPoints ?
            maxPoints : validMeasurements.count
    }
    
    internal func lineGraph(graph: BEMSimpleLineGraphView, valueForPointAtIndex index: Int) -> CGFloat {
        return CGFloat(measurementForIndex(index)?.cpm ?? 0)
    }
}