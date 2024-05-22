//
//  Data+Extensions.swift
//  HeloBleLib_Example
//
//  Created by AppleDev_9527 on 2024/5/22.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import Foundation

extension Data {
    public func hexStringFromData() -> String {
         return self.map { String(format: "%02x", $0) }.joined()
     }
}
