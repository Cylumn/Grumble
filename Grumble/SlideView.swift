//
//  SlideView.swift
//  Grumble
//
//  Created by Allen Chang on 3/31/20.
//  Copyright © 2020 Cylumn, Inc. All rights reserved.
//

import SwiftUI

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
    
    public var body: some View {
        ZStack{
            ForEach(0..<self.views.count) { i in
                self.views[i]
                    .padding([.top, .bottom], self.padding)
                    .background(Color.white)
                    .frame(width: sWidth())
                    .contentShape(Rectangle())
                    .offset(x: self.offsetValue(i))
                    .gesture(self.draggable[i] ?
                        DragGesture()
                         .onChanged { drag in
                            if self.index.wrappedValue == 0 {
                                if self.direction.rawValue * drag.translation.width < 0 {
                                    self.dragOffset = self.direction.rawValue * drag.translation.width
                                    self.lastDragPosition = drag
                                }
                            } else if self.index.wrappedValue == self.views.count - 1 {
                                if self.direction.rawValue * drag.translation.width > 0 {
                                    self.dragOffset = self.direction.rawValue * drag.translation.width
                                    self.lastDragPosition = drag
                                }
                            } else {
                                self.dragOffset = self.direction.rawValue * drag.translation.width
                                self.lastDragPosition = drag
                            }
                        }.onEnded { drag in
                            var adjustedOffset = self.dragOffset
                            if let ldp = self.lastDragPosition {
                                let timeDiff = drag.time.timeIntervalSince(ldp.time)
                                let speed = self.direction.rawValue * (drag.translation.width - ldp.translation.width) / CGFloat(timeDiff)
                                adjustedOffset = self.dragOffset + speed * 1.3
                            }
                            
                            if self.index.wrappedValue > 0 && adjustedOffset > sWidth() * 0.5 {
                                withAnimation(.easeOut(duration: 0.3)) {
                                    self.dragOffset = 0
                                    self.index.wrappedValue -= 1
                                    UIApplication.shared.endEditing()
                                }
                            } else if self.index.wrappedValue < self.views.count - 1 && adjustedOffset < -sWidth() * 0.5 {
                                withAnimation(.easeOut(duration: 0.3)) {
                                    self.dragOffset = 0
                                    self.index.wrappedValue += 1
                                    UIApplication.shared.endEditing()
                                }
                            } else {
                                withAnimation(.easeOut(duration: 0.3)) {
                                    self.dragOffset = 0
                                }
                            }
                        } : DragGesture().onChanged(){_ in}.onEnded(){_ in})
            }
        }
    }
}
