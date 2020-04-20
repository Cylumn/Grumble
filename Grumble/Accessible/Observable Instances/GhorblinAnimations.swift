//
//  GhorblinAnimations.swift
//  Grumble
//
//  Created by Allen Chang on 4/19/20.
//  Copyright © 2020 Cylumn, Inc. All rights reserved.
//

import Foundation
import SwiftUI

public class GhorblinAnimations: ObservableObject {
    private static var instance: GhorblinAnimations? = nil
    @Published private var dripData: CGFloat = 0
    @Published public var idleData: CGFloat = 0
    private var idleTimer: Timer? = nil
    
    public static func ga() -> GhorblinAnimations {
        if GhorblinAnimations.instance == nil {
            GhorblinAnimations.instance = GhorblinAnimations()
        }
        return GhorblinAnimations.instance!
    }
    
    //Getter Methods
    public func drip() -> CGFloat {
        return self.dripData
    }
    
    //Setter Methods
    public func setDrip(_ data: CGFloat) {
        withAnimation(gAnim(.springSlow)) {
            self.dripData = data
        }
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
