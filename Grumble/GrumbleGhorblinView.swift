//
//  GrumbleGhorblinView.swift
//  Grumble
//
//  Created by Allen Chang on 5/18/20.
//  Copyright © 2020 Cylumn, Inc. All rights reserved.
//

import SwiftUI

public struct GrumbleGhorblinView: View {
    @ObservedObject private var gc: GrumbleCookie = GrumbleCookie.gc()
    private var type: GhorblinType
    private var ghorblinFill: [Color]
    private var holdData: CGFloat
    
    //MARK: Initializers
    public init(_ type: GhorblinType, holdData: CGFloat) {
        self.type = type
        switch self.type {
        case .grumble:
            self.ghorblinFill = [gColor(.blue0), gColor(.blue4), Color(white: 0.93)]
        case .orthodox:
            self.ghorblinFill = [gColor(.dandelion), Color(white: 0.93)]
        case .defiant:
            self.ghorblinFill = [gColor(.coral), Color(white: 0.93)]
        case .grubologist:
            self.ghorblinFill = [gColor(.magenta), Color(white: 0.93)]
        }
        
        self.holdData = holdData
    }
    
    //MARK: Subviews
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
        ZStack(alignment: .top) {
            ZStack {
                GhorblinSheet(drip: self.gc.dripData, idleScale: self.gc.idleData, hold: self.holdData)
                    .fill(self.dripFill)
                
                GhorblinSheetOverlay(drip: self.gc.dripData, idleScale: self.gc.idleData, hold: self.holdData)
                    .fill(Color.white)
                
                GhorblinSheetHighlights(idle: self.gc.idleData, hold: self.holdData)
            }.offset(y: safeAreaInset(.top))
            
            Color.white
                .frame(height: safeAreaInset(.top) * 1.5)
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
        .offset(y: self.gc.coverDistance())
        .drawingGroup()
    }
}

struct GrumbleGhorblinView_Previews: PreviewProvider {
    static var previews: some View {
        GrumbleGhorblinView(.grumble, holdData: 0)
    }
}
