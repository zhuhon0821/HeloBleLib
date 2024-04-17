//
//  BaseDataManager.swift
//  HeloBleLib_Example
//
//  Created by AppleDev_9527 on 2024/4/17.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit

class BaseDataManager: NSObject {
    
    static let deviceNameKey = "_deviceNameKey"
    static func saveDeviceName(name:String) {
        UserDefaults.standard.set(name, forKey: deviceNameKey)
        UserDefaults.standard.synchronize()
    }
    static func getDeviceName() -> String {
        return UserDefaults.standard.object(forKey: deviceNameKey) as? String ?? ""
    }
    static func clearDeviceName() {
        return UserDefaults.standard.removeObject(forKey: deviceNameKey)
    }
    

}
