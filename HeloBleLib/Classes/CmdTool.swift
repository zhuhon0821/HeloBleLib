//
//  CmdTool.swift
//  HeloBleLib_Example
//
//  Created by AppleDev_9527 on 2024/7/19.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit
enum DeviceProtocolType {
    case probuffType
    case MTKType
}
class CmdTool: NSObject {
    
    public var type:DeviceProtocolType
    
    init(type: DeviceProtocolType) {
        self.type = type
    }
    
    //MARK:read base info
    public func read00DeviceInfomation() {
        
    }
//    public func write01PeerInfomation(_ configuration:Any) {
//        
//    }
//    public func write02MsgNotification(_ msgConf:Any) {
//        
//    }
//    public func readRealTimeData(_ rtDataScb:RTDataSbscrbr) {
//        
//    }
    //MARK: -- 01 PeerInfomation
    public func setDateTimeConf(date:Date) {
        if self.type == .probuffType {
            ProbuffManager().setDateTimeConf(date: date)
        } else {
            
        }
    }
    public func setUserConf(userConf:CUserConf) {
        if self.type == .probuffType {
            
        } else {
            
        }

    }
   
    public func setBloodPresureConf(cbpCaliConf:CBpCaliConf) {
        if self.type == .probuffType {
            
        } else {
            
        }

    }
    public func setHrAlarmConf(chrAlarmConf:CHrAlarmConf) {
        if self.type == .probuffType {
            
        } else {
            
        }
    }
    public func setGoalConf(cgoalConf:CGoalConf) {
        if self.type == .probuffType {
            
        } else {
            
        }
    }
    public func setGnssConf(cgnssConf:CGnssConf) {
        if self.type == .probuffType {
            
        } else {
            
        }
    }
    public func setAf24Conf(cafConf:CAfConf) {
        if self.type == .probuffType {
            
        } else {
            
        }
    }
    //MARK: -- 02 MsgNotification
    public func setDNDMode(_ dndModel:CMsgHandler) {
        if self.type == .probuffType {
            
        } else {
            
        }
    }
    public func addSpecialList(_ rolls:[CRoll]) {
        if self.type == .probuffType {
            
        } else {
            
        }
    }
    public func clearAllLists() {
        if self.type == .probuffType {
            
        } else {
            
        }
    }
    //MARK: -- 03 weather
    public func clearWeather() {
        if self.type == .probuffType {
            
        } else {
            
        }
    }
    public func setWeather(_ cweatherGroup : CWeatherGroup) {
        if self.type == .probuffType {
            
        } else {
            
        }
    }
    public func clearAirQuality() {
        if self.type == .probuffType {
            
        } else {
            
        }
    }
    public func writeAirQuality(cairQualityData:CAirQualityData) {
        if self.type == .probuffType {
            
        } else {
            
        }
    }
    //MARK: 04 alarm clock
    public func setAlarmClocks(_ calarmClocks:[CAlarmClock]) {
        if self.type == .probuffType {
            
        } else {
            
        }
    }
    public func clearAlarmClocks(){
        if self.type == .probuffType {
            
        } else {
            
        }
    }
    //MARK: -- 05 Calendar
    public func clearCalendar(){
        if self.type == .probuffType {
            
        } else {
            
        }
    }
    public func setCalendar(_ ccalendars:[CCalendar]){
        if self.type == .probuffType {
            
        } else {
            
        }
    }
    //MARK: -- 05 久坐提醒 Sedentary
    public func clearSedentariness() {
        if self.type == .probuffType {
            
        } else {
            
        }
    }
    public func setSedentariness(_ csedentarinesses:[CSedentariness]) {
        if self.type == .probuffType {
            
        } else {
            
        }
    }
    //MARK: device setting 设备设置
    public func setDeviceOption(_ cNotification:CDeviceConfNotification) {
        if self.type == .probuffType {
            
        } else {
            
        }
    }
    //MARK: -- c110 command
    public func setLifeStyle(_ clifeQualityData:CLifeQualityData){
        if self.type == .probuffType {
            
        } else {
            
        }
    }
    public func setHealthAlarmConf(_ model:CC110HealthAlarmConf) {
        if self.type == .probuffType {
            
        } else {
            
        }
    }
    public func readHistoryOfHealthAlarm() {
        if self.type == .probuffType {
            
        } else {
            
        }
    }
    public func setSOSConfirm() {
        if self.type == .probuffType {
            
        } else {
            
        }
    }
    public func setAFAlarm(_ af:Bool,_ checkAlarmP:Bool?) {
        if self.type == .probuffType {
            
        } else {
            
        }
    }
    public func setFallConfirm(_ fallRet:Bool) {
        if self.type == .probuffType {
            
        } else {
            
        }
    }
    public func setWalletInfo(_ wallet:CWallet) {
        if self.type == .probuffType {
            
        } else {
            
        }
    }
    //MARK: -- set Motors
    public func setMotors(_ motors:[CVibrateCnf]) {
        if self.type == .probuffType {
            
        } else {
            
        }
    }
    public func feelMotor(_ motor:CVibrateCnf) {
        if self.type == .probuffType {
            
        } else {
            
        }
    }
}
