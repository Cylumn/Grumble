//
//  GColor.swift
//  Grumble
//
//  Created by Allen Chang on 4/3/20.
//  Copyright © 2020 Cylumn, Inc. All rights reserved.
//

import Foundation
import SwiftUI

public enum GColor: String {
    //Blues
    case blue0 = "Columbia"
    case blue1 = "Picton"
    case blue2 = "Sea"
    case blue3 = "Teal"
    case blue4 = "Turquoise"
    
    //TurquoiseFoam? WTF is this
    case lightTurquoise = "TurquoiseFoam"
    
    //Input Colors
    case inputDefault = "inputDefault"
}

public func gColor(_ color: GColor) -> UIColor {
    switch color {
        case .inputDefault:
            return UIColor(white: 0.98, alpha: 1)
        default:
            return UIColor(named: color.rawValue) ?? UIColor.black
    }
}

public func gColor(_ color: GColor) -> Color {
    return Color(gColor(color))
}
