//
//  ProbuffHandle.swift
//  HeloBleLib_Example
//
//  Created by AppleDev_9527 on 2024/4/15.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit
import SwiftProtobuf

class ProbuffHandle: NSObject {
    public static let sharedInstance = ProbuffHandle()

    
    var _recvData:Data?
    var _recvFinished = true
    var _dataLength = 0
    
    var HEALTH_DATA_ENCRYPT_indexs:[IndexModel]?
    var ECG_DATA_ENCRYPT_indexs:[IndexModel]?
    var PPG_DATA_ENCRYPT_indexs:[IndexModel]?
    var RRI_DATA_ENCRYPT_indexs:[IndexModel]?
    var TEMPERATURE_DATA_indexs:[IndexModel]?
    var HEALTH_DATA_indexs:[IndexModel]?
    var GNSS_DATA_indexs:[IndexModel]?
    var ECG_DATA_indexs:[IndexModel]?
    var PPG_DATA_indexs:[IndexModel]?
    var RRI_DATA_indexs:[IndexModel]?
    var MEDIC_DATA_indexs:[IndexModel]?
    var SPO2_DATA_indexs:[IndexModel]?
    var SWIM_DATA_indexs:[IndexModel]?
    
    var HEALTH_DATA_ENCRYPT_index_sync:IndexModel?
    var ECG_DATA_ENCRYPT_index_sync:IndexModel?
    var PPG_DATA_ENCRYPT_index_sync:IndexModel?
    var RRI_DATA_ENCRYPT_index_sync:IndexModel?
    var TEMPERATURE_DATA_index_sync:IndexModel?
    var HEALTH_DATA_index_sync:IndexModel?
    var GNSS_DATA_index_sync:IndexModel?
    var ECG_DATA_index_sync:IndexModel?
    var PPG_DATA_index_sync:IndexModel?
    var RRI_DATA_index_sync:IndexModel?
    var MEDIC_DATA_index_sync:IndexModel?
    var SPO2_DATA_index_sync:IndexModel?
    var SWIM_DATA_index_sync:IndexModel?
    
    override init() {
        super.init()

        
    }
    public func braceletCmdReceive(bytes:Data) {
        if (_recvFinished) {
            if (!self.prefixCheck(data: bytes)) {
                return;
            }
            _recvData = bytes
            _dataLength = self.getDataLength(bytes: bytes)
        }else {
            _recvData?.append(bytes)
        
        }
        if ((_recvData?.count ?? 0) - 8 == _dataLength) {
            
            if let data = _recvData {
                self.dataCheck(bytes: data)
            }
            _recvData = nil;
            _recvFinished = true;
        }else {
            _recvFinished = false;
        }
        
    }
    func dataCheck(bytes:Data) {
        if bytes.count < 16 {
            return
        }
//        let newbytes = Data([0x44,0x54,0x04,0x00,0xa1,0xa1,0x0d,0x00, 0x08,0x01,0x10,0x01])
        
        let optCode = getOperationCode(bytes: bytes)
        let crcData = bytes[8...bytes.count-1]
        let crcCk = calcCrc16(data: crcData, len: UInt(crcData.count))
        let crcCode = getCrcCheckValue(bytes: bytes)
        if (crcCk != crcCode) {
            return;
        }
        let dataStr = HeloUtils.hexStringFromData(crcData)
        let dic = ["name":"up","id":optCode,"data":dataStr] as [String : Any]
        if let json = HeloUtils.objectToJSON(dic) {
            LogBleManager.write(json,.logTypeBleRaw)
        }
        
        do {
            
            switch optCode {
                case 0x0:
                let decodedInfo = try DeviceInfoResponse(serializedData: crcData)
                print(decodedInfo)
                    break
                case 0x1:
                let decodedInfo = try PeerInfoSubsriber(serializedData: crcData)
                print(decodedInfo)
                    break
                case 0x2:
                let decodedInfo = try MsgSubscriber(serializedData: crcData)
                print(decodedInfo)
                    break
                case 0x3:
                let decodedInfo = try WeatherSubscriber(serializedData: crcData)
                print(decodedInfo)
                    break
                case 0x4:
                let decodedInfo = try AlarmSubscriber(serializedData: crcData)
                print(decodedInfo)
                    break
                case 0x5:
                let decodedInfo = try SedtSubscriber(serializedData: crcData)
                print(decodedInfo)
                    break
                case 0x6:
                let decodedInfo = try DeviceConfSubscriber(serializedData: crcData)
                print(decodedInfo)
                    break
                case 0x7:
                let decodedInfo = try CalendarSubscriber(serializedData: crcData)
                print(decodedInfo)
                    break
                case 0x8:
                let decodedInfo = try MotorConfSubscriber(serializedData: crcData)
                print(decodedInfo)
                    break
                case 0x9:
                let decodedInfo = try DataInfoResponse(serializedData: crcData)
                print(decodedInfo)
                    break
                case 0xc:
                let decodedInfo = try C110Response(serializedData: crcData)
                print(decodedInfo)
                    break
                case 0x70:
                let decodedInfo = try RtNotification(serializedData: crcData)
                print(decodedInfo)
                    break
                case 0x80:
                let decodedInfo = try HisNotification(serializedData: crcData)
                if decodedInfo.hisData.hasSeq { 
                    //normal data
                    healthDataSyncProcess(hisData: decodedInfo.hisData,type: decodedInfo.type)
                } else {
                    //index data
                    if decodedInfo.indexTable.index.count > 0 {
                        var seqs = [IndexModel]()
                        for item in decodedInfo.indexTable.index {
                            if item.startSeq == item.endSeq {
                                continue
                            }
                            let date = Date(timeIntervalSince1970: TimeInterval(item.time.seconds))
                            let name = BleManager.sharedInstance.getDeviceName()
                            let model = IndexModel(data_from: name ?? "", date: date, seq_start: item.startSeq, seq_end: item.endSeq, indexType: decodedInfo.type.rawValue, isSynced: false)
                            let synced = GRDBManager.sharedInstance.selectIndexModelSynced(type: model.indexType, data_from: model.data_from, startSeq: model.seq_start, endSeq: model.seq_end, date: model.date, isSynced: true )
                            if synced == false {
                                seqs.append(model)
                            }
                        }
                        if seqs.count > 0 {
                            GRDBManager.sharedInstance.insertIndexModel(indexModels: seqs)
                            indexTableSyncProcess(indexs: seqs,type: decodedInfo.type)
                        }
                       
                    }
                }
                print(decodedInfo)
                    break
                case 0x90:
                let decodedInfo = try FilesUpdateResponse(serializedData: crcData)
                print(decodedInfo)
                    break
                case 0xffff:
                let decodedInfo = try ConParamsUpdate(serializedData: crcData)
                ProbuffManager.sharedInstance.mtu = Int(decodedInfo.mtu)
                print(decodedInfo)
                    break
                default:
                    break
            }
        } catch {
            print(error)
        }
        
    }
   
    public func getCrcCheckValue(bytes:Data) -> UInt16 {
        let a:UInt16 = UInt16(bytes[4]);
        let b:UInt16 = UInt16(bytes[5]);
        return a + 0x100 * b
    }
    
    public func calcCrc16(data: Data,len: UInt) -> UInt16 {
        var crcIn: UInt16 = 0x0000
        let poly: UInt16 = 0x1021
          
        for char in data {
            crcIn ^= UInt16(char) << 8
            for _ in 0..<8 {
                if crcIn & 0x8000 != 0 {
                    crcIn = (crcIn << 1) ^ poly
                } else {
                    crcIn <<= 1
                }
            }
        }
          
        return crcIn
    }
    
    public func getOperationCode(bytes:Data) -> Int {
      
        let a = bytes[6];
        let b = bytes[7];
        return Int(Int32(a) + 0x100 * Int32(b))
    }
    public func getDataLength(bytes:Data) -> Int {
        let a = bytes[2];
        let b = bytes[3];
        return Int(Int32(a) + (0x100 * Int32(b)))
    }
    public func prefixCheck(data:Data) -> Bool{
        let length = 8;
        if (data.count < length) { //8个byte： Perfix|len|crc|opt
            return false
        }
        return (data[0] == 0x44) && (data[1] == 0x54)
    }

}
//MARK: -- sync progress process
extension ProbuffHandle {
    func indexTableSyncProcess(indexs: [IndexModel],type: HisDataType) {

        switch type {
        case .healthData:
            HEALTH_DATA_indexs = indexs
            break
        case .gnssData:
            GNSS_DATA_indexs = indexs
            break
        case .ecgData:
            ECG_DATA_indexs = indexs
            break
        case .ppgData:
            PPG_DATA_indexs = indexs
            break
        case .rriData:
            RRI_DATA_indexs = indexs
            break
        case .medicData:
            MEDIC_DATA_indexs = indexs
            break
        case .spo2Data:
            SPO2_DATA_indexs = indexs
            break
        case .swimData:
            SWIM_DATA_indexs = indexs
            break
        case .temperatureData:
            TEMPERATURE_DATA_indexs = indexs
            break
        case .healthDataEncrypt:
            HEALTH_DATA_ENCRYPT_indexs = indexs
            break
        case .ecgDataEncrypt:
            ECG_DATA_ENCRYPT_indexs = indexs
            break
        case .ppgDataEncrypt:
            PPG_DATA_ENCRYPT_indexs = indexs
            break
        case .rriDataEncrypt:
            RRI_DATA_ENCRYPT_indexs = indexs
            break
        default: break
        }
        var sync = HisStartSync()
        var blocks = [HisBlock]()
        for index in indexs {
            
            if let type = HisDataType(rawValue: index.indexType) {
                sync.type = type
                var hisBlock = HisBlock()
                hisBlock.startSeq = index.seq_start
                hisBlock.endSeq = index.seq_end
                blocks.append(hisBlock)
            }
        }
        sync.block = blocks
        ProbuffManager.sharedInstance.read80HistoryDataStart(sync)
    }
    
    func healthDataSyncProcess(hisData: HisData,type: HisDataType) {
        
        
        if let index_sync = checkSyncIndex(hisData: hisData,type: type) {
            parseHealthData(hisData: hisData, type: type)
            let progress = progressCalculation(seq: hisData.seq,index_sycn: index_sync)
            var allComplete = false
            if progress == Float(1) {
                removeSyncIndex(type: type, index: index_sync)
                allComplete = checkSyncHealthDataComplete()
                if allComplete {
                    dataCalculation()
                }
            }
            if let datatype = HealthDataType(rawValue: type.rawValue) {
                BleManager.sharedInstance.dataSyncDelegate?.onSyncingWithHealthData(index_sync.date, datatype, progress, allComplete)
            }
//            print("type==>\(type)\ncurrentSeq==>\(hisData.seq), startseq==>\(index_sync.seq_start), endseq==>\(index_sync.seq_end)\nprogress==>\(progress * 100)%")
            
        }

    }
    func checkSyncIndex(hisData: HisData,type: HisDataType) -> IndexModel? {
        var index_sync:IndexModel?
        switch type {
        case .healthData:

                if let indexs = HEALTH_DATA_indexs {
                    for index in indexs {
                        if hisData.seq >= index.seq_start && hisData.seq < index.seq_end {
                            index_sync = index
                            break
                        }
                    }
                }

            if let preIndex = HEALTH_DATA_ENCRYPT_index_sync {
                if index_sync != preIndex {
                    removeSyncIndex(type: type, index: preIndex)
                }
            }
            HEALTH_DATA_ENCRYPT_index_sync = index_sync
            return HEALTH_DATA_ENCRYPT_index_sync
            
        case .gnssData:

                if let indexs = GNSS_DATA_indexs {
                    for index in indexs {
                        if hisData.seq >= index.seq_start && hisData.seq < index.seq_end {
                            index_sync = index
                            break
                        }
                    }
                }
            if let preIndex = GNSS_DATA_index_sync {
                if index_sync != preIndex {
                    removeSyncIndex(type: type, index: preIndex)
                }
            }
            GNSS_DATA_index_sync = index_sync
            return GNSS_DATA_index_sync
            
        case .ecgData:

                if let indexs = ECG_DATA_indexs {
                    for index in indexs {
                        if hisData.seq >= index.seq_start && hisData.seq < index.seq_end {
                            index_sync = index
                            break
                        }
                    }
                }
            if let preIndex = ECG_DATA_index_sync {
                if index_sync != preIndex {
                    removeSyncIndex(type: type, index: preIndex)
                }
            }
            ECG_DATA_index_sync = index_sync
            return ECG_DATA_index_sync
            
        case .ppgData:
                if let indexs = PPG_DATA_indexs {
                    for index in indexs {
                        if hisData.seq >= index.seq_start && hisData.seq < index.seq_end {
                            index_sync = index
                           break
                        }
                    }
                }
            if let preIndex = PPG_DATA_index_sync {
                if index_sync != preIndex {
                    removeSyncIndex(type: type, index: preIndex)
                }
            }
            PPG_DATA_index_sync = index_sync
            return PPG_DATA_index_sync
            
        case .rriData:
                if let indexs = RRI_DATA_indexs {
                    for index in indexs {
                        if hisData.seq >= index.seq_start && hisData.seq < index.seq_end {
                            index_sync = index
                            break
                        }
                    }
                }
            if let preIndex = RRI_DATA_index_sync {
                if index_sync != preIndex {
                    removeSyncIndex(type: type, index: preIndex)
                }
            }
            RRI_DATA_index_sync = index_sync
            return RRI_DATA_index_sync
            
        case .medicData:
                if let indexs = MEDIC_DATA_indexs {
                    for index in indexs {
                        if hisData.seq >= index.seq_start && hisData.seq < index.seq_end {
                            index_sync = index
                            break
                        }
                    }
                }
            if let preIndex = MEDIC_DATA_index_sync {
                if index_sync != preIndex {
                    removeSyncIndex(type: type, index: preIndex)
                }
            }
            MEDIC_DATA_index_sync = index_sync
            return MEDIC_DATA_index_sync
            
        case .spo2Data:
                if let indexs = SPO2_DATA_indexs {
                    for index in indexs {
                        if hisData.seq >= index.seq_start && hisData.seq < index.seq_end {
                            index_sync = index
                            break
                        }
                    }
                }
            if let preIndex = SPO2_DATA_index_sync {
                if index_sync != preIndex {
                    removeSyncIndex(type: type, index: preIndex)
                }
            }
            SPO2_DATA_index_sync = index_sync
            return SPO2_DATA_index_sync
        case .swimData:
                if let indexs = SWIM_DATA_indexs {
                    for index in indexs {
                        if hisData.seq >= index.seq_start && hisData.seq < index.seq_end {
                            index_sync = index
                            break
                        }
                    }
                }
            if let preIndex = SWIM_DATA_index_sync {
                if index_sync != preIndex {
                    removeSyncIndex(type: type, index: preIndex)
                }
            }
            SWIM_DATA_index_sync = index_sync
            return SWIM_DATA_index_sync
        case .temperatureData:
                if let indexs = TEMPERATURE_DATA_indexs {
                    for index in indexs {
                        if hisData.seq >= index.seq_start && hisData.seq < index.seq_end {
                            index_sync = index
                            break
                        }
                    }
                }
            if let preIndex = TEMPERATURE_DATA_index_sync {
                if index_sync != preIndex {
                    removeSyncIndex(type: type, index: preIndex)
                }
            }
            TEMPERATURE_DATA_index_sync = index_sync
            return TEMPERATURE_DATA_index_sync
        case .healthDataEncrypt:
                if let indexs = HEALTH_DATA_ENCRYPT_indexs {
                    for index in indexs {
                        if hisData.seq >= index.seq_start && hisData.seq < index.seq_end {
                            index_sync = index
                            break
                        }
                    }
                }
            if let preIndex = HEALTH_DATA_ENCRYPT_index_sync {
                if index_sync != preIndex {
                    removeSyncIndex(type: type, index: preIndex)
                }
            }
            HEALTH_DATA_ENCRYPT_index_sync = index_sync
            return HEALTH_DATA_ENCRYPT_index_sync
        case .ecgDataEncrypt:

                if let indexs = ECG_DATA_ENCRYPT_indexs {
                    for index in indexs {
                        if hisData.seq >= index.seq_start && hisData.seq < index.seq_end {
                            index_sync = index
                            break
                        }
                    }
                }
            if let preIndex = ECG_DATA_ENCRYPT_index_sync {
                if index_sync != preIndex {
                    removeSyncIndex(type: type, index: preIndex)
                }
            }
            ECG_DATA_ENCRYPT_index_sync = index_sync
            return ECG_DATA_ENCRYPT_index_sync
        case .ppgDataEncrypt:
                if let indexs = PPG_DATA_ENCRYPT_indexs {
                    for index in indexs {
                        if hisData.seq >= index.seq_start && hisData.seq < index.seq_end {
                            index_sync = index
                            break
                        }
                    }
                }
            if let preIndex = PPG_DATA_ENCRYPT_index_sync {
                if index_sync != preIndex {
                    removeSyncIndex(type: type, index: preIndex)
                }
            }
            PPG_DATA_ENCRYPT_index_sync = index_sync
            return PPG_DATA_ENCRYPT_index_sync
        case .rriDataEncrypt:
                if let indexs = RRI_DATA_ENCRYPT_indexs {
                    for index in indexs {
                        if hisData.seq >= index.seq_start && hisData.seq < index.seq_end {
                            index_sync = index
                            break
                        }
                    }
                }
            if let preIndex = RRI_DATA_ENCRYPT_index_sync {
                if index_sync != preIndex {
                    removeSyncIndex(type: type, index: preIndex)
                }
            }
            RRI_DATA_ENCRYPT_index_sync = index_sync
            return RRI_DATA_ENCRYPT_index_sync
        default: break
        }
        return nil
    }
    func progressCalculation(seq:UInt32,index_sycn:IndexModel) -> Float {
        let current = Float(seq-index_sycn.seq_start)
        let all = Float(index_sycn.seq_end-1-index_sycn.seq_start)
        var progress = current/all
        if progress.isNaN {
            progress = 1.0
        }
      
        return progress
    }
    func checkSyncHealthDataComplete() -> Bool {
        var sum = 0
        if let hEALTH_DATA_ENCRYPT_indexs = HEALTH_DATA_ENCRYPT_indexs {
            sum += hEALTH_DATA_ENCRYPT_indexs.count
        }
        if let eCG_DATA_ENCRYPT_indexs = ECG_DATA_ENCRYPT_indexs {
            sum += eCG_DATA_ENCRYPT_indexs.count
        }
        if let pPG_DATA_ENCRYPT_indexs = PPG_DATA_ENCRYPT_indexs {
            sum += pPG_DATA_ENCRYPT_indexs.count
        }
        if let rRI_DATA_ENCRYPT_indexs = RRI_DATA_ENCRYPT_indexs {
            sum += rRI_DATA_ENCRYPT_indexs.count
        }
        if let tEMPERATURE_DATA_indexs = TEMPERATURE_DATA_indexs {
            sum += tEMPERATURE_DATA_indexs.count
        }
        if let hEALTH_DATA_indexs = HEALTH_DATA_indexs {
            sum += hEALTH_DATA_indexs.count
        }
        if let gNSS_DATA_indexs = GNSS_DATA_indexs {
            sum += gNSS_DATA_indexs.count
        }
        if let eCG_DATA_indexs = ECG_DATA_indexs {
            sum += eCG_DATA_indexs.count
        }
        if let pPG_DATA_indexs = PPG_DATA_indexs {
            sum += pPG_DATA_indexs.count
        }
        if let rRI_DATA_indexs = RRI_DATA_indexs {
            sum += rRI_DATA_indexs.count
        }
        if let mEDIC_DATA_indexs = MEDIC_DATA_indexs {
            sum += mEDIC_DATA_indexs.count
        }
        if let sPO2_DATA_indexs = SPO2_DATA_indexs {
            sum += sPO2_DATA_indexs.count
        }
        if let sWIM_DATA_indexs = SWIM_DATA_indexs {
            sum += sWIM_DATA_indexs.count
        }
        print("all left==>\(sum)");
        return sum == 0
    }
    
    func removeSyncIndex(type:HisDataType,index:IndexModel) {
        var index_db = index
        index_db.isSynced = true
        GRDBManager.sharedInstance.insertIndexModel(indexModels: [index_db])
        switch type {
        case .healthData:
            
            HEALTH_DATA_indexs = HEALTH_DATA_indexs?.filter{$0 != HEALTH_DATA_index_sync}
            HEALTH_DATA_index_sync = nil
            break
        case .gnssData:
            
            GNSS_DATA_indexs = GNSS_DATA_indexs?.filter{$0 != GNSS_DATA_index_sync}
            GNSS_DATA_index_sync = nil
            break
        case .ecgData:
            
            ECG_DATA_indexs = ECG_DATA_indexs?.filter{$0 != ECG_DATA_index_sync}
            ECG_DATA_index_sync = nil
            break
        case .ppgData:
            PPG_DATA_indexs = ECG_DATA_indexs?.filter{$0 != PPG_DATA_index_sync}
            PPG_DATA_index_sync = nil
            break
        case .rriData:
            RRI_DATA_indexs = RRI_DATA_indexs?.filter{$0 != RRI_DATA_index_sync}
            RRI_DATA_index_sync = nil
            break
        case .medicData:
            MEDIC_DATA_indexs = MEDIC_DATA_indexs?.filter{$0 != MEDIC_DATA_index_sync}
            MEDIC_DATA_index_sync = nil
            break
        case .spo2Data:
            SPO2_DATA_indexs = SPO2_DATA_indexs?.filter{$0 != SPO2_DATA_index_sync}
            SPO2_DATA_index_sync = nil
            break
        case .swimData:
            SWIM_DATA_indexs = SWIM_DATA_indexs?.filter{$0 != SWIM_DATA_index_sync}
            SWIM_DATA_index_sync = nil
            break
        case .temperatureData:
            TEMPERATURE_DATA_indexs = TEMPERATURE_DATA_indexs?.filter{$0 != TEMPERATURE_DATA_index_sync}
            TEMPERATURE_DATA_index_sync = nil
            break
        case .healthDataEncrypt:
            HEALTH_DATA_ENCRYPT_indexs = HEALTH_DATA_ENCRYPT_indexs?.filter{$0 != HEALTH_DATA_ENCRYPT_index_sync}
            HEALTH_DATA_ENCRYPT_index_sync = nil
            break
            
        case .ecgDataEncrypt:
            ECG_DATA_ENCRYPT_indexs = ECG_DATA_ENCRYPT_indexs?.filter{$0 != ECG_DATA_ENCRYPT_index_sync}
            ECG_DATA_ENCRYPT_index_sync = nil
            break
        case .ppgDataEncrypt:
            PPG_DATA_ENCRYPT_indexs = PPG_DATA_ENCRYPT_indexs?.filter{$0 != PPG_DATA_ENCRYPT_index_sync}
            PPG_DATA_ENCRYPT_index_sync = nil
            break
        case .rriDataEncrypt:
            RRI_DATA_ENCRYPT_indexs = RRI_DATA_ENCRYPT_indexs?.filter{$0 != RRI_DATA_ENCRYPT_index_sync}
            RRI_DATA_ENCRYPT_index_sync = nil
            break
        default: break
        }
        
    }
    
}
//MARK: -- data parse
extension ProbuffHandle {
    func parseHealthData(hisData:HisData,type:HisDataType) {
        
        switch type {
        case .healthData:

            parseHisHealthData(hisDataHealth: hisData.health, seq: hisData.seq)
            break
        case .gnssData:
            let seconds = hisData.gnss.timeStamp.dateTime.seconds - (3600 * UInt32(hisData.gnss.timeStamp.timeZone));
            break
        case .ecgData:

            parseECGData(hisData: hisData.ecg, seq:hisData.seq)
            break
        case .ppgData:

            parsePPGData(hisData: hisData.ppg, seq:hisData.seq)
            break
        case .rriData:
            parseRRIData(hisData: hisData.rri, seq:hisData.seq)
            break
        case .medicData:
            break
        case .spo2Data:
//            let seconds = hisData.spo2.timeStamp.dateTime.seconds - (3600 * UInt32(hisData.spo2.timeStamp.timeZone));
            break
        case .swimData:
//            let seconds = hisData.swim.timeStamp.dateTime.seconds - (3600 * UInt32(hisData.swim.timeStamp.timeZone));
            break
        case .temperatureData:
//            let seconds = hisData.temp.timeStamp.dateTime.seconds - (3600 * UInt32(hisData.temp.timeStamp.timeZone));
            break
        case .healthDataEncrypt:
            
                if hisData.health.hasSleepData && !hisData.health.hasPedoData && !hisData.health.hasHrData && !hisData.health.hasHrvData && !hisData.health.hasBpData && !hisData.health.hasAfData && !hisData.health.hasMdtData && !hisData.health.hasMoodData && !hisData.health.hasBreathData && !hisData.health.hasBiozData && !hisData.health.hasBxoyData && !hisData.health.hasTemperatureData && !hisData.health.hasOutActData {
                    //skiped while it has sleep data only
                    
                } else {
                    
                }
            parseHisHealthData(hisDataHealth: hisData.healthencrypt.hisHealth.health, seq: hisData.seq)
            break
        case .ecgDataEncrypt:
            parseECGData(hisData: hisData.ecgencrypt.hisEcg.ecgencrypt, seq:hisData.seq)
            
            break
        case .ppgDataEncrypt:
            parsePPGData(hisData: hisData.ppgencrypt.hisPpg.ppgencrypt, seq:hisData.seq)
            break
        case .rriDataEncrypt:
            parseRRIData(hisData: hisData.rriencrypt.hisRri.rriencrypt, seq:hisData.seq)
            break
        default: break
        }
        
    }
    func parseHisHealthData(hisDataHealth:HisDataHealth,seq:UInt32) {
        
        
        var hdDict:Dictionary = [String:Any]()
        var date:Date?
        if hisDataHealth.hasTimeStamp {
            let timeInterval = TimeInterval(hisDataHealth.timeStamp.dateTime.seconds - (3600 * UInt32(hisDataHealth.timeStamp.timeZone)));
            date = Date(timeIntervalSince1970: timeInterval)
            let hour = NSCalendar.current.component(.hour, from: date!)
            let minute = NSCalendar.current.component(.minute, from: date!)
            let time = [hour,minute]
            hdDict["T"] = time
            
        } else {
            return
        }
        let dataFrom = BleManager.sharedInstance.getDeviceName()!
        var healthDataModel:HealthDataModel = HealthDataModel(data_from: dataFrom, date: date!, seq: seq, is_processed: false)
        
        
        var step:UInt32 = 0
        var calorie:Float = 0
        var distance:Float = 0
        var sport_type:Int = 0
        var state_type:Int = 0
        var pre_minute:Int = 0
        var cmd:String = ""
        //hrv
        var sdnn:Float = 0
        var rmssd:Float = 0
        var pnn50:Float = 0
        var mean:Float = 0
        //fatigue
        var fatigue: Float = 0
        //heart rate
        var maxBpm:UInt32 = 0
        var minBpm:UInt32 = 0
        var avgBpm:UInt32 = 0
        //spo2
        var maxOxy:UInt32 = 0
        var minOxy:UInt32 = 0
        var avgOxy:UInt32 = 0
        //temperature
        var huanjing_temp:UInt16 = 0
        var tibiao_temp:UInt16 = 0
        var yuce_temp:UInt16 = 0
        var shice_temp:UInt16 = 0
        var tempType:Int = -1
        //blood presure
        var dbp:UInt32 = 0
        var sbp:UInt32 = 0
        var bmp:UInt32 = 0
        //mood
        var moodLevel: UInt32 = 0
    
        hdDict["Q"] = seq
        if hisDataHealth.hasSleepData {
            var mDict:Dictionary = [String:Any]()
            mDict["a"] = hisDataHealth.sleepData.sleepData
            if hisDataHealth.sleepData.shutDown {
                mDict["s"] = hisDataHealth.sleepData.shutDown
            }
            if hisDataHealth.sleepData.charge {
                mDict["c"] = hisDataHealth.sleepData.charge
            }
            if mDict.count > 0 {
                hdDict["E"] = mDict
            }
            
        }
        if hisDataHealth.hasPedoData {
            var mDict:Dictionary = [String:Any]()
            if (hisDataHealth.pedoData.hasStep) {
                mDict["s"] = hisDataHealth.pedoData.step
                step = hisDataHealth.pedoData.step
            }
            if (hisDataHealth.pedoData.hasCalorie) {
                mDict["c"] = hisDataHealth.pedoData.calorie
                calorie = Float(hisDataHealth.pedoData.calorie) * 0.1
            }
            if (hisDataHealth.pedoData.hasDistance) {
                mDict["d"] = hisDataHealth.pedoData.distance
                distance = Float(hisDataHealth.pedoData.distance) * 0.1
            }
            if (hisDataHealth.pedoData.hasType) {
                mDict["t"] = hisDataHealth.pedoData.type
                sport_type = Int(hisDataHealth.pedoData.type)
            }
            if (hisDataHealth.pedoData.state > 0) {
                mDict["a"] = hisDataHealth.pedoData.state
                state_type = Int(hisDataHealth.pedoData.state & 15)
                pre_minute = Int((hisDataHealth.pedoData.state & 240) >> 4)
            }
            if mDict.count > 0 {
                hdDict["P"] = mDict
            }
            
        }
       
        if hisDataHealth.hasHrData {
            var mDict:Dictionary = [String:Any]()
            if (hisDataHealth.hrData.hasMaxBpm) {
                mDict["x"] = hisDataHealth.hrData.maxBpm
                maxBpm = hisDataHealth.hrData.maxBpm
            }
            if (hisDataHealth.hrData.hasMinBpm) {
                mDict["n"] = hisDataHealth.hrData.minBpm
                minBpm = hisDataHealth.hrData.minBpm
            }
            if (hisDataHealth.hrData.hasAvgBpm) {
                mDict["a"] = hisDataHealth.hrData.avgBpm
                avgBpm = hisDataHealth.hrData.avgBpm
            }
            if mDict.count > 0 {
                hdDict["H"] = mDict
            }
            let hr = HeartRateModel(data_from: dataFrom, date: date!, maxBpm: Int(maxBpm), minBpm: Int(minBpm), avgBpm: Int(avgBpm))
            BleManager.sharedInstance.dataSyncDelegate?.onSyncHeartRate(hr)
            
        }
        if hisDataHealth.hasHrvData {
            
            var mDict:Dictionary = [String:Any]()
            if (hisDataHealth.hrvData.hasSdnn) {
                mDict["s"] = hisDataHealth.hrvData.sdnn
                sdnn = hisDataHealth.hrvData.sdnn/10.0
            }
            if (hisDataHealth.hrvData.hasRmssd) {
                mDict["r"] = hisDataHealth.hrvData.rmssd
                rmssd = hisDataHealth.hrvData.rmssd/10.0
            }
            if (hisDataHealth.hrvData.hasPnn50) {
                mDict["p"] = hisDataHealth.hrvData.pnn50
                pnn50 = hisDataHealth.hrvData.pnn50/10.0
            }
            if (hisDataHealth.hrvData.hasMean) {
                mDict["m"] = hisDataHealth.hrvData.mean
                mean = hisDataHealth.hrvData.mean/10.0
            }
            if (hisDataHealth.hrvData.hasFatigue) {
                if hisDataHealth.hrvData.fatigue > 0 {
                    mDict["f"] = hisDataHealth.hrvData.fatigue
                    fatigue = hisDataHealth.hrvData.fatigue
                } else {
                    mDict["f"] = Int(hisDataHealth.hrvData.rmssd * 20)
                }
                mean = hisDataHealth.hrvData.mean/10.0
                let fm = FatigueModel(data_from: dataFrom, date: date!, sdnn: sdnn, rmssd: rmssd, pnn50: pnn50, mean: mean, fatigue: fatigue)
                BleManager.sharedInstance.dataSyncDelegate?.onSyncFatigue(fm)
            }
            if mDict.count > 0 {
                hdDict["V"] = mDict
            }
        }
        
        if hisDataHealth.hasBxoyData {
            maxOxy = hisDataHealth.bxoyData.maxOxy
            minOxy = hisDataHealth.bxoyData.minOxy
            avgOxy = hisDataHealth.bxoyData.agvOxy
            let spo2 = Spo2Model(data_from: dataFrom, date: date!, maxOxy: Int(maxOxy), avgOxy: Int(avgOxy), minOxy: Int(minOxy))
            BleManager.sharedInstance.dataSyncDelegate?.onSyncSpo2(spo2)
        }
        if hisDataHealth.hasTemperatureData {
            
            tempType = hisDataHealth.temperatureData.type.rawValue
            
            huanjing_temp = UInt16((hisDataHealth.temperatureData.eviBody >> 16) & 0x0000ffff);
            tibiao_temp = UInt16(hisDataHealth.temperatureData.eviBody & 0x0000ffff);
            yuce_temp = UInt16((hisDataHealth.temperatureData.estiArm >> 16) & 0x0000ffff);
            shice_temp = UInt16(hisDataHealth.temperatureData.estiArm & 0x0000ffff);
            let temp = TemperatureModel(data_from: dataFrom, date: date!, huanjing_temp: Int(huanjing_temp), tibiao_temp: Int(tibiao_temp), yuce_temp: Int(yuce_temp), shice_temp: Int(shice_temp), temp_ype: tempType)
            
            BleManager.sharedInstance.dataSyncDelegate?.onSyncTemperature(temp)
        }
        if hisDataHealth.hasBpData {
            dbp = hisDataHealth.bpData.dbp
            sbp = hisDataHealth.bpData.sbp
            bmp = hisDataHealth.bpData.time
            let bp = BloodPresureModel(data_from: dataFrom, date: date!, sbp: Int(sbp), dbp: Int(dbp), bpm: Int(bmp))
            BleManager.sharedInstance.dataSyncDelegate?.onSyncBloodPresure(bp)
        }
        if hisDataHealth.hasMoodData ,hisDataHealth.moodData.hasMoodLevel {
            moodLevel = hisDataHealth.moodData.moodLevel
            let mood = MoodModel(data_from: dataFrom, date: date!, moodLevel: Int(moodLevel))
            BleManager.sharedInstance.dataSyncDelegate?.onSyncMood(mood)
        }
        //BIA
        if hisDataHealth.hasBiozData {
            if hisDataHealth.biozData.hasX {
                let bioX = Int32(bitPattern: hisDataHealth.biozData.x)
                healthDataModel.bioX = bioX
            }
            if hisDataHealth.biozData.hasR {
                let bioR = Int32(bitPattern: hisDataHealth.biozData.r)
                healthDataModel.bioR = bioR
            }
            let bio = BioModel(data_from: dataFrom, date: date!, bioX: healthDataModel.bioX ?? 0, bioR: healthDataModel.bioR ?? 0)
            BleManager.sharedInstance.dataSyncDelegate?.onSyncBio(bio)
        }
        if hisDataHealth.hasIaqData {
            let iaqData = hisDataHealth.iaqData
            var humidity:Float = 0
            var temp: Float = 0
            if hisDataHealth.hasHumitureData {
                humidity = hisDataHealth.humitureData.humidity
                temp = hisDataHealth.humitureData.temperature
            }
            let iaq = IaqModel(data_from: dataFrom, date: date!, iaq: iaqData.iaq, tvoc: iaqData.tvoc, etoh: iaqData.etoh, eco2: iaqData.eco2, humidity: humidity, temperature:temp, autoMeasure: true)
            BleManager.sharedInstance.dataSyncDelegate?.onSyncIaq(iaq)
        }
        if hisDataHealth.hasOaqData {
            let oaqData = hisDataHealth.oaqData
            var humidity:Float = 0
            var temp: Float = 0
            if hisDataHealth.hasHumitureData {
                humidity = hisDataHealth.humitureData.humidity
                temp = hisDataHealth.humitureData.temperature
            }
            let oaq = OaqModel(data_from: dataFrom, date: date!, o3: oaqData.o3ConcPpb, fastAqi: Float(oaqData.fastAqi), epaAqi: Float(oaqData.epaAqi), humidity: humidity, temperature: temp, autoMeasure: true)
            BleManager.sharedInstance.dataSyncDelegate?.onSyncOaq(oaq)
        }
        cmd = HeloUtils.objectToJSON(hdDict) ?? ""
        if step > 0 {
            healthDataModel.step = step
        }
        if calorie > 0 {
            healthDataModel.calorie = calorie
        }
        if distance > 0 {
            healthDataModel.distance = distance
        }
        healthDataModel.sport_type = sport_type
        healthDataModel.state_type = state_type
        if pre_minute > 0 {
            healthDataModel.pre_minute = pre_minute
        }
        if cmd.count > 0 {
            healthDataModel.cmd = cmd
        }
        if sdnn > 0 {
            healthDataModel.sdnn = sdnn
        }
        if rmssd > 0 {
            healthDataModel.rmssd = rmssd
        }
        if pnn50 > 0 {
            healthDataModel.pnn50 = pnn50
        }
        if mean > 0 {
            healthDataModel.mean = mean
        }
        if fatigue > 0 {
            healthDataModel.fatigue = fatigue
        }
        if maxBpm > 0 {
            healthDataModel.maxBpm = maxBpm
        }
        if minBpm > 0 {
            healthDataModel.minBpm = minBpm
        }
        if avgBpm > 0 {
            healthDataModel.avgBpm = avgBpm
        }
        if maxOxy > 0 {
            healthDataModel.maxOxy = maxOxy
        }
        if minOxy > 0 {
            healthDataModel.minOxy = minOxy
        }
        if avgOxy > 0 {
            healthDataModel.avgOxy = avgOxy
        }
        if huanjing_temp > 0 {
            healthDataModel.huanjing_temp = huanjing_temp
        }
        if tibiao_temp > 0 {
            healthDataModel.tibiao_temp = tibiao_temp
        }
        if yuce_temp > 0 {
            healthDataModel.yuce_temp = yuce_temp
        }
        if shice_temp > 0 {
            healthDataModel.shice_temp = shice_temp
        }
        if tempType > -1 {
            healthDataModel.tempType = tempType
        }
        if dbp > 0 {
            healthDataModel.dbp = dbp
        }
        if sbp > 0 {
            healthDataModel.sbp = sbp
        }
        if bmp > 0 {
            healthDataModel.bmp = bmp
        }
        if moodLevel > 0 {
            healthDataModel.moodLevel = moodLevel
        }
        GRDBManager.sharedInstance.insertHealthDataModels(indexModels: [healthDataModel])
        
    }
    func parseECGData(hisData:HisDataECG,seq:UInt32) {
        var date:Date?
        if hisData.hasTimeStamp {
            let timeInterval = TimeInterval(hisData.timeStamp.dateTime.seconds - (3600 * UInt32(hisData.timeStamp.timeZone)));
            date = Date(timeIntervalSince1970: timeInterval)
        }
        
        if let json = HeloUtils.objectToJSON(hisData.rawData), let dateEcg = date {
            let model = ECGDataModel(data_from: BleManager.sharedInstance.getDeviceName()!, date: dateEcg, rawData: json, seq: Int(seq), is_processed: false)
            GRDBManager.sharedInstance.insertECGDataModels(ecgDataModels: [model])
        }
        
    }
    func parsePPGData(hisData:HisDataPPG,seq:UInt32) {
        var date:Date?
        if hisData.hasTimeStamp {
            let timeInterval = TimeInterval(hisData.timeStamp.dateTime.seconds - (3600 * UInt32(hisData.timeStamp.timeZone)));
            date = Date(timeIntervalSince1970: timeInterval)
        }
        if let json = HeloUtils.objectToJSON(hisData.rawData), let datePPG = date {
            let model = PPGDataModel(data_from: BleManager.sharedInstance.getDeviceName()!, date: datePPG, rawData: json, seq: Int(seq), is_processed: false)
            GRDBManager.sharedInstance.insertPPGDataModels(ppgDataModels: [model])
        }
    }
    func parseRRIData(hisData:HisDataRRI,seq:UInt32) {
        var date:Date?
        var temp:[Int16] = []
        if hisData.hasTimeStamp {
            let timeInterval = TimeInterval(hisData.timeStamp.dateTime.seconds - (3600 * UInt32(hisData.timeStamp.timeZone)));
            date = Date(timeIntervalSince1970: timeInterval)
            
            for value in hisData.rawData {
                let fValue = UInt16((value >> 16) & 0x0000ffff)
                let sValue = UInt16(value & 0x0000ffff)
                temp.append(Int16(bitPattern:fValue))
                temp.append(Int16(bitPattern:sValue))
            }
            if let json = HeloUtils.objectToJSON(temp), let dateRRI = date {
                let model = RRIDataModel(data_from: BleManager.sharedInstance.getDeviceName()!, date: dateRRI, rawData: json, seq: Int(seq), is_processed: false)
                GRDBManager.sharedInstance.insertRRIDataModels(rriDataModels: [model])
            }
        }
    }
}
extension ProbuffHandle {
    //MARK: Calculation of Sport,ECG,PPG,RRI,sleep
    func dataCalculation() {
        sportCalculation()
        ECGCalculation()
        PPGCalculation()
        RRICalculation()
        sleepCalculation()
    }
    func sportCalculation() {
        
    }
    func ECGCalculation() {
        let ecgIndexs = GRDBManager.sharedInstance.selectIndexModels(type:HealthDataType.ecgDataEncrypt.rawValue, data_from: BleManager.sharedInstance.getDeviceName()!, isSynced: true)
        for ecgIndex in ecgIndexs {
            let ecgs = GRDBManager.sharedInstance.selectECGDataModels(data_from: BleManager.sharedInstance.getDeviceName()!, isProcessed: false, startSeq: ecgIndex.seq_start, endSeq: ecgIndex.seq_end)
            var ecgStr = ""
            var ecgModel = ecgs.first
            for ecg in ecgs {
                ecgStr += ecg.rawData
            }
            ecgStr = ecgStr.replacingOccurrences(of: "[", with: "")
            ecgStr = ecgStr.replacingOccurrences(of: "]", with: ",")
            ecgStr.removeLast()
            ecgModel?.rawData = ecgStr
            if let ecgM = ecgModel {
                BleManager.sharedInstance.dataSyncDelegate?.onSyncECG(ecgM)
            }
            
        }
    }
    func PPGCalculation() {
        let ppgIndexs = GRDBManager.sharedInstance.selectIndexModels(type:HealthDataType.ppgDataEncrypt.rawValue, data_from: BleManager.sharedInstance.getDeviceName()!, isSynced: true)
        for ppgIndex in ppgIndexs {
            let ppgs = GRDBManager.sharedInstance.selectPPGDataModels(data_from: BleManager.sharedInstance.getDeviceName()!, isProcessed: false, startSeq: ppgIndex.seq_start, endSeq: ppgIndex.seq_end)
            var ppgStr = ""
            var ppgModel = ppgs.first
            for ppg in ppgs {
                ppgStr += ppg.rawData
            }
            ppgStr = ppgStr.replacingOccurrences(of: "[", with: "")
            ppgStr = ppgStr.replacingOccurrences(of: "]", with: ",")
            ppgStr.removeLast()
            ppgModel?.rawData = ppgStr
            if let ppgM = ppgModel {
                BleManager.sharedInstance.dataSyncDelegate?.onSyncPPG(ppgM)
            }
        }
    }
    func RRICalculation() {
        let rriIndexs = GRDBManager.sharedInstance.selectIndexModels(type:HealthDataType.rriDataEncrypt.rawValue, data_from: BleManager.sharedInstance.getDeviceName()!, isSynced: true)
        for rriIndex in rriIndexs {
            let rris = GRDBManager.sharedInstance.selectRRIDataModels(data_from: BleManager.sharedInstance.getDeviceName()!, isProcessed: false, startSeq: rriIndex.seq_start, endSeq: rriIndex.seq_end)
            var rriStr = ""
            var rriModel = rris.first
            for rri in rris {
                rriStr += rri.rawData
            }
            rriStr = rriStr.replacingOccurrences(of: "[", with: "")
            rriStr = rriStr.replacingOccurrences(of: "]", with: ",")
            rriStr.removeLast()
            rriModel?.rawData = rriStr
            if let rriM = rriModel {
                BleManager.sharedInstance.dataSyncDelegate?.onSyncRRI(rriM)
            }
            
        }
    }
    func sleepCalculation() {
        
    }
}
