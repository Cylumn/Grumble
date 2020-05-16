//
//  GFont.swift
//  Grumble
//
//  Created by Allen Chang on 4/3/20.
//  Copyright © 2020 Cylumn, Inc. All rights reserved.
//

import Foundation
import SwiftUI

//MARK: - Constants
private let fontMultiplier: CGFloat = 50

//MARK: - Enumerations
public enum GFont: String {
    case ubuntu = "Ubuntu-Regular"
    case ubuntuBold = "Ubuntu-Bold"
    case ubuntuBoldItalic = "Ubuntu-BoldItalic"
    case ubuntuItalic = "Ubuntu-Italic"
    case ubuntuLight = "Ubuntu-Light"
    case ubuntuLightItalic = "Ubuntu-LightItalic"
    case ubuntuMedium = "Ubuntu-Medium"
    case ubuntuMediumItalic = "Ubuntu-MediumItalic"
}

//MARK: - Font Getter Functions
public func gFont(_ name: GFont, _ size: CGFloat) -> Font {
    return Font.custom(name.rawValue, size: size)
}

public func gFont(_ name: GFont, _ size: CGFloat) -> UIFont {
    return UIFont(name: name.rawValue, size: size) ?? UIFont.systemFont(ofSize: size)
}

public func gFont(_ name: GFont, _ axis: ScreenDimension, _ fraction: CGFloat) -> Font {
    var length: CGFloat
    switch axis {
        case .width:
            length = sWidth()
        case .height:
            length = sHeight()
    }
    return Font.custom(name.rawValue, size: length * fraction / fontMultiplier)
}

public func gFont(_ name: GFont, _ axis: ScreenDimension, _ fraction: CGFloat) -> UIFont {
    var length: CGFloat
    switch axis {
        case .width:
            length = sWidth()
        case .height:
            length = sHeight()
    }
    return UIFont(name: name.rawValue, size: length * fraction / fontMultiplier) ?? UIFont.systemFont(ofSize: length * fraction / fontMultiplier)
}
