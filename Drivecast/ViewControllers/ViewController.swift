//
//  ViewController.swift
//  Drivecast
//
//  Created by Marc Rollin on 10/5/15.
//  Copyright © 2015 Safecast. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, SDCBluetoothManagerDelegate {
    let manager = SDCBluetoothManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
    
    func managerStateDidChange(manager: SDCBluetoothManager, state: SDCBluetoothManager.State) {
        switch state {
        case .Unavailable, .Stopped:
            log("Turn BLE on please!")
        case .Ready:
            do {
                try manager.startScanning()
            } catch {
                log(error)
            }
        default:
            return
        }
    }
    
    func managerDidDiscoverPeripheral(manager: SDCBluetoothManager, peripheral: SDCRemotePeripheral) {
        do {
            try manager.stopScanning()
            try manager.connect(peripheral)
        } catch {
            log(error)
        }
    }
    
    func remotePeripheralDidConnect(manager: SDCBluetoothManager, peripheral: SDCRemotePeripheral) {}
    func remotePeripheralDidDisconnect(manager: SDCBluetoothManager, peripheral: SDCRemotePeripheral) {}
    
    func remotePeripheralDidSendNewData(peripheral: SDCRemotePeripheral, data: String) {
        log(data)
    }
}
