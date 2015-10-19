//
//  SDCBluetoothManager.swift
//  Drivecast
//
//  Created by Marc Rollin on 10/13/15.
//  Copyright © 2015 Safecast. All rights reserved.
//

import Foundation
import CoreBluetooth

// MARK - Delegate Protocol
protocol SDCBluetoothManagerDelegate {
    func managerStateDidChange(manager: SDCBluetoothManager, state: SDCBluetoothManager.State)
    func managerDidDiscoverPeripheral(manager: SDCBluetoothManager, peripheral: SDCBluetoothRemotePeripheral)
    func remotePeripheralDidConnect(manager: SDCBluetoothManager, peripheral: SDCBluetoothRemotePeripheral)
    func remotePeripheralDidDisconnect(manager: SDCBluetoothManager, peripheral: SDCBluetoothRemotePeripheral)
    func remotePeripheralDidSendNewData(peripheral: SDCBluetoothRemotePeripheral, data: String)
}

// MARK - SDCBluetoothManager

/**
    Class simplifying the use of CoreBluetooth.
*/
class SDCBluetoothManager: NSObject {
    // CoreBluetooth Central Manager instance
    private var centralManager: CBCentralManager?

    // Bluetooth peripheral encapsulation
    private(set) var remotePeripheral: SDCBluetoothRemotePeripheral? {
        didSet {
            self.delegate?.managerStateDidChange(self, state: self.state)
        }
    }
    
    // Services configuration
    var configuration: SDCBluetoothManagerConfiguration?
    
    // Delegate instance
    var delegate: SDCBluetoothManagerDelegate?
    
    // Simple state machine
    var state: State {
        guard let centralManager = self.centralManager else {
            return .Stopped
        }
        
        switch centralManager.state {
        case .PoweredOn:
            if let remotePeripheral = remotePeripheral {
                switch remotePeripheral.state {
                case .Connected, .Disconnecting:
                    return .Connected
                default:
                    return .Connecting
                }
            }
            
            return .Ready

        case .Unsupported, .PoweredOff, .Unauthorized:
            if remotePeripheral != nil {
                remotePeripheral = nil
            }
            
            return .Unavailable
            
        case .Resetting, .Unknown:
            if remotePeripheral != nil {
                remotePeripheral = nil
            }

            return .NotReady
        }
    }
    
    // State enum
    enum State {
        case Ready
        case NotReady
        case Stopped
        case Unavailable
        case Connecting
        case Connected
    }
    
    // Error enum
    enum Error: ErrorType {
        case InvalidState(State)
    }
}

// MARK - Public Methods
extension SDCBluetoothManager {
    // Starts the central manager
    func start() throws {
        guard self.state == .Stopped else {
            throw SDCBluetoothManager.Error.InvalidState(self.state)
        }
        
        centralManager  = CBCentralManager(delegate: self, queue: nil,
            options: [CBCentralManagerOptionShowPowerAlertKey: true])
    }
    
    // Stops the central manager and disconnects peripheral or stops scanning if needed
    func stop() throws {
        guard self.state != .Stopped else {
            throw SDCBluetoothManager.Error.InvalidState(self.state)
        }
        
        switch self.state {
        case .Connected, .Connecting:
            try self.disconnect(self.remotePeripheral!)
        case .Ready:
            try self.stopScanning()
        default:
            break
        }
        
        self.centralManager = nil
    }
    
    // Starts scanning for remote peripherals
    func startScanning() throws {
        guard let centralManager = self.centralManager
            where self.state == .Ready else {
                throw SDCBluetoothManager.Error.InvalidState(self.state)
        }
        
        centralManager.scanForPeripheralsWithServices(configuration?.dataServiceIdentifiers, options: nil)
    }
    
    // Stops scanning for remote peripherals
    func stopScanning() throws {
        guard let centralManager = self.centralManager
            where self.state == .Ready else {
                throw SDCBluetoothManager.Error.InvalidState(self.state)
        }
        
        centralManager.stopScan()
    }
    
    // Connects a discovered peripheral
    func connect(peripheral: SDCBluetoothRemotePeripheral) throws {
        guard let centralManager = self.centralManager
            where self.state == .Ready else {
            throw SDCBluetoothManager.Error.InvalidState(self.state)
        }
        
        remotePeripheral = peripheral
        
        centralManager.connectPeripheral(peripheral.peripheral, options: nil)
    }
    
    // Disconnects a connecting or connected peripheral
    func disconnect(peripheral: SDCBluetoothRemotePeripheral) throws {
        guard let centralManager = self.centralManager
            where self.state == .Connecting || self.state == .Connected else {
            throw SDCBluetoothManager.Error.InvalidState(self.state)
        }
        
        centralManager.cancelPeripheralConnection(peripheral.peripheral)
    }
}

// MARK - SDCRemotePeripheral
extension SDCBluetoothManager: SDCBluetoothRemotePeripheralDelegate {

    // Forwarding the event to the delegate
    internal func remotePeripheralDidSendNewData(peripheral: SDCBluetoothRemotePeripheral, data: String) {
        self.delegate?.remotePeripheralDidSendNewData(peripheral, data: data)
    }
}

// MARK - CBCentralManagerDelegate
extension SDCBluetoothManager: CBCentralManagerDelegate {
    internal func centralManagerDidUpdateState(central: CBCentralManager) {
        self.delegate?.managerStateDidChange(self, state: self.state)
    }
    
    internal func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        let remotePeripheral = SDCBluetoothRemotePeripheral(peripheral: peripheral, configuration: configuration)
        
        self.delegate?.managerDidDiscoverPeripheral(self, peripheral: remotePeripheral)
    }
    
    internal func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        remotePeripheral = SDCBluetoothRemotePeripheral(peripheral: peripheral, configuration: configuration)
        
        self.delegate?.remotePeripheralDidConnect(self, peripheral: remotePeripheral!)
        
        // Starts discovering the peripheral's services
        do {
            remotePeripheral?.delegate = self
            
            try remotePeripheral?.discover()
        } catch {
            log(error)
        }
    }
    
    internal func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        remotePeripheral = nil
    }
    
    internal func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        let disconnectedPeripheral = remotePeripheral!
        
        remotePeripheral = nil
        
        self.delegate?.remotePeripheralDidDisconnect(self, peripheral: disconnectedPeripheral)
    }
}