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
    @ObservedObject private var gtc: GrumbleTypeCookie = GrumbleTypeCookie.gtc()
    private var ggc: GrumbleGrubCookie = GrumbleGrubCookie.ggc()
    private var show: Binding<Bool>
    private var type: GhorblinType
    
    private var background: GrumbleSheetBackground
    
    @GestureState(initialValue: CGFloat(0), resetTransaction: Transaction(animation: gAnim(.springSlow))) public var holdState
    private var holdScaleAnchor: UnitPoint
    @State private var impactOccurred: Bool = false
    
    @State private var canTossHorizontally: Bool = true
    
    //Initializer
    public init(show: Binding<Bool>) {
        self.type = GrumbleTypeCookie.gtc().type
        self.show = show
        
        self.background = GrumbleSheetBackground()
        
        self.holdScaleAnchor = UnitPoint.bottom
    }
    
    //MARK: Getter Methods
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
    
    //MARK: Function Methods
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
        self.gc.removed = []
        self.ggc.appendIndex = nil
    }
    
    private func onToss() {
        self.canTossHorizontally = false
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        self.gc.attemptRequestImmutableGrub()
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
            self.canTossHorizontally = true
        }
    }
    
    private func onAppend(_ index: Int) {
        withAnimation(gAnim(.easeOut)) {
            self.ggc.appendIndex = index
        }
        self.gc.setIndex(self.gc.trailingIndex(), animation: gAnim(.easeOut))
        self.gc.removeGrub(index)
        
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
    
    private var grumbleGesture: some Gesture {
        return LongPressGesture(minimumDuration: .infinity, maximumDistance: .infinity)
            .updating(self.$holdState) { value, state, transaction in
                transaction.animation = gAnim(.springSlow)
                state = 1
        }.simultaneously(with: DragGesture().onChanged { drag in
            if self.gc.coverDragState == .completed {
                let boundingSize: CGSize = CGSize(width: sWidth() * 0.2, height: 30)
                
                var width: CGFloat = 0
                if self.canTossHorizontally && self.gc.listCount() > 1 {
                    switch self.gc.index() {
                    case self.gc.startIndex():
                        width = min(drag.translation.width, 0)
                    case self.gc.listCount():
                        width = max(drag.translation.width, 0)
                    default:
                        width = drag.translation.width
                    }
                }
                if self.gc.dragAxis == GAxis.vertical {
                    var slurredWidth: CGFloat = width > 0 ? max(width - boundingSize.width, 0) : min(width + boundingSize.width, 0)
                    slurredWidth *= 0.3
                    width = min(max(width, -boundingSize.width), boundingSize.width) + slurredWidth
                }
                
                var height: CGFloat = 0
                if self.gc.index() < self.gc.listCount() {
                    height = self.gc.dragAxis == GAxis.horizontal ?
                        min(max(drag.translation.height, -boundingSize.height), boundingSize.height) :
                        drag.translation.height
                    
                    if self.gc.dragAxis == GAxis.vertical {
                        if !self.ggc.expandedInfo && (self.ggc.verticalDragPositive ?? false) && height > sHeight() * 0.1 {
                            self.ggc.expand(true)
                        } else if self.ggc.expandedInfo && height < sHeight() * -0.1 {
                            self.ggc.expand(false)
                        }
                    }
                }
                
                if self.gc.dragAxis == nil {
                    if abs(width) > boundingSize.width {
                        self.gc.dragAxis = GAxis.horizontal
                        
                        if self.ggc.expandedInfo {
                            self.ggc.expand(false)
                        }
                    } else if abs(height) > boundingSize.height {
                        self.gc.dragAxis = GAxis.vertical
                        
                        if self.ggc.verticalDragPositive == nil {
                            self.ggc.verticalDragPositive = height > 0
                        }
                    }
                }
                
                if self.gtc.type == .grumble || self.ggc.verticalDragPositive ?? false {
                    height = max(height, 0)
                }
                
                self.ggc.setGrumbleDrag(CGSize(width: width, height: height), animation: gAnim(.easeOut))
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
                    
                    if self.gtc.type == .grumble && self.gc.listCount() == 0 {
                        self.ggc.choose()
                    }
                case .completed:
                    if self.canTossHorizontally {
                        if drag.translation.width != 0 {
                            if self.gc.idleData < 1 {
                                self.gc.idleData = 1
                            } else {
                            self.gc.idleData = 0
                            }
                        }
                        
                        if self.gc.dragAxis != GAxis.horizontal {
                            if !self.ggc.expandedInfo && (self.ggc.verticalDragPositive ?? false) && drag.predictedEndTranslation.height > sHeight() * 0.1 {
                                self.ggc.expand(true)
                            } else if self.ggc.expandedInfo && drag.predictedEndTranslation.height < sHeight() * -0.1 {
                                self.ggc.expand(false)
                            }
                            
                            if self.gc.index() < self.gc.listCount() && !(self.ggc.verticalDragPositive ?? true) && drag.predictedEndTranslation.height < sHeight() * -0.6 {
                                if self.gtc.type != .grumble {
                                    self.onAppend(self.gc.index())
                                }
                            }
                        }
                        
                        if self.gc.dragAxis != GAxis.vertical {
                            if self.gc.index() > self.gc.startIndex() && drag.predictedEndTranslation.width > sWidth() * 0.5 {
                                self.gc.setIndex(self.gc.leadingIndex(), animation: gAnim(.easeOut))
                                self.onToss()
                            } else if self.gc.index() < self.gc.listCount() && drag.predictedEndTranslation.width < -sWidth() * 0.5 {
                                self.gc.setIndex(self.gc.trailingIndex(), animation: gAnim(.easeOut))
                                self.onToss()
                            }
                        }
                        
                        self.ggc.setGrumbleDrag(CGSize.zero, force: true, animation: gAnim(.easeOut))
                        self.gc.dragAxis = nil
                        self.ggc.verticalDragPositive = self.ggc.expandedInfo ? true : nil
                    }
                }
            }
        }).simultaneously(with: TapGesture().onEnded {
            if self.gc.coverDragState == .completed && self.gc.index() < self.gc.listCount() {
                self.ggc.expand()
            }
        })
    }
    
    public var body: some View {
        let bgScale: CGFloat = 1 + 0.1 * self.holdData() + 0.5 * self.coverDragData()
        let ghorblinScale: CGFloat = 1 + 0.2 * self.holdData() + 0.7 * self.coverDragData()
        return ZStack(alignment: .bottom) {
            Group {
                self.background
                    .scaleEffect(bgScale, anchor: self.holdScaleAnchor)
                
                if self.gc.coverDragState != .completed {
                    GrumbleGhorblinView(self.gtc.type, holdData: self.holdData())
                        .scaleEffect(ghorblinScale, anchor: self.holdScaleAnchor)
                }
            }
            
            if self.gc.coverDragState == .completed && self.gc.presentHideModal == .hidden {
                GrumbleGrubImageDisplay()
            }
            
            ZStack(alignment: self.gc.presentHideModal == PresentHideModal.shown ? .center : .topTrailing) {
                Color.clear
                
                if self.gc.presentHideModal == PresentHideModal.shown {
                    Color.black.opacity(0.4)
                        .edgesIgnoringSafeArea(.all)
                }
                
                GrumbleHideModal(self.hideSheet)
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
        }.frame(width: sWidth())
        .gesture(self.grumbleGesture, including: .all)
    }
}

struct GrumbleSheet_Previews: PreviewProvider {
    static var previews: some View {
        UserCookie.uc().setFoodList(["": Grub.testGrub()])
        return GrumbleSheet(show: Binding.constant(true))
    }
}
