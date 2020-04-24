//
//  GSoup.swift
//  Grumble
//
//  Created by Allen Chang on 4/22/20.
//  Copyright © 2020 Cylumn, Inc. All rights reserved.
//

import SwiftUI

public struct GSoup: GTag {
    public static var imgPath: String = "soup_"
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
        AnyView(GSoup(boundingSize, idleData: idleData, tossData: tossData))
    }
    
    private var cheeseSplash: some View {
        Path { p in
            p.addArc(center: CGPoint(x: self.bWidth * (0.6 + 0.2 * self.tossData), y: self.bHeight * (0.42 + 0.05 * self.tossData)),
                     radius: self.bWidth * 0.05 * self.tossData, startAngle: Angle(degrees: Double(-180 + 100 * self.tossData)), endAngle: Angle(degrees: Double(50 + 100 * self.tossData)), clockwise: true)
            p.addArc(center: CGPoint(x: self.bWidth * (0.62 + 0.3 * self.tossData), y: self.bHeight * (0.38 + 0.2 * self.tossData)),
                     radius: self.bWidth * 0.13 * self.tossData, startAngle: Angle(degrees: Double(80 + 80 * self.tossData)), endAngle: Angle(degrees: Double(180 + 110 * self.tossData)), clockwise: true)
        }.fill(Color(red: 1, green: 0.94, blue: 0.47))
        .rotationEffect(Angle(degrees: Double(5 + 10 * self.tossData)))
        .transformEffect(CGAffineTransform(scaleX: 1 - 0.2 * self.tossData, y: 1))
    }
    
    private var topBowl: some View {
        GSoup.imgPath.imageAsset(self, path: "TopBowl", scale: 0.88 + 0.03 * self.idleData, x: -0.02, y: 0.23 - 0.01 * self.idleData)
    }
    
    private var topCheese: some View {
        ZStack(alignment: .top) {
            Path() { p in
                p.move(to: CGPoint(x: self.bWidth * 0.22, y: self.bHeight * 0.4))
                p.addQuadCurve(to: CGPoint(x: self.bWidth * 0.4, y: self.bHeight * 0.43),
                               control: CGPoint(x: self.bWidth * 0.24, y: self.bHeight * 0.47))
                p.addQuadCurve(to: CGPoint(x: self.bWidth * 0.44, y: self.bHeight * 0.48),
                control: CGPoint(x: self.bWidth * 0.44, y: self.bHeight * 0.43))
                p.addQuadCurve(to: CGPoint(x: self.bWidth * 0.55, y: self.bHeight * 0.54),
                control: CGPoint(x: self.bWidth * 0.45, y: self.bHeight * 0.57))
                p.addQuadCurve(to: CGPoint(x: self.bWidth * 0.75, y: self.bHeight * 0.44),
                control: CGPoint(x: self.bWidth * 0.65, y: self.bHeight * 0.48))
                p.addQuadCurve(to: CGPoint(x: self.bWidth * 0.8, y: self.bHeight * 0.5),
                control: CGPoint(x: self.bWidth * 0.8, y: self.bHeight * 0.44))
                p.addQuadCurve(to: CGPoint(x: self.bWidth * 0.55, y: self.bHeight * 0.6),
                control: CGPoint(x: self.bWidth * 0.75, y: self.bHeight * 0.6))
                p.addQuadCurve(to: CGPoint(x: self.bWidth * 0.2, y: self.bHeight * 0.5),
                control: CGPoint(x: self.bWidth * 0.2, y: self.bHeight * 0.57))
                p.addQuadCurve(to: CGPoint(x: self.bWidth * 0.22, y: self.bHeight * 0.4),
                control: CGPoint(x: self.bWidth * 0.17, y: self.bHeight * 0.4))
            }.fill(Color(red: 1, green: 0.98, blue: 0.7))
            
            Path() { p in
                p.move(to: CGPoint(x: self.bWidth * 0.22, y: self.bHeight * 0.4))
                p.addQuadCurve(to: CGPoint(x: self.bWidth * 0.4, y: self.bHeight * 0.43),
                               control: CGPoint(x: self.bWidth * 0.24, y: self.bHeight * 0.47))
                p.addQuadCurve(to: CGPoint(x: self.bWidth * 0.44, y: self.bHeight * 0.48),
                               control: CGPoint(x: self.bWidth * 0.44, y: self.bHeight * 0.43))
                p.addQuadCurve(to: CGPoint(x: self.bWidth * 0.55, y: self.bHeight * 0.54),
                               control: CGPoint(x: self.bWidth * 0.45, y: self.bHeight * 0.57))
                p.addQuadCurve(to: CGPoint(x: self.bWidth * 0.75, y: self.bHeight * 0.44),
                               control: CGPoint(x: self.bWidth * 0.65, y: self.bHeight * 0.48))
                p.addQuadCurve(to: CGPoint(x: self.bWidth * 0.7, y: self.bHeight * 0.5),
                               control: CGPoint(x: self.bWidth * 0.8, y: self.bHeight * 0.44))
                p.addQuadCurve(to: CGPoint(x: self.bWidth * 0.45, y: self.bHeight * 0.56),
                               control: CGPoint(x: self.bWidth * 0.55, y: self.bHeight * 0.6))
                p.addQuadCurve(to: CGPoint(x: self.bWidth * 0.4, y: self.bHeight * 0.5),
                               control: CGPoint(x: self.bWidth * 0.38, y: self.bHeight * 0.53))
                p.addQuadCurve(to: CGPoint(x: self.bWidth * 0.2, y: self.bHeight * 0.4),
                               control: CGPoint(x: self.bWidth * 0.2, y: self.bHeight * 0.5))
                p.addQuadCurve(to: CGPoint(x: self.bWidth * 0.22, y: self.bHeight * 0.4),
                control: CGPoint(x: self.bWidth * 0.21, y: self.bHeight * 0.38))
            }.fill(Color(red: 1, green: 0.94, blue: 0.47))
            .offset(y: self.bHeight * -0.02 * self.idleData)
            
            Path { p in
                p.move(to: CGPoint(x: self.bWidth * 0.7, y: self.bHeight * (0.3 + 0.1 * self.tossData)))
                p.addQuadCurve(to: CGPoint(x: self.bWidth * (0.7 + 0.1 * self.tossData), y: self.bHeight * (0.3 - 0.15 * self.tossData)),
                               control: CGPoint(x: self.bWidth * (0.7 + 0.02 * self.tossData), y: self.bHeight * (0.32 - 0.1 * self.tossData)))
            }.stroke(style: StrokeStyle(lineWidth: self.bWidth * 0.05 * self.tossData, lineCap: .round))
            .foregroundColor(Color(red: 1, green: 0.98, blue: 0.7))
            .offset(x: self.bWidth * -0.3 * self.tossData, y: self.bHeight * -0.7 * self.tossData)
            .rotationEffect(Angle(degrees: Double(30 * self.tossData)))
            
            GSoup.imgPath.imageAsset(self, path: "TopCheese", scale: 0.62 - 0.03 * self.idleData, x: 0.03 - 0.1 * self.idleData, y: 0.31 + 0.04 * self.idleData)
            .rotationEffect(Angle(degrees: Double(-10 * self.idleData)))
        }
    }
    
    private var topBread: some View {
        GSoup.imgPath.imageAsset(self, path: "TopBread", scale: 0.32 - 0.05 * self.idleData - 0.03 * self.tossData, x: 0.08 - 0.1 * self.idleData + 0.3 * self.tossData, y: 0.3 + 0.08 * self.idleData - 0.7 * self.tossData)
            .rotationEffect(Angle(degrees: Double(-10 * self.idleData + 50 * self.tossData)))
    }
    
    private var mediumCheese: some View {
        GSoup.imgPath.imageAsset(self, path: "MediumCheese", scale: 0.65 - 0.07 * self.idleData, x: -0.03, y: 0.27 + 0.03 * self.idleData)
    }
    
    private var bottomBread: some View {
        GSoup.imgPath.imageAsset(self, path: "BottomBread", scale: 0.35 - 0.05 * self.idleData + 0.1 * self.tossData, x: -0.12 + 0.1 * self.tossData, y: 0.14 + 0.05 * self.idleData - 0.7 * self.tossData)
            .rotationEffect(Angle(degrees: Double(-40 * self.tossData)))
    }
    
    private var bottomCheese: some View {
        ZStack(alignment: .top) {
            GSoup.imgPath.imageAsset(self, path: "BottomCheese", scale: 0.72, x: -0.04, y: 0.25)
            
            Path { p in
                p.move(to: CGPoint(x: self.bWidth * (0.3 - 0.1 * self.tossData), y: self.bHeight * (0.35 - 0.2 * self.tossData)))
                p.addQuadCurve(to: CGPoint(x: self.bWidth * (0.3 - 0.2 * self.tossData), y: self.bHeight * (0.2 - 0.1 * self.tossData)),
                               control: CGPoint(x: self.bWidth * (0.3 - 0.15 * self.tossData), y: self.bHeight * (0.2 - 0.1 * self.tossData)))
            }.stroke(style: StrokeStyle(lineWidth: self.bWidth * 0.03 * self.tossData, lineCap: .round))
            .foregroundColor(Color(red: 1, green: 0.94, blue: 0.47))
            .offset(x: self.bWidth * 0.1 * self.tossData, y: self.bHeight * -0.05 * self.tossData)
            .rotationEffect(Angle(degrees: Double(-20 * self.tossData)))
        }
    }
    
    private var bottomBowl: some View {
        GSoup.imgPath.imageAsset(self, path: "BottomBowl", scale: 1.03 + 0.05 * self.idleData, x: 0.04, y: 0.11 - 0.03 * self.idleData)
    }
    
    public var body: some View {
        ZStack(alignment: .top) {
            Color.clear
            
            self.bottomBowl
            
            self.bottomCheese
            
            self.bottomBread
            
            self.mediumCheese
            
            self.topBread
            
            self.topCheese
            
            self.topBowl
            
            self.cheeseSplash
        }.frame(width: self.bWidth, height: self.bHeight)
    }
}

struct GSoup_Previews: PreviewProvider {
    static var previews: some View {
        GSoup(idleData: 0, tossData: 0)
    }
}
