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
    public var maxCalendarCount:UInt32 = 6
    var _max_sedt_count:Int = 3
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
    public func write01PeerInfomation(_ configuration:Any) {
        if let peerData = getPeerInformation(configuration) {
            writeCharacteristicByPBOpt(optCode: .PB_Opt_PeerInfo, payload: peerData)
        }
    }
    public func write02MsgNotification(_ msgConf:Any) {
        if let msgData = getMessageNotifyInformation(msgConf) {
            writeCharacteristicByPBOpt(optCode: .PB_Opt_MsgNotify, payload: msgData)
        }
    }
    //MARK: -- 01 PeerInfomation
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
        write01PeerInfomation(dateTime)
    }
    public func setUserConf(userConf:CUserConf) {
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
        write01PeerInfomation(conf)

    }
   
    public func setBloodPresureConf(cbpCaliConf:CBpCaliConf) {
        var bpCaliConf = BpCaliConf()
        bpCaliConf.srcDbp = cbpCaliConf.srcDbp
        bpCaliConf.srcSbp = cbpCaliConf.srcSbp
        bpCaliConf.difDbp = cbpCaliConf.difDbp
        bpCaliConf.difSbp = cbpCaliConf.difSbp
        bpCaliConf.dstSbp = cbpCaliConf.dstSbp
        bpCaliConf.dstDbp = cbpCaliConf.dstDbp
        bpCaliConf.userName = cbpCaliConf.userName
        bpCaliConf.takeMedicine = cbpCaliConf.takeMedicine
        bpCaliConf.hash = UInt32(bpCaliConf.hashValue)
        write01PeerInfomation(bpCaliConf)

    }
    
    public func setHrAlarmConf(chrAlarmConf:CHrAlarmConf) {
        
        var hrAlarmConf = HrAlarmConf()
        hrAlarmConf.enable = chrAlarmConf.enable
        hrAlarmConf.thsHigh = chrAlarmConf.thsHigh
        hrAlarmConf.thsLow = chrAlarmConf.thsLow
        hrAlarmConf.timeout = chrAlarmConf.timeout
        hrAlarmConf.interval = chrAlarmConf.interval
        hrAlarmConf.hash = UInt32(hrAlarmConf.hashValue)
        write01PeerInfomation(hrAlarmConf)
        
    }
    
    public func setGoalConf(cgoalConf:CGoalConf) {
        var goalConf = GoalConf()
        goalConf.distance = cgoalConf.distance
        goalConf.step = cgoalConf.step
        goalConf.calorie = cgoalConf.calorie
        goalConf.hash = UInt32(goalConf.hashValue)
        write01PeerInfomation(goalConf)
    }
    public func setGnssConf(cgnssConf:CGnssConf) {
        var gnssConf =  GnssConf()
        gnssConf.altitude = cgnssConf.altitude
        gnssConf.latitude = cgnssConf.latitude
        gnssConf.longitude = cgnssConf.longitude
        gnssConf.hash = UInt32(gnssConf.hashValue)
        write01PeerInfomation(gnssConf)
    }
    public func setAf24Conf(cafConf:CAfConf) {
        var afConf = AfConf()
        afConf.autoRun = cafConf.autoRun
        afConf.interval = cafConf.interval
        afConf.hash = UInt32(afConf.hashValue)
        write01PeerInfomation(afConf)
        
    }
    
    //MARK: -- 02 MsgNotification
    public func setDNDMode(_ dndModel:CMsgHandler) {
        var mH = MsgHandler()
        mH.policy = dndModel.policy
        var msgT = MsgHandler.Timing()
        msgT.startHour = dndModel.startHour
        msgT.startMinute = dndModel.startMinute
        msgT.endHour = dndModel.endHour
        msgT.endMinute = dndModel.endMinute
        mH.timing = msgT
        mH.hash = UInt32(mH.hashValue)
        write02MsgNotification(mH)
    }
    public func addSpecialList(_ rolls:[CRoll]) {
        var mArr = [MsgFilter.ID]()
        for roll in rolls {
            var mfID = MsgFilter.ID()
            mfID.id = roll.rollName
            mArr.append(mfID)
        }
        var mf = MsgFilter()
        mf.id = mArr
        mf.hash = UInt32(mf.hashValue)
        write02MsgNotification(mf)
    }
    public func clearAllLists() {
        var mf = MsgFilter()
        mf.id = []
        mf.hash = UInt32(mf.hashValue)
        write02MsgNotification(mf)
    }
    
    //MARK: -- 03 weather
    public func clearWeather() {
       var weatherNotification = WeatherNotification()
        weatherNotification.operation = .clear
        if let msgData = try? weatherNotification.serializedData() {
            writeCharacteristicByPBOpt(optCode: .PB_Opt_Weather, payload: msgData)
        }
    }
    public func setWeather(_ cweatherGroup : CWeatherGroup) {
       var weatherNotification = WeatherNotification()
        weatherNotification.operation = .add
        weatherNotification.group.hash = 2
        var weatherArr = [Weather]()
        var i = 0
        for cweather in cweatherGroup.weather24hoursArrs {
            if i == 12 && cweatherGroup.weather7daysArrs.count > 0 {
                break
            }
            var weather = Weather()
            var rtT = RtTime()
            rtT.seconds = UInt32(cweather.dateTime.timeIntervalSince1970)
            weather.dateTime = rtT
            weather.degreeMax = cweather.degreeMax
            weather.degreeMin = cweather.degreeMin
            weather.type =  .eachHour
            if let pm2P5 = cweather.pm2P5 {
                weather.pm2P5 = pm2P5
            }
            weatherArr.append(weather)
            i += 1
        }
        var j = 0
        for cweather in cweatherGroup.weather7daysArrs {
            if j == 5  {
                break
            }
            var weather = Weather()
            var rtT = RtTime()
            rtT.seconds = UInt32(cweather.dateTime.timeIntervalSince1970)
            weather.dateTime = rtT
            weather.degreeMax = cweather.degreeMax
            weather.degreeMin = cweather.degreeMin
            weather.type = .eachDay
            if let pm2P5 = cweather.pm2P5 {
                weather.pm2P5 = pm2P5
            }
            weatherArr.append(weather)
            
            j += 1
        }
        weatherNotification.group.data = weatherArr
        if let msgData = try? weatherNotification.serializedData() {
            writeCharacteristicByPBOpt(optCode: .PB_Opt_Weather, payload: msgData)
        }
    }
    public func clearAirQuality() {
        var airQualityNotification = AirQualityNotification()
        airQualityNotification.operation = .clear
        if let data = try? airQualityNotification.serializedData() {
            writeCharacteristicByPBOpt(optCode: .PB_Opt_AirQuality, payload: data)
        }
    }
    public func writeAirQuality(cairQualityData:CAirQualityData) {
        var airQualityData = AirQualityData()
        var airQualityNotification = AirQualityNotification()
        if let pm2P5 = cairQualityData.pm2P5 {
            airQualityData.pm2P5 = pm2P5
        }
        if let pm10 = cairQualityData.pm10 {
            airQualityData.pm10 = pm10
        }
        if let aqi = cairQualityData.aqi {
            airQualityData.aqi = aqi
        }
        if let o3 = cairQualityData.o3 {
            airQualityData.o3 = o3
        }
        if let no2 = cairQualityData.no2 {
            airQualityData.no2 = no2
        }
        if let so2 = cairQualityData.so2 {
            airQualityData.so2 = so2
        }
        if let co = cairQualityData.co {
            airQualityData.co = co
        }
        airQualityData.country = cairQualityData.country
        airQualityNotification.airdata = airQualityData
        airQualityNotification.operation = .add
        
        if let data = try? airQualityNotification.serializedData() {
            writeCharacteristicByPBOpt(optCode: .PB_Opt_AirQuality, payload: data)
        }
    }
    //MARK: 04 alarm clock
    static let _max_clock_count = 6
    public func setAlarmClocks(_ calarmClocks:[CAlarmClock]) {
        var alarmClocks = [AlarmClock]()
        var i = 0
        for calarmClock in calarmClocks {
            if i ==  ProbuffManager._max_clock_count {
                break
            }
            var alarmClock = AlarmClock()
            alarmClock.repeat = calarmClock.isRepeat
            alarmClock.monday = calarmClock.monday
            alarmClock.tuesday = calarmClock.tuesday
            alarmClock.wednesday = calarmClock.wednesday
            alarmClock.thursday = calarmClock.thursday
            alarmClock.friday = calarmClock.friday
            alarmClock.saturday = calarmClock.saturday
            alarmClock.sunday = calarmClock.sunday
            alarmClock.hour = calarmClock.hour
            alarmClock.minutes = calarmClock.minutes
            alarmClock.text = calarmClock.text
            alarmClocks.append(alarmClock)
            i += 1
        }
        var alarmGroup = AlarmGroup()
        alarmGroup.alarmclock = alarmClocks
        alarmGroup.hash = UInt32(alarmClocks.hashValue)
        var alarmNotification = AlarmNotification()
        alarmNotification.group = alarmGroup
        alarmNotification.operation = .add
        if let data = try? alarmNotification.serializedData() {
            writeCharacteristicByPBOpt(optCode: .PB_Opt_AlarmClock, payload: data)
        }
    }
    public func clearAlarmClocks(){
        var alarmNotification = AlarmNotification()
        alarmNotification.operation = .clear
        if let data = try? alarmNotification.serializedData() {
            writeCharacteristicByPBOpt(optCode: .PB_Opt_AlarmClock, payload: data)
        }
    }
    //MARK: -- 05 Calendar
    public func clearCalendar(){
        var calendarNotification = CalendarNotification()
        calendarNotification.operation = .clear
        if let data = try? calendarNotification.serializedData() {
            writeCharacteristicByPBOpt(optCode: .PB_Opt_Calendar, payload: data)
        }
    }
    public func setCalendar(_ ccalendars:[CCalendar]){
        
        var calendars = [Calendar]()
        var i = 0
        for ccalendar in ccalendars {
            if i == maxCalendarCount {
                break
            }
            var calendar = Calendar()
            calendar.text = ccalendar.text
            var time = RtTime()
            time.seconds = UInt32(ccalendar.date.timeIntervalSince1970 + Double(HeloUtils.tsFromGMT()))
            calendars.append(calendar)
            i += 1
        }
        var group = CalendarGroup()
        group.calendar = calendars
        var calendarNotification = CalendarNotification()
        calendarNotification.operation = .add
        calendarNotification.group = group
        if let data = try? calendarNotification.serializedData() {
            writeCharacteristicByPBOpt(optCode: .PB_Opt_Calendar, payload: data)
        }
    }
    
    //MARK: -- 05 久坐提醒 Sedentary
    public func clearSedentariness() {
        var sedtNotification = SedtNotification()
        sedtNotification.operation = .clear
        if let data = try? sedtNotification.serializedData() {
            writeCharacteristicByPBOpt(optCode: .PB_Opt_Sedentariness, payload: data)
        }
    }
    public func setSedentariness(_ csedentarinesses:[CSedentariness]) {
        
        var i = 0
        var sedentarinesses = [Sedentariness]()
        for csedentariness in csedentarinesses {
            if i ==  _max_sedt_count{
                break
            }
            var sedentariness = Sedentariness()
            sedentariness.repeat = csedentariness.isRepeat
            sedentariness.monday = csedentariness.monday
            sedentariness.tuesday = csedentariness.tuesday
            sedentariness.wednesday = csedentariness.wednesday
            sedentariness.thursday = csedentariness.thursday
            sedentariness.friday = csedentariness.friday
            sedentariness.saturday = csedentariness.saturday
            sedentariness.sunday = csedentariness.sunday
            sedentariness.startHour = csedentariness.startHour
            sedentariness.endHour = csedentariness.endHour
            sedentariness.duration = csedentariness.duration
            if csedentariness.threshold > 0 {
                sedentariness.threshold = csedentariness.threshold
            }
            sedentarinesses.append(sedentariness)
            i += 1
            
        }
        var sedtNotification = SedtNotification()
        sedtNotification.operation = .set
        var group = SedtGroup()
        group.sedentariness = sedentarinesses
        sedtNotification.group = group
        if let data = try? sedtNotification.serializedData() {
            writeCharacteristicByPBOpt(optCode: .PB_Opt_Sedentariness, payload: data)
        }
    }
    //MARK: device setting 设备设置
    public func setDeviceOption(_ cNotification:CDeviceConfNotification) {
       var deviceConfNotification = DeviceConfNotification()
        if let temperatureUnit = cNotification.temperatureUnit {
            deviceConfNotification.temperatureUnit = temperatureUnit
        }
        if let languageID = cNotification.languageID {
            deviceConfNotification.languageID = languageID
        }
        if let lcdGsSwitch = cNotification.lcdGsSwitch {
            deviceConfNotification.lcdGsSwitch = lcdGsSwitch
        }
        if let lcdGsTime = cNotification.lcdGsTime {
            var deviceLcdGs = DeviceLcdGs()
            deviceLcdGs.lcdGsStartHour = lcdGsTime.lcdGsStartHour
            deviceLcdGs.lcdGsEndHour = lcdGsTime.lcdGsEndHour
            deviceConfNotification.lcdGsTime = deviceLcdGs
        }
        if let dateFormat = cNotification.dateFormat {
            deviceConfNotification.dateFormat = dateFormat
        }
        if let hourFormat = cNotification.hourFormat {
            deviceConfNotification.hourFormat = hourFormat
        }
        if let autoHeartrate = cNotification.autoHeartrate {
            deviceConfNotification.autoHeartrate = autoHeartrate
        }
        if let autoSport = cNotification.autoSport {
            deviceConfNotification.autoSport = autoSport
        }
        if let habitualHand = cNotification.habitualHand {
            deviceConfNotification.habitualHand = habitualHand
        }
        if let nickName = cNotification.nickName {
            deviceConfNotification.nickName = nickName
        }
        if let autoAllsensor = cNotification.autoAllsensor {
            deviceConfNotification.autoAllsensor = autoAllsensor
        }
        if let cheathConfig = cNotification.heathConfig {
            //健康配置
            var heathConfig = HealthDataConfig()
            if let ecgConfig = cheathConfig.ecgConfig {
                heathConfig.ecgConfig = ecgConfig
            }
            if let fatigueConfig = cheathConfig.fatigueConfig {
                heathConfig.fatigueConfig = fatigueConfig
            }
            if let bpConfig = cheathConfig.bpConfig {
                heathConfig.bpConfig = bpConfig
            }
            if let afConfig = cheathConfig.afConfig {
                heathConfig.afConfig = afConfig
            }
            if let biozConfig = cheathConfig.biozConfig {
                heathConfig.biozConfig = biozConfig
            }
            if let moodConfig = cheathConfig.moodConfig {
                heathConfig.moodConfig = moodConfig
            }
            if let breathrateConfig = cheathConfig.breathrateConfig {
                heathConfig.breathrateConfig = breathrateConfig
            }
            if let mdtConfig = cheathConfig.mdtConfig {
                heathConfig.mdtConfig = mdtConfig
            }
            if let spo2Config = cheathConfig.spo2Config {
                heathConfig.spo2Config = spo2Config
            }
            if let temperatureConfig = cheathConfig.temperatureConfig {
                heathConfig.temperatureConfig = temperatureConfig
            }
            deviceConfNotification.heathConfig = heathConfig
        }
        if let healthSleep = cNotification.healthSleep {
            deviceConfNotification.healthSleep = healthSleep
        }
        if let backlightTime = cNotification.backlightTime {
            deviceConfNotification.backlightTime = backlightTime
        }
        if let gestureSensitivity = cNotification.gestureSensitivity {
            deviceConfNotification.gestureSensitivity = gestureSensitivity
        }
        if let stepsSensitivity = cNotification.stepsSensitivity {
            deviceConfNotification.stepsSensitivity = stepsSensitivity
        }
        if let powerOff = cNotification.powerOff {
            deviceConfNotification.powerOff = powerOff
        }
        if let factoryReset = cNotification.factoryReset {
            deviceConfNotification.factoryReset = factoryReset
        }
        if let bleUnbind = cNotification.bleUnbind {
            deviceConfNotification.bleUnbind = bleUnbind
        }
        if let autoMeasureTimes = cNotification.autoMeasureTime {
            var rtTimes = [RtTime]()
            for aDate in autoMeasureTimes {
                var rtTime = RtTime()
                rtTime.seconds = UInt32(aDate.timeIntervalSince1970 + Double(HeloUtils.tsFromGMT()))
                rtTimes.append(rtTime)
            }
            deviceConfNotification.autoMeasureTime = rtTimes
        }
        if let audioSwitch = cNotification.audioSwitch {
            deviceConfNotification.audioSwitch = audioSwitch
        }
        if let fallThreshold = cNotification.fallThreshold {
            deviceConfNotification.fallThreshold = fallThreshold
        }
        if let allMeasure = cNotification.allMeasure {
            deviceConfNotification.allMeasure = allMeasure
        }
        deviceConfNotification.hash = UInt32(deviceConfNotification.hashValue)
        if let data = try? deviceConfNotification.serializedData() {
            writeCharacteristicByPBOpt(optCode: .PB_Opt_DeviceConfig, payload: data)
        }
    }
    //MARK: c110_command
    
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

