//
//  SDCConfiguration.swift
//  Drivecast
//
//  Created by Marc Rollin on 10/14/15.
//  Copyright © 2015 Safecast. All rights reserved.
//

import UIKit
import CoreBluetooth

// Application configuration
struct SDCConfiguration {
    
    struct UI {
        static let circleWidth: CGFloat = 12.0
        static let lineGraphMaxPoints   = 40
        
        struct TabBarMenu {
            static let Dashboard        = 0
            static let Record           = 1
            static let Upload           = 2
        }
    }
    
    struct API {
        static let locale   = "en-US"
        
        #if STAGING
        // Safecast's staging API's base URL
        static let baseURL  = "http://api.staging.safecast.org/" + locale
        
        #else
        // Safecast's production API's base URL
        static let baseURL  = "https://api.safecast.org/" + locale
        
        #endif
    }
    
    struct Map {
        static let baseURL  = "http://safecast.org/tilemap/"
    }

    // A list of supported BLE Devices with their configuration
    struct BLEDevice {
        
        struct BGeigie {
            // End mark used to parse received data from the device
            static let endOfDataMark    = "\r\n"
            
            // UUID of compatible services for BLE devices
            static let dataServiceIdentifiers = [
                // BLEBee Service v1.0.0
                // https://github.com/michaelkroll/BLEbee/blob/master/firmware/BLEbee-v1.0.0/gatt.xml
                // https://github.com/michaelkroll/BLEbee/blob/master/firmware/BLEbee-v1.0.1/BLEBee-gatt.xml
                // https://github.com/michaelkroll/BLEbee/blob/master/firmware/BLEbee-v2.0.1/BLEBee-gatt.xml
                CBUUID(string: "EF080D8C-C3BE-41FF-BD3F-05A5F4795D7F"),
                
                // BLEBee Service v2.0.0
                // https://github.com/michaelkroll/BLEbee/blob/master/firmware/BLEbee-v2.0.0/BLEBee-gatt.xml
                CBUUID(string: "067978AC-B59F-4EC9-9C09-2AB6E5BDAD0B"),
            ]
            
            // UUID of compatible services' characteristics for BLE devices
            static let dataServiceCharacteristicIdentifiers = [
                // BLEBee Service v1.0.0 / Characteristic RX
                // https://github.com/michaelkroll/BLEbee/blob/master/firmware/BLEbee-v1.0.0/gatt.xml
                // https://github.com/michaelkroll/BLEbee/blob/master/firmware/BLEbee-v1.0.1/BLEBee-gatt.xml
                // https://github.com/michaelkroll/BLEbee/blob/master/firmware/BLEbee-v2.0.1/BLEBee-gatt.xml
                CBUUID(string: "A1E8F5B1-696B-4E4C-87C6-69DFE0B0093B"),
                
                // BLEBee Service v2.0.0 / Characteristic Data
                // https://github.com/michaelkroll/BLEbee/blob/master/firmware/BLEbee-v2.0.0/BLEBee-gatt.xml
                CBUUID(string: "067978AC-B99F-4EC9-9C09-2AB6E5BDAD0B"),
            ]
        }
        
        // Not supported yet
        struct OnyxBlue {
            // UUID of compatible services for BLE devices
            static let dataServiceIdentifiers = [
                // Blue Onyx (REVA-009)
                CBUUID(string: "180D")
            ]
            
            // UUID of compatible services' characteristics for BLE devices
            static let dataServiceCharacteristicIdentifiers = [
                // Blue Onyx (REVA-009)
                CBUUID(string: "2A37")
            ]
        }
    }
}