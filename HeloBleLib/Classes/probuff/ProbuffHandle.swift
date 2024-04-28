//
//  ProbuffHandle.swift
//  HeloBleLib_Example
//
//  Created by AppleDev_9527 on 2024/4/15.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit
import SwiftProtobuf
//protocol ProbuffHandleDelegate {
//    func indexTableSyncCompletion(indexs:[IndexModel],type: HisDataType);
//    func healthDataSyncCompletion(hisData:HisData,type:HisDataType);
//}
class ProbuffHandle: NSObject {
    public static let sharedInstance = ProbuffHandle()
//    public var delegate:ProbuffHandleDelegate?
    
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
                    healthDataSyncCompletion(hisData: decodedInfo.hisData,type: decodedInfo.type)
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
                            indexTableSyncCompletion(indexs: seqs,type: decodedInfo.type)
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

extension ProbuffHandle {
    func indexTableSyncCompletion(indexs: [IndexModel],type: HisDataType) {

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
    
    func healthDataSyncCompletion(hisData: HisData,type: HisDataType) {
        
        
        if let index_sync = checkSyncIndex(hisData: hisData,type: type) {
            let progress = progressCalculation(seq: hisData.seq,index_sycn: index_sync)
            var allcomplete = false
            if progress == Float(1) {
                removeSyncIndex(type: type, index: index_sync)
                allcomplete = checkSyncHealthDataComplete()
                
                print("date:\(index_sync.date),type==>\(type),complete progress==>\(progress),allcomplete:\(allcomplete)")
                
                if allcomplete {
                    print("health data sync complete")
                }
            }
            if let datatype = HealthDataType(rawValue: type.rawValue) {
                BleManager.sharedInstance.dataSyncDelegate?.onSyncingWithHealthData(index_sync.date, datatype, progress, allcomplete)
            }
//            print("type==>\(type)\ncurrentSeq==>\(hisData.seq), startseq==>\(index_sync.seq_start), endseq==>\(index_sync.seq_end)\nprogress==>\(progress * 100)%")
            
//            print("type==>\(type)\nprogress==>\(progress * 100)%%\n\(hisData)")
            
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
