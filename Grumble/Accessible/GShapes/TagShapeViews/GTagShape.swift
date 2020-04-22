//
//  GTagShape.swift
//  Grumble
//
//  Created by Allen Chang on 4/21/20.
//  Copyright © 2020 Cylumn, Inc. All rights reserved.
//

import SwiftUI

public struct GTagShape: Shape {
    private var pathBuilder: (CGRect, CGFloat) -> Path
    public var animatableData: CGFloat
    
    public init(_ idleData: CGFloat, _ pathBuilder: @escaping (CGRect, CGFloat) -> Path) {
        self.animatableData = idleData
        self.pathBuilder = pathBuilder
    }
    
    public func path(in rect: CGRect) -> Path {
        self.pathBuilder(rect, self.animatableData)
    }
}
