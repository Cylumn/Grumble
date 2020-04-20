//
//  GrumbleSheet.swift
//  Grumble
//
//  Created by Allen Chang on 4/17/20.
//  Copyright © 2020 Cylumn, Inc. All rights reserved.
//

import SwiftUI

public struct GrumbleSheet: View {
    @ObservedObject private var ga: GhorblinAnimations = GhorblinAnimations.ga()
    private var show: Binding<Bool>
    private var grub: Grub
    private var ghorblinFill: [Color]

    @GestureState(initialValue: CGFloat(0), resetTransaction: Transaction(animation: gAnim(.springSlow))) private var holdState
    private var holdScaleAnchor: UnitPoint
    @State private var coverDragState: CoverDragState = .covered
    @State private var dragDistance: CGFloat = 0
    @State private var impactOccurred: Bool = false
    
    public init(_ show: Binding<Bool>, _ grub: Grub, _ type: GhorblinType) {
        self.show = show
        self.grub = grub
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
        
        self.holdScaleAnchor = UnitPoint.bottom
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
    
    //Getter Methods
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
    
    public var body: some View {
        ZStack(alignment: .bottom) {
            Color(white: 0.2)
                .edgesIgnoringSafeArea(.all)
            
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
                
                Image(tagBGs[self.grub.tags["smallestTag"]!])
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: sWidth() * 0.3 + 80 * self.dragData())
                    .offset(y: 150)
                
                ZStack {
                    GhorblinSheet(drip: self.ga.drip(), idleScale: self.ga.idleData, hold: self.holdData())
                        .fill(self.dripFill)
                        .shadow(color: Color.white.opacity(0.2), radius: 20 * self.holdData())
                    
                    GhorblinSheetOverlay(drip: self.ga.drip(), idleScale: self.ga.idleData, hold: self.holdData())
                        .fill(Color.white)
                }.offset(y: self.coverDistance())
            }.scaleEffect(1 + 0.2 * self.holdData() + 0.7 * self.dragData(), anchor: self.holdScaleAnchor)
            .clipped()
            .edgesIgnoringSafeArea(.all)
            
            LinearGradient(gradient: Gradient(colors: [Color.clear, Color.black.opacity(0.6)]), startPoint: .top, endPoint: .bottom)
            .frame(height: sHeight() * 0.4)
            
            ZStack(alignment: .topTrailing) {
                Color.clear
                    .contentShape(Rectangle())
                    .gesture(LongPressGesture(minimumDuration: .infinity, maximumDistance: .infinity)
                        .updating(self.$holdState) { value, state, transaction in
                            transaction.animation = gAnim(.springSlow)
                            state = 1
                    }.simultaneously(with: DragGesture().onChanged { drag in
                        if self.coverDragState == .completed {
                            return
                        } else if drag.translation.height > sHeight() * 0.1 {
                            withAnimation(gAnim(.spring)) {
                                self.coverDragState = .cancelled
                            }
                        } else {
                            withAnimation(gAnim(.spring)) {
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
                            case .lifted, .completed:
                                self.dragDistance = -sHeight() * 0.6
                                self.coverDragState = .completed
                            default:
                                self.dragDistance = 0
                            }
                        }
                    }))
                
                Button(action: self.hideSheet, label: {
                    Image(systemName: "chevron.down.circle.fill")
                        .padding(25)
                        .foregroundColor(Color.black.opacity(0.5))
                        .font(.system(size: 30))
                })
            }
            
            if self.coverDragState == .completed {
                HStack(spacing: nil) {
                    VStack(spacing: 0) {
                        Spacer()
                        Text(grub.food)
                        .font(gFont(.ubuntuBold, .width, 4.5))
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 20) {
                        Spacer()
                        
                        Button(action: {}, label: {
                            Text("View")
                                .padding(10)
                                .padding([.leading, .trailing], 10)
                                .background(Color(white: 0.8))
                                .foregroundColor(Color(white: 0.3))
                                .cornerRadius(10)
                        })
                        
                        Button(action: {}, label: {
                            Text("Bon Appetit")
                                .padding(10)
                                .padding([.leading, .trailing], 10)
                                .background(gColor(.blue2))
                                .foregroundColor(Color(white: 0.3))
                                .cornerRadius(10)
                        })
                    }.font(gFont(.ubuntuLight, .width, 2.5))
                }.padding(20)
                .padding(.bottom, 20)
                .frame(alignment: .bottom)
                .foregroundColor(Color.white)
                .transition(.move(edge: .bottom))
            }
        }
    }
}

struct GrumbleSheet_Previews: PreviewProvider {
    static var previews: some View {
        GrumbleSheet(Binding.constant(true), Grub.testGrub(), .classic)
    }
}
