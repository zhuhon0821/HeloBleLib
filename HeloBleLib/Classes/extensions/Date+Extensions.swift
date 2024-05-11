//
//  Date+Extensions.swift
//  HeloBleLib_Example
//
//  Created by AppleDev_9527 on 2024/5/11.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import Foundation

extension Date {
   func getYearMonthDay() -> String {
        let calendar = NSCalendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: self)
        let year = components.year
        let month = components.month
        let day = components.day
        let dateStr = String(format: "%d%02d%02d",year ?? 0 ,month ?? 0,day ?? 0)
//       "\(year ?? 0)\(month ?? 0)\(day ?? 0)"
        return dateStr
    }
}
