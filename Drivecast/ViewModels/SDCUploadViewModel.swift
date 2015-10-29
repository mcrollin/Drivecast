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
import KVNProgress

class SDCUploadViewModel: NSObject {
    
    let allMeasurements     = MutableProperty<Results<SDCMeasurement>?>(nil)
    let validMeasurements   = MutableProperty<Results<SDCMeasurement>?>(nil)
    let measurementScaleCPM = MutableProperty<Int>(0)
    let cpmValueString      = MutableProperty<String>("")
    let usvhValueString     = MutableProperty<String>("")
    let mapCenterCoordinate = MutableProperty<CLLocationCoordinate2D?>(nil)
    let actionString        = MutableProperty<String>("?".uppercaseString)
    
    // Action
    private(set) var uploadAction: Action<AnyObject?, SDCImport, SDCSafecastAPI.ImportError>? = nil
    
    override init() {
        super.init()
        
        initializeUploadAction()
    }
}

// MARK - Measurements
extension SDCUploadViewModel {
    
    // Retrieve all and valid measurements
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
    
    // Discard all measurements
    func discardAllMeasurements() {
        let realm   = try! Realm()
        let measurements = realm.objects(SDCMeasurement)
        
        // Delete all measurements
        try! realm.write {
            realm.delete(measurements)
        }
        
        // Update measurements to dismiss the upload screen and display the record button
        updateMeasurementData()
    }

}

// MARK - Import
extension SDCUploadViewModel {
    
    private func generateUploadData(data: NSData, filename: String,
        parameters: Dictionary<String, String>, boundaryConstant: String) -> NSData {
            let uploadData  = NSMutableData()
            
            uploadData.appendData("\r\n--\(boundaryConstant)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
            uploadData.appendData("Content-Disposition: form-data; name=\"bgeigie_import[source]\"; filename=\"\(filename)\"\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
            uploadData.appendData("Content-Type: application/octet-stream\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
            uploadData.appendData(data)
            
            for (key, value) in parameters {
                uploadData.appendData("\r\n--\(boundaryConstant)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
                uploadData.appendData("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n\(value)".dataUsingEncoding(NSUTF8StringEncoding)!)
            }
            
            uploadData.appendData("\r\n--\(boundaryConstant)--\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
            
            return uploadData
    }
    
    // Initializes the sign in button action
    private func initializeUploadAction() {
        uploadAction = Action() { _ in
            
            return SignalProducer { sink, _ in
                KVNProgress.show()
                
                let realm                       = try! Realm()
                let measurements                = realm.objects(SDCMeasurement)
                let measurementsData: [String]  = measurements.map { return $0.data }
                let logs                        = measurementsData.reduce("", combine: { $0 + "\r\n" + $1 })
                let key                         = SDCUser.authenticatedUser!.key
                let fileData                    = logs.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
                let boundaryConstant            = "Boundary-" + NSUUID().UUIDString
                let firstMeasurement            = measurements.first!
                let date                        = NSDate()
                let formatter                   = NSDateFormatter()
                formatter.dateFormat            = "MMdd"
                let filename                    = "\(firstMeasurement.deviceId)-\(formatter.stringFromDate(date)).LOG"
                let uploadData                  = self.generateUploadData(fileData!, filename: filename,
                    parameters: ["api_key": key], boundaryConstant: boundaryConstant)
                
                SDCSafecastAPI.createImport(uploadData, boundaryConstant: boundaryConstant) { result in
                    switch result {
                    case .Success(let logImport):
                        log(logImport)
                        
                        self.discardAllMeasurements()
                        
                        KVNProgress.showSuccess()
                    case .Failure(let error):
                        log(error)
                        KVNProgress.showError()
                    }
                }
            }
        }
    }
}

// MARK - BEMSimpleLineGraphDelegate
extension SDCUploadViewModel: BEMSimpleLineGraphDelegate {
    internal func minValueForLineGraph(graph: BEMSimpleLineGraphView) -> CGFloat {
        return 0
    }
    
    internal func lineGraph(graph: BEMSimpleLineGraphView, didTouchGraphWithClosestIndex index: Int) {
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