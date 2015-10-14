//
//  SDCBluetoothManagerConfiguration.swift
//  Drivecast
//
//  Created by Marc Rollin on 10/13/15.
//  Copyright © 2015 Safecast. All rights reserved.
//

import Foundation
import CoreBluetooth

/**
    Struct that represents a configuration used by the SDCBluetoothManager.
*/
struct SDCBluetoothManagerConfiguration {
    // UUIDs for the service used to send data
    let dataServiceIdentifiers: [CBUUID]
    
    // UUIDs for the characteristic used to send data
    let dataServiceCharacteristicIdentifiers: [CBUUID]
    
    // Data indicating the end of a transmission
    let endOfDataMark: String
}
