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
                print(decodedInfo)
                    break
                case 0x90:
                let decodedInfo = try FilesUpdateResponse(serializedData: crcData)
                print(decodedInfo)
                    break
                case 0xffff:
                let decodedInfo = try ConParamsUpdate(serializedData: crcData)
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
