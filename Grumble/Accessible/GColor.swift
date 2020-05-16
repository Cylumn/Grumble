//
//  GColor.swift
//  Grumble
//
//  Created by Allen Chang on 4/3/20.
//  Copyright © 2020 Cylumn, Inc. All rights reserved.
//

import Foundation
import SwiftUI

//MARK: - Enumerations
public enum GColor: String {
    //Blues
    case blue0 = "Columbia"
    case blue1 = "Picton"
    case blue2 = "Sea"
    case blue3 = "Teal"
    case blue4 = "Turquoise"
    
    //TagColors in order
    case pumpkin = "Pumpkin"
    case dandelion = "Dandelion"
    case indigo = "Indigo"
    case coral = "Coral"
    case yolk = "Yolk"
    case poppy = "Poppy"
    case grass = "Grass"
    case crimson = "Crimson"
    case cerulean = "Cerulean"
    case dew = "Dew"
    case neon = "Neon"
    case wolfsbane = "Wolfsbane"
    case magenta = "Magenta"
    
    //TurquoiseFoam? WTF is this
    case lightTurquoise = "TurquoiseFoam"
}

//MARK: - Color Getter Functions
public func gColor(_ color: GColor) -> UIColor {
    switch color {
        default:
            return UIColor(named: color.rawValue) ?? UIColor.black
    }
}

public func gColor(_ color: GColor) -> Color {
    return Color(gColor(color))
}
