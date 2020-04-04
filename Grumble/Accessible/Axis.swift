//
//  Screen.swift
//  Grumble
//
//  Created by Allen Chang on 4/3/20.
//  Copyright © 2020 Cylumn, Inc. All rights reserved.
//

import Foundation
import SwiftUI

public enum Axis {
    case width
    case height
}

public func sWidth() -> CGFloat {
    return UIScreen.main.bounds.size.width
}

public func sHeight() -> CGFloat {
    return UIScreen.main.bounds.size.height
}

public func isX() -> Bool {
    let phoneRatio = String(format: "%.3f", sWidth() / sHeight())
    let refRatio = String(format: "%.3f",  9.0 / 16.0)
    return phoneRatio != refRatio
}
