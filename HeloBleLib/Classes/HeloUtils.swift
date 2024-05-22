//
//  HeloUtils.swift
//  HeloBleLib_Example
//
//  Created by AppleDev_9527 on 2024/5/11.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import Foundation

open class HeloUtils  {
    static let _his_date_Key:String = "_his_date_Key"
    
    static func inOneDay(date1:Date,date2:Date) -> Bool {
        return date1.getYearMonthDay() == date2.getYearMonthDay()
    }
    static func getFileHisDate() -> Date? {
        let hisDate = UserDefaults.standard.object(forKey: _his_date_Key) as? Date
        return hisDate
        
    }
    static func saveFileHisDate(_ date:Date) {
        UserDefaults.standard.set(date, forKey: _his_date_Key)
        UserDefaults.standard.synchronize()
    }
    static func needUpdateFileDate(_ date:Date) -> Bool {
        
        if let hisDate = HeloUtils.getFileHisDate() {
            if HeloUtils.inOneDay(date1: date, date2: hisDate) {
                return false
            }
        }
        HeloUtils.saveFileHisDate(date)
        return true
    }
    
    static func objectToJSON(_ object: Any) -> String? {
        if #available(iOS 13.0, *) {
            if let jsonData = try? JSONSerialization.data(withJSONObject: object, options: .withoutEscapingSlashes) {
                return String(data: jsonData, encoding: .utf8)
            }
        } else {
            if let jsonData = try? JSONSerialization.data(withJSONObject: object, options: .prettyPrinted) {
                return String(data: jsonData, encoding: .utf8)
            }
        }
         return nil
     }
    
    
   static func createDocumentPath(fileName: String) -> URL? {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let fileURL = documentsDirectory?.appendingPathComponent(fileName)
        
        if let fileURL = fileURL, FileManager.default.fileExists(atPath: fileURL.path) {
            if FileManager.default.fileExists(atPath: fileURL.path, isDirectory: nil) {
//                print("The path already exists and is a directory.")
            } else {
//                print("The path already exists and is a file.")
            }
        } else {
            do {
                try FileManager.default.createDirectory(at: fileURL!, withIntermediateDirectories: true, attributes: nil)
                print("Directory created at path: \(fileURL?.path ?? "Unknown")")
            } catch {
                print("Error creating directory at path: \(error.localizedDescription)")
            }
        }
        
        return fileURL
    }
    
    static func tsFromGMT() -> Int {
        let tz = NSTimeZone.system
        return tz.secondsFromGMT()
    }
    static func numberToTime(year:UInt32,month:UInt32,day:UInt32) -> TimeInterval? {
        var dateComponents = DateComponents()
        dateComponents.year = Int(year)
        dateComponents.month = Int(month)
        dateComponents.day = Int(day)
        let calendar = NSCalendar.current
        if let date = calendar.date(from: dateComponents) {
            let date1 = date.addingTimeInterval(TimeInterval(tsFromGMT()))
            return date1.timeIntervalSince1970
        }
        return nil
    }
}
