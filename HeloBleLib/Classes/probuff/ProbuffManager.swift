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
    override init() {
        super.init()
        
    }
    /**
     *param example:[height:170,weight:65,gender:1 represent female or 0 represent male,age:25,calibWalk:100,calibRun:100]
     */
//    public func setPersonalInfo(param:Dictionary<String, Any>) {
//        
//        
//        if let jsonData = try? JSONSerialization.data(withJSONObject: param, options: []) {
//            if let jsonString = String(data: jsonData, encoding: .utf8) {
//                if let userConf = try? UserConf(jsonString: jsonString) {
//                    if let data = try? userConf.serializedData() {
//                        BleManager.sharedInstance.writeCommend(data: data)
//                    }
//                }
//            }
//        }
//    }
    
    /**
     *param example:[height:170,weight:65,gender:1 represent female or 0 represent male,age:25,calibWalk:100,calibRun:100]
     */
    public func setPersonalInfo(userConf:UserConf) {
        if let data = try? userConf.serializedData() {
            BleManager.sharedInstance.writeCommend(data: data)
            
        }
    }
}
