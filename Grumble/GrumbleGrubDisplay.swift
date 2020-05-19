//
//  GrumbleGrubDisplay.swift
//  Grumble
//
//  Created by Allen Chang on 5/17/20.
//  Copyright © 2020 Cylumn, Inc. All rights reserved.
//

import SwiftUI

public struct GrumbleGrubDisplay: View {
    @ObservedObject private var gc: GrumbleCookie = GrumbleCookie.gc()
    @ObservedObject private var ggc: GrumbleGrubCookie = GrumbleGrubCookie.ggc()
    
    //MARK: Getter Methods
    private func renderingRange() -> [Int] {
        if self.gc.fidList.count == 0 {
            return []
        }
        
        let small: Int = max(self.gc.fidIndex - 1, 0)
        let large: Int = min(self.gc.fidIndex + 1, self.gc.fidList.count - 1)
        return (small ... large).filter { self.gc.grub($0) != nil }
    }
    
    private func coverDragData() -> CGFloat {
        return min(abs(self.gc.coverDrag.height / sHeight()) * 3, 1)
    }
    
    private func grumbleDragData(_ index: Int) -> CGFloat {
        let data: CGFloat = abs(self.ggc.grumbleDrag.width) / sWidth()
        
        switch index {
        case self.gc.fidIndex - 1, self.gc.fidIndex + 1:
            return (1 - data)
        case self.gc.fidIndex:
            return data
        default:
            return 1
        }
    }
    
    private func offsetX(_ index: Int) -> CGFloat {
        let translation: CGFloat = self.ggc.grumbleDrag.width
        let accelerateThreshold: CGFloat = 0.5 * sWidth()
        let speedFraction: CGFloat = abs(translation) / sWidth()
        
        let distanceFromThreshold: CGFloat = abs(translation) - accelerateThreshold
        let direction: CGFloat = translation < 0 ? -1 : 1
        
        let smallDistance: CGFloat = min(abs(translation), accelerateThreshold) * direction * speedFraction
        let largeDistance: CGFloat = max(distanceFromThreshold, 0) * direction * (2 - speedFraction)
        
        switch index {
        case _ where index < self.gc.fidIndex - 1:
            return -sWidth()
        case self.gc.fidIndex - 1:
            return -sWidth() + smallDistance + largeDistance
        case self.gc.fidIndex:
            return smallDistance + largeDistance
        case self.gc.fidIndex + 1:
            return sWidth() + smallDistance + largeDistance
        default:
            return sWidth()
        }
    }
    
    private func offsetY(_ index: Int) -> CGFloat {
        let magnitude: CGFloat = -150
        return self.grumbleDragData(index) * magnitude
    }
    
    private func rotation(_ index: Int) -> Angle {
        let data: CGFloat = self.ggc.grumbleDrag.width / sWidth()
        let angle: CGFloat = 0.2 * 360
        
        switch index {
        case _ where index < self.gc.fidIndex - 1:
            return Angle(degrees: Double(-angle))
        case self.gc.fidIndex - 1:
            return Angle(degrees: Double(-angle + data * angle))
        case self.gc.fidIndex:
            return Angle(degrees: Double(data * angle))
        case self.gc.fidIndex + 1:
            return Angle(degrees: Double(angle + data * angle))
        default:
            return Angle(degrees: Double(angle))
        }
    }
    
    private func chooseOffsetY() -> CGFloat {
        let dataFraction: CGFloat = 0.3
        let smallHeight: CGFloat = min(self.ggc.chooseData, dataFraction) * sHeight() * -0.2
        let largeHeight: CGFloat = max(self.ggc.chooseData - dataFraction, 0) * sHeight()
        return smallHeight + largeHeight
    }
    
    //MARK: Subviews
    private func tagIcon(_ tag: GrubTag, index: Int) -> some View {
        let size = sWidth() * 0.18
        return gTagView(tag, CGSize(width: size, height: size), idleData: self.gc.idleData, tossData: self.grumbleDragData(index))
    }
    
    public var body: some View {
        //MARK: Transformations
        var coverShadowOpacity: CGFloat = 0.2
        var coverShadowWidth: CGFloat = 0.7
        var coverShadowHeight: CGFloat = 0.23
        var coverShadowOffsetY: CGFloat = -0.09
        
        var grubShadowWidth: CGFloat = 0.3
        var grubShadowHeight: CGFloat = 0.08
        var grubShadowOffsetY: CGFloat = -0.08
        
        var grubOffsetY: CGFloat = -0.12
        var grubScale: CGFloat = 1.0
        
        //CoverDragData
        coverShadowOpacity -= 0.2 * self.coverDragData()
        coverShadowWidth += 0.2 * self.coverDragData()
        coverShadowHeight += 0.2 * self.coverDragData()
        coverShadowOffsetY += 0.05 * self.coverDragData()
        
        grubShadowWidth += 0.1 * self.coverDragData()
        grubShadowHeight += 0.02 * self.coverDragData()
        grubShadowOffsetY += 0.055 * self.coverDragData()
        
        grubOffsetY += 0.065 * self.coverDragData()
        grubScale += 0.2 * self.coverDragData()
        
        //ChooseData
        grubShadowWidth *= 1 + 2 * self.ggc.chooseData
        grubShadowHeight *= 1 + 2 * self.ggc.chooseData
        grubShadowOffsetY += 0.3 * self.ggc.chooseData
        
        grubScale += 2 * self.ggc.chooseData
        
        //isX
        coverShadowOffsetY += isX() ? 0.03 : 0
        
        grubOffsetY += isX() ? 0.015 : 0
        
        return ZStack {
            Ellipse()
                .fill(Color.black.opacity(Double(coverShadowOpacity)))
                .frame(width: sWidth() * coverShadowWidth, height: sWidth() * coverShadowHeight)
                .offset(y: sHeight() * coverShadowOffsetY)
            
            ForEach(self.renderingRange(), id: \.self) { index in
                ZStack {
                    Ellipse()
                        .fill(Color.black.opacity(Double(0.3 - 0.3 * self.grumbleDragData(index))))
                        .frame(width: sWidth() * grubShadowWidth, height: sWidth() * grubShadowHeight)
                        .offset(x: self.offsetX(index), y: sHeight() * grubShadowOffsetY)
                    
                    self.tagIcon(self.gc.grub(index)!.priorityTag, index: index)
                        .rotationEffect(self.rotation(index))
                        .offset(x: self.offsetX(index),
                                y: sHeight() * grubOffsetY + self.offsetY(index) + self.chooseOffsetY())
                        .scaleEffect(grubScale)
                }
            }.transition(.identity)
        }
    }
}

struct GrumbleGrubDisplay_Previews: PreviewProvider {
    static var previews: some View {
        GrumbleGrubDisplay()
    }
}
