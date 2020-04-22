//
//  GBurger.swift
//  Grumble
//
//  Created by Allen Chang on 4/21/20.
//  Copyright © 2020 Cylumn, Inc. All rights reserved.
//

import SwiftUI

public struct GBurger: View, GTag {
    public static var imgPath: String = "burger_"
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
        AnyView(GBurger(boundingSize, idleData: idleData, tossData: tossData))
    }
    
    private var topBun: some View {
        GBurger.imgPath.imageAsset(self, path: "TopBun", scale: 0.95 + 0.05 * self.idleData, y: 0.04 - 0.05 * self.idleData)
    }
    
    private func sauce(_ idleData: CGFloat) -> some Shape {
        return GTagShape(idleData) { rect, idle in
            var path = Path()
            path.move(to: CGPoint(x: self.bWidth * 0.15, y: self.bHeight * 0.4))
            path.addQuadCurve(to: CGPoint(x: self.bWidth * 0.4, y: self.bHeight * 0.5),
                              control: CGPoint(x: self.bWidth * 0.2, y: self.bHeight * 0.5))
            path.addQuadCurve(to: CGPoint(x: self.bWidth * 0.585, y: self.bHeight * (0.5 + 0.05 * idle)),
                              control: CGPoint(x: self.bWidth * 0.58, y: self.bHeight * 0.48))
            path.addArc(center: CGPoint(x: self.bWidth * 0.63, y: self.bHeight * (0.5 + 0.05 * idle)),
                        radius: self.bWidth * 0.045, startAngle: Angle(degrees: 180), endAngle: Angle(degrees: 30), clockwise: true)
            path.addQuadCurve(to: CGPoint(x: self.bWidth * 0.75, y: self.bHeight * 0.47),
                              control: CGPoint(x: self.bWidth * 0.67, y: self.bHeight * 0.48))
            path.addQuadCurve(to: CGPoint(x: self.bWidth * 0.8, y: self.bHeight * 0.4),
                              control: CGPoint(x: self.bWidth * 0.8, y: self.bHeight * 0.45))
            path.addQuadCurve(to: CGPoint(x: self.bWidth * 0.3, y: self.bHeight * 0.3),
                              control: CGPoint(x: self.bWidth * 0.8, y: self.bHeight * 0.25))
            path.addQuadCurve(to: CGPoint(x: self.bWidth * 0.15, y: self.bHeight * 0.4),
                              control: CGPoint(x: self.bWidth * 0.08, y: self.bHeight * 0.32))
            path.closeSubpath()
            return path
        }
    }
    
    private var lettuce: some View {
        GBurger.imgPath.imageAsset(self, path: "Lettuce", scale: 0.9 + 0.03 * self.idleData, x: 0.02 * self.idleData, y: 0.28 - 0.02 * self.idleData)
    }
    
    private var tomato: some View {
        GBurger.imgPath.imageAsset(self, path: "Tomato", scale: 0.8 + 0.02 * self.idleData, y: 0.4 - 0.02 * self.idleData)
    }
    
    private var cheese: some View {
        let cheese = GTagShape(self.idleData) { rect, idle in
            var path = Path()
            path.move(to: CGPoint(x: self.bWidth * 0.15, y: self.bHeight * (0.55 - 0.05 * idle)))
            path.addLine(to: CGPoint(x: self.bWidth * 0.2, y: self.bHeight * 0.65))
            path.addLine(to: CGPoint(x: self.bWidth * 0.3, y: self.bHeight * (0.8 + 0.05 * idle)))
            path.addArc(center: CGPoint(x: self.bWidth * 0.34, y: self.bHeight * (0.8 + 0.05 * idle)),
                        radius: self.bWidth * 0.03, startAngle: Angle(degrees: 135), endAngle: Angle(degrees: 45), clockwise: true)
            path.addLine(to: CGPoint(x: self.bWidth * 0.5, y: self.bHeight * 0.7))
            path.addQuadCurve(to: CGPoint(x: self.bWidth * 0.85, y: self.bHeight * 0.5),
                              control: CGPoint(x: self.bWidth * 0.9, y: self.bHeight * 0.6))
            path.addQuadCurve(to: CGPoint(x: self.bWidth * 0.75, y: self.bHeight * 0.45),
                              control: CGPoint(x: self.bWidth * 0.85, y: self.bHeight * 0.48))
            path.addQuadCurve(to: CGPoint(x: self.bWidth * 0.15, y: self.bHeight * (0.55 - 0.05 * idle)),
                              control: CGPoint(x: self.bWidth * 0.15, y: self.bHeight * 0.35))
            path.closeSubpath()
            return path
        }
        
        let shine = GTagShape(self.idleData) { rect, idle in
            var highlight = Path()
            highlight.move(to: CGPoint(x: self.bWidth * 0.33, y: self.bHeight * (0.77 + 0.02 * idle)))
            highlight.addLine(to: CGPoint(x: self.bWidth * (0.28 - 0.02 * idle), y: self.bHeight * (0.68 + 0.03 * idle)))
            return highlight
        }
        
        return ZStack {
            cheese.fill(gColor(.dandelion))
            
            shine
                .stroke(style: StrokeStyle(lineWidth: self.bWidth * 0.04, lineCap: .round))
                .fill(Color(red: 1, green: 0.93, blue: 0.47))
        }
    }
    
    private var patty: some View {
        GBurger.imgPath.imageAsset(self, path: "Patty", scale: 0.9 - 0.03 * self.idleData, y: 0.48 + 0.02 * self.idleData)
    }
    
    private var bottomBun: some View {
        GBurger.imgPath.imageAsset(self, path: "BottomBun", scale: 0.85 - 0.05 * self.idleData, y: 0.58 + 0.02 * self.idleData)
    }
    
    public var body: some View {
        ZStack(alignment: .top) {
            self.bottomBun
            self.patty
                .offset(y: self.bHeight * 0.01 * self.tossData)
            self.cheese
                .offset(y: self.bHeight * (0.04 - 0.03 * self.tossData))
            self.sauce(self.idleData)
                .fill(Color.red)
                .offset(x: self.bWidth * -0.03, y: self.bHeight * (0.19 - 0.08 * self.tossData))
                .rotationEffect(Angle(degrees: Double(-2 * self.tossData)))
            self.tomato
                .offset(x: self.bWidth * 0.05 * self.tossData, y: self.bHeight * -0.13 * self.tossData)
                .rotationEffect(Angle(degrees: Double(5 * self.tossData)))
            self.lettuce
                .offset(y: self.bHeight * -0.17 * self.tossData)
                .rotationEffect(Angle(degrees: Double(-5 * self.tossData)))
            self.sauce(1 - self.idleData)
                .fill(Color(red: 1, green: 0.93, blue: 0.47))
                .offset(x: self.bWidth * 0.08, y: self.bHeight * (0.01 - 0.25 * self.tossData))
                .rotationEffect(Angle(degrees: Double(5 * self.tossData)))
            self.topBun
                .offset(y: self.bHeight * -0.4 * self.tossData)
                .rotationEffect(Angle(degrees: Double(15 * self.tossData)))
        }.frame(width: self.bWidth, height: self.bHeight)
    }
}

struct GBurger_Previews: PreviewProvider {
    static var previews: some View {
        GBurger(idleData: 0, tossData: 0)
    }
}
