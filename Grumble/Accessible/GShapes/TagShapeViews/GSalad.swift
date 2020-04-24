//
//  GSalad.swift
//  Grumble
//
//  Created by Allen Chang on 4/22/20.
//  Copyright © 2020 Cylumn, Inc. All rights reserved.
//

import SwiftUI

public struct GSalad: GTag {
    public static var imgPath: String = "salad_"
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
        AnyView(GSalad(boundingSize, idleData: idleData, tossData: tossData))
    }
    
    private var topBowl: some View {
        GSalad.imgPath.imageAsset(self, path: "TopBowl", scale: 0.98 - 0.02 * self.idleData, y: 0.6 - 0.02 * self.idleData)
    }
    
    private var topLettuce: some View {
        GSalad.imgPath.imageAsset(self, path: "TopLettuce", scale: 0.93 - 0.1 * self.idleData, x: -0.02, y: 0.43 + 0.02 * self.idleData - 0.03 * self.tossData)
    }
    
    private var topOlives: some View {
        GSalad.imgPath.imageAsset(self, path: "TopOlives", scale: 0.6 + 0.2 * self.idleData, x: 0.05, y: 0.56 - 0.1 * self.idleData - 0.1 * self.tossData)
        .rotationEffect(Angle(degrees: Double(-10 * self.tossData)))
    }
    
    private var topOnions: some View {
        GSalad.imgPath.imageAsset(self, path: "TopOnions", scale: 0.25 + 0.05 * self.idleData, x: -0.05 + 0.1 * self.idleData + 0.2 * self.tossData, y: 0.55 - 0.03 * self.idleData - 0.2 * self.tossData)
        .rotationEffect(Angle(degrees: Double(20 * self.tossData)))
    }
    
    private var topCheese: some View {
        GSalad.imgPath.imageAsset(self, path: "TopCheese", scale: 0.98, y: 0.37 - 0.03 * self.idleData - 0.1 * self.tossData)
    }
    
    private var middleOnions: some View {
        GSalad.imgPath.imageAsset(self, path: "MiddleOnions", scale: 0.48 + 0.1 * self.idleData, x: -0.25, y: 0.3 - 0.1 * self.idleData - 0.2 * self.tossData)
        .rotationEffect(Angle(degrees: Double(20 * self.tossData)))
    }
    
    private var middleOlives: some View {
        GSalad.imgPath.imageAsset(self, path: "MiddleOlives", scale: 0.4, x: -0.08, y: 0.35 - 0.03 * self.idleData - 0.1 * self.tossData)
    }
    
    private var cucumber: some View {
        GSalad.imgPath.imageAsset(self, path: "Cucumber", scale: 0.8 + 0.1 * self.idleData, x: -0.08 + 0.05 * self.idleData, y: 0.23 - 0.07 * self.idleData + 0.02 * self.tossData)
        .rotationEffect(Angle(degrees: Double(30 * self.tossData)))
    }
    
    private var tomato: some View {
        GSalad.imgPath.imageAsset(self, path: "Tomato", scale: 0.9 - 0.05 * self.idleData, x: 0.02, y: 0.3 - 0.04 * self.idleData - 0.2 * self.tossData)
        .rotationEffect(Angle(degrees: Double(-10 * self.tossData)))
    }
    
    private var bottomOlives: some View {
        GSalad.imgPath.imageAsset(self, path: "BottomOlives", scale: 0.12 + 0.03 * self.idleData, x: 0.23 - 0.4 * self.tossData, y: 0.35 - 0.07 * self.idleData - 0.4 * self.tossData)
        .rotationEffect(Angle(degrees: Double(-50 * self.tossData)))
    }
    
    private var bottomCheese: some View {
        GSalad.imgPath.imageAsset(self, path: "BottomCheese", scale: 0.2, x: 0.2 * self.tossData, y: 0.3 - 0.1 * self.idleData - 0.4 * self.tossData)
        .rotationEffect(Angle(degrees: Double(20 * self.tossData)))
    }
    
    private var bottomOnions: some View {
        GSalad.imgPath.imageAsset(self, path: "BottomOnions", scale: 0.35 + 0.05 * self.idleData, x: 0.18 + 0.02 * self.idleData + 0.2 * self.tossData, y: 0.15 - 0.1 * self.idleData - 0.5 * self.tossData)
            .rotationEffect(Angle(degrees: Double(-20 * self.tossData)))
    }
    
    private var bottomLettuce: some View {
        GSalad.imgPath.imageAsset(self, path: "BottomLettuce", scale: 1 + 0.03 * self.idleData, y: 0.05 - 0.05 * self.idleData - 0.05 * self.tossData)
    }
    
    private var bottomBowl: some View {
        GSalad.imgPath.imageAsset(self, path: "BottomBowl", scale: 0.98 + 0.02 * self.idleData, y: 0.5 - 0.05 * self.idleData)
    }
    
    public var body: some View {
        ZStack(alignment: .top) {
            Color.clear
            
            Group {
                self.bottomBowl
                self.bottomLettuce
                self.bottomOnions
                self.bottomCheese
                self.bottomOlives
            }
            
            Group {
                self.tomato
                self.cucumber
                self.middleOlives
                self.middleOnions
            }
            
            Group {
                self.topCheese
                self.topOnions
                self.topOlives
                self.topLettuce
                self.topBowl
            }
        }.frame(width: self.bWidth, height: self.bHeight)
    }
}

struct GSalad_Previews: PreviewProvider {
    static var previews: some View {
        GSalad(idleData: 0, tossData: 0)
    }
}
