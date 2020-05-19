//
//  GrumbleSheetBackground.swift
//  Grumble
//
//  Created by Allen Chang on 5/17/20.
//  Copyright © 2020 Cylumn, Inc. All rights reserved.
//

import SwiftUI

public struct GrumbleSheetBackground: View {
    private var type: GhorblinType
    private var tableColor: Color
    
    private var grubDisplay: GrumbleGrubDisplay
    
    //MARK: Initializers
    public init(_ type: GhorblinType) {
        self.type = type
        switch self.type {
        case .grumble:
            self.tableColor = gColor(.blue2)
        case .orthodox:
            self.tableColor = gColor(.dandelion)
        case .defiant:
            self.tableColor = gColor(.coral)
        case .grubologist:
            self.tableColor = gColor(.magenta)
        }
        
        self.grubDisplay = GrumbleGrubDisplay()
    }
    
    //MARK: Subviews
    private var background: some View {
        Group {
            Image("Cave")
                .resizable()
            
            Color.black.opacity(0.05)
            
            LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.2), Color.clear, Color.black.opacity(0.8)]),
                           startPoint: .top, endPoint: .bottomLeading)
        }
    }
    
    private var table: some View {
        Group {
            Ellipse()
                .fill(self.tableColor)
                .frame(width: sWidth() * 1.5, height: sHeight() * 0.3)
            
            Rectangle()
                .fill(self.tableColor)
                .frame(width: sWidth(), height: sHeight() * 0.15)
        }
    }
    
    private var plate: some View {
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
        }
    }
    
    public var body: some View {
        ZStack(alignment: .bottom) {
            self.background
            
            ZStack(alignment: .bottom) {
                self.table
                
                Group {
                    self.plate
                    
                    self.grubDisplay
                }.offset(y: isX() ? sHeight() * -0.05 : 0)
            }.frame(width: sWidth())
            
            LinearGradient(gradient: Gradient(colors: [Color.clear, Color.black.opacity(0.3)]),
                           startPoint: .top, endPoint: .bottom)
                .frame(height: sHeight() * 0.3)
        }.frame(width: sWidth())
    }
}

struct GrumbleSheetBackground_Previews: PreviewProvider {
    static var previews: some View {
        GrumbleSheetBackground(.grumble)
    }
}
