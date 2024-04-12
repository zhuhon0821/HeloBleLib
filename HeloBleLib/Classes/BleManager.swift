//
//  BleManager.swift
//  HeloBLEKit
//
//  Created by AppleDev_9527 on 2024/4/10.
//

import UIKit
import GRDB
import SwiftProtobuf
import CoreBluetooth

public protocol BleManagerDelegate {
    
    func didReceiveDeviceState(state: CBManagerState)
    func didDiscoverDevice(peripheral: CBPeripheral)
    func didConnectedDeviceSuccess(peripheral: CBPeripheral)
    func didConnectedDeviceFailed(peripheral: CBPeripheral)
    func didDisconnectedDevice(peripheral: CBPeripheral)
}

public class BleManager:NSObject, CBCentralManagerDelegate {
    
    public static let sharedInstance = BleManager()
    public var delegate: BleManagerDelegate?
    
    var centralManager: CBCentralManager!
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    public func startScanBleDevice(uuids:[CBUUID]?) {
        centralManager.scanForPeripherals(withServices: uuids)
    }
    public func stopScanBleDevice() {
        centralManager.stopScan()
    }
    public func connectBleDevice(peripheral: CBPeripheral) {
        centralManager.connect(peripheral)
    }
    public func cancelConnectBleDevice(peripheral: CBPeripheral) {
        centralManager.cancelPeripheralConnection(peripheral)
    }
    public func recoveryBleDevice(peripheral: CBPeripheral) {
        if let uuid = UUID(uuidString: peripheral.identifier.uuidString) {
            centralManager.retrievePeripherals(withIdentifiers: [uuid])
        }
        
    }
    
}
extension BleManager {
    
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        delegate?.didReceiveDeviceState(state: central.state)
    }
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        delegate?.didConnectedDeviceSuccess(peripheral: peripheral)
    }
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        delegate?.didDiscoverDevice(peripheral: peripheral)
    }
    public func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
        
    }
    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        delegate?.didConnectedDeviceFailed(peripheral: peripheral)
    }
    public func centralManager(_ central: CBCentralManager, connectionEventDidOccur event: CBConnectionEvent, for peripheral: CBPeripheral) {
        
    }
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, timestamp: CFAbsoluteTime, isReconnecting: Bool, error: Error?) {
        
    }
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        delegate?.didDisconnectedDevice(peripheral: peripheral)
    }
}
