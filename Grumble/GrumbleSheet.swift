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
    @ObservedObject private var gc: GrumbleCookie = GrumbleCookie.gc()
    private var ggc: GrumbleGrubCookie = GrumbleGrubCookie.ggc()
    private var show: Binding<Bool>
    private var type: GhorblinType
    
    private var background: GrumbleSheetBackground
    
    @GestureState(initialValue: CGFloat(0), resetTransaction: Transaction(animation: gAnim(.springSlow))) public var holdState
    private var holdScaleAnchor: UnitPoint
    @State private var impactOccurred: Bool = false
    
    @State private var canDragHorizontal: Bool = true
    
    //Initializer
    public init( _ type: GhorblinType, show: Binding<Bool>) {
        self.type = type
        self.show = show
        
        self.background = GrumbleSheetBackground(type)
        
        self.holdScaleAnchor = UnitPoint.bottom
    }
    
    //Getter Methods
    public func holdData() -> CGFloat {
        switch self.gc.coverDragState {
        case .cancelled, .completed:
            return 0
        default:
            return self.holdState
        }
    }
    
    private func coverDragData() -> CGFloat {
        return min(abs(self.gc.coverDrag.height / sHeight()) * 3, 1)
    }
    
    //Function Methods
    private func hideSheet() {
        withAnimation(gAnim(.spring)) {
            self.show.wrappedValue = false
            self.gc.dripData = 0
            self.gc.coverDrag = CGSize.zero
            self.ggc.expandedInfo = false
        }
        self.gc.coverDragState = .covered
        self.gc.presentHideModal = .hidden
        self.gc.endIdleAnimation()
        self.ggc.chooseData = 0
        
        Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { _ in
            self.gc.fidIndex = 0
            self.gc.fidList = []
        }
    }
    
    private func completeGrubSheet() {
        if self.gc.fidList.count > 0 {
            Grub.removeFood(self.gc.fidList[self.gc.fidIndex])
        }
        self.hideSheet()
    }
    
    private func onToss() {
        self.canDragHorizontal = false
        UINotificationFeedbackGenerator().notificationOccurred(.error)
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
            self.canDragHorizontal = true
        }
    }
    
    private var grumbleGesture: some Gesture {
        return LongPressGesture(minimumDuration: .infinity, maximumDistance: .infinity)
            .updating(self.$holdState) { value, state, transaction in
                transaction.animation = gAnim(.springSlow)
                state = 1
        }.simultaneously(with: DragGesture().onChanged { drag in
            if self.gc.coverDragState == .completed {
                if self.ggc.expandedInfo {
                    withAnimation(gAnim(.spring)) {
                        self.ggc.expandedInfo = false
                    }
                }
                
                if self.canDragHorizontal && self.gc.fidList.count > 1 {
                    switch self.gc.fidIndex{
                    case 0:
                        self.ggc.grumbleDrag = CGSize(width: min(drag.translation.width, 0), height: 0)
                    case self.gc.fidList.count - 1:
                        self.ggc.grumbleDrag = CGSize(width: max(drag.translation.width, 0), height: 0)
                    default:
                        self.ggc.grumbleDrag = CGSize(width: drag.translation.width, height: 0)
                    }
                }
            } else if drag.translation.height > sHeight() * 0.1 {
                withAnimation(gAnim(.easeOut)) {
                    self.gc.coverDragState = .cancelled
                }
            } else {
                withAnimation(gAnim(.easeOut)) {
                    self.gc.coverDrag = CGSize(width: 0, height: min(drag.translation.height, 0))
                
                    if !self.impactOccurred && self.gc.coverDistance() < self.gc.coverDrag.height * 0.5 {
                        self.impactOccurred = true
                        let impact = UIImpactFeedbackGenerator(style: .medium)
                        impact.impactOccurred()
                        self.gc.coverDragState = .lifted
                    } else if self.gc.coverDistance() >= self.gc.coverDrag.height * 0.5 {
                        self.impactOccurred = false
                        self.gc.coverDragState = .covered
                    }
                }
            }
        }.onEnded { drag in
            withAnimation(gAnim(.easeOut)) {
                switch self.gc.coverDragState {
                case .cancelled, .covered:
                    self.gc.coverDragState = .covered
                    self.gc.coverDrag = CGSize.zero
                case .lifted:
                    self.gc.coverDrag = CGSize(width: 0, height: -sHeight() * 0.6)
                    self.gc.coverDragState = .completed
                    
                    if self.gc.fidList.count == 0 {
                        self.ggc.choose()
                    }
                case .completed:
                    if self.canDragHorizontal {
                        if self.ggc.grumbleDrag.width != 0 {
                            if self.gc.idleData < 1 {
                                self.gc.idleData = 1
                            } else {
                                self.gc.idleData = 0
                            }
                        }
                        
                        if self.gc.fidIndex > 0 && drag.predictedEndTranslation.width > sWidth() * 0.5 {
                            self.gc.fidIndex -= 1
                            self.ggc.grumbleDrag = CGSize.zero
                            
                            self.onToss()
                        } else if self.gc.fidIndex < self.gc.fidList.count - 1 && drag.predictedEndTranslation.width < -sWidth() * 0.5 {
                            self.gc.fidIndex += 1
                            self.ggc.grumbleDrag = CGSize.zero
                            
                            self.onToss()
                        } else {
                            self.ggc.grumbleDrag = CGSize.zero
                        }
                    }
                }
            }
        })
    }
    
    private var hideModal: some View {
        ZStack {
            if self.gc.presentHideModal == PresentHideModal.shown {
                ZStack(alignment: .bottom) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white)
                        .frame(maxWidth: .infinity)
                    
                    ZStack(alignment: .top) {
                        Color.clear
                        
                        VStack(alignment: .center, spacing: 10) {
                            if self.gc.fidList.count > 0 {
                                Text("Enjoy Your")
                                
                                Text(self.gc.grub()?.food ?? "")
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
                        Text(self.gc.fidList.count > 0 ? "Directions" : "Back")
                            .padding(5)
                            .padding([.leading, .trailing], 10)
                            .background(gColor(.blue0))
                            .font(gFont(.ubuntuBold, .width, 2.5))
                            .foregroundColor(Color.white)
                            .cornerRadius(20)
                    }).padding(.bottom, 20)
                }.padding([.leading, .trailing], 50)
                .frame(height: 400)
            } else if self.gc.presentHideModal == PresentHideModal.hidden {
                Button(action: self.hideSheet, label: {
                    Image(systemName: "chevron.down.circle.fill")
                        .padding(25)
                        .foregroundColor(self.gc.coverDragState == .covered || self.gc.coverDragState == .cancelled ? Color.black.opacity(0.5) : Color.white.opacity(0.8))
                        .font(.system(size: 30))
                }).offset(y: 20)
            }
        }
    }
    
    public var body: some View {
        let bgScale: CGFloat = 1 + 0.1 * self.holdData() + 0.5 * self.coverDragData()
        let ghorblinScale: CGFloat = 1 + 0.2 * self.holdData() + 0.7 * self.coverDragData()
        return ZStack(alignment: .bottom) {
            Group {
                self.background
                    .scaleEffect(bgScale, anchor: self.holdScaleAnchor)
                
                if self.gc.coverDragState != .completed {
                    GrumbleGhorblinView(self.type, holdData: self.holdData())
                        .scaleEffect(ghorblinScale, anchor: self.holdScaleAnchor)
                }
            }
            
            Color.clear
                .contentShape(Rectangle())
                .gesture(self.grumbleGesture)
            
            if self.gc.coverDragState == .completed && self.gc.presentHideModal == .hidden {
                GrumbleGrubImageDisplay()
            }
            
            ZStack(alignment: self.gc.presentHideModal == PresentHideModal.shown ? .center : .topTrailing) {
                Color.clear
                
                if self.gc.presentHideModal == PresentHideModal.shown {
                    Color.black.opacity(0.4)
                        .edgesIgnoringSafeArea(.all)
                }
                
                self.hideModal
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
        }.frame(width: sWidth())
    }
}

struct GrumbleSheet_Previews: PreviewProvider {
    static var previews: some View {
        UserCookie.uc().setFoodList(["": Grub.testGrub()])
        return GrumbleSheet(.grumble, show: Binding.constant(true))
    }
}
