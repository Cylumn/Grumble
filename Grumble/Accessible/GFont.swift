//
//  GFont.swift
//  Grumble
//
//  Created by Allen Chang on 4/3/20.
//  Copyright © 2020 Cylumn, Inc. All rights reserved.
//

import Foundation
import SwiftUI

private let fontMultiplier: CGFloat = 50

public enum GFont: String {
    //Ubuntu
    case ubuntu = "Ubuntu-Regular"
    case ubuntuBold = "Ubuntu-Bold"
    case ubuntuBoldItalic = "Ubuntu-BoldItalic"
    case ubuntuItalic = "Ubuntu-Italic"
    case ubuntuLightItalic = "Ubuntu-LightItalic"
    case ubuntuMedium = "Ubuntu-Medium"
    case ubuntuMediumItalic = "Ubuntu-MediumItalic"
    
    //Caveat -- UNUSED
    case caveat = "Caveat-Regular"
    case caveatBold = "Caveat-Bold"
    
    //Teko
    case teko = "Teko-Regular"
    case tekoBold = "Teko-Bold"
    case tekoSemiBold = "Teko-SemiBold"
    case tekoLight = "Teko-Light"
    case tekoMedium = "Teko-Medium"
}

public func gFont(_ name: GFont, _ axis: Axis, _ fraction: CGFloat) -> Font {
    var length: CGFloat
    switch axis {
        case .width:
            length = sWidth()
        case .height:
            length = sHeight()
    }
    return Font.custom(name.rawValue, size: length * fraction / fontMultiplier)
}

public func gFont(_ name: GFont, _ axis: Axis, _ fraction: CGFloat) -> UIFont {
    var length: CGFloat
    switch axis {
        case .width:
            length = sWidth()
        case .height:
            length = sHeight()
    }
    return UIFont(name: name.rawValue, size: length * fraction / fontMultiplier) ?? UIFont.systemFont(ofSize: length * fraction / fontMultiplier)
}
