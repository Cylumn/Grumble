//
//  GrumbleGrubDisplay.swift
//  Grumble
//
//  Created by Allen Chang on 5/17/20.
//  Copyright © 2020 Cylumn, Inc. All rights reserved.
//

import SwiftUI

//MARK: Helper Functions
private func renderingRange(_ gc: GrumbleCookie, _ ggc: GrumbleGrubCookie) -> [Int] {
    if gc.listCount() == 0 {
        return []
    }
    
    let small: Int = max(gc.leadingIndex(), 0)
    let large: Int = min(gc.trailingIndex(), gc.listCount() - 1)
    return (small ... large).filter { !(ggc.appendIndex != $0 && gc.removed.contains($0)) && gc.grub($0) != nil }
}

private func grumbleDragData(_ gc: GrumbleCookie, _ ggc: GrumbleGrubCookie, _ index: Int) -> CGFloat {
    let data: CGFloat = abs(ggc.dragData(.horizontal)) / sWidth()
    
    switch index {
    case gc.leadingIndex(), gc.trailingIndex():
        return (1 - data)
    case gc.index():
        return data
    default:
        return 1
    }
}

private func offsetX(_ gc: GrumbleCookie, _ ggc: GrumbleGrubCookie, _ index: Int) -> CGFloat {
    if index == ggc.appendIndex {
        return 0
    }
    
    let translation: CGFloat = ggc.dragData(.horizontal)
    let accelerateThreshold: CGFloat = 0.5 * sWidth()
    let speedFraction: CGFloat = abs(translation) / sWidth()
    
    let distanceFromThreshold: CGFloat = abs(translation) - accelerateThreshold
    let direction: CGFloat = translation < 0 ? -1 : 1
    
    let smallDistance: CGFloat = min(abs(translation), accelerateThreshold) * direction * speedFraction
    let largeDistance: CGFloat = max(distanceFromThreshold, 0) * direction * (2 - speedFraction)
    
    let leadingIndex: Int = gc.leadingIndex()
    let trailingIndex: Int = gc.trailingIndex()
    switch index {
    case _ where index < leadingIndex:
        return -sWidth()
    case leadingIndex:
        return -sWidth() + smallDistance + largeDistance
    case gc.index():
        return smallDistance + largeDistance
    case trailingIndex:
        return sWidth() + smallDistance + largeDistance
    default:
        return sWidth()
    }
}

private func appendOffsetY(_ ggc: GrumbleGrubCookie, _ index: Int) -> CGFloat {
    return ggc.appendIndex == index ? sHeight() * -0.6 : 0
}

//MARK: Views
public struct GrumbleGrubDisplay: View {
    @ObservedObject private var gc: GrumbleCookie = GrumbleCookie.gc()
    @ObservedObject private var gtc: GrumbleTypeCookie = GrumbleTypeCookie.gtc()
    @ObservedObject private var ggc: GrumbleGrubCookie = GrumbleGrubCookie.ggc()
    private var loadingImage: Image
    
    //MARK: Initializers
    public init() {
        self.loadingImage = Image("LoadingIcon")
    }
    
    //MARK: Getter Methods
    private func coverDragData() -> CGFloat {
        return min(abs(self.gc.coverDrag.height / sHeight()) * 3, 1)
    }
    
    private func offsetY(_ index: Int) -> CGFloat {
        let magnitude: CGFloat = -150
        return grumbleDragData(self.gc, self.ggc, index) * magnitude + min(self.ggc.dragData(.vertical), 0)
    }
    
    private func rotation(_ index: Int) -> Angle {
        let data: CGFloat = self.ggc.dragData(.horizontal) / sWidth()
        let angle: CGFloat = 0.2 * 360
        
        let leadingIndex: Int = self.gc.leadingIndex()
        let trailingIndex: Int = self.gc.trailingIndex()
        switch index {
        case _ where index < leadingIndex:
            return Angle(degrees: Double(-angle))
        case leadingIndex:
            return Angle(degrees: Double(-angle + data * angle))
        case self.gc.index():
            return Angle(degrees: Double(data * angle))
        case trailingIndex:
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
        let size = sWidth() * 0.58
        return gTagView(tag, CGSize(width: size, height: size), idleData: self.gc.idleData,
                        tossData: grumbleDragData(self.gc, self.ggc, index))
    }
    
    public var body: some View {
        //MARK: Transformations
        var coverShadowOpacity: CGFloat = 0.2
        var coverShadowWidth: CGFloat = 0.7
        var coverShadowHeight: CGFloat = 0.23
        var coverShadowOffsetY: CGFloat = 0.35
        
        var grubShadowWidth: CGFloat = 0.3
        var grubShadowHeight: CGFloat = 0.08
        var grubShadowOffsetY: CGFloat = 0.34
        
        var grubOffsetY: CGFloat = 0.31
        var grubScale: CGFloat = 0.3
        
        //CoverDragData
        coverShadowOpacity -= 0.2 * self.coverDragData()
        coverShadowWidth += 0.2 * self.coverDragData()
        coverShadowHeight += 0.2 * self.coverDragData()
        coverShadowOffsetY += 0.05 * self.coverDragData()
        
        grubShadowWidth += 0.1 * self.coverDragData()
        grubShadowHeight += 0.02 * self.coverDragData()
        grubShadowOffsetY += 0.01 * self.coverDragData()
        
        grubOffsetY += 0.0 * self.coverDragData()
        grubScale += 0.1 * self.coverDragData()
        
        //ChooseData
        grubShadowWidth *= 1 + 2 * self.ggc.chooseData
        grubShadowHeight *= 1 + 2 * self.ggc.chooseData
        grubShadowOffsetY += 0.3 * self.ggc.chooseData
        
        grubScale += 0.6 * self.ggc.chooseData
        
        //isX
        coverShadowOffsetY += isX() ? 0.03 : 0
        
        grubOffsetY += isX() ? 0.015 : 0
        
        return ZStack {
            Color.clear
            
            Ellipse()
                .fill(Color.black.opacity(Double(coverShadowOpacity)))
                .frame(width: sWidth() * coverShadowWidth, height: sWidth() * coverShadowHeight)
                .offset(y: sHeight() * coverShadowOffsetY)
            
            ForEach(renderingRange(self.gc, self.ggc), id: \.self) { index in
                ZStack {
                    Ellipse()
                        .fill(Color.black.opacity(Double(0.3 - 0.3 * grumbleDragData(self.gc, self.ggc, index))))
                        .frame(width: sWidth() * grubShadowWidth, height: sWidth() * grubShadowHeight)
                        .offset(x: offsetX(self.gc, self.ggc, index), y: sHeight() * grubShadowOffsetY)
                    
                    self.tagIcon(self.gc.grub(index)!.priorityTag, index: index)
                        .scaleEffect(grubScale)
                        .rotationEffect(self.rotation(index))
                        .offset(x: offsetX(self.gc, self.ggc, index),
                                y: sHeight() * grubOffsetY + self.offsetY(index) + self.chooseOffsetY() + appendOffsetY(self.ggc, index))
                }
            }.transition(.identity)
            
            if self.gc.coverDragState == .completed && self.gc.index() >= self.gc.listCount() - 1 {
                if self.gtc.type == .grumble {
                    Text("[EmptyGrub]")
                        .rotationEffect(self.rotation(self.gc.listCount()))
                        .offset(x: offsetX(self.gc, self.ggc, self.gc.listCount()),
                                y: sHeight() * grubOffsetY + self.offsetY(self.gc.listCount()) + self.chooseOffsetY())
                } else {
                    self.loadingImage
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: sWidth() * (0.5 + 0.2 * self.gc.idleData))
                        .offset(x: offsetX(self.gc, self.ggc, self.gc.listCount()),
                                y: sHeight() * 0.1)
                        .transition(AnyTransition.asymmetric(insertion: .scale(scale: 1, anchor: .center), removal: .identity))
                    
                    Text(".. Loading ..")
                    .font(gFont(.ubuntuBold, .width, 3))
                    .rotationEffect(self.rotation(self.gc.listCount()))
                    .offset(x: offsetX(self.gc, self.ggc, self.gc.listCount()),
                            y: sHeight() * grubOffsetY + self.offsetY(self.gc.listCount()) + self.chooseOffsetY())
                    .transition(AnyTransition.asymmetric(insertion: .opacity, removal: .identity))
                    .shadow(color: Color.black.opacity(0.5), radius: 3)
                }
            }
        }//.drawingGroup()
    }
}

public struct GrumbleGrubImageDisplay: View {
    private static var cachedImages: [String: AnyView] = [:]
    @ObservedObject private var gc: GrumbleCookie = GrumbleCookie.gc()
    @ObservedObject private var ggc: GrumbleGrubCookie = GrumbleGrubCookie.ggc()
    @GestureState(initialValue: CGFloat(0), resetTransaction: Transaction(animation: gAnim(.springSlow))) private var holdData
    
    //MARK: Getter Methods
    private func offsetY(_ index: Int) -> CGFloat {
        return self.gc.index() == index ? min(self.ggc.dragData(.vertical), 0) : 0
    }
    
    //MARK: Function Methods
    public static func cacheImage(_ key: String, value: Image?) {
        GrumbleGrubImageDisplay.cachedImages[key] =
            AnyView(value?
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: sWidth() * 0.9))
    }
    
    private func imageItem(_ grub: Grub, index: Int) -> some View {
        if GrumbleGrubImageDisplay.cachedImages[grub.imgPath()] == nil {
            GrumbleGrubImageDisplay.cacheImage(grub.img, value: grub.image())
        }
        return VStack(spacing: 0) {
            GrumbleGrubImageDisplay.cachedImages[grub.imgPath()]!
                .cornerRadius(0)
            
            if self.gc.index() == index && self.ggc.expandedInfo {
                Text(grub.food)
                    .padding(10)
                    .background(Color.white)
                    .cornerRadius(5)
                    .shadow(color: Color.black.opacity(0.3), radius: 5)
                    .font(gFont(.ubuntuBold, .width, 3))
                    .foregroundColor(Color(white: 0.3))
                    .offset(y: -25)
                    .zIndex(1)
                    .transition(AnyTransition.move(edge: .bottom).combined(with: .opacity))
            }
            
            if self.gc.index() == index {
                VStack(spacing: 0) {
                    if self.ggc.expandedInfo {
                        VStack(spacing: 10) {
                            if grub.restaurant != nil || grub.price != nil {
                                HStack {
                                    if grub.restaurant != nil {
                                        Text(grub.restaurant!)
                                    }
                                    
                                    if grub.restaurant != nil && grub.price != nil {
                                        Spacer()
                                    }
                                    
                                    if grub.price != nil {
                                        Text("$" + String(format:"%.2f", grub.price!))
                                    }
                                }.padding([.leading, .trailing], 40)
                                .font(gFont(.ubuntuBold, .width, 2.3))
                                .foregroundColor(Color(white: 0.3))
                                
                                Divider()
                                    .frame(width: sWidth() * 0.5, height: 1)
                                    .background(Color(white: 0.2))
                                    .padding(.top, 5)
                                    .padding(.bottom, 20)
                            }
                            
                            Group {
                                Button(action: {}, label: {
                                    Text("Show More Information")
                                        .padding(10)
                                        .font(gFont(.ubuntuMedium, .width, 2))
                                        .onTapGesture {
                                            withAnimation(gAnim(.easeOut)) {
                                                ListCookie.lc().selectedGrub = self.gc.grub()
                                            }
                                        }
                                }).background(Color.white)
                                .foregroundColor(gTagColors[grub.priorityTag])
                                .cornerRadius(5)
                                
                                Button(action: {}, label: {
                                    Text("Bon Appetit!")
                                        .padding(10)
                                        .font(gFont(.ubuntuMedium, .width, 2.5))
                                        .onTapGesture {
                                            self.ggc.choose()
                                        }
                                }).background(gTagColors[grub.priorityTag])
                                .foregroundColor(Color.white)
                                .cornerRadius(5)
                            }.shadow(color: Color.black.opacity(0.2), radius: 3)
                        }.offset(y: -15)
                        .padding([.top, .bottom], 10)
                        .transition(AnyTransition.move(edge: .top).combined(with: .opacity))
                    } else {
                        EmptyView()
                    }
                }.frame(maxWidth: .infinity)
                .zIndex(-1)
                .transition(.identity)
            }
        }.frame(width: sWidth() * 0.9)
        .background(Color(white: 0.98).opacity(self.ggc.expandedInfo ? 1 : 0).transition(.scale(scale: 1)))
        .cornerRadius(10)
    }
    
    public var body: some View {
        ForEach(renderingRange(self.gc, self.ggc), id: \.self) { index in
            self.imageItem(self.gc.grub(index)!, index: index)
                .scaleEffect(1 - 0.4 * grumbleDragData(self.gc, self.ggc, index))
                .offset(x: offsetX(self.gc, self.ggc, index), y: self.offsetY(index) + appendOffsetY(self.ggc, index))
        }.transition(.identity)
        .position(x: sWidth() * 0.5, y: sHeight() * (self.ggc.expandedInfo ? 0.45 : 0.35))
        .zIndex(1)
    }
}

struct GrumbleGrubDisplay_Previews: PreviewProvider {
    static var previews: some View {
        GrumbleGrubDisplay()
    }
}
