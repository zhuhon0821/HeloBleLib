//
//  ModelManager.swift
//  HeloBleLib_Example
//
//  Created by AppleDev_9527 on 2024/4/19.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import Foundation


struct UserConf_C : Codable {
    
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
