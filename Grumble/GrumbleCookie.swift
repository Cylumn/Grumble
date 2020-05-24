//
//  GrumbleCookie.swift
//  Grumble
//
//  Created by Allen Chang on 5/17/20.
//  Copyright © 2020 Cylumn, Inc. All rights reserved.
//

import Foundation
import SwiftUI

//MARK: Enumerations
public enum GhorblinType {
    case grumble
    case orthodox
    case defiant
    case grubologist
}

public enum CoverDragState {
    case cancelled
    case covered
    case lifted
    case completed
}

public enum PresentHideModal {
    case hidden
    case inProgress
    case shown
}

//MARK: Cookies
public class GrumbleCookie: ObservableObject {
    private static var instance: GrumbleCookie? = nil
    private var grubList: [(String, Grub)] = []
    @Published public var grubIndex: Int = 0
    private var maxObservedIndex: Int = 1
    private var requesting: Bool = false
    
    //MARK: Drag Translations
    @Published public var coverDrag: CGSize = CGSize.zero
    
    //MARK: Data
    @Published public var dripData: CGFloat = 0
    @Published public var idleData: CGFloat = 0
    
    @Published public var coverDragState: CoverDragState = .covered
    
    @Published public var presentHideModal: PresentHideModal = .hidden
    
    private var idleTimer: Timer? = nil
    
    //MARK: Initializers
    public static func gc() -> GrumbleCookie {
        if GrumbleCookie.instance == nil {
            GrumbleCookie.instance = GrumbleCookie()
        }
        return GrumbleCookie.instance!
    }
    
    //MARK: Getter Methods
    public func listCount() -> Int {
        return self.grubList.count
    }
    
    public func index() -> Int {
        return self.grubIndex
    }
    
    public func grub(_ index: Int) -> Grub? {
        if self.grubList.count == 0 {
            return nil
        }
        return self.grubList[index].1
    }
    
    public func grub() -> Grub? {
        return self.grub(self.index())
    }
    
    public func coverDistance() -> CGFloat {
        return self.coverDrag.height * 0.5 + min(self.coverDrag.height + sHeight() * 0.3, 0) * 10
    }
    
    public func unobservedGrubList() -> ArraySlice<(String, Grub)> {
        if self.maxObservedIndex + 1 < self.grubList.count {
            return self.grubList.suffix(from: self.maxObservedIndex + 1)
        } else {
            return []
        }
    }
    
    //MARK: Setter Methods
    public func setGrubList(_ list: [(String, Grub)]) {
        self.grubList = list
        self.maxObservedIndex = 1
    }
    
    public func setIndex(_ index: Int) {
        self.maxObservedIndex = max(self.maxObservedIndex, index + 1)
        self.grubIndex = index
    }
    
    public func startIdleAnimation() {
        if self.idleTimer == nil {
            self.idleTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                withAnimation(Animation.easeIn.speed(0.25)) {
                    if self.idleData < 1 {
                        self.idleData = 1
                    } else {
                        self.idleData = 0
                    }
                    
                    if self.dripData < 1 {
                        self.dripData = 1
                    } else {
                        self.dripData = 0
                    }
                }
            }
            self.idleTimer!.fire()
        }
    }
    
    public func endIdleAnimation() {
        if self.idleTimer != nil {
            withAnimation(Animation.easeIn.speed(0.25)) {
                self.idleData = 0
            }
            
            self.idleTimer!.invalidate()
            self.idleTimer = nil
        }
    }
    
    public func attemptRequestImmutableGrub() {
        if GrumbleTypeCookie.gtc().type != .grumble && self.maxObservedIndex >= self.grubList.count - 4 && !self.requesting {
            self.requesting = true
            requestImmutableGrub(ArraySlice(self.grubList), count: 10) { list in
                self.grubList = self.grubList + list.shuffled()
                self.requesting = false
            }
        }
    }
}

public class GrumbleTypeCookie: ObservableObject {
    private static var instance: GrumbleTypeCookie? = nil
    @Published public var type: GhorblinType = .grumble
    
    //MARK: Initializers
    public static func gtc() -> GrumbleTypeCookie {
        if GrumbleTypeCookie.instance == nil {
            GrumbleTypeCookie.instance = GrumbleTypeCookie()
        }
        return GrumbleTypeCookie.instance!
    }
}

public class GrumbleGrubCookie: ObservableObject {
    private static var instance: GrumbleGrubCookie? = nil
    @Published public var expandedInfo: Bool = false
    
    //MARK: Drag Translations
    @Published public var grumbleDrag: CGSize = CGSize.zero
    
    //MARK: Data
    @Published public var chooseData: CGFloat = 0
    
    //MARK: Initializers
    public static func ggc() -> GrumbleGrubCookie {
        if GrumbleGrubCookie.instance == nil {
            GrumbleGrubCookie.instance = GrumbleGrubCookie()
        }
        return GrumbleGrubCookie.instance!
    }
    
    public func choose() {
        withAnimation(Animation.easeOut(duration: 0.3)) {
            self.chooseData = 0.3
            GrumbleCookie.gc().presentHideModal = PresentHideModal.inProgress
        }
        
        Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { _ in
            withAnimation(Animation.easeIn(duration: 0.9)) {
                self.chooseData = 1
            }
        }
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { _ in
            withAnimation(gAnim(.easeOut)) {
                GrumbleCookie.gc().presentHideModal = PresentHideModal.shown
            }
        }
    }
}
