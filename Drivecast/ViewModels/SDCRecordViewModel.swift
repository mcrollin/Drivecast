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
    
    let title = MutableProperty<String>("")
    
    func connect() {
        do {
            let dataServiceIdentifiers                  = [CBUUID(string:"EF080D8C-C3BE-41FF-BD3F-05A5F4795D7F")]
            let dataServiceCharacteristicIdentifiers    = [CBUUID(string:"A1E8F5B1-696B-4E4C-87C6-69DFE0B0093B")]
            let endOfDataMark                           = "\r\n"
            
            let configuration = SDCBluetoothManagerConfiguration(dataServiceIdentifiers: dataServiceIdentifiers,
                dataServiceCharacteristicIdentifiers: dataServiceCharacteristicIdentifiers,
                endOfDataMark: endOfDataMark)
            
            manager.configuration = configuration
            manager.delegate = self
            
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
}

// MARK - SDCBluetoothManagerDelegate
extension SDCRecordViewModel: SDCBluetoothManagerDelegate {
    
    func managerStateDidChange(manager: SDCBluetoothManager, state: SDCBluetoothManager.State) {
        switch state {
        case .Unavailable, .Stopped:
            title.value = "Unable to connect".uppercaseString
            log("Turn BLE on please!")
        case .Ready:
            do {
                title.value = "scanning".uppercaseString
                log("Scanning for peripherals")
                try manager.startScanning()
            } catch {
                log(error)
            }
        default:
            return
        }
    }
    
    func managerDidDiscoverPeripheral(manager: SDCBluetoothManager, peripheral: SDCRemotePeripheral) {
        title.value = "connecting".uppercaseString
        log("Connecting to \(peripheral.peripheral.name)")
        
        do {
            try manager.stopScanning()
            try manager.connect(peripheral)
        } catch {
            log(error)
        }
    }
    
    func remotePeripheralDidConnect(manager: SDCBluetoothManager, peripheral: SDCRemotePeripheral) {
        title.value = peripheral.peripheral.name!
        log("Connected to \(peripheral.peripheral.name)")
    }
    
    func remotePeripheralDidDisconnect(manager: SDCBluetoothManager, peripheral: SDCRemotePeripheral) {
        log("Disconnected from \(peripheral.peripheral.name)")
    }
    
    func remotePeripheralDidSendNewData(peripheral: SDCRemotePeripheral, data: String) {
        log(data)
    }
}
