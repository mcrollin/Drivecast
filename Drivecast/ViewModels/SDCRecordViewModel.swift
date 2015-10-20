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
    let consoleText             = MutableProperty<NSAttributedString>(NSAttributedString())
    let lastMeasurement         = MutableProperty<SDCMeasurement?>(nil)
    let isReadyToRecord         = MutableProperty<Bool>(false)
    let isRecording             = MutableProperty<Bool>(false)
    let noticeIsVisible         = MutableProperty<Bool>(false)
    
    // Action
    private(set) var toggleRecordingAction: Action<AnyObject?, Bool, NoError>? = nil
    
    let emphasysAttributes: Dictionary<String, AnyObject>!
    let noticeAttributes: Dictionary<String, AnyObject>!
    let normalAttributes: Dictionary<String, AnyObject>!
    
    override init() {
        let paragraphStyle  = NSMutableParagraphStyle()
        
        paragraphStyle.lineSpacing      = 3
        paragraphStyle.paragraphSpacing = 9
        
        emphasysAttributes = [
            NSForegroundColorAttributeName  : UIColor(named: .Main),
            NSParagraphStyleAttributeName   : paragraphStyle
        ]
        
        noticeAttributes = [
            NSForegroundColorAttributeName  : UIColor(named: .Notice),
            NSParagraphStyleAttributeName   : paragraphStyle
        ]
        
        normalAttributes = [
            NSForegroundColorAttributeName  : UIColor(named: .Text),
            NSParagraphStyleAttributeName   : paragraphStyle
        ]
        
        super.init()
        
        initializeToggleRecordingAction()
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
                
                sendNext(sink, true)
                sendCompleted(sink)
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
                self.duration++
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
            log(error)
        }
    }
    
    // Disconnects from the device
    func disconnect() {
        do {
            try manager.stop()
        } catch {
            log(error)
        }
    }
    
    private func record(measurement: SDCMeasurement) {
        // If recordings are being parsed, then we are ready to record
        isReadyToRecord.value = true
        
        // Display a notice message if some elements of the measurement aren't valid
        if !measurement.dataValidity {
            showNotice("device is starting up")
        } else if !measurement.gpsValidity {
            showNotice("gps information is currently unavailable")
        } else {
            hideNotice()
        }
        
        // Update displayed information about the measurement
        cpmString.value         = "\(measurement.cpm)"
        usvhString.value        = String(format: "%.3f", measurement.usvh)
        
        // If recording update information about the recording
        if isRecording.value {
            
            // Update the count
            count++
            
            // Update the distance
            if let lastRecordedMeasurement = self.lastRecordedMeasurement,
                let lastMeasurement = self.lastMeasurement.value
                where lastRecordedMeasurement == lastMeasurement
                    && lastMeasurement.gpsValidity
                    && measurement.gpsValidity {
                        log("\(distance)")
                        
                        distance    += lastMeasurement.location.distanceFromLocation(measurement.location)
            }
            
            // Record measurement
            lastRecordedMeasurement = measurement
        }
    }
    
    private func updateActivity(line: String) {
        activityDetailsString.value = line.uppercaseString
    }
    
    enum ConsoleTextType {
        case Normal
        case Emphasys
        case Notice
    }
    
    private func printOnConsole(line: String, type: ConsoleTextType = .Normal) {
        let updatedText = NSMutableAttributedString()
        let line        = "\(line)\n"
        
        switch type {
        case .Normal:
            updatedText.appendAttributedString(
                NSAttributedString(
                    string: line,
                    attributes: normalAttributes))
            
        case .Emphasys:
            updatedText.appendAttributedString(
                NSAttributedString(
                    string: "> \(line)".uppercaseString,
                    attributes: emphasysAttributes))
            
        case .Notice:
            updatedText.appendAttributedString(
                NSAttributedString(
                    string: "! \(line)".uppercaseString,
                    attributes: noticeAttributes))
            
        }
        
        updatedText.appendAttributedString(consoleText.value)
        
        consoleText.value = updatedText
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
            let activity = "your Bluetooth is turned OFF or disabled\nplease turn it back ON to continue"
             
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
                log(error)
            }
        default:
            return
        }
    }
    
    internal func managerDidDiscoverPeripheral(manager: SDCBluetoothManager, peripheral: SDCBluetoothRemotePeripheral) {

        var activity: String
        
        if let peripheralName = peripheral.peripheral.name {
            title.value = peripheralName.uppercaseString
            activity    = "connecting to \(peripheralName)."
        } else {
            title.value = "connecting".uppercaseString
            activity    = "connecting to the device."
        }
        
        printOnConsole(activity, type: .Emphasys)
        updateActivity(activity)
        
        do {
            try manager.stopScanning()
            try manager.connect(peripheral)
        } catch {
            log(error)
        }
    }
    
    internal func remotePeripheralDidConnect(manager: SDCBluetoothManager, peripheral: SDCBluetoothRemotePeripheral) {

        var activity: String
        
        if let peripheralName = peripheral.peripheral.name {
            title.value = peripheralName.uppercaseString
            printOnConsole("connected to \(peripheralName).", type: .Emphasys)
            activity    = "awaiting a first measurement from \(peripheralName)."
        } else {
            title.value = "connected".uppercaseString
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
        // Parse raw data into a dictionary
        guard let measurementDictionary = data.parseMeasurementData() else {
            return
        }

        // Construct the measurement
        let measurement = SDCMeasurement(value: measurementDictionary)
        
        // Record measurement
        record(measurement)
        
        // Save last measurement
        lastMeasurement.value   = measurement
        
        printOnConsole(measurement.data)
    }
}
