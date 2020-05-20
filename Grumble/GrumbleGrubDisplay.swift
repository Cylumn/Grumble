//
//  GrumbleGrubDisplay.swift
//  Grumble
//
//  Created by Allen Chang on 5/17/20.
//  Copyright © 2020 Cylumn, Inc. All rights reserved.
//

import SwiftUI

//MARK: Helper Functions
private func renderingRange(_ gc: GrumbleCookie) -> [Int] {
    if gc.fidList.count == 0 {
        return []
    }
    
    let small: Int = max(gc.fidIndex - 1, 0)
    let large: Int = min(gc.fidIndex + 1, gc.fidList.count - 1)
    return (small ... large).filter { gc.grub($0) != nil }
}

private func grumbleDragData(_ gc: GrumbleCookie, _ ggc: GrumbleGrubCookie, _ index: Int) -> CGFloat {
    let data: CGFloat = abs(ggc.grumbleDrag.width) / sWidth()
    
    switch index {
    case gc.fidIndex - 1, gc.fidIndex + 1:
        return (1 - data)
    case gc.fidIndex:
        return data
    default:
        return 1
    }
}

private func offsetX(_ gc: GrumbleCookie, _ ggc: GrumbleGrubCookie, _ index: Int) -> CGFloat {
    let translation: CGFloat = ggc.grumbleDrag.width
    let accelerateThreshold: CGFloat = 0.5 * sWidth()
    let speedFraction: CGFloat = abs(translation) / sWidth()
    
    let distanceFromThreshold: CGFloat = abs(translation) - accelerateThreshold
    let direction: CGFloat = translation < 0 ? -1 : 1
    
    let smallDistance: CGFloat = min(abs(translation), accelerateThreshold) * direction * speedFraction
    let largeDistance: CGFloat = max(distanceFromThreshold, 0) * direction * (2 - speedFraction)
    
    switch index {
    case _ where index < gc.fidIndex - 1:
        return -sWidth()
    case gc.fidIndex - 1:
        return -sWidth() + smallDistance + largeDistance
    case gc.fidIndex:
        return smallDistance + largeDistance
    case gc.fidIndex + 1:
        return sWidth() + smallDistance + largeDistance
    default:
        return sWidth()
    }
}

//MARK: Views
public struct GrumbleGrubDisplay: View {
    @ObservedObject private var gc: GrumbleCookie = GrumbleCookie.gc()
    @ObservedObject private var ggc: GrumbleGrubCookie = GrumbleGrubCookie.ggc()
    
    //MARK: Getter Methods
    private func coverDragData() -> CGFloat {
        return min(abs(self.gc.coverDrag.height / sHeight()) * 3, 1)
    }
    
    private func offsetY(_ index: Int) -> CGFloat {
        let magnitude: CGFloat = -150
        return grumbleDragData(self.gc, self.ggc, index) * magnitude
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
        return gTagView(tag, CGSize(width: size, height: size), idleData: self.gc.idleData,
                        tossData: grumbleDragData(self.gc, self.ggc, index))
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
            
            ForEach(renderingRange(self.gc), id: \.self) { index in
                ZStack {
                    Ellipse()
                        .fill(Color.black.opacity(Double(0.3 - 0.3 * grumbleDragData(self.gc, self.ggc, index))))
                        .frame(width: sWidth() * grubShadowWidth, height: sWidth() * grubShadowHeight)
                        .offset(x: offsetX(self.gc, self.ggc, index), y: sHeight() * grubShadowOffsetY)
                    
                    self.tagIcon(self.gc.grub(index)!.priorityTag, index: index)
                        .rotationEffect(self.rotation(index))
                        .offset(x: offsetX(self.gc, self.ggc, index),
                                y: sHeight() * grubOffsetY + self.offsetY(index) + self.chooseOffsetY())
                        .scaleEffect(grubScale)
                }
            }.transition(.identity)
        }
    }
}

public struct GrumbleGrubImageDisplay: View {
    @ObservedObject private var gc: GrumbleCookie = GrumbleCookie.gc()
    @ObservedObject private var ggc: GrumbleGrubCookie = GrumbleGrubCookie.ggc()
    @GestureState(initialValue: CGFloat(0), resetTransaction: Transaction(animation: gAnim(.springSlow))) private var holdData
    
    //MARK: Function Methods
    private func expand() {
        withAnimation(gAnim(.spring)) {
            self.ggc.expandedInfo.toggle()
        }
    }
    
    private func imageItem(_ grub: Grub, index: Int) -> some View {
        VStack(spacing: 0) {
            ZStack {
                grub.image()?
                .resizable()
                .aspectRatio(contentMode: .fit)
            }.overlay(Color.white.opacity(Double(self.holdData) * 0.5))
            .cornerRadius(0)
            .gesture(LongPressGesture(minimumDuration: 1)
                .updating(self.$holdData) { value, state, transaction in
                    transaction.animation = gAnim(.spring)
                    state = 1
            }.onEnded { _ in
                self.expand()
            }.simultaneously(with: TapGesture().onEnded {
                self.expand()
            }))
            
            if self.gc.fidIndex == index && self.ggc.expandedInfo {
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
            
            if self.gc.fidIndex == index {
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
                                Button(action: {
                                    withAnimation(gAnim(.easeOut)) {
                                        ListCookie.lc().selectedFID = self.gc.fidList[self.gc.fidIndex]
                                    }
                                }, label: {
                                    Text("Show More Information")
                                        .padding(10)
                                        .font(gFont(.ubuntuMedium, .width, 2))
                                }).background(Color.white)
                                .foregroundColor(gTagColors[grub.priorityTag])
                                .cornerRadius(5)
                                
                                Button(action: self.ggc.choose, label: {
                                    Text("Bon Appetit!")
                                        .padding(10)
                                        .font(gFont(.ubuntuMedium, .width, 2.5))
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
        }.frame(width: sWidth() * (0.9 - 0.3 * grumbleDragData(self.gc, self.ggc, index)))
        .background(Color(white: 0.98))
        .cornerRadius(10)
    }
    
    public var body: some View {
        ForEach(renderingRange(self.gc), id: \.self) { index in
            self.imageItem(self.gc.grub(index)!, index: index)
                .offset(x: offsetX(self.gc, self.ggc, index))
        }.transition(.opacity)
        .position(x: sWidth() * 0.5, y: sHeight() * (self.ggc.expandedInfo ? 0.45 : 0.35))
    }
}

struct GrumbleGrubDisplay_Previews: PreviewProvider {
    static var previews: some View {
        GrumbleGrubDisplay()
    }
}
