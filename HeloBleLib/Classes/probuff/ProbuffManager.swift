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
    public var mtu:Int = 20
    
    override init() {
        super.init()
    }
    //MARK:sync detail data
    public func read80HistoryDataIndexTable(_ type:HisDataType) {
        for type in HisDataType.allCases {
            var itSync = HisITSync()
            itSync.type = type
            if let data = getHistoryDataIndexTable(itSync) {
                writeCharacteristicByPBOpt(optCode: .PB_Opt_HistoryData, payload: data)
            }
        }

    }
    public func read80HistoryDataStart(_ idSync:HisStartSync) {
        if let data = getHistoryDataStart(idSync) {
            writeCharacteristicByPBOpt(optCode: .PB_Opt_HistoryData, payload: data)
        }
    }
    //MARK:read base info
    public func read00DeviceInfomation() {
        var diR = DeviceInfoRequest()
        diR.operation = .read
        diR.reserved = 123
        if let data = try? diR.serializedData() {
            writeCharacteristicByPBOpt(optCode: .PB_Opt_PeerInfo, payload: data)
        }
    }
    public func write01PeerInfomation() {
        var piN = PeerInfoNotification()
        
    }
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
            writeCharacteristicByPBOpt(optCode: .PB_Opt_PeerInfo, payload: data)
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
            
            writeCharacteristicByPBOpt(optCode: .PB_Opt_PeerInfo, payload: data)
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
extension ProbuffManager {
    //MARK: -- Request
    func getDeviceInfoRequest() -> Data?{
        var diR = DeviceInfoRequest()
        diR.operation = .read
        diR.reserved = 123
        return try? diR.serializedData()
    }
    func getDataInfoRequest() -> Data? {
        var diR = DataInfoRequest()
        diR.reserved = 123
        return try? diR.serializedData()
    }
    //MARK: -- Subscriber
    func getRealTimeDataSubscriber(_ rtDSB:RTDataSbscrbr,_ isRunInBackground:Bool) -> Data? {
        var rtSBR = RtSubscriber()
        var rtSensor = RtSensor()
        
        rtSensor.operation = .sensorStartSync
        
        var rtSMArr = [RtSync.stopAll,RtSync.stopAll,RtSync.stopAll,RtMode.backNormal] as [Any]
        
        switch (rtDSB) {
            case .RTDataSbscrbrReadTime:
                rtSMArr[0] = RtSync.onlyOnce;
                break
            case .RTDataSbscrbrReadBattery:
                rtSMArr[1] = RtSync.onlyOnce;
                break
            case .RTDataSbscrbrReadHealth:
                rtSMArr[2] = RtSync.onlyOnce;
                break
            case .RTDataSbscrbrEasyCameraOn:
                rtSMArr[3] = RtMode.enterCamera;
                rtSBR.mode = rtSMArr[3] as! RtMode
                break
            case .RTDataSbscrbrEasyCameraOff:
                rtSMArr[3] = RtMode.backNormal;
                rtSBR.mode = rtSMArr[3] as! RtMode
                break
            case .RTDataSbscrbrTenMinute:
                rtSMArr[0] = RtSync.onTenMinuteChange
                break
            case .RTDataSbscrbrStartDfu:
                rtSMArr[3] = RtMode.rtStartDfuMode;
                rtSBR.mode = rtSMArr[3] as! RtMode
                break
            case .RTDataSbscrbrStopDfu:
                rtSMArr[3] = RtMode.backNormal
                rtSBR.mode = rtSMArr[3] as! RtMode
                break
            case .RTDataSbscrbrHrMeasure:
                rtSMArr[3] = RtMode.hrMeasure
                rtSBR.mode = rtSMArr[3] as! RtMode
                break
            case .RTDataSbscrbrBiaMeasure:
                rtSensor.type = UInt32(SensorType.bioz.rawValue);
                rtSBR.sensor = rtSensor;
                break
            case .RTDataSbscrbrFatigueMeasure:
                rtSMArr[3] = RtMode.fatigueMeasure
                rtSBR.mode = rtSMArr[3] as! RtMode
                break
            case .RTDataSbscrbrBreatheMeasure:
                //与心率同一条命令
                rtSMArr[3] = RtMode.hrMeasure;
                rtSBR.mode = rtSMArr[3] as! RtMode
                break
            case .RTDataSbscrbrPressureMeasure:
                rtSMArr[3] = RtMode.pressureMeasure
                rtSBR.mode = rtSMArr[3] as! RtMode
                break
            case .RTDataSbscrbrMeasureState:
                rtSMArr[3] = RtMode.rtViewMeasureState
            rtSBR.mode = rtSMArr[3] as! RtMode
                break
            case .RTDataSbscrbrSensorNone:
               
                break
            case .RTDataSbscrbrSensorEcg:
                rtSensor.type = UInt32(SensorType.ecg.rawValue)
                rtSBR.sensor = rtSensor
                break
            case .RTDataSbscrbrSensorPpg:
                rtSensor.type = UInt32(SensorType.ppg.rawValue)
                rtSBR.sensor = rtSensor
                break
            case .RTDataSbscrbrSensorMag:
                rtSensor.type = UInt32(SensorType.mag.rawValue)
                rtSBR.sensor = rtSensor
                break
            case .RTDataSbscrbrSensorGyro:
                rtSensor.type = UInt32(SensorType.gyro.rawValue)
                rtSBR.sensor = rtSensor
                break
            case .RTDataSbscrbrSensorAcc:
                rtSensor.type = UInt32(SensorType.acc.rawValue)
                rtSBR.sensor = rtSensor
                break
            case .RTDataSbscrbrSensorBp:
                rtSensor.type = UInt32(SensorType.bp.rawValue)
                rtSBR.sensor = rtSensor
                break
            case .RTDataSbscrbrSensorBpresult:
                rtSensor.type = UInt32(SensorType.bpresult.rawValue)
                rtSBR.sensor = rtSensor
                break
            case .RTDataSbscrbrSensorTemperature:
                rtSensor.type = UInt32(SensorType.temperature.rawValue)
                rtSBR.sensor = rtSensor
                break
            case .RTDataSbscrbrSensorTwoEcg:
                rtSensor.type = UInt32(SensorType.twoEcg.rawValue)
                rtSBR.sensor = rtSensor
                break
            case .RTDataSbscrbrSensorTypeEcgDetect:
                rtSensor.type = UInt32(SensorType.ecgDetect.rawValue)
                rtSBR.sensor = rtSensor
                break
            case .RTDataSbscrbrSensorTypeSPO2:
                rtSensor.type = UInt32(SensorType.spo2.rawValue)
                rtSBR.sensor = rtSensor
                break
            case .RTDataSbscrbrSensorTypeOaq:
                rtSensor.type = UInt32(SensorType.oaq.rawValue)
                rtSBR.sensor = rtSensor
                break
            case .RTDataSbscrbrSensorTypeIaq:
                rtSensor.type = UInt32(SensorType.iaq.rawValue)
                rtSBR.sensor = rtSensor
                break
            case .RTDataSbscrbrSensorTypeHumiture:
                rtSensor.type = UInt32(SensorType.humiture.rawValue)
                rtSBR.sensor = rtSensor
                break
                
        }
        
        if (isRunInBackground) {
            rtSMArr[0] = RtSync.onTenMinuteChange
        }
        rtSBR.time = rtSMArr[0] as! RtSync
        rtSBR.battery = rtSMArr[1] as! RtSync
        rtSBR.health = rtSMArr[2] as! RtSync
    //    rtSBR.mode = (RtMode)rtSMArr[3];
        return  try?rtSBR.serializedData()
    }
    func resignRealTimeDataSubscriber(_ rtDSB:RTDataSbscrbr) -> Data? {
        var rtSBR = RtSubscriber()
        var rtSensor = RtSensor()
        rtSensor.operation = SensorOperation.sensorStopSync
        
        var rtSMArr = [RtSync.stopAll,RtSync.stopAll,RtSync.stopAll,RtMode.backNormal] as [Any]
        
        switch (rtDSB) {
        case .RTDataSbscrbrReadTime:
            rtSMArr[0] = RtSync.onlyOnce
            break
        case .RTDataSbscrbrReadBattery:
            rtSMArr[1] = RtSync.onlyOnce
            break
        case .RTDataSbscrbrReadHealth:
            rtSMArr[2] = RtSync.onlyOnce
            break
        case .RTDataSbscrbrEasyCameraOn:
            rtSMArr[3] = RtMode.enterCamera
            rtSBR.mode = rtSMArr[3] as! RtMode
            break
        case .RTDataSbscrbrEasyCameraOff:
            rtSMArr[3] = RtMode.backNormal
            rtSBR.mode = rtSMArr[3] as! RtMode
            break
        case .RTDataSbscrbrTenMinute:
            rtSMArr[0] = RtSync.onTenMinuteChange
            break
        case .RTDataSbscrbrStartDfu:
            rtSMArr[3] = RtMode.rtStartDfuMode
            rtSBR.mode = rtSMArr[3] as! RtMode
            break
        case .RTDataSbscrbrStopDfu:
            rtSMArr[3] = RtMode.backNormal
            rtSBR.mode = rtSMArr[3] as! RtMode
            break
        case .RTDataSbscrbrHrMeasure:
            rtSMArr[3] = RtSync.stopAll
            rtSBR.mode = rtSMArr[3] as! RtMode
            break
        case .RTDataSbscrbrBiaMeasure:
            rtSensor.type = UInt32(SensorType.bioz.rawValue);
            rtSBR.sensor = rtSensor
            break
        case .RTDataSbscrbrFatigueMeasure:
            rtSMArr[3] = RtSync.stopAll
            rtSBR.mode = rtSMArr[3] as! RtMode
            break
        case .RTDataSbscrbrBreatheMeasure:
            rtSMArr[3] = RtSync.stopAll
            rtSBR.mode = rtSMArr[3] as! RtMode
            break
        case .RTDataSbscrbrPressureMeasure:
            rtSMArr[3] = RtSync.stopAll
            rtSBR.mode = rtSMArr[3] as! RtMode
            break
        case .RTDataSbscrbrSensorNone:
            
            break
        case .RTDataSbscrbrSensorEcg:
            rtSensor.type = UInt32(SensorType.ecg.rawValue)
            rtSBR.sensor = rtSensor
            break
        case .RTDataSbscrbrSensorPpg:
            rtSensor.type = UInt32(SensorType.ppg.rawValue)
            rtSBR.sensor = rtSensor
            break
        case .RTDataSbscrbrSensorMag:
            rtSensor.type = UInt32(SensorType.mag.rawValue)
            rtSBR.sensor = rtSensor
            break
        case .RTDataSbscrbrSensorGyro:
            rtSensor.type = UInt32(SensorType.gyro.rawValue)
            rtSBR.sensor = rtSensor
            break
        case .RTDataSbscrbrSensorAcc:
            rtSensor.type = UInt32(SensorType.acc.rawValue)
            rtSBR.sensor = rtSensor
            break
        case .RTDataSbscrbrSensorBp:
            rtSensor.type = UInt32(SensorType.bp.rawValue)
            rtSBR.sensor = rtSensor
            break
        case .RTDataSbscrbrSensorBpresult:
            rtSensor.type = UInt32(SensorType.bpresult.rawValue)
            rtSBR.sensor = rtSensor
            break
        case .RTDataSbscrbrSensorTemperature:
            rtSensor.type = UInt32(SensorType.temperature.rawValue)
            rtSBR.sensor = rtSensor
            break
        case .RTDataSbscrbrSensorTwoEcg:
            rtSensor.type = UInt32(SensorType.twoEcg.rawValue)
            rtSBR.sensor = rtSensor
            break
        case .RTDataSbscrbrSensorTypeEcgDetect:
            rtSensor.type = UInt32(SensorType.ecgDetect.rawValue)
            rtSBR.sensor = rtSensor
            break
        case .RTDataSbscrbrSensorTypeSPO2:
            rtSensor.type = UInt32(SensorType.spo2.rawValue)
            rtSBR.sensor = rtSensor
            break
        case .RTDataSbscrbrSensorTypeOaq:
            rtSensor.type = UInt32(SensorType.oaq.rawValue)
            rtSBR.sensor = rtSensor
            break
        case .RTDataSbscrbrSensorTypeIaq:
            rtSensor.type = UInt32(SensorType.iaq.rawValue)
            rtSBR.sensor = rtSensor
            break
        case .RTDataSbscrbrSensorTypeHumiture:
            rtSensor.type = UInt32(SensorType.humiture.rawValue)
            rtSBR.sensor = rtSensor
            break
            
        case .RTDataSbscrbrMeasureState:
            break
        }
        rtSBR.time = rtSMArr[0] as! RtSync
        rtSBR.battery = rtSMArr[1] as! RtSync
        rtSBR.health = rtSMArr[2] as! RtSync
        rtSBR.mode = rtSMArr[3] as! RtMode
        return try? rtSBR.serializedData()
    }
    func getHistoryDataIndexTable(_ idSync:HisITSync) -> Data? {
        var hS = HisSubscriber()
        hS.operation = .itSync
        hS.itSync = idSync
        return try? hS.serializedData()
    }
    func getHistoryDataStart(_ idSync:HisStartSync) -> Data? {
        var hS = HisSubscriber()
        hS.operation = .startSync
        hS.startSync = idSync
        return try? hS.serializedData()
    }
    func getHistoryDataStop(_ idSync:HisStopSync) -> Data?{
        var hS = HisSubscriber()
        hS.operation = .stopSync
        hS.stopSync = idSync
        return try? hS.serializedData()
    }
    func getFileUpdateRequestDesc() -> Data? {
        var fuR = FilesUpdateRequest()
        fuR.desc = true
        return try? fuR.serializedData()
    }
    func getFileUpdateRequestInit(_ idRequest:FUInitRequest) -> Data?{
        var fuR = FilesUpdateRequest()
        fuR.init_p = idRequest
        return try? fuR.serializedData()
    }
    func getFileUpdateRequestData(_ idRequest:FUDataRequest) -> Data?{
        var fuR = FilesUpdateRequest()
        fuR.data = idRequest
        return try? fuR.serializedData()
    }
    func getFileUpdateRequestExit(_ idRequest:FUExitRequest) -> Data?{
        var fuR = FilesUpdateRequest()
        fuR.exit = idRequest
        return try? fuR.serializedData()
    }
    
    //MARK: -- Information
    func getPeerInformation(_ configuration: Any) -> Data? {
        var peerInfoNotification = PeerInfoNotification()
        if configuration is DateTime {
            peerInfoNotification.dateTime = configuration as! DateTime
        } else if configuration is GnssConf {
            peerInfoNotification.gnssConf = configuration as! GnssConf
        } else if configuration is HrAlarmConf {
            peerInfoNotification.hrAlarmConf = configuration as! HrAlarmConf
        } else if configuration is UserConf {
            peerInfoNotification.userConf = configuration as! UserConf
        } else if configuration is GoalConf {
            peerInfoNotification.goalConf = configuration as! GoalConf
        } else if configuration is BpCaliConf {
            peerInfoNotification.bpcaliConf = configuration as! BpCaliConf
        } else if configuration is AfConf {
            peerInfoNotification.afConf = configuration as! AfConf
        }
        return try? peerInfoNotification.serializedData()
    }
    func getMessageNotifyInformation(_ msgConf: Any) -> Data? {
        var msgN = MsgNotification()
        if msgConf is MsgHandler {
            msgN.handler = msgConf as! MsgHandler
        } else if msgConf is MsgFilter {
            msgN.filter = msgConf as! MsgFilter
        } else if msgConf is MsgNotify {
            msgN.notify = msgConf as! MsgNotify
        }
        return try? msgN.serializedData()
    }
    func get24WeatherGroupData(_ weatherGroup: Any) -> Data? {
        var wN = WeatherNotification()
        if let wp = weatherGroup as? WeatherGroup {
            wN.operation = .add
            wN.group = wp
        }
        return try? wN.serializedData()
    }
    func get24WeatherClear() -> Data?{
        var wN = WeatherNotification()
        wN.operation = .clear
        return try? wN.serializedData()
    }
    func getAlarmClcoksAddData(_ alarmClock:Any) -> Data? {
        var aN = AlarmNotification()
        if let ac = alarmClock as? AlarmGroup {
            aN.operation = .add
            aN.group = ac
        }
        return try? aN.serializedData()
    }
    func getAlarmClcoksRemoveData(_ alarmClock:Any) -> Data? {
        var aN = AlarmNotification()
        if let ac = alarmClock as? AlarmIDList {
            aN.operation = .remove
            aN.idList = ac
        }
        return try? aN.serializedData()
    }
    func getAlarmClcoksClearData() -> Data? {
        var aN = AlarmNotification()
        aN.operation = .clear
        return try? aN.serializedData()
    }
    func getSedentarinessSetData(_ sedtGroup:Any) -> Data? {
        var sN = SedtNotification()
        
        if let sedt = sedtGroup as? SedtGroup {
            sN.operation = .set;
            sN.group = sedt;
        }
        return try? sN.serializedData()
    }
    func getSedentarinessClearData() -> Data? {
        var sN = SedtNotification()
        sN.operation = .clear
        return try? sN.serializedData()
    }
    func getDeviceConfSetData(_ dcSet:DeviceConfNotification) -> Data? {
        var dcN = dcSet
        dcN.hash = 123
        return try? dcN.serializedData()
        
    }
    func getCalendarAddData(_ cldar:CalendarGroup) -> Data? {
        var cN = CalendarNotification()
        cN.operation = .add
        cN.group = cldar
        return try? cN.serializedData()
    }
    func getCalendarRemoveData(_ cldar:CalendarGroup) -> Data? {
        var cN = CalendarNotification()
        cN.operation = .remove
        cN.group = cldar
        return try? cN.serializedData()
    }
    func getCalendarClearData() -> Data? {
        var cN = CalendarNotification()
        cN.operation = .clear
        return try? cN.serializedData()
    }
    func getMotorConfData(_ motorConf:Any) -> Data? {
        var mcN = MotorConfNotification()
        if motorConf is MotorConf {
            mcN.conf = motorConf as! MotorConf
            mcN.operation = .config
        } else if motorConf is MotorVibrate {
            mcN.vibrate = motorConf as! MotorVibrate
            mcN.operation = .vibrate
        }
        return try? mcN.serializedData()
    }
    func getReadCS110Cmd() -> Data?{
        var command = C110Command()
        command.operation = .read
        return try? command.serializedData()
    }
    func getWriteCS110Cmd(_ cs110Data:C110Data) -> Data?{
        var command = C110Command()
        command.operation = .write
        command.data = cs110Data
        return try? command.serializedData()
    }
    func getAirQualityClearData() -> Data?{
        var airQ = AirQualityNotification()
        airQ.operation = .clear
        return try? airQ.serializedData()
    }
    func getAirQualityAddData(_ airQuality:AirQualityData) -> Data?{
        var airQ = AirQualityNotification()
        airQ.airdata = airQuality
        airQ.operation = .add
        return try? airQ.serializedData()
    }
    
}
extension ProbuffManager {
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
    
    public func writeCharacteristicByPBOpt(optCode:PB_Opt,payload:Data) {
        
        let dataStr = HeloUtils.hexStringFromData(payload)
        let dic = ["name":"down","id":optCode.rawValue,"data":dataStr] as [String : Any]
        if let json = HeloUtils.objectToJSON(dic) {
            LogBleManager.write(json,.logTypeBleRaw)
        }
        let writeData = appendWriteData(optCode: optCode, payload: payload)
        if (writeData.count < 8) {
            return;
        }
        let queueId = String(format: "com.write.%d.serialQueue", optCode.rawValue)
        let serialQueue = DispatchQueue(label: queueId)
        var i = 0
        while i < writeData.count {
            var range = NSMakeRange(i, mtu)
            if i + mtu > writeData.count {
                range = NSMakeRange(i, writeData.count - i)
            }
            let tData = writeData.subdata(in: Range(range)!)
            serialQueue.asyncAfter(deadline: .now() + .milliseconds(20)) {
                BleManager.sharedInstance.writeCommand(data: tData)
            }
            i += mtu
            
        }
    }

}

