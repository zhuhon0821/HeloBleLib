//
//  BleManager.swift
//  HeloBLEKit
//
//  Created by AppleDev_9527 on 2024/4/10.
//

import UIKit
import GRDB
import CoreBluetooth

public protocol BleManagerDelegate:AnyObject {
    
    func didReceiveDeviceState(state: CBManagerState)
    func didDiscoverDevice(peripheral: CBPeripheral)
    func didConnectedDeviceSuccess(peripheral: CBPeripheral)
    func didConnectedDeviceFailed(peripheral: CBPeripheral)
    func didDisconnectedDevice(peripheral: CBPeripheral)
}
public protocol BleDataSyncDelegate:AnyObject {
    
    func onSyncingWithHealthData(_ date:Date,_ type:HealthDataType,_ progress:Float,_ allCompleted:Bool)
    func onSyncFatigue(_ fatigu:FatigueModel)
    func onSyncSpo2(_ spo2: Spo2Model)
    func onSyncHeartRate(_ hr: HeartRateModel)
    func onSyncBloodPresure(_ bp: BloodPresureModel)
    func onSyncMood(_ mood: MoodModel)
    func onSyncTemperature(_ temp: TemperatureModel)
    func onSyncIaq(_ iaq: IaqModel)
    func onSyncOaq(_ oaq: OaqModel)
    func onSyncBio(_ bio: BioModel)
    
    func onSyncECG(_ ecg: ECGDataModel)
    func onSyncRRI(_ rri: RRIDataModel)
    func onSyncPPG(_ ppg: PPGDataModel)
    func onSyncSleep(_ sleep: SleepCmdModel)
    
}
public class BleManager:NSObject {
    
    public static let sharedInstance = BleManager()
    public weak var delegate: BleManagerDelegate?
    public weak var dataSyncDelegate: BleDataSyncDelegate?
    public var connectedPeripheral:CBPeripheral?
    var writeCharacteristic:CBCharacteristic?
    var centralManager: CBCentralManager!
    
    static let restoreIdentifier = "com.iwown.helo.unique.restore"
    let deviceUuidKey = "_deviceUuidKey_sdk"
    let deviceNameKey = "_deviceNameKey_sdk"
    
    override init() {
        super.init()
        
        centralManager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionRestoreIdentifierKey:BleManager.restoreIdentifier])
    }
    public func startScanBleDevice(uuids:[CBUUID]?) {
        
        let options = [CBCentralManagerScanOptionAllowDuplicatesKey: true]
        centralManager.scanForPeripherals(withServices: uuids, options: options)
    }
    public func stopScanBleDevice() {
        centralManager.stopScan()
    }
    public func connectBleDevice(peripheral: CBPeripheral) {
        
        centralManager.connect(peripheral, options: [CBConnectPeripheralOptionNotifyOnNotificationKey:true,
                                                    CBConnectPeripheralOptionNotifyOnDisconnectionKey:true])
    }
    public func cancelConnectBleDevice(peripheral: CBPeripheral) {
        centralManager.cancelPeripheralConnection(peripheral)
        connectedPeripheral = nil
    }
    
    public func retrieveCachedPeripherals() {
        if let uuidstr = getDeviceUuid(){
            if let uuid = UUID(uuidString: uuidstr)  {
                let peripheralIdentifiers: [UUID] = [uuid]
                centralManager.retrievePeripherals(withIdentifiers: peripheralIdentifiers)
            }
        }
        
    }
    public func retrieveConnectdPeripherals() {
        if let uuidstr = getDeviceUuid() {
            let uuid = CBUUID(string: uuidstr)
            let peripheralIdentifiers: [CBUUID] = [uuid]
            centralManager.retrieveConnectedPeripherals(withServices: peripheralIdentifiers)
        }
        
    }

    public func writeCommand(data:Data) {
//        if let characteristic = writeCharacteristic {
//            connectedPeripheral?.writeValue(data, for: characteristic, type: .withResponse)
//        }
        if let services = connectedPeripheral?.services {
            for  service in services {
                if let characteristics = service.characteristics {
                    for cha in characteristics {
                        if cha.uuid.uuidString == PROBUFF_CHARACT_SET_UUID {
                            connectedPeripheral?.writeValue(data, for: cha, type: .withoutResponse)
                            break
                        }
                    }
                }
                
            }
        }
        
    }
   public func setNotificationForCharacteristic(_ peripheral: CBPeripheral, serviceUUID: CBUUID, characteristicUUID: CBUUID, enable: Bool) {
        for service in peripheral.services ?? [] {
            if service.uuid == serviceUUID {
                for characteristic in service.characteristics ?? [] {
                    if characteristic.uuid == characteristicUUID {
                        // Everything is found, set notification!
                        peripheral.setNotifyValue(enable, for: characteristic)
                        print("---------peripheral setNotifyValue:enable forCharacteristic:characteristic----------")
                    }
                }
            }
        }
    }
    public func writeCharacteristic(_ peripheral: CBPeripheral, sUUID: String, cUUID: String, data: Data, withResponse: Bool) {
        // Sends data to BLE peripheral to process HID and send EHIF command to PC
        let writeType: CBCharacteristicWriteType = withResponse ? .withResponse : .withoutResponse
          
        for service in peripheral.services ?? [] {
            if service.uuid.uuidString == sUUID {
                for characteristic in service.characteristics ?? [] {
                    if characteristic.uuid.uuidString == cUUID {
                        // EVERYTHING IS FOUND, WRITE characteristic!
                        peripheral.writeValue(data, for: characteristic, type: writeType)
                        return // 如果只打算写入一个特征，可以在这里返回
                    }
                }
            }
        }
        // 如果需要处理没有找到对应特征或服务的情况，可以在这里添加代码
    }
}
extension BleManager {
    public func saveDeviceUuid(uuid:String) {
        UserDefaults.standard.set(uuid, forKey: deviceUuidKey)
        UserDefaults.standard.synchronize()
    }
    public func getDeviceUuid() -> String? {
        return UserDefaults.standard.object(forKey: deviceUuidKey) as? String
    }
    public func clearDeviceUuid() {
        return UserDefaults.standard.removeObject(forKey: deviceUuidKey)
    }
    
    public func saveDeviceName(name:String) {
        UserDefaults.standard.set(name, forKey: deviceNameKey)
        UserDefaults.standard.synchronize()
    }
    public func getDeviceName() -> String? {
        return UserDefaults.standard.object(forKey: deviceNameKey) as? String
    }
    public func clearDeviceName() {
        return UserDefaults.standard.removeObject(forKey: deviceNameKey)
    }
    
}
extension BleManager:CBCentralManagerDelegate {
    
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        delegate?.didReceiveDeviceState(state: central.state)
        if central.state == .poweredOn {
            if let p = self.connectedPeripheral {
                connectBleDevice(peripheral: p)
            } else {
                retrieveConnectdPeripherals()
            }
            
           //UUID.fromString("2E8C0001-2D91-5533-3117-59380A40AF8F")
        } else if central.state == .poweredOff {
            if let p = self.connectedPeripheral {
                delegate?.didDisconnectedDevice(peripheral: p)
            }
            
        }
    }
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices(nil)
        self.connectedPeripheral = peripheral
        saveDeviceUuid(uuid: peripheral.identifier.uuidString)
        if let name = peripheral.name{
            saveDeviceName(name: name)
        }
        delegate?.didConnectedDeviceSuccess(peripheral: peripheral)
        LogBleManager.write("didConnect",.logTypeNormal)
    }
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if RSSI.intValue > -100 && peripheral.name != nil {
            delegate?.didDiscoverDevice(peripheral: peripheral)
        }
        
    }
    public func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
        if let peripherals = dict[CBCentralManagerRestoredStatePeripheralsKey] as? [CBPeripheral] {
            let uuidStr = getDeviceUuid()
            for p in peripherals {
                if p.identifier.uuidString == uuidStr {
                    self.connectedPeripheral = p
                    break
                }
            }
        }
        
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
        LogBleManager.write("didDisconnectPeripheral",.logTypeNormal)
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
    public func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        
        if (characteristic.uuid.uuidString == PROBUFF_CHARACT_DFU_UUID) {
            ProbuffManager.sharedInstance.writeUpgradeCmdA(peripheral)
        }
    }
    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if (characteristic.uuid.uuidString == PROBUFF_CHARACT_DFU_UUID) {
            ProbuffManager.sharedInstance.writeUpgradeCmdB(peripheral)
        }
    }
   
}
extension BleManager {
    public func syncHealthData(completion:(_ date:Date,_ type:HealthDataType,_ progress:Float,_ allCompleted:Bool)->Void) {
        ProbuffManager.sharedInstance.read80HistoryDataIndexTable(.healthData)
       
        
    }
}
