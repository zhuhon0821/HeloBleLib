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
            var allcomplete = false
            if progress == Float(1) {
                removeSyncIndex(type: type, index: index_sync)
                allcomplete = checkSyncHealthDataComplete()
            }
            if let datatype = HealthDataType(rawValue: type.rawValue) {
                BleManager.sharedInstance.dataSyncDelegate?.onSyncingWithHealthData(index_sync.date, datatype, progress, allcomplete)
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
        
        let progress = Float(seq-index_sycn.seq_start)/Float(index_sycn.seq_end-1-index_sycn.seq_start)
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
            let seconds = hisData.health.timeStamp.dateTime.seconds - (3600 * UInt32(hisData.health.timeStamp.timeZone));
            break
        case .gnssData:
            let seconds = hisData.gnss.timeStamp.dateTime.seconds - (3600 * UInt32(hisData.gnss.timeStamp.timeZone));
            break
        case .ecgData:
            let seconds = hisData.ecg.timeStamp.dateTime.seconds - (3600 * UInt32(hisData.ecg.timeStamp.timeZone));
            break
        case .ppgData:
            let seconds = hisData.ppg.timeStamp.dateTime.seconds - (3600 * UInt32(hisData.ppg.timeStamp.timeZone));
            break
        case .rriData:
            let seconds = hisData.rri.timeStamp.dateTime.seconds - (3600 * UInt32(hisData.rri.timeStamp.timeZone));
            break
        case .medicData:
            break
        case .spo2Data:
            let seconds = hisData.spo2.timeStamp.dateTime.seconds - (3600 * UInt32(hisData.spo2.timeStamp.timeZone));
            break
        case .swimData:
            let seconds = hisData.swim.timeStamp.dateTime.seconds - (3600 * UInt32(hisData.swim.timeStamp.timeZone));
            break
        case .temperatureData:
            let seconds = hisData.temp.timeStamp.dateTime.seconds - (3600 * UInt32(hisData.temp.timeStamp.timeZone));
            break
        case .healthDataEncrypt:
            let seconds = hisData.healthencrypt.hisHealth.health.timeStamp.dateTime.seconds - (3600 * UInt32(hisData.healthencrypt.hisHealth.health.timeStamp.timeZone));
            
            let date = Date(timeIntervalSince1970: TimeInterval(seconds))
            
                if hisData.health.hasSleepData && !hisData.health.hasPedoData && !hisData.health.hasHrData && !hisData.health.hasHrvData && !hisData.health.hasBpData && !hisData.health.hasAfData && !hisData.health.hasMdtData && !hisData.health.hasMoodData && !hisData.health.hasBreathData && !hisData.health.hasBiozData && !hisData.health.hasBxoyData && !hisData.health.hasTemperatureData && !hisData.health.hasOutActData {
                    //skiped while it has sleep data only
                    
                } else {
                    
                }
            handleHisHealthData(hisDataHealth: hisData.health, seq: hisData.seq)
            break
        case .ecgDataEncrypt:
            let seconds = hisData.ecgencrypt.hisEcg.ecgencrypt.timeStamp.dateTime.seconds - (3600 * UInt32(hisData.ecgencrypt.hisEcg.ecgencrypt.timeStamp.timeZone));
            break
        case .ppgDataEncrypt:
            let seconds = hisData.ppgencrypt.hisPpg.ppgencrypt.timeStamp.dateTime.seconds - (3600 * UInt32(hisData.ppgencrypt.hisPpg.ppgencrypt.timeStamp.timeZone));
            break
        case .rriDataEncrypt:
            let seconds = hisData.rriencrypt.hisRri.rriencrypt.timeStamp.dateTime.seconds - (3600 * UInt32(hisData.rriencrypt.hisRri.rriencrypt.timeStamp.timeZone));
            break
        default: break
        }
        
    }
    func handleHisHealthData(hisDataHealth:HisDataHealth,seq:UInt32) {
        
        var step:UInt32 = 0
        var calorie:Float = 0
        var distance:Float = 0
        var sport_type:Int = 0
        var state_type:Int = 0
        var pre_minute:Int = 0
        var cmd:String = ""
        
        var hdDict:Dictionary = [String:Any]()
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
            if (hisDataHealth.pedoData.step > 0) {
                mDict["s"] = hisDataHealth.pedoData.step
                step = hisDataHealth.pedoData.step
            }
            if (hisDataHealth.pedoData.calorie > 0) {
                mDict["c"] = hisDataHealth.pedoData.calorie
                calorie = Float(hisDataHealth.pedoData.calorie) * 0.1
            }
            if (hisDataHealth.pedoData.distance > 0) {
                mDict["d"] = hisDataHealth.pedoData.distance
                distance = Float(hisDataHealth.pedoData.distance) * 0.1
            }
            if (hisDataHealth.pedoData.type > 0) {
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
            if (hisDataHealth.hrData.maxBpm > 0) {
                mDict["x"] = hisDataHealth.hrData.maxBpm
            }
            if (hisDataHealth.hrData.minBpm > 0) {
                mDict["n"] = hisDataHealth.hrData.minBpm
            }
            if (hisDataHealth.hrData.avgBpm > 0) {
                mDict["a"] = hisDataHealth.hrData.avgBpm
            }
            if mDict.count > 0 {
                hdDict["H"] = mDict
            }
        }
        if hisDataHealth.hasHrvData {
            
            var mDict:Dictionary = [String:Any]()
            if (hisDataHealth.hrvData.sdnn > 0) {
                mDict["s"] = hisDataHealth.hrvData.sdnn
//                model61.sdnn = hrv.sdnn/10.0;
            }
            if (hisDataHealth.hrvData.rmssd > 0) {
                mDict["r"] = hisDataHealth.hrvData.rmssd
//                model61.rmssd = hrv.rmssd/10.0;
            }
            if (hisDataHealth.hrvData.pnn50 > 0) {
                mDict["p"] = hisDataHealth.hrvData.pnn50
//                model61.pnn50 = hrv.pnn50/10.0;
            }
            if (hisDataHealth.hrvData.mean > 0) {
                mDict["m"] = hisDataHealth.hrvData.mean
//                model61.mean = hrv.mean/10.0;
            }
            if (hisDataHealth.hrvData.hasFatigue) {
                if hisDataHealth.hrvData.fatigue > 0 {
                    mDict["f"] = hisDataHealth.hrvData.fatigue
                } else {
                    mDict["f"] = Int(hisDataHealth.hrvData.rmssd * 20)
                }
//                model61.mean = hrv.mean/10.0;
            }
            if mDict.count > 0 {
                hdDict["V"] = mDict
            }
        }
        var date:Date?
        if hisDataHealth.hasTimeStamp {
            let timeInterval = TimeInterval(hisDataHealth.timeStamp.dateTime.seconds - (3600 * UInt32(hisDataHealth.timeStamp.timeZone)));
            date = Date(timeIntervalSince1970: timeInterval)
            let hour = NSCalendar.current.component(.hour, from: date!)
            let minute = NSCalendar.current.component(.minute, from: date!)
            let time = [hour,minute]
            hdDict["T"] = time
            
        }
        let hdDictJson = hdDict
        if hisDataHealth.hasBiozData {
            hisDataHealth.biozData.x
            hisDataHealth.biozData.r
        }
        cmd = dictionaryToJSON(hdDict) ?? ""
        if let recordDate = date {
            let healthDataModel = HealthDataModel(data_from: BleManager.sharedInstance.getDeviceName()!, date: recordDate, seq: seq, is_processed: false, step: step, calorie: calorie, distance: distance, sport_type: sport_type, state_type: state_type, pre_minute: pre_minute, cmd: cmd)
            GRDBManager.sharedInstance.insertHealthDataModels(indexModels: [healthDataModel])
        }
        
    }
    func dictionaryToJSON(_ dictionary: [String: Any]) -> String? {
        if let jsonData = try? JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted) {
            return String(data: jsonData, encoding: .utf8)
        }
        return nil
    }
}
