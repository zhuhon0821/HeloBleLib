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
    /**
     *param example:[height:170,weight:65,gender:1 represent female or 0 represent male,age:25,calibWalk:100,calibRun:100]
     */
//    public func setPersonalInfo(param:Dictionary<String, Any>) {
//        
//        
//        if let jsonData = try? JSONSerialization.data(withJSONObject: param, options: []) {
//            if let jsonString = String(data: jsonData, encoding: .utf8) {
//                if let userConf = try? UserConf(jsonString: jsonString) {
//                    if let data = try? userConf.serializedData() {
//                        BleManager.sharedInstance.writeCommend(data: data)
//                    }
//                }
//            }
//        }
//    }
    
    /**
     *param example:[height:170,weight:65,gender:1 represent female or 0 represent male,age:25,calibWalk:100,calibRun:100]
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
    public func setPersonalInfo(userConf:UserConf) {
        if let data = try? userConf.serializedData() {
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
    public func setMessageFilterConf(msgHandler:MsgHandler) {
        if let data = try? msgHandler.serializedData() {
            BleManager.sharedInstance.writeCommand(data: data)
        }
    }
    
    //getMessageFilterConf
    
}
