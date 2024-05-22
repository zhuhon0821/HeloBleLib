//
//  String+Extensions.swift
//  HeloBleLib_Example
//
//  Created by AppleDev_9527 on 2024/5/22.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import Foundation

extension String {
   public func stringToByte() -> Data? {
        // 移除空格并转换为大写
        let hexString = self.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
          
        // 检查字符串长度是否为偶数
        guard hexString.count % 2 == 0 else {
            return nil
        }
          
        var data = Data()
          
        // 遍历字符串，每两个字符转换为一个字节
        for index in stride(from: 0, to: hexString.count, by: 2) {
            let startIndex = hexString.index(hexString.startIndex,offsetBy: index)
            let endIndex = hexString.index(hexString.startIndex,offsetBy: index + 1)
            let hexPair = String(hexString[startIndex...endIndex])
              
            // 转换两位十六进制数为字节
            if let byteValue = UInt8(hexPair, radix: 16) {
                let byte = [UInt8](repeating: byteValue, count: 1)
                data.append(byte, count: 1)
            } else {
                // 如果转换失败，返回 nil
                return nil
            }
        }
          
        return data
    }
   
}
