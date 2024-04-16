//
//  BleManager.swift
//  HeloBLEKit
//
//  Created by AppleDev_9527 on 2024/4/10.
//

import UIKit
import GRDB
import CoreBluetooth

public protocol BleManagerDelegate {
    
    func didReceiveDeviceState(state: CBManagerState)
    func didDiscoverDevice(peripheral: CBPeripheral)
    func didConnectedDeviceSuccess(peripheral: CBPeripheral)
    func didConnectedDeviceFailed(peripheral: CBPeripheral)
    func didDisconnectedDevice(peripheral: CBPeripheral)
}

public class BleManager:NSObject {
    
    public static let sharedInstance = BleManager()
    public var delegate: BleManagerDelegate?
    public var connectedPeripheral:CBPeripheral?
    var writeCharacteristic:CBCharacteristic?
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
    public func writeCommend(data:Data) {
        if let characteristic = writeCharacteristic {
            
            connectedPeripheral?.writeValue(data, for: characteristic, type: .withResponse)
        }
    }
}
extension BleManager:CBCentralManagerDelegate {
    
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        delegate?.didReceiveDeviceState(state: central.state)
    }
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices(nil)
        self.connectedPeripheral = peripheral
        delegate?.didConnectedDeviceSuccess(peripheral: peripheral)
    }
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if RSSI.intValue > -100 && peripheral.name != nil {
            delegate?.didDiscoverDevice(peripheral: peripheral)
        }
        
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
extension BleManager:CBPeripheralDelegate {
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if (error != nil) {
                    return
        }
        if service.uuid.uuidString == PROBUFF_SERVICE_LONG_UUID {
            for cha in (service.characteristics ?? []) as [CBCharacteristic] {
                if cha.uuid.uuidString == PROBUFF_CHARACT_READ_UUID {
                    peripheral.setNotifyValue(true, for: cha)
                } else if cha.uuid.uuidString == PROBUFF_CHARACT_SET_UUID  {
                    writeCharacteristic = cha
                }
            }
        }
    }
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if error != nil {
            return
        }
        for service in peripheral.services! {
            peripheral.discoverCharacteristics(nil, for: service )
        }
    }
    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if error != nil {
            print("Write failed:\(error!.localizedDescription)")
        } else {
            print("Write successful")
        }
    }
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let data = characteristic.value {
            if characteristic.uuid.uuidString == PROBUFF_CHARACT_READ_UUID {

                ProbuffHandle.sharedInstance.braceletCmdReceive(bytes: data)
                
            } else if characteristic.uuid.uuidString ==  HEARTRATE_CHARACT_ID {
                ///当以 UINT8 格式发送心率值格式时，心率值格式位应设置为 0。以 UINT16 格式发送心率值格式时
                ///，心率值格式位应设置为 1。
                ///如果服务器支持传感器接触特性，则传感器接触支持位（Flags 字段的第 2 位）应设置为 1。如果服务器不支持传感器接触特性，则传感器接触支持位应设置为 0。
                //data是结构体  使用[UInt8]构造方法得到data的byte数组
                
                let hr = data[1]
                let head = data[0]
                let touch = head & 0b00000010

            } else {
                
            }
        }
       

    }
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?) {
        
    }
   
}
