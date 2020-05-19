//
//  GTagShape.swift
//  Grumble
//
//  Created by Allen Chang on 4/21/20.
//  Copyright © 2020 Cylumn, Inc. All rights reserved.
//

import SwiftUI

private var cachedImages: [String: Image] = [:]

public protocol GTag: View {
    static var imgPath: String { get }
    var bWidth: CGFloat { get set }
    var bHeight: CGFloat { get set }
    var idleData: CGFloat { get set }
    var tossData: CGFloat { get set }
    
    static func genericInit(_ boundingSize: CGSize, idleData: CGFloat, tossData: CGFloat) -> AnyView
}

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

public struct GTagIcon: View {
    private static var instances: [UniqueID: [GrubTag: GTagIcon]] = [:]
    private var tag: GrubTag
    private var size: CGSize
    private var iconSize: CGSize
    
    fileprivate init(tag: GrubTag, size: CGSize) {
        self.tag = tag
        self.size = size
        let dimension = min(size.width, size.height)
        self.iconSize = CGSize(width: 0.65 * dimension, height: 0.65 * dimension)
    }
    
    public static func icon(tag: GrubTag, id: UniqueID, size: CGSize) -> GTagIcon {
        if GTagIcon.instances[id] == nil {
            GTagIcon.instances[id] = [:]
        }
        if GTagIcon.instances[id]![tag] == nil {
            GTagIcon.instances[id]![tag] = GTagIcon(tag: tag, size: size)
        }
        return GTagIcon.instances[id]![tag]!
    }
    
    public enum UniqueID {
        case tagBox
    }
    
    public var body: some View {
        ZStack {
            gTagColors[self.tag]
            
            ZStack {
                Image("GhorblinPlate")
                    .resizable()
                    .frame(width: self.size.width * 0.9, height: self.size.height * 0.3)
                    .offset(y: self.size.height * 0.27)
            }.frame(width: self.size.width)
            
            Ellipse()
                .fill(Color.black.opacity(0.2))
                .frame(width: self.size.width * 0.7, height: self.size.height * 0.2)
                .offset(y: self.size.height * 0.23)
            
            gTagView(self.tag, self.iconSize, idleData: 0, tossData: 0)
        }.frame(width: self.size.width, height: self.size.height)
    }
}

internal extension String {
    func imageAsset<GTagView>(_ tag: GTagView, path: String, scale: CGFloat, x: CGFloat = 0, y: CGFloat = 0) -> some View where GTagView: GTag {
        if cachedImages[self + path] == nil {
            cachedImages[self + path] = Image(self + path)
        }
        return cachedImages[self + path]!
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: tag.bWidth * scale)
            .offset(x: tag.bWidth * x, y: tag.bHeight * y)
    }
}

struct GTagShape_Previews: PreviewProvider {
    static var previews: some View {
        GTagIcon(tag: food, size: CGSize(width: 200, height: 150))
    }
}
