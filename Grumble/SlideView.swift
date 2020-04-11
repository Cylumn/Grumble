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
    private var bgColor: Color
    private var viewWidth: CGFloat
    private var views: [AnyView]
    private var padding: CGFloat
    private var height: CGFloat?
    
    @State private var dragOffset: CGFloat = 0
    private var unDraggable: Set<Int>?
    @State private var lastDragPosition: DragGesture.Value? = nil
    
    //Initializer
    public init(index: Binding<Int>, direction: Direction = Direction.leftToRight, offsetFactor: CGFloat = 1, bgColor: Color = Color.white, viewWidth: CGFloat = sWidth(), views: [AnyView], padding: CGFloat = 10, height: CGFloat? = nil, unDraggable: Set<Int>? = nil) {
        self.index = index
        self.direction = direction
        self.offsetFactor = offsetFactor
        self.bgColor = bgColor
        self.viewWidth = viewWidth
        self.views = views
        self.padding = padding
        self.height = height
        
        self.unDraggable = unDraggable
    }
    
    //Getter Methods
    private func offsetValue(_ index: Int) -> CGFloat {
        switch index {
            case _ where index < self.index.wrappedValue - 1:
                return self.direction.rawValue * self.offsetFactor * -self.viewWidth
            case self.index.wrappedValue - 1:
                return self.direction.rawValue * self.offsetFactor * (self.dragOffset - self.viewWidth)
            case self.index.wrappedValue:
                return self.direction.rawValue * self.offsetFactor * self.dragOffset
            case self.index.wrappedValue + 1:
                return self.direction.rawValue * (self.dragOffset + self.viewWidth)
            default:
                return self.direction.rawValue * self.viewWidth
        }
    }
    
    private func offsetValueCumulative(_ index: Int) -> CGFloat {
        switch index {
            case _ where index < self.index.wrappedValue - 1:
                return self.direction.rawValue * max(CGFloat(self.index.wrappedValue - index) * self.offsetFactor * -self.viewWidth, -sWidth())
            case _ where index > self.index.wrappedValue + 1:
                return self.direction.rawValue * min(CGFloat(index - self.index.wrappedValue) * self.viewWidth, sWidth())
            default:
                return self.offsetValue(index)
        }
    }
    
    private var gesture: some Gesture {
        DragGesture()
        .onChanged { drag in
            if self.unDraggable?.contains(self.index.wrappedValue) ?? false || self.views.count == 1 {
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
            if self.unDraggable?.contains(self.index.wrappedValue) ?? false || self.views.count == 1 {
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
        ZStack(alignment: .bottom) {
            ForEach(0 ..< self.views.count, id: \.self) { i in
                ZStack {
                    if self.offsetValueCumulative(i) > 2 * -sWidth() && self.offsetValueCumulative(i) < 2 * sWidth() {
                        self.views[i]
                            .padding([.top, .bottom], self.padding)
                            .background(self.bgColor)
                            .frame(width: self.viewWidth)
                            .offset(x: self.viewWidth >= sWidth() ? self.offsetValue(i) : self.offsetValueCumulative(i))
                    }
                }
            }
        }.frame(width: sWidth(), height: self.height)
        .contentShape(Rectangle())
        .gesture(self.gesture)
    }
}
