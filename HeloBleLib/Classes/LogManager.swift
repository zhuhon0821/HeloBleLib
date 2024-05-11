//
//  LogManager.swift
//  HeloBleLib_Example
//
//  Created by AppleDev_9527 on 2024/5/11.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import Foundation
import SwiftyBeaver

public enum LogFileType {
    
    case logTypeNormal
    case logTypeBleRaw
}


open class LogBleManager {
    
    static var bleRawDataFileDestination:FileDestination?
    static var normalDataFileDestination:FileDestination?
    
    open class func write(_ info:String,_ type:LogFileType) {
        let date = Date()
        let needUpdateFileDate = HeloUtils.needUpdateFileDate(date)
        if needUpdateFileDate == true {
            bleRawDataFileDestination = nil
            normalDataFileDestination = nil
        }
        
        switch type {
        case .logTypeBleRaw:
            if bleRawDataFileDestination == nil {
             let loger = SwiftyBeaver.self
               var bleFilePath = HeloUtils.createDocumentPath(fileName: "sdk")
                let dateStr = date.getYearMonthDay()
                bleFilePath = bleFilePath?.appendingPathComponent("sdk_ble_\(dateStr).txt")
                bleRawDataFileDestination = FileDestination(logFileURL: bleFilePath)
                bleRawDataFileDestination!.format = "$DHH:mm:ss $M"
                loger.addDestination(bleRawDataFileDestination!)
            }
            DispatchQueue.global().async {
                let _ = bleRawDataFileDestination!.send(.info, msg: info, thread: "", file: "", function: "", line: 1)
            }
            break
        case .logTypeNormal:
            if normalDataFileDestination == nil {
                let loger = SwiftyBeaver.self
                var normalFilePath = HeloUtils.createDocumentPath(fileName: "sdk")
                let dateStr = date.getYearMonthDay()
                 normalFilePath = normalFilePath?.appendingPathComponent("sdk_normal_\(dateStr).txt")
                normalDataFileDestination = FileDestination(logFileURL: normalFilePath)
                normalDataFileDestination!.format = "$DHH:mm:ss $M"
                loger.addDestination(normalDataFileDestination!)
               
            }
            DispatchQueue.global().async {
                let _ = normalDataFileDestination!.send(.info, msg: info, thread: "", file: "", function: "", line: 1)
            }

            break
        }
        
    }

}
