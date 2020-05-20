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
    public var fidList: [String] = []
    @Published public var fidIndex: Int = 0
    
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
    public func grub(_ index: Int) -> Grub? {
        if self.fidList.count == 0 {
            return nil
        }
        return UserCookie.uc().foodList()[self.fidList[index]]
    }
    
    public func grub() -> Grub? {
        return self.grub(self.fidIndex)
    }
    
    public func coverDistance() -> CGFloat {
        return self.coverDrag.height * 0.5 + min(self.coverDrag.height + sHeight() * 0.3, 0) * 10
    }
    
    //MARK: Setter Methods
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
