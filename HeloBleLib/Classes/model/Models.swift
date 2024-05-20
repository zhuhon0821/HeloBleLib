//
//  ModelManager.swift
//  HeloBleLib_Example
//
//  Created by AppleDev_9527 on 2024/4/19.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import Foundation
/**
 @languageId 枚举类型 表示设置语言类型
 @lcdGsSwitch bool类型 表示设置翻腕亮屏开关
 @lcdGsTime 结构体类型 表示设置翻腕亮屏时间段（包括：开始时间和结束时间）
 @distanceUnit bool类型 表示设置距离单位为公制或者英制
 @temperatureUnit bool类型 表示设置温度单位为摄氏度或者华氏度
 @hourFormat bool类型 表示设置时间格式为12小时制或者24小时制
 @dateFormat bool类型 表示设置日期格式为：mm/dd或者dd/mm
 @autoHeartrate bool类型 表示设置自动心率开关
 @autoSport bool类型 表示设置自动运动开关
 @habitualHand bool类型 表示设置佩戴左右手
 @nickName string类型 表示设置佩戴者名字
 @autoAllsensor bool类型 表示设置所以健康测试开关
 @heathConfig 结构体类型 表示设置动态健康（包括：心电、疲劳度、血压、房颤、体脂率、心情、呼吸率、冥想、血氧）配置开关
 @healthSleep bool类型 表示设置科学睡眠开关
 @backlightTime int类型 表示设置背光亮屏时间：默认5秒
 @gestureSensitivity int类型 表示设置翻腕灵敏度
 */
struct CDeviceConfNotification {

    /// English[default]
    var languageID: DeviceLanuage?
    /// 0：disable lcd switching by gesture, 1[default]：enable lcd switching by gesture
    var lcdGsSwitch: Bool?
    var lcdGsTime: CDeviceLcdGs?
    /// 0[default]: metric unit, 1: imperial units
    var distanceUnit: Bool?
    /// 0[default]: Celsius, 1: Fahrenheit
    var temperatureUnit: Bool?
    /// 0[default]: 24hour, 1: 12hour
    var hourFormat: Bool?
    /// 0[default]: month/day, 1: day/month
    var dateFormat: Bool?
    /// 0[default]: disable auto-heartrate detection, 1: enable
    var autoHeartrate: Bool?
    /// 0[default]: disable auto-sport detection, 1: enable
    var autoSport: Bool?
    /// 0[default]: left hand
    var habitualHand: Bool?
    var nickName: String?
    var autoAllsensor: Bool?
    var heathConfig: CHealthDataConfig?
    var healthSleep: Bool?
    ///[default = 5]
    var backlightTime: UInt32?
    var gestureSensitivity: UInt32?
    var stepsSensitivity: UInt32?
    var powerOff: Bool?
    var factoryReset: Bool?
    var bleUnbind: Bool?
    var autoMeasureTime: [Date]?
    var audioSwitch: Bool?
    var fallThreshold: UInt32?
    var allMeasure: Bool?
    init(languageID: DeviceLanuage? = nil, lcdGsSwitch: Bool? = nil, lcdGsTime: CDeviceLcdGs? = nil, distanceUnit: Bool? = nil, temperatureUnit: Bool? = nil, hourFormat: Bool? = nil, dateFormat: Bool? = nil, autoHeartrate: Bool? = nil, autoSport: Bool? = nil, habitualHand: Bool? = nil, nickName: String? = nil, autoAllsensor: Bool? = nil, heathConfig: CHealthDataConfig? = nil, healthSleep: Bool? = nil, backlightTime: UInt32? = nil, gestureSensitivity: UInt32? = nil, stepsSensitivity: UInt32? = nil, powerOff: Bool? = nil, factoryReset: Bool? = nil, bleUnbind: Bool? = nil, autoMeasureTime: [Date]? = nil, audioSwitch: Bool? = nil, fallThreshold: UInt32? = nil, allMeasure: Bool? = nil) {
        self.languageID = languageID
        self.lcdGsSwitch = lcdGsSwitch
        self.lcdGsTime = lcdGsTime
        self.distanceUnit = distanceUnit
        self.temperatureUnit = temperatureUnit
        self.hourFormat = hourFormat
        self.dateFormat = dateFormat
        self.autoHeartrate = autoHeartrate
        self.autoSport = autoSport
        self.habitualHand = habitualHand
        self.nickName = nickName
        self.autoAllsensor = autoAllsensor
        self.heathConfig = heathConfig
        self.healthSleep = healthSleep
        self.backlightTime = backlightTime
        self.gestureSensitivity = gestureSensitivity
        self.stepsSensitivity = stepsSensitivity
        self.powerOff = powerOff
        self.factoryReset = factoryReset
        self.bleUnbind = bleUnbind
        self.autoMeasureTime = autoMeasureTime
        self.audioSwitch = audioSwitch
        self.fallThreshold = fallThreshold
        self.allMeasure = allMeasure
    }

}
struct CDeviceLcdGs {
 
    /// 0[default]~23:  the start hour of switching lcd by gesture
    var lcdGsStartHour: UInt32
    /// 0[default]~23:  the end hour of switching lcd by gesture
    var lcdGsEndHour: UInt32
    init(lcdGsStartHour: UInt32, lcdGsEndHour: UInt32) {
        self.lcdGsStartHour = lcdGsStartHour
        self.lcdGsEndHour = lcdGsEndHour
    }
}
struct CHealthDataConfig {

    var ecgConfig: Bool?
    var fatigueConfig: Bool?
    var bpConfig: Bool?
    var afConfig: Bool?
    var biozConfig: Bool?
    var moodConfig: Bool?
    var breathrateConfig: Bool?
    var mdtConfig: Bool?
    var spo2Config: Bool?
    var temperatureConfig: Bool?
    init(ecgConfig: Bool? = nil, fatigueConfig: Bool? = nil, bpConfig: Bool? = nil, afConfig: Bool? = nil, biozConfig: Bool? = nil, moodConfig: Bool? = nil, breathrateConfig: Bool? = nil, mdtConfig: Bool? = nil, spo2Config: Bool? = nil, temperatureConfig: Bool? = nil) {
        self.ecgConfig = ecgConfig
        self.fatigueConfig = fatigueConfig
        self.bpConfig = bpConfig
        self.afConfig = afConfig
        self.biozConfig = biozConfig
        self.moodConfig = moodConfig
        self.breathrateConfig = breathrateConfig
        self.mdtConfig = mdtConfig
        self.spo2Config = spo2Config
        self.temperatureConfig = temperatureConfig
    }
  
}
struct CSedentariness {
    
    /// TRUE: repeat every week
    var isRepeat: Bool
    /// TRUE: active on this day
    var monday: Bool
    var tuesday: Bool
    var wednesday: Bool
    var thursday: Bool
    var friday: Bool
    var saturday: Bool
    var sunday: Bool
    /// 0~23
    var startHour: UInt32
    var endHour: UInt32
    /// 0~1440
    var duration: UInt32
    var threshold: UInt32 = 50
    init(isRepeat: Bool, monday: Bool, tuesday: Bool, wednesday: Bool, thursday: Bool, friday: Bool, saturday: Bool, sunday: Bool, startHour: UInt32, endHour: UInt32, duration: UInt32, threshold: UInt32) {
        self.isRepeat = isRepeat
        self.monday = monday
        self.tuesday = tuesday
        self.wednesday = wednesday
        self.thursday = thursday
        self.friday = friday
        self.saturday = saturday
        self.sunday = sunday
        self.startHour = startHour
        self.endHour = endHour
        self.duration = duration
        self.threshold = threshold
    }
}
struct CCalendar {
    
    var date: Date
    var text: String
    init(date: Date, text: String) {
        self.date = date
        self.text = text
    }
    
}
struct CAlarmClock {
    
    /// Unique id of each alarmclock
    var id: UInt32
    var isRepeat: Bool
    var monday: Bool
    var tuesday: Bool
    var wednesday: Bool
    var thursday: Bool
    var friday: Bool
    var saturday: Bool
    var sunday: Bool
    var hour: UInt32
    var minutes: UInt32
    var text: String
    init(id: UInt32, isRepeat: Bool, monday: Bool, tuesday: Bool, wednesday: Bool, thursday: Bool, friday: Bool, saturday: Bool, sunday: Bool, hour: UInt32, minutes: UInt32, text: String) {
        self.id = id
        self.isRepeat = isRepeat
        self.monday = monday
        self.tuesday = tuesday
        self.wednesday = wednesday
        self.thursday = thursday
        self.friday = friday
        self.saturday = saturday
        self.sunday = sunday
        self.hour = hour
        self.minutes = minutes
        self.text = text
    }

}
struct CAirQualityData {

  var pm2P5: UInt32?
  var pm10: UInt32?
  var aqi: UInt32?
  var o3: UInt32?
  var no2: UInt32?
  var so2: UInt32?
  var co: UInt32?
  var country: UInt32// 0 = china, 1 = us
    init(pm2P5: UInt32? = nil, pm10: UInt32? = nil, aqi: UInt32? = nil, o3: UInt32? = nil, no2: UInt32? = nil, so2: UInt32? = nil, co: UInt32? = nil, country: UInt32) {
        self.pm2P5 = pm2P5
        self.pm10 = pm10
        self.aqi = aqi
        self.o3 = o3
        self.no2 = no2
        self.so2 = so2
        self.co = co
        self.country = country
    }
  
}
struct CWeatherGroup {
    // Groups numbers 24, means 24 hours weather data ,You must sort the data by date
    var weather24hoursArrs:[CHourWeather] //eachHour
    var weather7daysArrs:[CDayWeather] //eachDay
    init(weather24hoursArrs: [CHourWeather], weather7daysArrs: [CDayWeather]) {
        self.weather24hoursArrs = weather24hoursArrs
        self.weather7daysArrs = weather7daysArrs
    }
}
struct CDayWeather {
    var dateTime: Date
    var desc: WeatherDesc
    var degreeMax: Int32
    var degreeMin: Int32
    var pm2P5: UInt32?
    init(dateTime: Date, desc: WeatherDesc, degreeMax: Int32, degreeMin: Int32, pm2P5: UInt32? = nil) {
        self.dateTime = dateTime
        self.desc = desc
        self.degreeMax = degreeMax
        self.degreeMin = degreeMin
        self.pm2P5 = pm2P5
    }
}
struct CHourWeather {
  
    var dateTime: Date
    var desc: WeatherDesc
    var degreeMax: Int32
    var degreeMin: Int32
    var pm2P5: UInt32?
    init(dateTime: Date, desc: WeatherDesc, degreeMax: Int32, degreeMin: Int32, pm2P5: UInt32? = nil) {
        self.dateTime = dateTime
        self.desc = desc
        self.degreeMax = degreeMax
        self.degreeMin = degreeMin
        self.pm2P5 = pm2P5
    }
    
}
struct CRoll {
    var rollName: String
//    var rId:UInt32
    init(rollName: String) {
        self.rollName = rollName
    }
}
/// From peer to device
struct CMsgHandler {
  
    var policy: MsgHandler.Policy
    var startHour: UInt32
    var startMinute: UInt32
    var endHour: UInt32
    var endMinute: UInt32
    init(policy: MsgHandler.Policy, startHour: UInt32, startMinute: UInt32, endHour: UInt32, endMinute: UInt32) {
        self.policy = policy
        self.startHour = startHour
        self.startMinute = startMinute
        self.endHour = endHour
        self.endMinute = endMinute
    }
}
struct CAfConf:Codable {
    
    var autoRun: Bool
    /// minutes, 0: always run
    var interval: UInt32
    init(autoRun: Bool, interval: UInt32) {
        self.autoRun = autoRun
        self.interval = interval
    }
}
struct CGnssConf:Codable {
    
    var altitude: Float
    var latitude: Float
    var longitude: Float
    init(altitude: Float, latitude: Float, longitude: Float) {
        self.altitude = altitude
        self.latitude = latitude
        self.longitude = longitude
    }
}
struct CGoalConf:Codable {
  /// meters
  var distance: UInt32
  var step: UInt32
  var calorie: UInt32
    init(distance: UInt32, step: UInt32, calorie: UInt32) {
        self.distance = distance
        self.step = step
        self.calorie = calorie
    }
}
struct CHrAlarmConf:Codable {
  
  var enable: Bool
  /// 50~200, when hr value goes beyond [ths_low, ths_high], (re-)start counter
  var thsHigh: UInt32
  /// 40~190
  var thsLow: UInt32
  /// seconds, trigger alarm when couter reaches this value
  var timeout: UInt32
  /// minutes, re-alarm interval
  var interval: UInt32
    init(enable: Bool, thsHigh: UInt32, thsLow: UInt32, timeout: UInt32, interval: UInt32) {
        self.enable = enable
        self.thsHigh = thsHigh
        self.thsLow = thsLow
        self.timeout = timeout
        self.interval = interval
    }
}
struct CBpCaliConf:Codable {
    
  var srcSbp: UInt32
  var srcDbp: UInt32
  var dstSbp: UInt32
  var dstDbp: UInt32
  var difSbp: Int32
  var difDbp: Int32
  var userName: String
  var takeMedicine: Bool
    init(srcSbp: UInt32, srcDbp: UInt32, dstSbp: UInt32, dstDbp: UInt32, difSbp: Int32, difDbp: Int32, userName: String, takeMedicine: Bool) {
        self.srcSbp = srcSbp
        self.srcDbp = srcDbp
        self.dstSbp = dstSbp
        self.dstDbp = dstDbp
        self.difSbp = difSbp
        self.difDbp = difDbp
        self.userName = userName
        self.takeMedicine = takeMedicine
    }
  
}
struct CUserConf : Codable {
    
    var height: UInt32
    var weight: UInt32
    /// 0[default]: male, 1: female
    var gender: Bool
    var age: UInt32
    /// 50~200, calibrate value of walking
    var calibWalk: UInt32
    /// 50~200, calibrate value of running
    var calibRun: UInt32
    var grade: UInt32
    /// 80~230mm, Wrist circumference
    var wristCircumference: UInt32
    var historyOfHypertension: Bool
    var hash: UInt32
    
    init(height: UInt32, weight: UInt32, gender: Bool, age: UInt32, calibWalk: UInt32, calibRun: UInt32, grade: UInt32, wristCircumference: UInt32, historyOfHypertension: Bool, hash: UInt32) {
        self.height = height
        self.weight = weight
        self.gender = gender
        self.age = age
        self.calibWalk = calibWalk
        self.calibRun = calibRun
        self.grade = grade
        self.wristCircumference = wristCircumference
        self.historyOfHypertension = historyOfHypertension
        self.hash = hash
    }
}



/// 定义一个将 Encodable 对象转换为 JSON 字符串的通用方法
func encodeToJSON<T: Encodable>(object: T) throws -> String {
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    /// 可选：设置输出格式为美化后的 JSON
    let data = try encoder.encode(object)
    return String(data: data, encoding: .utf8)!
}
/// 封装方法，用于将 JSON 字符串解码为指定的结构体类型 T
func decodeJSON<T: Decodable>(jsonString: String) throws -> T {
    let decoder = JSONDecoder()
    /// 设置解码器的选项，比如处理空值或者其他设置
    /// decoder.keyDecodingStrategy = .convertFromSnakeCase
    /// 尝试解码 JSON 字符串为指定类型 T
    return try decoder.decode(T.self, from: jsonString.data(using: .utf8)!)
}
