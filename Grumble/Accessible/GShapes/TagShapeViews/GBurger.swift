//
//  GBurger.swift
//  Grumble
//
//  Created by Allen Chang on 4/21/20.
//  Copyright © 2020 Cylumn, Inc. All rights reserved.
//

import SwiftUI

public struct GBurger: GTag {
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
        var scale: CGFloat = 0.95
        var offsetY: CGFloat = 0.06
        
        scale += 0.05 * self.idleData
        offsetY -= 0.05 * self.idleData
        
        offsetY -= 0.6 * self.tossData
        
        return GBurger.imgPath.imageAsset(self, path: "TopBun", scale: scale, y: offsetY)
    }
    
    private func sauce(_ idleData: CGFloat, offsetX: CGFloat, offsetY: CGFloat) -> some Shape {
        return GTagShape(idleData) { rect, idle in
            var path = Path()
            path.move(to: CGPoint(x: self.bWidth * 0.15 + offsetX, y: self.bHeight * 0.4 + offsetY))
            path.addQuadCurve(to: CGPoint(x: self.bWidth * 0.4 + offsetX, y: self.bHeight * 0.5 + offsetY),
                              control: CGPoint(x: self.bWidth * 0.2 + offsetX, y: self.bHeight * 0.5 + offsetY))
            path.addQuadCurve(to: CGPoint(x: self.bWidth * 0.585 + offsetX, y: self.bHeight * (0.5 + 0.05 * idle) + offsetY),
                              control: CGPoint(x: self.bWidth * 0.58 + offsetX, y: self.bHeight * 0.48 + offsetY))
            path.addArc(center: CGPoint(x: self.bWidth * 0.63 + offsetX, y: self.bHeight * (0.5 + 0.05 * idle) + offsetY),
                        radius: self.bWidth * 0.045, startAngle: Angle(degrees: 180), endAngle: Angle(degrees: 30), clockwise: true)
            path.addQuadCurve(to: CGPoint(x: self.bWidth * 0.75 + offsetX, y: self.bHeight * 0.47 + offsetY),
                              control: CGPoint(x: self.bWidth * 0.67 + offsetX, y: self.bHeight * 0.48 + offsetY))
            path.addQuadCurve(to: CGPoint(x: self.bWidth * 0.8 + offsetX, y: self.bHeight * 0.4 + offsetY),
                              control: CGPoint(x: self.bWidth * 0.8 + offsetX, y: self.bHeight * 0.45 + offsetY))
            path.addQuadCurve(to: CGPoint(x: self.bWidth * 0.3 + offsetX, y: self.bHeight * 0.3 + offsetY),
                              control: CGPoint(x: self.bWidth * 0.8 + offsetX, y: self.bHeight * 0.25 + offsetY))
            path.addQuadCurve(to: CGPoint(x: self.bWidth * 0.15 + offsetX, y: self.bHeight * 0.4 + offsetY),
                              control: CGPoint(x: self.bWidth * 0.08 + offsetX, y: self.bHeight * 0.32 + offsetY))
            path.closeSubpath()
            return path
        }
    }
    
    private var lettuce: some View {
        var scale: CGFloat = 0.9
        var offsetX: CGFloat = 0.0
        var offsetY: CGFloat = 0.3
            
        scale += 0.03 * self.idleData
        offsetX += 0.02 * self.idleData
        offsetY -= 0.02 * self.idleData
        
        offsetY -= 0.23 * self.tossData
            
        return GBurger.imgPath.imageAsset(self, path: "Lettuce", scale: scale, x: offsetX, y: offsetY)
    }
    
    private var tomato: some View {
        var scale: CGFloat = 0.8
        var offsetX: CGFloat = 0.0
        var offsetY: CGFloat = 0.42
        
        scale += 0.02 * self.idleData
        offsetY -= 0.02 * self.idleData
        
        offsetX += 0.05 * self.tossData
        offsetY -= 0.13 * self.tossData
        
        return GBurger.imgPath.imageAsset(self, path: "Tomato", scale: scale, x: offsetX, y: offsetY)
    }
    
    private var cheese: some View {
        var offsetY: CGFloat = 0.06
        
        offsetY -= 0.03 * self.tossData
        
        let cheese = GTagShape(self.idleData) { rect, idle in
            var path = Path()
            path.move(to: CGPoint(x: self.bWidth * 0.15, y: self.bHeight * (0.55 - 0.05 * idle + offsetY)))
            path.addLine(to: CGPoint(x: self.bWidth * 0.2, y: self.bHeight * (0.65 + offsetY)))
            path.addLine(to: CGPoint(x: self.bWidth * 0.3, y: self.bHeight * (0.8 + 0.05 * idle + offsetY)))
            path.addArc(center: CGPoint(x: self.bWidth * 0.34, y: self.bHeight * (0.8 + 0.05 * idle + offsetY)),
                        radius: self.bWidth * 0.03, startAngle: Angle(degrees: 135), endAngle: Angle(degrees: 45), clockwise: true)
            path.addLine(to: CGPoint(x: self.bWidth * 0.5, y: self.bHeight * (0.7 + offsetY)))
            path.addQuadCurve(to: CGPoint(x: self.bWidth * 0.85, y: self.bHeight * (0.5 + offsetY)),
                              control: CGPoint(x: self.bWidth * 0.9, y: self.bHeight * (0.6 + offsetY)))
            path.addQuadCurve(to: CGPoint(x: self.bWidth * 0.75, y: self.bHeight * (0.45 + offsetY)),
                              control: CGPoint(x: self.bWidth * 0.85, y: self.bHeight * (0.48 + offsetY)))
            path.addQuadCurve(to: CGPoint(x: self.bWidth * 0.15, y: self.bHeight * (0.55 - 0.05 * idle + offsetY)),
                              control: CGPoint(x: self.bWidth * 0.15, y: self.bHeight * (0.35 + offsetY)))
            path.closeSubpath()
            return path
        }
        
        let shine = GTagShape(self.idleData) { rect, idle in
            var highlight = Path()
            highlight.move(to: CGPoint(x: self.bWidth * 0.33, y: self.bHeight * (0.77 + 0.02 * idle + offsetY)))
            highlight.addLine(to: CGPoint(x: self.bWidth * (0.28 - 0.02 * idle), y: self.bHeight * (0.68 + 0.03 * idle + offsetY)))
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
        var scale: CGFloat = 0.9
        var offsetY: CGFloat = 0.5
        
        scale -= 0.03 * self.idleData
        offsetY += 0.02 * self.idleData
        
        offsetY += 0.01 * self.tossData
        
        return GBurger.imgPath.imageAsset(self, path: "Patty", scale: scale, y: offsetY)
    }
    
    private var bottomBun: some View {
        var scale: CGFloat = 0.85
        var offsetY: CGFloat = 0.6
        
        scale -= 0.05 * self.idleData
        offsetY += 0.02 * self.idleData
        
        return GBurger.imgPath.imageAsset(self, path: "BottomBun", scale: scale, y: offsetY)
    }
    
    public var body: some View {
        ZStack(alignment: .top) {
            Color.clear
            
            ZStack(alignment: .top) {
                self.bottomBun
                self.patty
                self.cheese
                self.sauce(self.idleData, offsetX: self.bWidth * -0.03, offsetY: self.bHeight * (0.21 - 0.08 * self.tossData))
                    .fill(Color.red)
                    .rotationEffect(Angle(degrees: Double(-2 * self.tossData)))
                self.tomato
                    .rotationEffect(Angle(degrees: Double(5 * self.tossData)))
                self.lettuce
                    .rotationEffect(Angle(degrees: Double(-5 * self.tossData)))
                self.sauce(1 - self.idleData, offsetX: self.bWidth * 0.08, offsetY: self.bHeight * (0.03 - 0.35 * self.tossData))
                    .fill(Color(red: 1, green: 0.93, blue: 0.47))
                    .rotationEffect(Angle(degrees: Double(5 * self.tossData)))
                self.topBun
                    .rotationEffect(Angle(degrees: Double(15 * self.tossData)))
            }
        }.frame(width: self.bWidth, height: self.bHeight)
    }
}

struct GBurger_Previews: PreviewProvider {
    static var previews: some View {
        GBurger(idleData: 0, tossData: 0)
    }
}
