//
//  GDate.swift
//  Grumble
//
//  Created by Allen Chang on 4/9/20.
//  Copyright © 2020 Cylumn, Inc. All rights reserved.
//

import Foundation

private let format: String = "yyyy-MM-dd HH:mm:ss"

public func dateComponent() -> DateComponents {
    let date = Date()
    let calender = Calendar.current
    let components = calender.dateComponents([.year,.month,.day,.hour,.minute,.second], from: date)
    return components
}

public func getDate() -> String {
    let components = dateComponent()
    return String(components.year!) + "-" + String(components.month!) + "-" + String(components.day!) + " " + String(components.hour!) + ":" + String(components.minute!) + ":" + String(components.second!)
}
