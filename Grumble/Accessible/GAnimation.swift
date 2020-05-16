//
//  GAnimation.swift
//  Grumble
//
//  Created by Allen Chang on 4/3/20.
//  Copyright © 2020 Cylumn, Inc. All rights reserved.
//

import Foundation
import SwiftUI

//MARK: - Constants
private let dampingFraction: Double = 0.8
private let dampingFractionSlow: Double = 1.5
private let duration: Double = 0.3
private let durationSlow: Double = 1

//MARK: - Enumerations
public enum GAnimation {
    case spring
    case springSlow
    case easeOut
    case easeOutSlow
    case easeInOut
}

//MARK: - Animation Getter Functions
public func gAnim(_ animation: GAnimation) -> Animation {
    switch animation {
    case .spring:
        return .spring(dampingFraction: dampingFraction)
    case .springSlow:
        return .spring(dampingFraction: dampingFractionSlow)
    case .easeOut:
        return .easeOut(duration: duration)
    case .easeOutSlow:
        return .easeOut(duration: durationSlow)
    default:
        return .easeInOut
    }
}
