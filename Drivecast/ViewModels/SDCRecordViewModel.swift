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
    
    let title           = MutableProperty<String>("")
    let consoleText     = MutableProperty<NSAttributedString>(NSAttributedString())
    let readyToRecord   = MutableProperty<Bool>(false)
    let lastMeasurement = MutableProperty<SDCMeasurement?>(nil)
    let cpmString       = MutableProperty<String>("0")
    
    let emphasysAttributes: Dictionary<String, AnyObject>!
    let normalAttributes: Dictionary<String, AnyObject>!
    
    override init() {
        let paragraphStyle  = NSMutableParagraphStyle()
        
        paragraphStyle.lineSpacing      = 3
        paragraphStyle.paragraphSpacing = 9
        
        emphasysAttributes = [
            NSForegroundColorAttributeName  : UIColor(named: UIColor.Name.Main),
            NSParagraphStyleAttributeName   : paragraphStyle
        ]
        
        normalAttributes = [
            NSForegroundColorAttributeName  : UIColor(named: UIColor.Name.TextColor),
            NSParagraphStyleAttributeName   : paragraphStyle
        ]
        
        super.init()
    }
    
    func connect() {
        do {
            let services        = SDCConfiguration.BLE.Drivecast.dataServiceIdentifiers
            let characteristics = SDCConfiguration.BLE.Drivecast.dataServiceCharacteristicIdentifiers
            let mark            = SDCConfiguration.BLE.Drivecast.endOfDataMark
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
    
    func disconnect() {
        do {
            try manager.stop()
        } catch {
            log(error)
        }
    }
    
    private func printOnConsole(line: String, emphasys: Bool = false) {
        let updatedText = NSMutableAttributedString()
        let line        = "\(line)\n"
        
        if emphasys {
            updatedText.appendAttributedString(
                NSAttributedString(
                    string: "> \(line)".uppercaseString,
                    attributes: emphasysAttributes))
        } else {
            updatedText.appendAttributedString(
                NSAttributedString(
                    string: line,
                    attributes: normalAttributes))
        }
        
        updatedText.appendAttributedString(consoleText.value)
        
        consoleText.value = updatedText
    }
}

// MARK - SDCBluetoothManagerDelegate
extension SDCRecordViewModel: SDCBluetoothManagerDelegate {
    
    func managerStateDidChange(manager: SDCBluetoothManager, state: SDCBluetoothManager.State) {
        switch state {
        case .Unavailable, .Stopped:
            printOnConsole("Bluetooth is off", emphasys: true)
            title.value = "Unable to connect".uppercaseString
            
        case .Ready:
            do {
                printOnConsole("Scanning for compatible devices", emphasys: true)
                title.value = "scanning".uppercaseString
                try manager.startScanning()
            } catch {
                log(error)
            }
        default:
            return
        }
    }
    
    func managerDidDiscoverPeripheral(manager: SDCBluetoothManager, peripheral: SDCBluetoothRemotePeripheral) {
        title.value = "connecting".uppercaseString
        
        if let peripheralName = peripheral.peripheral.name {
            printOnConsole("Connecting to \(peripheralName)", emphasys: true)
        } else {
            printOnConsole("Connecting to the device", emphasys: true)
        }
        
        do {
            try manager.stopScanning()
            try manager.connect(peripheral)
        } catch {
            log(error)
        }
    }
    
    func remotePeripheralDidConnect(manager: SDCBluetoothManager, peripheral: SDCBluetoothRemotePeripheral) {
        title.value = peripheral.peripheral.name!

        if let peripheralName = peripheral.peripheral.name {
            printOnConsole("Connected to \(peripheralName)", emphasys: true)
        } else {
            printOnConsole("Connected to the device", emphasys: true)
        }
    }
    
    func remotePeripheralDidDisconnect(manager: SDCBluetoothManager, peripheral: SDCBluetoothRemotePeripheral) {
        readyToRecord.value = false
        
        if let peripheralName = peripheral.peripheral.name {
            printOnConsole("Disconnected from \(peripheralName)", emphasys: true)
        } else {
            printOnConsole("Disconnected from the device", emphasys: true)
        }
    }
    
    func remotePeripheralDidSendNewData(peripheral: SDCBluetoothRemotePeripheral, data: String) {
        printOnConsole(data)
        
        if let measurementDictionary = data.parseMeasurementData() {
            readyToRecord.value = true

            let measurement = SDCMeasurement(dictionary: measurementDictionary)
            
            log(measurement)
            
            lastMeasurement.value   = measurement
            cpmString.value         = "\(measurement.cpm) CPM"
        }
    }
}
