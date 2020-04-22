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

    @GestureState(initialValue: CGFloat(0), resetTransaction: Transaction(animation: gAnim(.springSlow))) private var holdState
    private var holdScaleAnchor: UnitPoint
    @State private var coverDragState: CoverDragState = .covered
    @State private var dragDistance: CGFloat = 0
    @State private var impactOccurred: Bool = false
    
    @State private var dragHorizontal: CGFloat = 0
    @State private var canDragHorizontal: Bool = true
    
    @State private var chosenGrubData: CGFloat = 0
    @State private var presentHideModal: PresentHideModal = .hidden
    
    private var selectedFID: Binding<String?>
    private var showSheet: Binding<Bool>
    private var onGrubSheetHide: Binding<() -> Void>
    
    public init( _ type: GhorblinType, show: Binding<Bool>, _ fidList: [String], selectedFID: Binding<String?>, showSheet: Binding<Bool>, onGrubSheetHide: Binding<() -> Void>) {
        switch type {
        case .classic:
            self.ghorblinFill = [gColor(.blue0), gColor(.blue4), Color(white: 0.9)]
        case .similar:
            self.ghorblinFill = [gColor(.dandelion), Color(white: 0.9)]
        case .defiant:
            self.ghorblinFill = [gColor(.coral), Color(white: 0.9)]
        case .grubologist:
            self.ghorblinFill = [gColor(.magenta), Color(white: 0.9)]
        }
        self.show = show
        self.fidList = fidList
        
        self.holdScaleAnchor = UnitPoint.bottom
        
        self.selectedFID = selectedFID
        self.showSheet = showSheet
        self.onGrubSheetHide = onGrubSheetHide
    }
    
    //Sheet Visuals
    public enum GhorblinType {
        case classic
        case similar
        case defiant
        case grubologist
    }
    
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
        let magnitude: CGFloat = -100
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
        let smallHeight: CGFloat = min(self.chosenGrubData, dataFraction) * sHeight() * -0.35
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
        TabRouter.tr().hide(false)
        self.ga.endIdleAnimation()
        self.fidIndex = 0
        self.chosenGrubData = 0
        self.presentHideModal = .hidden
    }
    
    private func completeGrubSheet() {
        Grub.removeFood(self.fidList[self.fidIndex])
        self.hideSheet()
    }
    
    private func onGrumble() {
        self.canDragHorizontal = false
        UINotificationFeedbackGenerator().notificationOccurred(.error)
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
            self.canDragHorizontal = true
        }
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
    
    private func tagIcon(_ tag: Int, index: Int) -> some View {
        switch tag {
        case GrubTags.burger.rawValue:
            let size = sWidth() * 0.1 + 80 * self.dragData()
            return AnyView(
                GBurger(CGSize(width: size, height: size), idleData: self.ga.idleData, tossData: self.dragHorizontalData(index))
            )
        default:
            return AnyView(Image(tagBGs[tag])
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: sWidth() * 0.3 + 80 * self.dragData()))
        }
    }
    
    private var ghorblinView: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.clear, Color.black.opacity(0.3)]), startPoint: .top, endPoint: .bottomLeading)
                .frame(height: sHeight() * 0.65)
                .offset(y: -sHeight() * 0.35)
            
            Ellipse()
                .fill(Color.black)
                .frame(width: 250 + 50 * self.dragData(), height: 60 + 20 * self.dragData())
                .shadow(color: Color.black, radius: 10 + 20 * self.dragData())
                .opacity(Double(0.5 - 0.5 * self.dragData()))
                .offset(y: 210)
            
            if self.fidList.count > 0 {
                ForEach(self.grubRenderingRange(), id: \.self) { index in
                    self.tagIcon(self.grub(index)!.tags["smallestTag"]!, index: index)
                        .rotationEffect(self.grubRotation(index))
                        .offset(x: self.grubOffsetX(index), y: 150 + self.grubOffsetY(index) + self.chosenGrubOffsetY())
                        .scaleEffect(1 + 2 * self.chosenGrubData)
                }
            }
            
            ZStack {
                GhorblinSheet(drip: self.ga.drip(), idleScale: self.ga.idleData, hold: self.holdData())
                    .fill(self.dripFill)
                    .shadow(color: Color.white.opacity(0.2), radius: 20 * self.holdData())
                
                GhorblinSheetOverlay(drip: self.ga.drip(), idleScale: self.ga.idleData, hold: self.holdData())
                    .fill(Color.white)
            }.offset(y: self.coverDistance())
        }
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
                        
                        VStack(spacing: 10) {
                            Text("Enjoy Your")
                            
                            Text(self.grub()?.food ?? "Empty Stomach!")
                        }.font(gFont(.ubuntuLight, .width, 3.5))
                        .foregroundColor(Color(white: 0.2))
                        .padding(.top, 50)
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
    
    public var body: some View {
        ZStack(alignment: .bottom) {
            Color(white: 0.2)
                .edgesIgnoringSafeArea(.all)
            
            self.ghorblinView
                .scaleEffect(1 + 0.2 * self.holdData() + 0.7 * self.dragData(), anchor: self.holdScaleAnchor)
                .clipped()
                .edgesIgnoringSafeArea(.all)
            
            LinearGradient(gradient: Gradient(colors: [Color.clear, Color.black.opacity(0.6)]), startPoint: .top, endPoint: .bottom)
            .frame(height: sHeight() * 0.4)
            
            ZStack(alignment: self.presentHideModal == PresentHideModal.shown ? .center : .topTrailing) {
                Color.clear
                    .contentShape(Rectangle())
                    .gesture(LongPressGesture(minimumDuration: .infinity, maximumDistance: .infinity)
                        .updating(self.$holdState) { value, state, transaction in
                            transaction.animation = gAnim(.springSlow)
                            state = 1
                    }.simultaneously(with: DragGesture().onChanged { drag in
                        if self.coverDragState == .completed {
                            if self.canDragHorizontal {
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
                            withAnimation(gAnim(.spring)) {
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
                            case .cancelled:
                                self.coverDragState = .covered
                            case .lifted:
                                self.dragDistance = -sHeight() * 0.6
                                self.coverDragState = .completed
                            case .completed:
                                if self.canDragHorizontal {
                                    if self.fidIndex > 0 && drag.predictedEndTranslation.width > sWidth() * 0.5 {
                                        self.fidIndex -= 1
                                        self.dragHorizontal = 0
                                        
                                        self.onGrumble()
                                    } else if self.fidIndex < self.fidList.count - 1 && drag.predictedEndTranslation.width < -sWidth() * 0.5 {
                                        self.fidIndex += 1
                                        self.dragHorizontal = 0
                                        
                                        self.onGrumble()
                                    } else {
                                        self.dragHorizontal = 0
                                    }
                                }
                            default:
                                self.dragDistance = 0
                            }
                        }
                    }))
                
                if self.presentHideModal == PresentHideModal.shown {
                    Color.black.opacity(0.4)
                        .edgesIgnoringSafeArea(.all)
                }
                
                self.hideModal
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
            
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
                            self.selectedFID.wrappedValue = self.fidList[self.fidIndex]
                            withAnimation(gAnim(.easeOut)) {
                                self.showSheet.wrappedValue = true
                            }
                            self.onGrubSheetHide.wrappedValue = {}
                        }, label: {
                            Text("View")
                                .padding(10)
                                .padding([.leading, .trailing], 10)
                                .background(Color(white: 0.8))
                                .foregroundColor(Color(white: 0.3))
                                .cornerRadius(10)
                        })
                        
                        Button(action: {
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
            }.padding(20)
            .padding(.bottom, 20)
            .frame(alignment: .bottom)
            .foregroundColor(Color.white)
            .offset(y: self.coverDragState == .completed && self.presentHideModal == PresentHideModal.hidden ? 0 : sHeight())
        }
    }
}

struct GrumbleSheet_Previews: PreviewProvider {
    static var previews: some View {
        GrumbleSheet(.classic, show: Binding.constant(true), Array(UserCookie.uc().foodList().keys), selectedFID: Binding.constant(""), showSheet: Binding.constant(false), onGrubSheetHide: Binding.constant({}))
    }
}
