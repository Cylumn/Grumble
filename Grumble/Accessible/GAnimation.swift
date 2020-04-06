//
//  GAnimation.swift
//  Grumble
//
//  Created by Allen Chang on 4/3/20.
//  Copyright © 2020 Cylumn, Inc. All rights reserved.
//

import Foundation
import SwiftUI

private let dampingFraction: Double = 0.8
private let dampingFractionSlow: Double = 1.5
private let duration: Double = 0.3

public enum GAnimation {
    case spring
    case springSlow
    case easeOut
    case easeInOut
}

public func gAnim(_ animation: GAnimation) -> Animation {
    switch animation {
        case .spring:
            return .spring(dampingFraction: dampingFraction)
        case .springSlow:
            return .spring(dampingFraction: dampingFractionSlow)
        case .easeOut:
            return .easeOut(duration: duration)
        default:
            return .easeInOut
    }
}
