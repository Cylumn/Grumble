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

public protocol GTag: View {
    static var imgPath: String { get }
    var bWidth: CGFloat { get set }
    var bHeight: CGFloat { get set }
    var idleData: CGFloat { get set }
    var tossData: CGFloat { get set }
    
    static func genericInit(_ boundingSize: CGSize, idleData: CGFloat, tossData: CGFloat) -> AnyView
}

internal extension String {
    func imageAsset<GTagView>(_ tag: GTagView, path: String, scale: CGFloat, x: CGFloat = 0, y: CGFloat = 0) -> some View where GTagView: GTag {
        return Image(self + path)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: tag.bWidth * scale)
            .offset(x: tag.bWidth * x, y: tag.bHeight * y)
    }
}
