//
//  GFood.swift
//  Grumble
//
//  Created by Allen Chang on 4/23/20.
//  Copyright © 2020 Cylumn, Inc. All rights reserved.
//

import SwiftUI

public struct GFood: GTag {
    public static var imgPath: String = "food_"
    public var bWidth: CGFloat
    public var bHeight: CGFloat
    public var idleData: CGFloat
    public var tossData: CGFloat
    
    public init(_ boundingSize: CGSize = CGSize(width: 300, height: 300), idleData: CGFloat, tossData: CGFloat) {
        self.bWidth = boundingSize.width
        self.bHeight = boundingSize.height
        self.idleData = idleData
        self.tossData = tossData
    }
    
    public static func genericInit(_ boundingSize: CGSize, idleData: CGFloat, tossData: CGFloat) -> AnyView {
        AnyView(GFood(boundingSize, idleData: idleData, tossData: tossData))
    }
    
    private var logo: some View {
        GFood.imgPath.imageAsset(self, path: "Logo", scale: 0.19 + 0.04 * self.idleData + 0.1 * self.tossData, x: -0.3 * self.tossData, y: 0.44 - 0.7 * self.tossData)
            .rotationEffect(Angle(degrees: Double(20 * self.tossData)))
    }
    
    private var tag: some View {
        GFood.imgPath.imageAsset(self, path: "Tag", scale: 0.35 + 0.06 * self.idleData, x: 0.18 + 0.03 * self.idleData, y: 0.05 - 0.01 * self.idleData)
        .rotationEffect(Angle(degrees: Double(-40 * self.tossData)))
        .scaleEffect(x: 1, y: 1 - 0.2 * self.tossData)
    }
    
    private var bag: some View {
        GFood.imgPath.imageAsset(self, path: "Bag", scale: 0.86 + 0.1 * self.idleData, y: 0.05)
    }
    
    public var body: some View {
        ZStack(alignment: .bottom) {
            Color.clear
            
            ZStack(alignment: .top) {
                self.bag
                
                self.tag
                
                self.logo
            }.scaleEffect(1.1, anchor: UnitPoint.bottom)
            .offset(y: self.bHeight * -0.1)
        }.frame(width: self.bWidth, height: self.bHeight)
    }
}

struct GFood_Previews: PreviewProvider {
    static var previews: some View {
        GFood(idleData: 0, tossData: 0)
    }
}
