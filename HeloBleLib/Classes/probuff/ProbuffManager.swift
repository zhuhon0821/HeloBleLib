//
//  ProbuffManager.swift
//  HeloBleLib_Example
//
//  Created by AppleDev_9527 on 2024/4/15.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit

class ProbuffManager: NSObject {
    public static let sharedInstance = ProbuffManager()
    override init() {
        super.init()
        
    }

    func appendWriteData(optCode:PB_Opt,payload:Data) -> Data {
        var pbytes = Data([0, 0, 0, 0, 0, 0, 0, 0])
        pbytes[0] = 0x44
        pbytes[1] = 0x54
        
        let len = payload.count
        let lenA = len/0x100
        let lenB = len%0x100
        pbytes[2] = UInt8(lenB);
        pbytes[3] = UInt8(lenA);
    
        let crcCode = ProbuffHandle.sharedInstance.calcCrc16(data: payload, len: UInt(payload.count))
        let crcA = crcCode/0x100;
        let crcB = crcCode%0x100;
        pbytes[4] = UInt8(crcB);
        pbytes[5] = UInt8(crcA);
        
        let optI = optCode.rawValue
        let optA = optI/0x100;
        let optB = optI%0x100;
        pbytes[6] = UInt8(optB);
        pbytes[7] = UInt8(optA);
        
        var headerData = pbytes
        headerData.append(contentsOf: payload)
        return headerData
    }
    /*
    func writeCharacteristicByPBOpt(optCode:PB_Opt,payload:Data) {
       
        let mtu = 20
        
        NSData *writeData = [_dataHandle appendWriteData:optCode
                                          andPayloadData:payload];
        if (writeData.length < 8) {
            NSLog(@"WARNING: Data length incorrect: %@",writeData);
            //[BGLog write:[NSString stringWithFormat:@"data length incorrect %@\n", writeData]];
            return;
        }
        NSString *writeStr = [NSStringUtils NSDataToByteTohex:writeData];
        NSString *optStr = [writeStr substringWithRange:NSMakeRange(12, 4)];
        SCQASCType sType = [self scqascType:optStr];

            dispatch_async([self bleQueue], ^{
                if (!self.cmdQueueCancelFlag) {
                    NSString *logDown = [NSString stringWithFormat:@"{name:\"down\", id:\"%ld\", sentence:\"%@\"}",(long)optCode,[NSStringUtils NSDataToByteTohex:payload]];
                    [IVBLEUtils writeBLELog:logDown andType:BLE_LOG_NORMAL];
                    [BGLog write:@"write to bracelet\n"];
                    for (int i = 0; i <= writeData.length; i += mtu) {
                        NSRange range = NSMakeRange(i, mtu);
                        if ((i+mtu) > writeData.length) {
                            range = NSMakeRange(i, writeData.length-i);
                        }
                        NSData *tData = [writeData subdataWithRange:range];
                        [self writeToBracelet:tData];
                    }
                    self.longCmdsDuring = YES;
                    //[self suspendCmdQueueAfterSendCmd:sType]; //一组操作结束，悬挂队列
                    if (![self iwownPBNoResponseCmd:@(optCode)]) {
                        //PB的无需等待回复cmd操作，自动返回
                        [self suspendCmdQueueAfterSendCmd:sType];
                        //[self resumeCmdQueueAfterResponse];
                    }
                }
            });
    }
    */
    public func setDateTimeConf(date:Date) {
        let tz = NSTimeZone.system
        let tsFromGMT = tz.secondsFromGMT()
        let rtDate = date.addingTimeInterval(TimeInterval(tsFromGMT))
        var rtTime = RtTime()
        rtTime.seconds = UInt32(rtDate.timeIntervalSince1970)
        var dateTime = DateTime()
        let timeZone = (tsFromGMT/3600)
        dateTime.dateTime = rtTime
        dateTime.timeZone = Int32(timeZone)
        
        if let data = try? dateTime.serializedData() {
            BleManager.sharedInstance.writeCommand(data: data)
        }
    }
    public func setUserConf(userConf:UserConf_C) {
        var conf = UserConf()
        conf.height = userConf.height
        conf.weight = userConf.weight
        conf.age = userConf.age
        conf.gender = userConf.gender
        conf.calibRun = userConf.calibRun
        conf.calibWalk = userConf.calibWalk
        conf.wristCircumference = userConf.wristCircumference
        conf.historyOfHypertension = userConf.historyOfHypertension
        conf.hash = userConf.hash
        
        if let data = try?conf.serializedData() {
            BleManager.sharedInstance.writeCommand(data: data)
        }
    }
   
    public func setBloodPresureConf(bpCaliConf:BpCaliConf) {
        if let data = try? bpCaliConf.serializedData() {
            BleManager.sharedInstance.writeCommand(data: data)
        }
    }
    public func setHrAlarmConf(hrAlarmConf:HrAlarmConf) {
        if let data = try? hrAlarmConf.serializedData() {
            BleManager.sharedInstance.writeCommand(data: data)
        }
    }
    public func setGoalConf(goalConf:GoalConf) {
        if let data = try? goalConf.serializedData() {
            BleManager.sharedInstance.writeCommand(data: data)
        }
    }
    public func setGnssConf(gnssConf:GnssConf) {
        if let data = try? gnssConf.serializedData() {
            BleManager.sharedInstance.writeCommand(data: data)
        }
    }
    public func setAf24Conf(afConf:AfConf) {
        if let data = try? afConf.serializedData() {
            BleManager.sharedInstance.writeCommand(data: data)
        }
    }
    public func setMessageNotifyConf(msgNotify:MsgNotify) {
        if let data = try? msgNotify.serializedData() {
            BleManager.sharedInstance.writeCommand(data: data)
        }
    }
    public func setMessageHandleConf(msgHandler:MsgHandler) {
        if let data = try? msgHandler.serializedData() {
            BleManager.sharedInstance.writeCommand(data: data)
        }
    }
    public func setMessageFilterConf(msgFilter:MsgFilter) {
        if let data = try? msgFilter.serializedData() {
            BleManager.sharedInstance.writeCommand(data: data)
        }
    }
    public func setWeatherGroup(weatherGroup:WeatherGroup) {
        if let data = try? weatherGroup.serializedData() {
            BleManager.sharedInstance.writeCommand(data: data)
        }
    }
    //getWeatherGroup
    
}
