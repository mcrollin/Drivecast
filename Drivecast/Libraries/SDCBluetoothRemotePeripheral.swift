//
//  SDCBluetoothRemotePeripheral.swift
//  Drivecast
//
//  Created by Marc Rollin on 10/13/15.
//  Copyright © 2015 Safecast. All rights reserved.
//

import Foundation
import CoreBluetooth

// MARK - Delegate Protocol
protocol SDCBluetoothRemotePeripheralDelegate {
    func remotePeripheralDidSendNewData(peripheral: SDCBluetoothRemotePeripheral, data: String)
}

// Encapsulates a bluetooth peripheral.
class SDCBluetoothRemotePeripheral: NSObject {
    
    // Bluetooth peripheral
    let peripheral: CBPeripheral

    // Direct accessor to the peripheral properties
    var identifier: NSUUID { return peripheral.identifier }
    var state: CBPeripheralState { return peripheral.state }
    
    // Services configuration
    let configuration: SDCBluetoothManagerConfiguration?
    
    // Delegate instance
    var delegate: SDCBluetoothRemotePeripheralDelegate?
    
    // Data buffer string
    private var buffer: String = ""
    
    enum Error: ErrorType {
        case PeripheralNeedToBeConnected
    }
    
    required init(peripheral: CBPeripheral, configuration: SDCBluetoothManagerConfiguration?) {
        self.peripheral     = peripheral
        self.configuration  = configuration
        
        super.init()
        
        peripheral.delegate = self
    }
}

// MARK - Equatable
// Comparision method betweee two SDCRemotePeripheral
func ==(lhs: SDCBluetoothRemotePeripheral, rhs: SDCBluetoothRemotePeripheral) -> Bool {
    return lhs.identifier.UUIDString == rhs.identifier.UUIDString
}

// MARK - Public methods
extension SDCBluetoothRemotePeripheral {
    func discover() throws {
        // Device needs to be connected in order to discovering its services
        guard peripheral.state == .Connected else {
            throw SDCBluetoothRemotePeripheral.Error.PeripheralNeedToBeConnected
        }
        
        // Starts the service discovery process
        peripheral.discoverServices(configuration?.dataServiceIdentifiers)
    }
}

// MARK - Private methods
extension SDCBluetoothRemotePeripheral {
    private func handleReceivedData(data: NSData) {
        let dataString = String(data: data, encoding: NSUTF8StringEncoding)!
        
        // If no mark is specified the data will be sent as received
        guard let endOfDataMark = configuration?.endOfDataMark else {
            self.delegate?.remotePeripheralDidSendNewData(self, data: dataString)
            
            return
        }
        
        // Append new data to the buffer
        buffer += dataString
        
        // Split it based on the endOfDataMark
        var dataArray = buffer.componentsSeparatedByString(endOfDataMark)
        
        // Moving the last element back to the buffer
        buffer = dataArray.last!
        dataArray.removeLast()
        
        // Sending data by chunk based on the endOfDataMark
        for dataString in dataArray {
            self.delegate?.remotePeripheralDidSendNewData(self, data: dataString)
        }
    }
}

// MARK - CBPeripheralDelegate
extension SDCBluetoothRemotePeripheral: CBPeripheralDelegate {
    internal func peripheralDidUpdateName(peripheral: CBPeripheral) {}
    internal func peripheralDidUpdateRSSI(peripheral: CBPeripheral, error: NSError?) {}

    internal func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        
        // Iterate to find the data characteristic in the services discovered
        for service in peripheral.services! {
            peripheral.discoverCharacteristics(configuration?.dataServiceCharacteristicIdentifiers, forService: service)
        }
    }
    
    internal func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {

        // Subscribe to updates on the data service's characteristic
        if let characteristic = service.characteristics?.last {
            peripheral.setNotifyValue(true, forCharacteristic: characteristic)
        }
    }
    
    internal func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        
        // Let the handler take care of the data received
        if let data = characteristic.value {
            self.handleReceivedData(data)
        }
    }
}