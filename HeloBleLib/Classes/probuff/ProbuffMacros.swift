//
//  GlobalMacros.swift
//  HeloBleLib_Example
//
//  Created by AppleDev_9527 on 2024/4/15.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import Foundation

public let PROBUFF_SERVICE_UUID = "0001"
public let PROBUFF_SERVICE_LONG_UUID = "2E8C0001-2D91-5533-3117-59380A40AF8F"
public let PROBUFF_CHARACT_READ_UUID = "2E8C0002-2D91-5533-3117-59380A40AF8F"
public let PROBUFF_CHARACT_SET_UUID = "2E8C0003-2D91-5533-3117-59380A40AF8F"
public let PROBUFF_SERVICE_DFU_UUID = "FE59"
public let PROBUFF_CHARACT_DFU_UUID = "8EC90003-F315-4F60-9FB8-838830DAEA50"
public let HEARTRATE_CHARACT_ID = "2A37"
public let PEDOMETER_NEW_CHARACT_SET_UUID = "FF21"


enum PB_Opt:Int {
    case PB_Opt_DeviceInfo = 0x0000
    case PB_Opt_PeerInfo = 0x0001
    case PB_Opt_MsgNotify = 0x0002
    case PB_Opt_Weather = 0x0003
    case PB_Opt_AlarmClock = 0x0004
    case PB_Opt_Sedentariness = 0x0005
    case PB_Opt_DeviceConfig = 0x0006
    case PB_Opt_Calendar = 0x0007
    case PB_Opt_MotorConfig = 0x0008
    case PB_Opt_DataInfo = 0x0009
    case PB_Opt_om0_Cmd = 0x000A
    case PB_Opt_shbus_Cmd = 0x000B
    case PB_Opt_CS110Cmd = 0x000C
    case PB_Opt_AirQuality = 0x000D
    case PB_Opt_RealTimeData = 0x0070
    case PB_Opt_HistoryData = 0x0080
    case PB_Opt_FileUpdate = 0x0090
    case PB_Opt_DebugConfig =  0xFFFE
    case PB_Opt_ConnectionParams =  0xFFFF
    case PB_Opt_OutOfConfigRanger = 0x10000 //超出预设范围，用于处理异常
}
