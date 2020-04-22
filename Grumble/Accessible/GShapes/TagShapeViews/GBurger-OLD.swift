//
//  GBurger.swift
//  Grumble
//
//  Created by Allen Chang on 4/21/20.
//  Copyright © 2020 Cylumn, Inc. All rights reserved.
//

import SwiftUI

public struct GBurgerOLD: View {
    private var boundingSize: CGSize
    
    @State private var topBunRSize: CGSize = CGSize(width: 0.9, height: 0.9 * 0.49)
    
    public init(_ boundingSize: CGSize = CGSize(width: 300, height: 300)) {
        self.boundingSize = boundingSize
    }
    
    private func bWidth() -> CGFloat {
        return self.boundingSize.width
    }
    
    private func bHeight() -> CGFloat {
        return self.boundingSize.height
    }
    
    private var bun: some Shape {
        let width: CGFloat = self.bWidth() * self.topBunRSize.width
        let height: CGFloat = self.bHeight() * self.topBunRSize.height
        
        var path = Path()
        path.move(to: CGPoint(x: width * 0.5, y: height * 0.05))
        path.addQuadCurve(to: CGPoint(x: 0, y: height * 0.65),
                          control: CGPoint(x: width * 0.1, y: height * 0.1))
        path.addLine(to: CGPoint(x: 0, y: height * 0.7))
        path.addQuadCurve(to: CGPoint(x: width * 0.5, y: height),
                          control: CGPoint(x: 0, y: height))
        path.addQuadCurve(to: CGPoint(x: width, y: height * 0.7),
                          control: CGPoint(x: width, y: height))
        path.addLine(to: CGPoint(x: width, y: height * 0.65))
        path.addQuadCurve(to: CGPoint(x: width * 0.5, y: height * 0.05),
                          control: CGPoint(x: width * 0.9, y: height * 0.1))
        return path
    }
    
    private struct SesameSeeds: View {
        private static var scale: CGFloat = 0
        private var size: CGSize
        private var showShadow: Bool
        
        fileprivate init(_ size: CGSize, showShadow: Bool = true) {
            self.size = CGSize(width: size.width * SesameSeeds.scale, height: size.height * SesameSeeds.scale)
            self.showShadow = showShadow
        }
        
        fileprivate static func setScale(_ scale: CGFloat) {
            SesameSeeds.scale = scale
        }
        
        public var body: some View {
            ZStack(alignment: .topLeading) {
                if self.showShadow {
                    ZStack(alignment: .bottomTrailing) {
                        Color.clear
                        
                        Ellipse()
                            .fill(Color(red: 1, green: 0.56, blue: 0))
                            .frame(width: self.size.height * 0.8, height: self.size.height * 0.6)
                    }
                }
                
                Ellipse()
                    .fill(Color(red: 1, green: 0.9, blue: 0.6))
                    .frame(width: self.size.width * 0.85, height: self.size.height * 0.85)
            }.frame(width: self.size.width, height: self.size.height)
        }
    }
    
    private var topBun: some View {
        let rPointsX: [CGFloat] = [-0.17, -0.03, -0.12, -0.35, 0.13, 0.08, 0.25]
        let rPointsY: [CGFloat] = [0.07, 0.07, 0.2, 0.18, 0, 0.17, 0.09]
        
        var highlight = Path()
        highlight.move(to: CGPoint(x: self.bWidth() * 0.53 * self.topBunRSize.width, y: self.bHeight() * 0.07 * self.topBunRSize.height))
        highlight.addQuadCurve(to: CGPoint(x: self.bWidth() * 0.01 * self.topBunRSize.width, y: self.bHeight() * 0.58 * self.topBunRSize.height),
                               control: CGPoint(x: (self.bWidth() * 0.1) * self.topBunRSize.width, y: self.bHeight() * 0.10 * self.topBunRSize.height))
        
        SesameSeeds.setScale(self.topBunRSize.width)
        
        var shadowPath = Path()
        shadowPath.move(to: CGPoint(x: self.bWidth() * 0.9 * self.topBunRSize.width, y: 0))
        shadowPath.addQuadCurve(to: CGPoint(x: self.bWidth() * 0, y: self.bHeight() * 0.33),
                                control: CGPoint(x: self.bWidth() * 0.85, y: self.bHeight() * self.topBunRSize.height))
        shadowPath.addLine(to: CGPoint(x: 0, y: self.bHeight() * 0.35))
        shadowPath.addLine(to: CGPoint(x: 0, y: self.bHeight() * self.topBunRSize.height))
        shadowPath.addLine(to: CGPoint(x: self.bWidth(), y: self.bHeight() * self.topBunRSize.height))
        shadowPath.addLine(to: CGPoint(x: self.bWidth(), y: 0))
        shadowPath.closeSubpath()
        
        return ZStack(alignment: .top) {
            SesameSeeds(CGSize(width: self.bWidth() * 0.10, height: self.bHeight() * 0.10), showShadow: false)
                .offset(x: self.bWidth() * -0.1 * self.topBunRSize.width, y: 0)
            
            SesameSeeds(CGSize(width: self.bWidth() * 0.10, height: self.bHeight() * 0.10), showShadow: false)
                .offset(x: self.bWidth() * 0.33 * self.topBunRSize.width, y: self.bHeight() * 0.04)
            
            self.bun
                .fill(Color(red: 1, green: 0.65, blue: 0))
            
            highlight
                .stroke(style: StrokeStyle(lineWidth: self.bWidth() * 0.03, lineCap: .round))
                .fill(Color(red: 1, green: 0.93, blue: 0.47))
                .offset(x: self.bWidth() * (1 - self.topBunRSize.width) * 0.5)
            
            ForEach(0 ..< rPointsX.count, id: \.self) { index in
                SesameSeeds(CGSize(width: self.bWidth() * 0.10, height: self.bHeight() * 0.10))
                    .offset(x: self.bWidth() * rPointsX[index] * self.topBunRSize.width, y: self.bHeight() * rPointsY[index])
            }
            
            SesameSeeds(CGSize(width: self.bWidth() * 0.10, height: self.bHeight() * 0.10), showShadow: false)
                .offset(x: self.bWidth() * 0.3 * self.topBunRSize.width, y: self.bHeight() * 0.2)
            
            shadowPath
                .fill(Color(red: 1, green: 0.56, blue: 0).opacity(0.3))
                .clipShape(self.bun)
                .blendMode(.multiply)
        }
    }
    
    private var sauce: some Shape {
        var path = Path()
        path.move(to: CGPoint(x: self.bWidth() * 0.15, y: self.bHeight() * 0.3))
        path.addQuadCurve(to: CGPoint(x: self.bWidth() * 0.4, y: self.bHeight() * 0.5),
                          control: CGPoint(x: self.bWidth() * 0.2, y: self.bHeight() * 0.5))
        path.addQuadCurve(to: CGPoint(x: self.bWidth() * 0.585, y: self.bHeight() * 0.5),
                          control: CGPoint(x: self.bWidth() * 0.58, y: self.bHeight() * 0.48))
        path.addArc(center: CGPoint(x: self.bWidth() * 0.63, y: self.bHeight() * 0.5),
                    radius: self.bWidth() * 0.045, startAngle: Angle(degrees: 180), endAngle: Angle(degrees: 30), clockwise: true)
        path.addQuadCurve(to: CGPoint(x: self.bWidth() * 0.75, y: self.bHeight() * 0.47),
                          control: CGPoint(x: self.bWidth() * 0.67, y: self.bHeight() * 0.48))
        path.addQuadCurve(to: CGPoint(x: self.bWidth() * 0.8, y: self.bHeight() * 0.4),
                          control: CGPoint(x: self.bWidth() * 0.8, y: self.bHeight() * 0.45))
        path.closeSubpath()
        return path
    }
    
    private func lettuce(scaleX: CGFloat, scaleY: CGFloat) -> some Shape {
        let width = self.bWidth() * scaleX
        let height = self.bHeight() * scaleY
        
        var path = Path()
        path.move(to: CGPoint(x: width * 0.08, y: height * 0.3))
        path.addQuadCurve(to: CGPoint(x: width * 0.13, y: height * 0.46),
                          control: CGPoint(x: width * 0.02, y: height * 0.43))
        path.addQuadCurve(to: CGPoint(x: width * 0.2, y: height * 0.5),
                          control: CGPoint(x: width * 0.2, y: height * 0.47))
        path.addQuadCurve(to: CGPoint(x: width * 0.3, y: height * 0.55),
                          control: CGPoint(x: width * 0.2, y: height * 0.6))
        path.addQuadCurve(to: CGPoint(x: width * 0.4, y: height * 0.55),
                          control: CGPoint(x: width * 0.35, y: height * 0.5))
        path.addQuadCurve(to: CGPoint(x: width * 0.5, y: height * 0.55),
                          control: CGPoint(x: width * 0.45, y: height * 0.6))
        path.addQuadCurve(to: CGPoint(x: width * 0.65, y: height * 0.53),
                          control: CGPoint(x: width * 0.55, y: height * 0.5))
        path.addQuadCurve(to: CGPoint(x: width * 0.8, y: height * 0.48),
                          control: CGPoint(x: width * 0.75, y: height * 0.55))
        path.addQuadCurve(to: CGPoint(x: width * 0.85, y: height * 0.45),
                          control: CGPoint(x: width * 0.83, y: height * 0.45))
        path.addQuadCurve(to: CGPoint(x: width * 0.93, y: height * 0.3),
                          control: CGPoint(x: width, y: height * 0.5))
        return path
    }
    
    private var tomato: some Shape {
        var path = Path()
        path.move(to: CGPoint(x: self.bWidth() * 0.11, y: self.bHeight() * 0.4))
        path.addLine(to: CGPoint(x: self.bWidth() * 0.11, y: self.bHeight() * 0.45))
        path.addQuadCurve(to: CGPoint(x: self.bWidth() * 0.5, y: self.bHeight() * 0.6),
                          control: CGPoint(x: self.bWidth() * 0.11, y: self.bHeight() * 0.6))
        path.addQuadCurve(to: CGPoint(x: self.bWidth() * 0.89, y: self.bHeight() * 0.45),
                          control: CGPoint(x: self.bWidth() * 0.89, y: self.bHeight() * 0.6))
        path.addLine(to: CGPoint(x: self.bWidth() * 0.89, y: self.bHeight() * 0.4))
        path.closeSubpath()
        return path
    }
    
    private var cheese: some View {
        var path = Path()
        path.move(to: CGPoint(x: self.bWidth() * 0.15, y: self.bHeight() * 0.55))
        path.addLine(to: CGPoint(x: self.bWidth() * 0.2, y: self.bHeight() * 0.65))
        path.addLine(to: CGPoint(x: self.bWidth() * 0.3, y: self.bHeight() * 0.8))
        path.addArc(center: CGPoint(x: self.bWidth() * 0.34, y: self.bHeight() * 0.8),
                    radius: self.bWidth() * 0.03, startAngle: Angle(degrees: 135), endAngle: Angle(degrees: 45), clockwise: true)
        path.addLine(to: CGPoint(x: self.bWidth() * 0.5, y: self.bHeight() * 0.7))
        path.addQuadCurve(to: CGPoint(x: self.bWidth() * 0.85, y: self.bHeight() * 0.5),
                          control: CGPoint(x: self.bWidth() * 0.9, y: self.bHeight() * 0.6))
        path.closeSubpath()
        
        var highlight = Path()
        highlight.move(to: CGPoint(x: self.bWidth() * 0.33, y: self.bHeight() * 0.77))
        highlight.addLine(to: CGPoint(x: self.bWidth() * 0.28, y: self.bHeight() * 0.68))
        
        
        return ZStack {
            path.fill(gColor(.dandelion))
            
            highlight
                .stroke(style: StrokeStyle(lineWidth: self.bWidth() * 0.04, lineCap: .round))
                .fill(Color(red: 1, green: 0.93, blue: 0.47))
        }
    }
    
    private var patty: some Shape {
        var path = Path()
        path.move(to: CGPoint(x: self.bWidth() * 0.11, y: self.bHeight() * 0.48))
        path.addQuadCurve(to: CGPoint(x: self.bWidth() * 0.05, y: self.bHeight() * 0.55),
                          control: CGPoint(x: self.bWidth() * 0.08, y: self.bHeight() * 0.48))
        path.addLine(to: CGPoint(x: self.bWidth() * 0.05, y: self.bHeight() * 0.63))
        path.addQuadCurve(to: CGPoint(x: self.bWidth() * 0.5, y: self.bHeight() * 0.78),
                          control: CGPoint(x: self.bWidth() * 0.11, y: self.bHeight() * 0.78))
        path.addQuadCurve(to: CGPoint(x: self.bWidth() * 0.95, y: self.bHeight() * 0.63),
                          control: CGPoint(x: self.bWidth() * 0.89, y: self.bHeight() * 0.78))
        path.addLine(to: CGPoint(x: self.bWidth() * 0.95, y: self.bHeight() * 0.55))
        path.addQuadCurve(to: CGPoint(x: self.bWidth() * 0.89, y: self.bHeight() * 0.48),
                          control: CGPoint(x: self.bWidth() * 0.92, y: self.bHeight() * 0.48))
        path.closeSubpath()
        return path
    }
    
    private var bottomBun: some View {
        var path = Path()
        path.move(to: CGPoint(x: self.bWidth() * 0.08, y: self.bHeight() * 0.65))
        path.addQuadCurve(to: CGPoint(x: self.bWidth() * 0.5, y: self.bHeight() * 0.9),
                          control: CGPoint(x: self.bWidth() * 0.08, y: self.bHeight() * 0.9))
        path.addQuadCurve(to: CGPoint(x: self.bWidth() * 0.92, y: self.bHeight() * 0.65),
                          control: CGPoint(x: self.bWidth() * 0.92, y: self.bHeight() * 0.9))
        return path.fill(Color(red: 1, green: 0.67, blue: 0))
    }
    
    public var body: some View {
        ZStack(alignment: .top) {
            ZStack(alignment: .bottomTrailing) {
                Color.clear
                
                Ellipse()
                    .fill(Color.black.opacity(0.2))
                    .frame(width: self.bWidth() * 0.8, height: self.bHeight() * 0.4)
                    //.shadow(radius: self.bWidth() * 0.05)
            }
            
            self.bottomBun
            Color(red: 1, green: 0.56, blue: 0).opacity(0.5)
                .clipShape(self.patty)
                .offset(x: self.bWidth() * 0.02, y: self.bHeight() * 0.02)
                .mask(self.bottomBun)
                .blendMode(.multiply)
            Color(red: 1, green: 0.56, blue: 0).opacity(0.5)
                .clipShape(self.patty)
                .offset(y: self.bHeight() * 0.05)
                .mask(self.bottomBun)
                .blendMode(.multiply)
            
            Group {
                self.patty
                    .fill(Color(red: 0.82, green: 0.26, blue: 0))
                ZStack {
                    Color.clear
                    
                    Ellipse()
                        .fill(Color.black.opacity(0.3))
                        .frame(width: self.bWidth() * 0.75, height: self.bHeight() * 0.5)
                        .offset(x: self.bWidth() * 0.03, y: self.bHeight() * 0.1)
                }.clipShape(self.patty)
                Color.black.opacity(0.2)
                    .clipShape(self.sauce)
                    .offset(x: self.bWidth() * -0.03, y: self.bHeight() * 0.20)
            }
            
            Group {
                self.cheese
                
                self.sauce
                    .fill(Color.red)
                    .offset(x: self.bWidth() * -0.03, y: self.bHeight() * 0.15)
                
                self.tomato
                    .fill(Color(red: 0.9, green: 0, blue: 0))
                ZStack {
                    Color.clear
                    
                    Rectangle()
                        .fill(Color(red: 0.85, green: 0, blue: 0))
                        .frame(width: self.bWidth() * 0.5)
                        .offset(x: self.bWidth() * 0.08)
                }.clipShape(self.tomato)
                
                self.lettuce(scaleX: 1, scaleY: 1)
                    .fill(Color(red: 0.47, green: 0.78, blue: 0.2))
                Color.black.opacity(0.2)
                    .clipShape(self.lettuce(scaleX: 0.9, scaleY: 0.7))
                    .offset(x: self.bWidth() * 0.05, y: self.bHeight() * 0.12)
                
                self.sauce
                    .fill(Color(red: 1, green: 0.93, blue: 0.47))
                    .offset(x: self.bWidth() * 0.08, y: self.bHeight() * -0.03)
                
                self.topBun
            }
        }.frame(width: self.bWidth(), height: self.bHeight())
    }
}

struct GBurgerOLD_Previews: PreviewProvider {
    static var previews: some View {
        GBurgerOLD()
    }
}
