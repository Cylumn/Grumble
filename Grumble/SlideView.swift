//
//  SlideView.swift
//  Grumble
//
//  Created by Allen Chang on 3/31/20.
//  Copyright © 2020 Cylumn, Inc. All rights reserved.
//

import SwiftUI

private let dragSpeedConsidered: CGFloat = 1.3

public enum Direction: CGFloat {
    case leftToRight = 1
    case rightToLeft = -1
}

public struct SlideView: View {
    private var index: Binding<Int>
    private var direction: Direction
    private var offsetFactor: CGFloat
    private var views: [AnyView]
    private var padding: CGFloat
    
    @State private var dragOffset: CGFloat = 0
    private var draggable: [Bool]
    @State private var lastDragPosition: DragGesture.Value? = nil
    
    //Initializer
    public init(index: Binding<Int>, direction: Direction = Direction.leftToRight, offsetFactor: CGFloat = 1, views: [AnyView], padding: CGFloat = 10, draggable: [Bool]) {
        self.index = index
        self.direction = direction
        self.offsetFactor = offsetFactor
        self.views = views
        self.padding = padding
        
        self.draggable = draggable
    }
    
    //Getter Methods
    private func offsetValue(_ index: Int) -> CGFloat {
        switch index {
            case _ where index < self.index.wrappedValue - 1:
                return self.direction.rawValue * self.offsetFactor * sWidth()
            case self.index.wrappedValue - 1:
                return self.direction.rawValue * self.offsetFactor * (self.dragOffset - sWidth())
            case self.index.wrappedValue:
                return self.direction.rawValue * self.offsetFactor * self.dragOffset
            case self.index.wrappedValue + 1:
                return self.direction.rawValue * (self.dragOffset + sWidth())
            default:
                return self.direction.rawValue * sWidth()
        }
    }
    
    private var gesture: some Gesture {
        DragGesture()
        .onChanged { drag in
            if !self.draggable[self.index.wrappedValue] {
                return
            }
            
            switch self.index.wrappedValue {
                case 0:
                    if self.direction.rawValue * drag.translation.width < 0 {
                        self.dragOffset = self.direction.rawValue * drag.translation.width
                        self.lastDragPosition = drag
                    }
                case self.views.count - 1:
                    if self.direction.rawValue * drag.translation.width > 0 {
                        self.dragOffset = self.direction.rawValue * drag.translation.width
                        self.lastDragPosition = drag
                    }
                default:
                    self.dragOffset = self.direction.rawValue * drag.translation.width
                    self.lastDragPosition = drag
            }
        }.onEnded { drag in
            if !self.draggable[self.index.wrappedValue] {
                return
            }
            
            var adjustedOffset = self.dragOffset
            if let ldp = self.lastDragPosition {
                let timeDiff = drag.time.timeIntervalSince(ldp.time)
                let speed = self.direction.rawValue * (drag.translation.width - ldp.translation.width) / CGFloat(timeDiff)
                adjustedOffset = self.dragOffset + speed * dragSpeedConsidered
            }
            
            if self.index.wrappedValue > 0 && adjustedOffset > sWidth() * 0.5 {
                withAnimation(gAnim(.easeOut)) {
                    self.dragOffset = 0
                    self.index.wrappedValue -= 1
                    UIApplication.shared.endEditing()
                }
            } else if self.index.wrappedValue < self.views.count - 1 && adjustedOffset < -sWidth() * 0.5 {
                withAnimation(gAnim(.easeOut)) {
                    self.dragOffset = 0
                    self.index.wrappedValue += 1
                    UIApplication.shared.endEditing()
                }
            } else {
                withAnimation(gAnim(.easeOut)) {
                    self.dragOffset = 0
                }
            }
        }
    }
    
    public var body: some View {
        ZStack {
            ForEach(0 ..< self.views.count) { i in
                self.views[i]
                    .padding([.top, .bottom], self.padding)
                    .background(Color.white)
                    .frame(width: sWidth())
                    .offset(x: self.offsetValue(i))
            }
        }.contentShape(Rectangle())
        .gesture(self.gesture)
    }
}
