//
//  SDCConnectPeripheralViewModel.swift
//  Drivecast
//
//  Created by Marc Rollin on 10/14/15.
//  Copyright © 2015 Safecast. All rights reserved.
//

import Foundation
import CoreBluetooth
import ReactiveCocoa
import enum Result.NoError

class SDCRecordViewModel: NSObject {
    private let manager = SDCBluetoothManager()
    private var timer: NSTimer?
    private var lastRecordedMeasurement: SDCMeasurement? {
        didSet {
            lastRecordedMeasurement?.add()
        }
    }
    
    private var duration: NSTimeInterval        = 0 { didSet { durationString.value = duration.clockString() } }
    private var distance: CLLocationDistance    = 0 { didSet { distanceString.value = distance.stringWithUnit() } }
    private var count: Int                      = 0 { didSet { countString.value    = "\(count)" } }
    
    let title                   = MutableProperty<String>("")
    let activityDetailsString   = MutableProperty<String>("")
    let noticeString            = MutableProperty<String>("")
    let actionButtonString      = MutableProperty<String>("start recording".uppercaseString)
    let cpmString               = MutableProperty<String>("0")
    let usvhString              = MutableProperty<String>("0")
    let countString             = MutableProperty<String>("0")
    let distanceString          = MutableProperty<String>(0.0.stringWithUnit())
    let durationString          = MutableProperty<String>("00:00:00")
    let consoleArray            = MutableProperty<Array<ConsoleEntry>>([])
    let lastMeasurement         = MutableProperty<SDCMeasurement?>(nil)
    let isReadyToRecord         = MutableProperty<Bool>(false)
    let isRecording             = MutableProperty<Bool>(false)
    let noticeIsVisible         = MutableProperty<Bool>(false)
    
    // Actions
    private(set) var toggleRecordingAction: Action<AnyObject?, Bool, NoError>? = nil
    private(set) var simulateDeviceAction: Action<AnyObject?, Bool, NoError>? = nil
    
    struct ConsoleEntry {
        let text: String
        let color: UIColor
    }
    
    enum ConsoleEntryType {
        case Normal
        case Emphasys
        case Notice
    }

    
    override init() {
        super.init()
        
        initializeToggleRecordingAction()
        initializeSimulateDeviceAction()
    }
    
    // Initializes the toogle recording button action
    private func initializeToggleRecordingAction() {
        toggleRecordingAction = Action(enabledIf:isReadyToRecord) { _ in
            return SignalProducer { sink, _ in
                self.isRecording.value = !self.isRecording.value
                
                if self.isRecording.value {
                    self.printOnConsole("started recording", type: .Emphasys)
                    self.actionButtonString.value = "pause recording".uppercaseString
                    self.timer = self.resumeTimer()

                } else {
                    self.printOnConsole("stopped recording", type: .Emphasys)
                    self.actionButtonString.value = "resume recording".uppercaseString
                }
                
                sink.sendNext(true)
                sink.sendCompleted()
            }
        }
    }
    
    private func generateSimulationMeasurement(deviceId: String, latitude: Double, longitude: Double) -> SDCMeasurement {
        let measurement             = SDCMeasurement()
        
        measurement.deviceId        = deviceId
        measurement.cpm             = Int(arc4random_uniform(75) + 25)
        measurement.latitude        = latitude
        measurement.longitude       = longitude
        measurement.date            = NSDate()
        measurement.dataValidity    = true
        measurement.gpsValidity     = true
        measurement.data            = "SIMULATED DATA"
        
        return measurement
    }
    
    // Simulates Device Measurements (only used in DEBUG mode)
    private func simulateDevice() -> NSTimer {
        
        let precision               = 100000.0
        let deviceId                = "42"
        var latitude                = 52.507534 // Checkpoint Charlie
        var longitude               = 13.390375 // location in Berlin
        
        handleMeasurement(generateSimulationMeasurement(deviceId,
            latitude: latitude, longitude: longitude))
        
        return NSTimer.schedule(repeatInterval: 1.0) { timer in
            let deltaLatitude: Double   = Double(arc4random_uniform(10)) * (arc4random_uniform(2) == 0 ? 1.0 : -1.0) / precision
            let deltaLongitude: Double  = Double(arc4random_uniform(10)) * (arc4random_uniform(2) == 0 ? 1.0 : -1.0) / precision
            
            latitude    += deltaLatitude
            longitude   += deltaLongitude
            
            self.handleMeasurement(self.generateSimulationMeasurement(deviceId,
                latitude: latitude, longitude: longitude))
        }
    }
    
    // Initializes the toogle recording button action
    private func initializeSimulateDeviceAction() {
        simulateDeviceAction = Action() { _ in
            return SignalProducer { sink, _ in
                
                self.disconnect()
                
                self.title.value            = "Device Simulator"
                self.isReadyToRecord.value  = true
                
                self.simulateDevice()
                
                sink.sendNext(true)
                sink.sendCompleted()
            }
        }
    }
    
    // Resumes the timer
    private func resumeTimer() -> NSTimer {
        // Avoids multiple timers to be started at the same time
        self.timer?.invalidate()
        
        return NSTimer.schedule(repeatInterval: 1.0) { timer in
            if (self.isReadyToRecord.value
                && self.isRecording.value) {
                self.duration += 1
            } else if !self.isRecording.value {
                self.timer?.invalidate()
            }
        }
    }
    
    // Stats connection with the device
    func connect() {
        do {
            let services        = SDCConfiguration.BLEDevice.BGeigie.dataServiceIdentifiers
            let characteristics = SDCConfiguration.BLEDevice.BGeigie.dataServiceCharacteristicIdentifiers
            let mark            = SDCConfiguration.BLEDevice.BGeigie.endOfDataMark
            let configuration   = SDCBluetoothManagerConfiguration(
                dataServiceIdentifiers: services,
                dataServiceCharacteristicIdentifiers: characteristics,
                endOfDataMark: mark
            )
            
            manager.configuration   = configuration
            manager.delegate        = self
            
            try manager.start()
        } catch {
            dlog(error)
        }
    }
    
    // Disconnects from the device
    func disconnect() {
        do {
            try manager.stop()
        } catch {
            dlog(error)
        }
    }
    
    private func handleData(data: String) {
        // Parse raw data into a dictionary
        guard let measurement = SDCMeasurement.fromData(data) else {
            return
        }
        
        handleMeasurement(measurement)
    }
    
    private func handleMeasurement(measurement: SDCMeasurement) {
        // Record measurement
        record(measurement)
        
        // Save last measurement
        lastMeasurement.value   = measurement
        
        printOnConsole(measurement.data)
    }
    
    private func record(measurement: SDCMeasurement) {
        // If recordings are being parsed, then we are ready to record
        isReadyToRecord.value = true
        
        // Display a notice message if some elements of the measurement aren't valid
        if !measurement.dataValidity {
            showNotice("device is starting up")
        } else if !measurement.gpsValidity {
            showNotice("gps is unavailable")
        } else {
            hideNotice()
        }
        
        // Setting the screen's title using the device id
        title.value             = "bGeigie Nano #\(measurement.deviceId)".uppercaseString
        
        // Update displayed information about the measurement
        cpmString.value         = "\(measurement.cpm)"
        usvhString.value        = String(format: "%.3f", measurement.usvh)
        
        // If recording update information about the recording
        if isRecording.value {
            
            // Update the count
            count += 1
            
            // Update the distance
            if let lastRecordedMeasurement = self.lastRecordedMeasurement,
                let lastMeasurement = self.lastMeasurement.value
                where lastRecordedMeasurement == lastMeasurement
                    && lastMeasurement.gpsValidity
                    && measurement.gpsValidity {
                        distance    += lastMeasurement.location.distanceFromLocation(measurement.location)
            }
            
            // Record measurement
            lastRecordedMeasurement = measurement
        }
    }
    
    private func updateActivity(line: String) {
        activityDetailsString.value = line.uppercaseString
    }
    
    private func printOnConsole(line: String, type: ConsoleEntryType = .Normal) {
        let entry: ConsoleEntry!
        
        switch type {
        case .Normal:
            entry = ConsoleEntry(text: line, color: UIColor(named: .Text))
            
        case .Emphasys:
            entry = ConsoleEntry(text: line.uppercaseString, color: UIColor(named: .Main))

        case .Notice:
            entry = ConsoleEntry(text: line.uppercaseString, color: UIColor(named: .Notice))
            
        }
        
        consoleArray.value.append(entry)
    }
    
    private func showNotice(message: String) {
        let notice = message.uppercaseString
        
        if notice != noticeString.value {
            printOnConsole(notice, type: .Notice)
            
            noticeString.value      = notice
            noticeIsVisible.value   = true
        }
    }
    
    private func hideNotice() {
        noticeIsVisible.value   = false
    }
}

// MARK - SDCBluetoothManagerDelegate
extension SDCRecordViewModel: SDCBluetoothManagerDelegate {
    
    internal func managerStateDidChange(manager: SDCBluetoothManager, state: SDCBluetoothManager.State) {
        switch state {
        case .Unavailable, .Stopped:
            let activity = "please turn your bluetooth on to continue"
             
            printOnConsole(activity, type: .Emphasys)
            updateActivity(activity)
            title.value = "unable to connect".uppercaseString
            
        case .Ready:
            do {
                let activity = "scanning for compatible devices"
                
                printOnConsole(activity, type: .Emphasys)
                updateActivity(activity)
                
                title.value = "scanning".uppercaseString
                
                try manager.startScanning()
            } catch {
                dlog(error)
            }
        default:
            return
        }
    }
    
    internal func managerDidDiscoverPeripheral(manager: SDCBluetoothManager, peripheral: SDCBluetoothRemotePeripheral) {

        var activity: String
        
        title.value = "connecting".uppercaseString
        
        if let peripheralName = peripheral.peripheral.name {
            activity    = "connecting to \(peripheralName)."
        } else {
            activity    = "connecting to the device."
        }
        
        printOnConsole(activity, type: .Emphasys)
        updateActivity(activity)
        
        do {
            try manager.stopScanning()
            try manager.connect(peripheral)
        } catch {
            dlog(error)
        }
    }
    
    internal func remotePeripheralDidConnect(manager: SDCBluetoothManager, peripheral: SDCBluetoothRemotePeripheral) {

        var activity: String
        
        title.value = "connected".uppercaseString
        
        if let peripheralName = peripheral.peripheral.name {
            printOnConsole("connected to \(peripheralName).", type: .Emphasys)
            activity    = "awaiting a first measurement from \(peripheralName)."
        } else {
            printOnConsole("connected to the device.", type: .Emphasys)
            activity    = "awaiting a first measurement."
        }
        
        printOnConsole(activity, type: .Emphasys)
        updateActivity(activity)
    }
    
    internal func remotePeripheralDidDisconnect(manager: SDCBluetoothManager, peripheral: SDCBluetoothRemotePeripheral) {
        isReadyToRecord.value = false
        
        if let peripheralName = peripheral.peripheral.name {
            printOnConsole("disconnected from \(peripheralName).", type: .Emphasys)
        } else {
            printOnConsole("disconnected from the device", type: .Emphasys)
        }
    }
    
    internal func remotePeripheralDidSendNewData(peripheral: SDCBluetoothRemotePeripheral, data: String) {
        handleData(data)
    }
}
