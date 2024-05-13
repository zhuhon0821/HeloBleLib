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
    static let sdk_log_path = "sdk/log"
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
               var bleFilePath = HeloUtils.createDocumentPath(fileName: sdk_log_path)
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
                var normalFilePath = HeloUtils.createDocumentPath(fileName: sdk_log_path)
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
    
    static func cleanUpSDKTextFilesOlderThan30days() throws {
        let directoryPath = HeloUtils.createDocumentPath(fileName: sdk_log_path)
         let fileManager = FileManager.default
        let directoryURLs = try fileManager.contentsOfDirectory(at: directoryPath!, includingPropertiesForKeys: nil, options: []) as [URL]
         
         let dateFormatter = DateFormatter()
         dateFormatter.dateFormat = "yyyyMMdd" // 设定日期格式与文件名尾缀匹配
         
         let calendar = NSCalendar.current
         let now = Date()
         let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: now)!
         
         for fileURL in directoryURLs {
             let filePath = fileURL.path
             let fileExtension = fileURL.pathExtension
             
             guard fileExtension == "txt" else {
                 continue // 跳过非.txt文件
             }
             
             let fileName = fileURL.deletingPathExtension()
             let dateString = String(fileName.absoluteString.suffix(8)) // 假设文件名尾缀总是日期格式且长度为8
             
             if let date = dateFormatter.date(from: dateString) {
                 if date < thirtyDaysAgo {
                     try fileManager.removeItem(at: fileURL)
                     print("Removed file: \(filePath)")
                 }
             }
         }
     }

}
