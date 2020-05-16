//
//  ScreenDimension.swift
//  Grumble
//
//  Created by Allen Chang on 4/3/20.
//  Copyright © 2020 Cylumn, Inc. All rights reserved.
//

import Foundation
import SwiftUI

//MARK: - Enumerations
public enum ScreenDimension {
    case width
    case height
}

public enum GAxis {
    case horizontal
    case vertical
}

//MARK: - Dimension Functions
public func sWidth() -> CGFloat {
    return UIScreen.main.bounds.size.width
}

public func sHeight() -> CGFloat {
    return UIScreen.main.bounds.size.height
}

public func safeAreaInset(_ edge: Edge.Set) -> CGFloat {
    switch edge {
        case .top:
            return UIApplication.shared.windows[0].safeAreaInsets.top
        case .leading:
            return UIApplication.shared.windows[0].safeAreaInsets.left
        case .bottom:
            return UIApplication.shared.windows[0].safeAreaInsets.bottom
        case .trailing:
            return UIApplication.shared.windows[0].safeAreaInsets.right
        default:
            return 0
    }
}

public func isX() -> Bool {
    let phoneRatio = String(format: "%.3f", sWidth() / sHeight())
    let refRatio = String(format: "%.3f",  9.0 / 16.0)
    return phoneRatio != refRatio
}
