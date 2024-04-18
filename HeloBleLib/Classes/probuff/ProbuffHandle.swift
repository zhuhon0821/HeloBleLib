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
//        let arr = [Player(id: "5", name: "Arthur11", score: 1001),Player(id: "6", name: "Barbara11", score: 10001),Player(id: "7", name: "Barbara21", score: 1111),Player(id: "8", name: "Barbara31", score: 2222)]
//        GRDBManager.sharedInstance.insertPlayers(players: arr)
//        let players = GRDBManager.sharedInstance.selectPlayer()
//        print(players)
        
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
        let optCode = getOperationCode(bytes: bytes)
        let crcData = bytes[8...bytes.count-1]

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
   
    func getCrcCheckValue(bytes:Data) -> Int {
        let a = bytes[4];
        let b = bytes[5];
        return (Int)(Int32(a) + 0x100 * Int32(b))
    }
    func CalcCrc16(data:Data, len:UInt32) -> Int {
        var wCRCin = 0x0000;
        let wCPoly = 0x1021;

        for wChar in data {
            wCRCin ^= (Int(wChar) << 8);
            for _ in 0...8 {
                if(wCRCin & 0x8000) != 0 {
                    wCRCin = (wCRCin << 1) ^ wCPoly
                } else {
                    wCRCin = wCRCin << 1
                }
            }
        }
        return wCRCin
       
    }
    func getOperationCode(bytes:Data) -> Int {
      
        let a = bytes[6];
        let b = bytes[7];
        return Int(Int32(a) + 0x100 * Int32(b))
    }
    func getDataLength(bytes:Data) -> Int {
        let a = bytes[2];
        let b = bytes[3];
        return Int(Int32(a) + (0x100 * Int32(b)))
    }
    func prefixCheck(data:Data) -> Bool{
        let length = 8;
        if (data.count < length) { //8个byte： Perfix|len|crc|opt
            return false
        }
        return (data[0] == 0x44) && (data[1] == 0x54)
    }

}
