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
    public static let sharedInstance = CmdTool(type: .probuffType)
    
    public func syncHealthData() {
        ProbuffManager.sharedInstance.read80HistoryDataIndexTable(.healthData)
    }
    
    //MARK:read base info
    public func read00DeviceInfomation() {
        
        if self.type == .probuffType {
            ProbuffManager.sharedInstance.read00DeviceInfomation()
        } else {
           print("MTK")
        }
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
    public func setDateTimeConf(_ date:Date) {
        if self.type == .probuffType {
            ProbuffManager().setDateTimeConf(date)
        } else {
            
        }
    }
    public func setUserConf(_ userConf:CUserConf) {
        if self.type == .probuffType {
            ProbuffManager().setUserConf(userConf)
        } else {
            
        }

    }
   
    public func setBloodPresureConf(_ cbpCaliConf:CBpCaliConf) {
        if self.type == .probuffType {
            ProbuffManager().setBloodPresureConf(cbpCaliConf)
        } else {
            
        }

    }
    public func setHrAlarmConf(_ chrAlarmConf:CHrAlarmConf) {
        if self.type == .probuffType {
            ProbuffManager().setHrAlarmConf(chrAlarmConf)
        } else {
            
        }
    }
    public func setGoalConf(_ cgoalConf:CGoalConf) {
        if self.type == .probuffType {
            ProbuffManager().setGoalConf(cgoalConf)
        } else {
            
        }
    }
    public func setGnssConf(_ cgnssConf:CGnssConf) {
        if self.type == .probuffType {
            ProbuffManager().setGnssConf(cgnssConf)
        } else {
            
        }
    }
    public func setAf24Conf(_ cafConf:CAfConf) {
        if self.type == .probuffType {
            ProbuffManager().setAf24Conf(cafConf)
        } else {
            
        }
    }
    //MARK: -- 02 MsgNotification
    public func setDNDMode(_ dndModel:CMsgHandler) {
        if self.type == .probuffType {
            ProbuffManager().setDNDMode(dndModel)
        } else {
            
        }
    }
    public func addSpecialList(_ rolls:[CRoll]) {
        if self.type == .probuffType {
            ProbuffManager().addSpecialList(rolls)
        } else {
            
        }
    }
    public func clearAllLists() {
        if self.type == .probuffType {
            ProbuffManager().clearAllLists()
        } else {
            
        }
    }
    //MARK: -- 03 weather
    public func clearWeather() {
        if self.type == .probuffType {
            ProbuffManager().clearWeather()
        } else {
            
        }
    }
    public func setWeather(_ cweatherGroup : CWeatherGroup) {
        if self.type == .probuffType {
            ProbuffManager().setWeather(cweatherGroup)
        } else {
            
        }
    }
    public func clearAirQuality() {
        if self.type == .probuffType {
            ProbuffManager().clearAirQuality()
        } else {
            
        }
    }
    public func writeAirQuality(_ cairQualityData:CAirQualityData) {
        if self.type == .probuffType {
            ProbuffManager().writeAirQuality(cairQualityData)
        } else {
            
        }
    }
    //MARK: 04 alarm clock
    public func setAlarmClocks(_ calarmClocks:[CAlarmClock]) {
        if self.type == .probuffType {
            ProbuffManager().setAlarmClocks(calarmClocks)
        } else {
            
        }
    }
    public func clearAlarmClocks(){
        if self.type == .probuffType {
            ProbuffManager().clearAlarmClocks()
        } else {
            
        }
    }
    //MARK: -- 05 Calendar
    public func clearCalendar(){
        if self.type == .probuffType {
            ProbuffManager().clearCalendar()
        } else {
            
        }
    }
    public func setCalendar(_ ccalendars:[CCalendar]){
        if self.type == .probuffType {
            ProbuffManager().setCalendar(ccalendars)
        } else {
            
        }
    }
    //MARK: -- 05 久坐提醒 Sedentary
    public func clearSedentariness() {
        if self.type == .probuffType {
            ProbuffManager().clearSedentariness()
        } else {
            
        }
    }
    public func setSedentariness(_ csedentarinesses:[CSedentariness]) {
        if self.type == .probuffType {
            ProbuffManager().setSedentariness(csedentarinesses)
        } else {
            
        }
    }
    //MARK: device setting 设备设置
    public func setDeviceOption(_ cNotification:CDeviceConfNotification) {
        if self.type == .probuffType {
            ProbuffManager().setDeviceOption(cNotification)
        } else {
            
        }
    }
    //MARK: -- c110 command
    public func setLifeStyle(_ clifeQualityData:CLifeQualityData){
        if self.type == .probuffType {
            ProbuffManager().setLifeStyle(clifeQualityData)
        } else {
            
        }
    }
    public func setHealthAlarmConf(_ model:CC110HealthAlarmConf) {
        if self.type == .probuffType {
            ProbuffManager().setHealthAlarmConf(model)
        } else {
            
        }
    }
    public func readHistoryOfHealthAlarm() {
        if self.type == .probuffType {
            ProbuffManager().readHistoryOfHealthAlarm()
        } else {
            
        }
    }
    public func setSOSConfirm() {
        if self.type == .probuffType {
            ProbuffManager().setSOSConfirm()
        } else {
            
        }
    }
    public func setAFAlarm(_ af:Bool,_ checkAlarmP:Bool?) {
        if self.type == .probuffType {
            ProbuffManager().setAFAlarm(af, checkAlarmP)
        } else {
            
        }
    }
    public func setFallConfirm(_ fallRet:Bool) {
        if self.type == .probuffType {
            ProbuffManager().setFallConfirm(fallRet)
        } else {
            
        }
    }
    public func setWalletInfo(_ wallet:CWallet) {
        if self.type == .probuffType {
            ProbuffManager().setWalletInfo(wallet)
        } else {
            
        }
    }
    //MARK: -- set Motors
    public func setMotors(_ motors:[CVibrateCnf]) {
        if self.type == .probuffType {
            ProbuffManager().setMotors(motors)
        } else {
            
        }
    }
    public func feelMotor(_ motor:CVibrateCnf) {
        if self.type == .probuffType {
            ProbuffManager().feelMotor(motor)
        } else {
            
        }
    }
}
