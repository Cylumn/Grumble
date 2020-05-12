//
//  GrumbleSheet.swift
//  Grumble
//
//  Created by Allen Chang on 4/17/20.
//  Copyright © 2020 Cylumn, Inc. All rights reserved.
//

import SwiftUI
import AVFoundation

public struct GrumbleSheet: View {
    @ObservedObject private var uc: UserCookie = UserCookie.uc()
    @ObservedObject private var ga: GhorblinAnimations = GhorblinAnimations.ga()
    private var show: Binding<Bool>
    private var fidList: [String]
    @State private var fidIndex: Int = 0
    private var ghorblinFill: [Color]
    private var type: Int
    private static var tableColors: [Color] = [gColor(.blue2), gColor(.dandelion), gColor(.coral), gColor(.magenta)]

    @GestureState(initialValue: CGFloat(0), resetTransaction: Transaction(animation: gAnim(.springSlow))) private var holdState
    private var holdScaleAnchor: UnitPoint
    @State private var coverDragState: CoverDragState = .covered
    @State private var dragDistance: CGFloat = 0
    @State private var impactOccurred: Bool = false
    
    @State private var dragHorizontal: CGFloat = 0
    @State private var canDragHorizontal: Bool = true
    
    @State private var chosenGrubData: CGFloat = 0
    @State private var presentHideModal: PresentHideModal = .hidden
    
    //Initializer
    public init( _ type: GhorblinType, show: Binding<Bool>, _ fidList: [String]) {
        switch type {
        case .grumble:
            self.type = 0
            self.ghorblinFill = [gColor(.blue0), gColor(.blue4), Color(white: 0.93)]
        case .orthodox:
            self.type = 1
            self.ghorblinFill = [gColor(.dandelion), Color(white: 0.93)]
        case .defiant:
            self.type = 2
            self.ghorblinFill = [gColor(.coral), Color(white: 0.93)]
        case .grubologist:
            self.type = 3
            self.ghorblinFill = [gColor(.magenta), Color(white: 0.93    )]
        }
        self.show = show
        self.fidList = fidList
        
        self.holdScaleAnchor = UnitPoint.bottom
    }
    
    //Sheet Visuals
    public enum GhorblinType {
        case grumble
        case orthodox
        case defiant
        case grubologist
    }
    
    //States
    private enum CoverDragState {
        case cancelled
        case covered
        case lifted
        case completed
    }
    
    private enum PresentHideModal {
        case hidden
        case inProgress
        case shown
    }
    
    //Getter Methods
    private func grub(_ index: Int) -> Grub? {
        if self.fidList.count == 0 {
            return nil
        }
        return self.uc.foodList()[self.fidList[index]]
    }
    
    private func grub() -> Grub? {
        return self.grub(self.fidIndex)
    }
    
    private func holdData() -> CGFloat {
        switch self.coverDragState {
        case .cancelled, .completed:
            return 0
        default:
            return self.holdState
        }
    }
    
    private func dragData() -> CGFloat {
        return min(abs(self.dragDistance / sHeight()) * 3, 1)
    }
    
    private func coverDistance() -> CGFloat {
        return self.dragDistance * 0.5 + min(self.dragDistance + sHeight() * 0.3, 0) * 10
    }
    
    private func dragHorizontalData(_ index: Int) -> CGFloat {
        let scaledDH: CGFloat = abs(self.dragHorizontal) / sWidth()
        
        switch index {
        case self.fidIndex - 1, self.fidIndex + 1:
            return (1 - scaledDH)
        case self.fidIndex:
            return scaledDH
        default:
            return 1
        }
    }
    
    private func grubRenderingRange() -> [Int] {
        if self.fidList.count == 0 {
            return []
        }
        
        let small: Int = max(self.fidIndex - 1, 0)
        let large: Int = min(self.fidIndex + 1, self.fidList.count - 1)
        return (small ... large).filter { self.grub($0) != nil }
    }
    
    private func grubOffsetX(_ index: Int) -> CGFloat {
        let bufferFraction: CGFloat = 0.5 * sWidth()
        let speedFraction: CGFloat = abs(dragHorizontal) / sWidth()
        
        let distanceFromBuffer: CGFloat = abs(self.dragHorizontal) - bufferFraction
        let direction: CGFloat = self.dragHorizontal < 0 ? -1 : 1
        
        let smallDistance: CGFloat = min(abs(self.dragHorizontal), bufferFraction) * direction * speedFraction
        let largeDistance: CGFloat = max(distanceFromBuffer, 0) * direction * (2 - speedFraction)
        
        switch index {
        case _ where index < self.fidIndex - 1:
            return -sWidth()
        case self.fidIndex - 1:
            return -sWidth() + smallDistance + largeDistance
        case self.fidIndex:
            return smallDistance + largeDistance
        case self.fidIndex + 1:
            return sWidth() + smallDistance + largeDistance
        default:
            return sWidth()
        }
    }
    
    private func grubOffsetY(_ index: Int) -> CGFloat {
        let magnitude: CGFloat = -150
        return self.dragHorizontalData(index) * magnitude
    }
    
    private func grubRotation(_ index: Int) -> Angle {
        let scaledDH: CGFloat = self.dragHorizontal / sWidth()
        let angle: CGFloat = 0.2 * 360
        
        switch index {
        case _ where index < self.fidIndex - 1:
            return Angle(degrees: Double(-angle))
        case self.fidIndex - 1:
            return Angle(degrees: Double(-angle + scaledDH * angle))
        case self.fidIndex:
            return Angle(degrees: Double(scaledDH * angle))
        case self.fidIndex + 1:
            return Angle(degrees: Double(angle + scaledDH * angle))
        default:
            return Angle(degrees: Double(angle))
        }
    }
    
    private func chosenGrubOffsetY() -> CGFloat {
        let dataFraction: CGFloat = 0.3
        let smallHeight: CGFloat = min(self.chosenGrubData, dataFraction) * sHeight() * -0.2
        let largeHeight: CGFloat = max(self.chosenGrubData - dataFraction, 0) * sHeight()
        return smallHeight + largeHeight
    }
    
    //Function Methods
    private func hideSheet() {
        withAnimation(gAnim(.spring)) {
            self.show.wrappedValue = false
            self.ga.setDrip(0)
            self.dragDistance = 0
            self.coverDragState = .covered
        }
        self.ga.endIdleAnimation()
        self.chosenGrubData = 0
        self.presentHideModal = .hidden
        
        Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { _ in
            self.fidIndex = 0
        }
    }
    
    private func completeGrubSheet() {
        if self.fidList.count > 0 {
            Grub.removeFood(self.fidList[self.fidIndex])
        }
        self.hideSheet()
    }
    
    private func onBonAppetit() {
        withAnimation(Animation.easeOut(duration: 0.3)) {
            self.chosenGrubData = 0.3
            self.presentHideModal = PresentHideModal.inProgress
        }
        
        Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { _ in
            withAnimation(Animation.easeIn(duration: 0.9)) {
                self.chosenGrubData = 1
            }
        }
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { _ in
            withAnimation(gAnim(.easeOut)) {
                self.presentHideModal = PresentHideModal.shown
            }
        }
    }
    
    private func onToss() {
        self.canDragHorizontal = false
        UINotificationFeedbackGenerator().notificationOccurred(.error)
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
            self.canDragHorizontal = true
        }
    }
    
    private var background: some View {
        ZStack(alignment: .bottom) {
            Image("Cave")
                .resizable()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            Color.black.opacity(0.05)
            
            LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.2), Color.clear, Color.black.opacity(0.8)]), startPoint: .top, endPoint: .bottomLeading)
            
            ZStack(alignment: .bottom) {
                Ellipse()
                    .fill(GrumbleSheet.tableColors[self.type])
                    .frame(width: sWidth() * 1.5, height: sHeight() * 0.3)
                    .clipped()
                
                Rectangle()
                    .fill(GrumbleSheet.tableColors[self.type])
                    .frame(width: sWidth(), height: sHeight() * 0.15)
                
                Group {
                    Ellipse()
                        .fill(Color.black.opacity(0.2))
                        .frame(width: sWidth() * 0.95, height: sWidth() * 0.35)
                        .offset(y: sHeight() * -0.02)
                    
                    Image("GhorblinPlate")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: sWidth() * 0.9)
                        .offset(y: sHeight() * -0.03)
                    
                    Ellipse()
                        .fill(Color.black.opacity(Double(0.2 - 0.2 * self.dragData())))
                        .frame(width: sWidth() * (0.7 + 0.2 * self.dragData()), height: sWidth() * (0.23 + 0.2 * self.dragData()))
                        .offset(y: sHeight() * (-0.09 + (isX() ? 0.02 : 0) + 0.05 * self.dragData()))
                    
                    ForEach(self.grubRenderingRange(), id: \.self) { index in
                        ZStack {
                            Ellipse()
                                .fill(Color.black.opacity(Double(0.3 - 0.3 * self.dragHorizontalData(index))))
                                .frame(width: sWidth() * (0.2 + 0.1 * self.dragData()), height: sWidth() * (0.08 + 0.02 * self.dragData()))
                                .offset(x: self.grubOffsetX(index),
                                        y: sHeight() * (-0.08 + 0.01 * self.dragData()) + sHeight() * 0.3 * self.chosenGrubData)
                                .scaleEffect(1 + 2 * self.chosenGrubData)
                            
                            self.tagIcon(self.grub(index)!.priorityTag, index: index)
                                .rotationEffect(self.grubRotation(index))
                                .offset(x: self.grubOffsetX(index), y: sHeight() * (-0.12 + (isX() ? 0.005 : 0)) + self.grubOffsetY(index) + self.chosenGrubOffsetY())
                                .scaleEffect(1 + 2 * self.chosenGrubData)
                        }
                    }.offset(y: isX() ? sHeight() * 0.01 : 0)
                }.offset(y: isX() ? sHeight() * -0.05 : 0)
            }.frame(width: sWidth())
        }.frame(width: sWidth())
    }
    
    private var dripFill: some ShapeStyle {
        let gradientRatio: CGFloat = 0.5
        var gradientStops: [Gradient.Stop] = []
        for index in 0 ..< self.ghorblinFill.count - 2 {
            gradientStops.append(Gradient.Stop(color: self.ghorblinFill[index], location: CGFloat(index) * gradientRatio / CGFloat(self.ghorblinFill.count - 2)))
        }
        gradientStops.append(Gradient.Stop(color: self.ghorblinFill[self.ghorblinFill.count - 2], location: gradientRatio))
        gradientStops.append(Gradient.Stop(color: self.ghorblinFill[self.ghorblinFill.count - 1], location: gradientRatio + 0.1))
        
        return LinearGradient(gradient:
            Gradient(stops: gradientStops), startPoint: .top, endPoint: .bottom)
    }
    
    private func tagIcon(_ tag: GrubTag, index: Int) -> some View {
        let size = sWidth() * (0.18 + 0.1 * self.dragData())
        return gTagView(tag, CGSize(width: size, height: size), idleData: self.ga.idleData, tossData: self.dragHorizontalData(index))
    }
    
    private var ghorblinView: some View {
        ZStack(alignment: .top) {
            ZStack {
                GhorblinSheet(drip: self.ga.drip(), idleScale: self.ga.idleData, hold: self.holdData())
                    .fill(self.dripFill)
                
                GhorblinSheetOverlay(drip: self.ga.drip(), idleScale: self.ga.idleData, hold: self.holdData())
                    .fill(Color.white)
                
                GhorblinSheetHighlights(idle: self.ga.idleData, hold: self.holdData())
            }.offset(y: self.coverDistance() + safeAreaInset(.top))
            
            Color.white
                .frame(height: safeAreaInset(.top))
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var grumbleGesture: some Gesture {
        return LongPressGesture(minimumDuration: .infinity, maximumDistance: .infinity)
            .updating(self.$holdState) { value, state, transaction in
                transaction.animation = gAnim(.springSlow)
                state = 1
        }.simultaneously(with: DragGesture().onChanged { drag in
            if self.coverDragState == .completed {
                if self.canDragHorizontal && self.fidList.count > 1 {
                    switch self.fidIndex{
                    case 0:
                        self.dragHorizontal = min(drag.translation.width, 0)
                    case self.fidList.count - 1:
                        self.dragHorizontal = max(drag.translation.width, 0)
                    default:
                        self.dragHorizontal = drag.translation.width
                    }
                }
            } else if drag.translation.height > sHeight() * 0.1 {
                withAnimation(gAnim(.easeOut)) {
                    self.coverDragState = .cancelled
                }
            } else {
                withAnimation(gAnim(.easeOut)) {
                    self.dragDistance = min(drag.translation.height, 0)
                
                    if !self.impactOccurred && self.coverDistance() < self.dragDistance * 0.5 {
                        self.impactOccurred = true
                        let impact = UIImpactFeedbackGenerator(style: .medium)
                        impact.impactOccurred()
                        self.coverDragState = .lifted
                    } else if self.coverDistance() >= self.dragDistance * 0.5 {
                        self.impactOccurred = false
                        self.coverDragState = .covered
                    }
                }
            }
        }.onEnded { drag in
            withAnimation(gAnim(.easeOut)) {
                switch self.coverDragState {
                case .cancelled, .covered:
                    self.coverDragState = .covered
                    self.dragDistance = 0
                case .lifted:
                    self.dragDistance = -sHeight() * 0.6
                    self.coverDragState = .completed
                    
                    if self.fidList.count == 0 {
                        self.onBonAppetit()
                    }
                case .completed:
                    if self.canDragHorizontal {
                        if self.dragHorizontal != 0 {
                            if self.ga.idleData < 1 {
                                self.ga.idleData = 1
                            } else {
                                self.ga.idleData = 0
                            }
                        }
                        
                        if self.fidIndex > 0 && drag.predictedEndTranslation.width > sWidth() * 0.5 {
                            self.fidIndex -= 1
                            self.dragHorizontal = 0
                            
                            self.onToss()
                        } else if self.fidIndex < self.fidList.count - 1 && drag.predictedEndTranslation.width < -sWidth() * 0.5 {
                            self.fidIndex += 1
                            self.dragHorizontal = 0
                            
                            self.onToss()
                        } else {
                            self.dragHorizontal = 0
                        }
                    }
                }
            }
        })
    }
    
    private var hideModal: some View {
        ZStack {
            if self.presentHideModal == PresentHideModal.shown {
                ZStack(alignment: .bottom) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white)
                        .frame(maxWidth: .infinity)
                    
                    ZStack(alignment: .top) {
                        Color.clear
                        
                        VStack(alignment: .center, spacing: 10) {
                            if self.fidList.count > 0 {
                                Text("Enjoy Your")
                                
                                Text(self.grub()?.food ?? "")
                                    .multilineTextAlignment(.center)
                            } else {
                                Text("Empty Stomach!")
                                
                                Spacer().frame(height: 10)
                                
                                Text("Your ghorblin needs more virtual grub...")
                                    .font(gFont(.ubuntuLight, .width, 2.5))
                                    .multilineTextAlignment(.center)
                            }
                        }.font(gFont(.ubuntuLight, .width, 3.5))
                        .foregroundColor(Color(white: 0.2))
                        .padding(.top, 30)
                        .padding(20)
                    }
                    
                    Button(action: self.completeGrubSheet, label: {
                        Text("Back")
                            .padding(5)
                            .padding([.leading, .trailing], 10)
                            .background(gColor(.blue0))
                            .font(gFont(.ubuntuBold, .width, 2.5))
                            .foregroundColor(Color.white)
                            .cornerRadius(20)
                    }).padding(.bottom, 20)
                }.padding([.leading, .trailing], 50)
                .frame(height: 400)
            } else if self.presentHideModal == PresentHideModal.hidden {
                Button(action: self.hideSheet, label: {
                    Image(systemName: "chevron.down.circle.fill")
                        .padding(25)
                        .foregroundColor(Color.black.opacity(0.5))
                        .font(.system(size: 30))
                })
            }
        }
    }
    
    private var overlayUI: some View {
        HStack(spacing: nil) {
            VStack(spacing: 0) {
                Spacer()
                Text(self.grub()?.food ?? "")
                .font(gFont(.ubuntuBold, .width, 4.5))
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 20) {
                Spacer()
                
                if self.fidList.count > 0 {
                    Button(action: {
                        ListCookie.lc().selectedFID = self.fidList[self.fidIndex]
                        withAnimation(gAnim(.easeOut)) {
                            ListCookie.lc().presentGrubSheet = true
                        }
                    }, label: {
                        Text("View")
                            .padding(10)
                            .padding([.leading, .trailing], 10)
                            .background(Color(white: 0.95))
                            .foregroundColor(Color(white: 0.3))
                            .cornerRadius(10)
                    })
                    
                    Button(action: {
                        self.onBonAppetit()
                    }, label: {
                        Text("Bon Appetit")
                            .padding(10)
                            .padding([.leading, .trailing], 10)
                            .background(gColor(.blue2))
                            .foregroundColor(Color(white: 0.3))
                            .cornerRadius(10)
                    })
                }
            }.font(gFont(.ubuntuLight, .width, 2.5))
        }
    }
    
    public var body: some View {
        ZStack(alignment: .bottom) {
            self.background
                .scaleEffect(1 + 0.1 * self.holdData() + 0.5 * self.dragData(), anchor: self.holdScaleAnchor)
                .clipped()
                .edgesIgnoringSafeArea(.all)
            
            LinearGradient(gradient: Gradient(colors: [Color.clear, Color.black.opacity(0.3)]), startPoint: .top, endPoint: .bottom)
                .frame(height: sHeight() * 0.3)
            
            self.ghorblinView
                .scaleEffect(1 + 0.2 * self.holdData() + 0.7 * self.dragData(), anchor: self.holdScaleAnchor)
                .clipped()
                .edgesIgnoringSafeArea(.all)
            
            ZStack(alignment: self.presentHideModal == PresentHideModal.shown ? .center : .topTrailing) {
                Color.clear
                    .contentShape(Rectangle())
                    .gesture(self.grumbleGesture)
                
                if self.presentHideModal == PresentHideModal.shown {
                    Color.black.opacity(0.4)
                        .edgesIgnoringSafeArea(.all)
                }
                
                self.hideModal
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
            
            self.overlayUI
                .padding(20)
                .padding(.bottom, 20)
                .frame(alignment: .bottom)
                .foregroundColor(Color.white)
                .offset(y: self.coverDragState == .completed && self.presentHideModal == PresentHideModal.hidden ? 0 : sHeight())
        }.frame(width: sWidth())
    }
}

struct GrumbleSheet_Previews: PreviewProvider {
    static var previews: some View {
        UserCookie.uc().setFoodList(["": Grub.testGrub()])
        return GrumbleSheet(.grumble, show: Binding.constant(true), Array(UserCookie.uc().foodList().keys))
    }
}
