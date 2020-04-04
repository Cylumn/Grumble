//
//  Screen.swift
//  Grumble
//
//  Created by Allen Chang on 4/3/20.
//  Copyright © 2020 Cylumn, Inc. All rights reserved.
//

import Foundation
import SwiftUI

enum Axis {
    case width
    case height
}

func sWidth() -> CGFloat {
    return UIScreen.main.bounds.size.width
}

func sHeight() -> CGFloat {
    return UIScreen.main.bounds.size.height
}

func isX() -> Bool {
    let phoneRatio = String(format: "%.3f", sWidth() / sHeight())
    let refRatio = String(format: "%.3f",  9.0 / 16.0)
    return phoneRatio != refRatio
}
