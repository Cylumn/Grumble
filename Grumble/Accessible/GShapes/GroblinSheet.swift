//
//  GroblinSheet.swift
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

public struct GhorblinSheet: Shape {
    private static let blueOrig: [[CGFloat]] = [[155, 45, 85, 25, 105, 45, 65, 55], [35, 85, 75, 100]]
    private static let blueFinal: [[CGFloat]] = [[215, 95, 115, 45, 145, 75, 95, 65], [95, 115, 95, 130]]
    private let dripRadius: CGFloat = 15
    
    public var animatableData: CGFloat = 0
    
    public init(animatableData: CGFloat) {
        self.animatableData = animatableData
    }
    
    //Shape Method Implementation
    public func path(in rect: CGRect) -> Path {
        var dripPath = Path()
        
        //Before Groblin
        dripPath.move(to: CGPoint(x: -dripRadius, y: 0))
        dripPattern(path: &dripPath, firstCavity: .up, originalHeights: GhorblinSheet.blueOrig[0], finalHeights: GhorblinSheet.blueFinal[0], animatableData: self.animatableData, radius: self.dripRadius)
        let dripTube: CGPoint = dripPath.currentPoint!
        dripPath.addLine(to: CGPoint(x: dripTube.x, y: 185))
        
        
        //After Groblin
        dripPath.addLine(to: CGPoint(x: dripTube.x + self.dripRadius * 2, y: 185))
        dripPattern(path: &dripPath, firstCavity: .down, originalHeights: GhorblinSheet.blueOrig[1], finalHeights: GhorblinSheet.blueFinal[1], animatableData: self.animatableData, radius: self.dripRadius)
        dripPath.addLine(to: CGPoint(x: 375, y: 0))
        dripPath.closeSubpath()
        
        return dripPath
    }
}

struct GroblinSheet_Previews: PreviewProvider {
    static var previews: some View {
        GrumbleSheet(Grub.testGrub())
    }
}
