//
//  GhorblinSheet.swift
//  Grumble
//
//  Created by Allen Chang on 4/17/20.
//  Copyright © 2020 Cylumn, Inc. All rights reserved.
//

import SwiftUI

private enum Cavity {
    case up
    case down
}

private enum GSAnimatableData {
    case drip
    case idle
    case hold
}

private func curveTo(path: inout Path, _ firstTangentAxis: GAxis, to: CGPoint, radius: CGFloat){
    let from = path.currentPoint!
    
    switch firstTangentAxis {
    case .horizontal:
        path.addArc(tangent1End: CGPoint(x: to.x, y: from.y), tangent2End: to, radius: radius)
    case .vertical:
        path.addArc(tangent1End: CGPoint(x: from.x, y: to.y), tangent2End: to, radius: radius)
    }
}

private func semiCircle(path: inout Path, _ cavity: Cavity, to: CGPoint, radius: CGFloat) {
    let from = path.currentPoint!
    var direction: CGFloat = 0
    switch cavity {
    case .up:
        direction = 1
    case .down:
        direction = -1
    }
    
    curveTo(path: &path, .vertical, to: CGPoint(x: (to.x - from.x) * 0.5 + from.x, y: to.y + direction * radius), radius: radius)
    curveTo(path: &path, .horizontal, to: to, radius: radius)
}

private func dripPattern(path: inout Path, firstCavity: Cavity, originalHeights: [CGFloat], finalHeights: [CGFloat], animatableData: CGFloat, radius: CGFloat) {
    var cavity = firstCavity
    for index in 0 ..< originalHeights.count {
        let height = originalHeights[index] + (finalHeights[index] - originalHeights[index]) * animatableData
        path.addLine(to: CGPoint(x: path.currentPoint!.x, y: height))
        semiCircle(path: &path, cavity, to: CGPoint(x: path.currentPoint!.x + radius * 2, y: height), radius: radius)
        
        switch cavity {
        case .up:
            cavity = .down
        case .down:
            cavity = .up
        }
    }
}

private func foodCover(path: inout Path, start: CGPoint, width: CGFloat, scaleX: CGFloat, hold: CGFloat) {
    path.addArc(center: CGPoint(x: start.x, y: start.y), radius: 10, startAngle: Angle(degrees: -90), endAngle: Angle(degrees: 90), clockwise: true)
    
    let cover = CGPoint(x: start.x, y: start.y + 15)
    path.addLine(to: CGPoint(x: start.x, y: cover.y))
    path.addQuadCurve(to: CGPoint(x: cover.x - 75 * scaleX, y: cover.y + 100),
                      control: CGPoint(x: cover.x - 75 * scaleX, y: cover.y + 10))
    path.addLine(to: CGPoint(x: cover.x - 75 * scaleX, y: cover.y + 100 - 2))
    path.addArc(center: CGPoint(x: cover.x - 75 * scaleX, y: cover.y + 100), radius: 2,
                startAngle: Angle(degrees: -90), endAngle: Angle(degrees: 180), clockwise: true)
    path.addQuadCurve(to: CGPoint(x: cover.x + width * 0.5, y: cover.y + 130),
                      control: CGPoint(x: cover.x - 85 * scaleX, y: cover.y + 130))
    path.addQuadCurve(to: CGPoint(x: cover.x + 75 * scaleX + 2 + width, y: cover.y + 100),
                      control: CGPoint(x: cover.x + 85 * scaleX + width, y: cover.y + 130))
    path.addArc(center: CGPoint(x: cover.x + 75 * scaleX + width, y: cover.y + 100), radius: 2,
                startAngle: Angle(degrees: 0), endAngle: Angle(degrees: -90), clockwise: true)
    path.addLine(to: CGPoint(x: cover.x + 75 * scaleX + width, y: cover.y + 100))
    path.addQuadCurve(to: CGPoint(x: cover.x + width, y: cover.y),
                      control: CGPoint(x: cover.x + 75 * scaleX + width, y: cover.y + 10))
    path.addLine(to: CGPoint(x: start.x + width, y: start.y + 10))
    
    path.addArc(center: CGPoint(x: start.x + width, y: start.y), radius: 10,
                startAngle: Angle(degrees: 90), endAngle: Angle(degrees: -90), clockwise: true)
}

private func ghorblinStomach(path: inout Path, start: CGPoint, scale: CGFloat, hold: CGFloat) {
    path.addQuadCurve(to: CGPoint(x: start.x + 30, y: start.y + 25),
                      control: CGPoint(x: start.x, y: start.y + 25))
    path.addLine(to: CGPoint(x: start.x + 30, y: start.y + 80))
    path.addQuadCurve(to: CGPoint(x: start.x - 45 + 5 * scale, y: start.y + 115),
                      control: CGPoint(x: start.x - 45 + 5 * scale, y: start.y + 60))
    path.addQuadCurve(to: CGPoint(x: start.x - 10 + 5 * scale, y: start.y + 158 - 5 * scale),
                      control: CGPoint(x: start.x - 45 + 5 * scale, y: start.y + 158 - 5 * scale))
    path.addQuadCurve(to: CGPoint(x: start.x + 20, y: start.y + 150),
                      control: CGPoint(x: start.x + 10, y: start.y + 157 - 5 * scale))
    path.addArc(center: CGPoint(x: start.x + 15, y: start.y + 170 - 5 * scale), radius: 20 - 5 * scale,
                startAngle: Angle(degrees: -90), endAngle: Angle(degrees: 90), clockwise: false)
    
    let width: CGFloat = 21
    path.addArc(center: CGPoint(x: start.x - 27, y: start.y + 210 - 10 * scale), radius: 20,
                startAngle: Angle(degrees: -90), endAngle: Angle(degrees: 180), clockwise: true)
    path.addLine(to: CGPoint(x: start.x - 47, y: start.y + 220))
    foodCover(path: &path, start: CGPoint(x: start.x - 47, y: start.y + 220 - 5 * scale + 30 * (1 - hold)), width: width, scaleX: 1.4 - 0.1 * scale - 0.2 * hold, hold: hold)
    path.addArc(center: CGPoint(x: start.x - 47 + width + 10, y: start.y + 210 - 5 * scale),
                radius: 10, startAngle: Angle(degrees: 180), endAngle: Angle(degrees: -90), clockwise: false)
    path.addLine(to: CGPoint(x: start.x + 30, y: start.y + 200 - 5 * scale))
    
    path.addArc(center: CGPoint(x: start.x + 20, y: start.y + 160), radius: 40 - 5 * scale,
                startAngle: Angle(degrees: 90), endAngle: Angle(degrees: -90), clockwise: true)
    path.addQuadCurve(to: CGPoint(x: start.x + 117 + 5 * scale, y: start.y + 65 - 2.5 * scale),
                      control: CGPoint(x: start.x + 105, y: start.y + 130))
    path.addQuadCurve(to: CGPoint(x: start.x + 135 + 5 * scale, y: start.y + 30),
                      control: CGPoint(x: start.x + 135, y: start.y + 62))
    path.addQuadCurve(to: CGPoint(x: start.x + 115, y: start.y - 10),
                      control: CGPoint(x: start.x + 140, y: start.y - 10))
    path.addArc(center: CGPoint(x: start.x + 75, y: start.y + 10), radius: 50 + 5 * scale,
                startAngle: Angle(degrees: 0), endAngle: Angle(degrees: -135), clockwise: true)
}

private func ghorblinLogo(path: inout Path, start: CGPoint, dripRadius: CGFloat, scale: CGFloat, hold: CGFloat) {
    path.addQuadCurve(to: CGPoint(x: start.x + 50, y: start.y + 30),
                      control: CGPoint(x: start.x + 30, y: start.y + 45))
    path.addArc(center: CGPoint(x: start.x + 72, y: start.y + 47), radius: 27,
                startAngle: Angle(degrees: 230), endAngle: Angle(degrees: 0), clockwise: false)
    path.addArc(center: CGPoint(x: start.x + 72 - 2 * scale, y: start.y + 90), radius: 27 + 2 * scale,
                startAngle: Angle(degrees: 0), endAngle: Angle(degrees: -180), clockwise: false)
    path.addLine(to: CGPoint(x: start.x + 45 - 4 * scale, y: start.y + 80))
    path.addLine(to: CGPoint(x: start.x + 55, y: start.y + 80))
    path.addArc(center: CGPoint(x: start.x + 55, y: start.y + 70), radius: 10,
                startAngle: Angle(degrees: 90), endAngle: Angle(degrees: -90), clockwise: true)
    path.addArc(center: CGPoint(x: start.x + 35, y: start.y + 70), radius: 10,
                startAngle: Angle(degrees: -90), endAngle: Angle(degrees: 180), clockwise: true)
    path.addArc(center: CGPoint(x: start.x + 13 - 2 * hold, y: start.y + 130), radius: 35 - 2 * scale + 6 * hold,
                startAngle: Angle(degrees: -70), endAngle: Angle(degrees: 50), clockwise: true)
    path.addArc(center: CGPoint(x: start.x + 49 - 5 * scale - 4 * hold, y: start.y + 167 - 4 * scale + 5 * hold), radius: 10 - 3 * scale,
                startAngle: Angle(degrees: -90), endAngle: Angle(degrees: 0), clockwise: false)
    
    path.addArc(center: CGPoint(x: start.x + 65 - 8 * scale - 4 * hold, y: start.y + 182), radius: 6 - 1 * scale,
                startAngle: Angle(degrees: -180), endAngle: Angle(degrees: 0), clockwise: true)
    
    path.addArc(center: CGPoint(x: start.x + 45 - 5 * scale - 4 * hold, y: start.y + 170 - 6 * scale + 3 * hold), radius: 26 - 4 * scale,
                startAngle: Angle(degrees: 0), endAngle: Angle(degrees: -90), clockwise: true)
    path.addQuadCurve(to: CGPoint(x: start.x + 30 - 2 * scale, y: start.y + 144 - 2 * scale + 3 * hold),
                      control: CGPoint(x: start.x + 40, y: start.y + 144 - 2 * scale + 3 * hold))
    path.addArc(center: CGPoint(x: start.x + 13 - 2 * hold, y: start.y + 130), radius: 20 - 2 * scale + 3 * hold,
                startAngle: Angle(degrees: 50), endAngle: Angle(degrees: Double(-30 + 5 * hold)), clockwise: false)
    path.addArc(center: CGPoint(x: start.x + 22, y: start.y + 126), radius: 6,
                startAngle: Angle(degrees: -90), endAngle: Angle(degrees: 90), clockwise: true)
    path.addLine(to: CGPoint(x: start.x + 35, y: start.y + 132))
    path.addQuadCurve(to: CGPoint(x: start.x + 45, y: start.y + 133),
                      control: CGPoint(x: start.x + 40, y: start.y + 132))
    path.addArc(center: CGPoint(x: start.x + 72, y: start.y + 90), radius: 50,
                startAngle: Angle(degrees: 120), endAngle: Angle(degrees: 0), clockwise: true)
    path.addArc(center: CGPoint(x: start.x + 122, y: start.y + 60), radius: 20,
                startAngle: Angle(degrees: 90), endAngle: Angle(degrees: 0), clockwise: true)
    path.addArc(center: CGPoint(x: start.x + 122, y: start.y + 40), radius: 20,
                startAngle: Angle(degrees: 0), endAngle: Angle(degrees: -100), clockwise: true)
    path.addArc(center: CGPoint(x: start.x + 72, y: start.y + 45), radius: 53,
                startAngle: Angle(degrees: -30), endAngle: Angle(degrees: -130), clockwise: true)
}

public struct GhorblinSheet: Shape {
    private static let blueOrig: [[CGFloat]] = [[215, 105, 205, 125, 235, 165, 175, 105], [55, 85, 75, 100]]
    private static let blueFinal: [[CGFloat]] = [[220, 135, 155, 145, 255, 160, 185, 125], [75, 95, 85, 130]]
    private let dripRadius: CGFloat = 15
    
    public var animatableData: AnimatablePair<AnimatablePair<CGFloat, CGFloat>, CGFloat>
    
    public init(drip: CGFloat, idleScale: CGFloat, hold: CGFloat) {
        self.animatableData = AnimatablePair(AnimatablePair(drip, idleScale), hold)
    }
    
    private func data(_ data: GSAnimatableData) -> CGFloat {
        switch data {
        case .drip:
            return self.animatableData.first.first
        case .idle:
            return self.animatableData.first.second
        case .hold:
            return self.animatableData.second
        }
    }
    
    //Shape Method Implementation
    public func path(in rect: CGRect) -> Path {
        var dripPath = Path()
        
        //Before Ghorblin
        dripPath.move(to: CGPoint(x: -dripRadius, y: 0))
        dripPattern(path: &dripPath, firstCavity: .up, originalHeights: GhorblinSheet.blueOrig[0], finalHeights: GhorblinSheet.blueFinal[0], animatableData: self.data(.drip), radius: self.dripRadius)
        let tubeX = dripPath.currentPoint!.x //225
        dripPath.addLine(to: CGPoint(x: tubeX, y: 170))
        ghorblinStomach(path: &dripPath, start: CGPoint(x: tubeX, y: 170 + 10 * self.data(.hold)), scale: self.data(.idle), hold: self.data(.hold))
        
        //After Ghorblin
        dripPath.addLine(to: CGPoint(x: tubeX + self.dripRadius * 2, y: 150))
        dripPattern(path: &dripPath, firstCavity: .down, originalHeights: GhorblinSheet.blueOrig[1], finalHeights: GhorblinSheet.blueFinal[1], animatableData: self.data(.drip), radius: self.dripRadius)
        dripPath.addLine(to: CGPoint(x: 375, y: 0))
        dripPath.closeSubpath()
        
        return dripPath
    }
}

public struct GhorblinSheetOverlay: Shape {
    private static let highlightsOrig: [[CGFloat]] = [[55, 125, 85, 145, 60, 85, 75], [35, 85, 55, 105, 50]]
    private static let highlightsFinal: [[CGFloat]] = [[85, 215, 95, 115, 45, 145, 75], [55, 105, 65, 80, 75]]
    private let dripRadius: CGFloat = 15
    
    public var animatableData: AnimatablePair<AnimatablePair<CGFloat, CGFloat>, CGFloat>
    
    public init(drip: CGFloat, idleScale: CGFloat, hold: CGFloat) {
        self.animatableData = AnimatablePair(AnimatablePair(drip, idleScale), hold)
    }
    
    private func data(_ data: GSAnimatableData) -> CGFloat {
        switch data {
        case .drip:
            return self.animatableData.first.first
        case .idle:
            return self.animatableData.first.second
        case .hold:
            return self.animatableData.second
        }
    }
    
    public func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        dripPattern(path: &path, firstCavity: .down, originalHeights: GhorblinSheetOverlay.highlightsOrig[0], finalHeights: GhorblinSheetOverlay.highlightsFinal[0], animatableData: self.data(.drip), radius: self.dripRadius)
        let tubeX = path.currentPoint!.x //210
        path.addLine(to: CGPoint(x: tubeX, y: 150))
        
        path.addQuadCurve(to: CGPoint(x: tubeX + 10, y: 180),
                          control: CGPoint(x: tubeX, y: 170))
        ghorblinLogo(path: &path, start: CGPoint(x: 210 + 5 * self.data(.idle), y: 150 - 5 * self.data(.idle) + 3 * self.data(.hold)), dripRadius: self.dripRadius, scale: self.data(.idle), hold: self.data(.hold))
        
        path.addQuadCurve(to: CGPoint(x: tubeX + self.dripRadius * 2, y: 140),
                          control: CGPoint(x: tubeX + self.dripRadius * 2, y: 160))
        path.addLine(to: CGPoint(x: tubeX + self.dripRadius * 2, y: 140))
        dripPattern(path: &path, firstCavity: .down, originalHeights: GhorblinSheetOverlay.highlightsOrig[1], finalHeights: GhorblinSheetOverlay.highlightsFinal[1], animatableData: self.data(.drip), radius: self.dripRadius)
        path.addLine(to: CGPoint(x: 375, y: 0))
        path.closeSubpath()
        
        var ghroblinGapMask = Path()
        ghroblinGapMask.addArc(center: CGPoint(x: 332 + 7 * self.data(.idle), y: 195 - 7 * self.data(.idle)), radius: 10, startAngle: Angle(degrees: -95), endAngle: Angle(degrees: 0), clockwise: false)
        ghroblinGapMask.addArc(center: CGPoint(x: 332 + 7 * self.data(.idle), y: 205 - 7 * self.data(.idle)), radius: 10, startAngle: Angle(degrees: 0), endAngle: Angle(degrees: 90), clockwise: false)
        path.addPath(ghroblinGapMask)
        
        path.addRoundedRect(in: CGRect(x: 215 - 13 * self.data(.idle), y: 355 + 8 * self.data(.hold), width: 40 + 10 * self.data(.idle), height: 7 - 2 * self.data(.idle)), cornerSize: CGSize(width: 3, height: 10))
        path.addRoundedRect(in: CGRect(x: 176 + 2 * self.data(.idle), y: 372 - 3 * self.data(.idle), width: 10, height: 20), cornerSize: CGSize(width: 5, height: 5))
        
        var xT: CGFloat = 18 + 1 * self.data(.idle) + 5 * self.data(.hold)
        var yT: CGFloat = 0 - 3 * self.data(.idle) + 20 * (1 - self.data(.hold))
        path.move(to: CGPoint(x: 70 + xT, y: 500 + yT))
        path.addQuadCurve(to: CGPoint(x: 92 + xT, y: 451 + yT),
                          control: CGPoint(x: 75 + xT, y: 460 + yT))
        path.addArc(center: CGPoint(x: 95 + xT, y: 455 + yT), radius: 5,
                    startAngle: Angle(degrees: -135), endAngle: Angle(degrees: 45), clockwise: false)
        path.addQuadCurve(to: CGPoint(x: 80 + xT, y: 500 + yT),
                          control: CGPoint(x: 83 + xT, y: 470 + yT))
        path.addArc(center: CGPoint(x: 75 + xT, y: 500 + yT), radius: 5,
                    startAngle: Angle(degrees: 0), endAngle: Angle(degrees: 180), clockwise: false)
        path.closeSubpath()
        
        xT = 3 - 3 * self.data(.idle) - 15 * self.data(.hold)
        yT = -10 - 5 * self.data(.idle) + 20 * (1 - self.data(.hold)) + 10 * self.data(.hold)
        path.move(to: CGPoint(x: 287 + xT, y: 515 + yT))
        path.addQuadCurve(to: CGPoint(x: 208 + xT, y: 530 + yT), control: CGPoint(x: 268 + xT, y: 528 + yT))
        path.addArc(center: CGPoint(x: 203 + xT, y: 535 + yT), radius: 5, startAngle: Angle(degrees: -90), endAngle: Angle(degrees: 90), clockwise: true)
        path.addQuadCurve(to: CGPoint(x: 293 + xT, y: 523 + yT), control: CGPoint(x: 263 + xT, y: 540 + yT))
        path.addArc(center: CGPoint(x: 290 + xT, y: 519 + yT), radius: 5, startAngle: Angle(degrees: 120), endAngle: Angle(degrees: -120), clockwise: true)
        
        xT = 18 + 2 * self.data(.idle) - 10 * self.data(.hold)
        yT = 10 - 5 * self.data(.idle) + 30 * (1 - self.data(.hold))
        path.move(to: CGPoint(x: 183 + xT, y: 439 + yT))
        path.addQuadCurve(to: CGPoint(x: 215 + xT, y: 460 + yT), control: CGPoint(x: 195 + xT, y: 445 + yT))
        path.addArc(center: CGPoint(x: 225 + xT, y: 455 + yT), radius: 10, startAngle: Angle(degrees: 135), endAngle: Angle(degrees: 0), clockwise: true)
        path.addQuadCurve(to: CGPoint(x: 200 + xT, y: 415 + yT), control: CGPoint(x: 225 + xT, y: 420 + yT))
        path.addArc(center: CGPoint(x: 195 + xT, y: 430 + yT), radius: 15, startAngle: Angle(degrees: -90), endAngle: Angle(degrees: 135), clockwise: true)
        
        path.addRoundedRect(in: CGRect(x: 176 - 50 * self.data(.idle) - 20 * self.data(.hold), y: 522 + 20 * (1 - self.data(.hold)), width: 10, height: 20), cornerSize: CGSize(width: 5, height: 5), transform: CGAffineTransform(rotationAngle: -0.2 - 0.1 * self.data(.idle)))
        
        return path
    }
}

struct GhorblinSheet_Previews: PreviewProvider {
    static var previews: some View {
        GrumbleSheet(Binding.constant(true), Grub.testGrub(), .classic)
    }
}
