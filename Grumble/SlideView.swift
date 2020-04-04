//
//  SlideView.swift
//  Grumble
//
//  Created by Allen Chang on 3/31/20.
//  Copyright © 2020 Cylumn, Inc. All rights reserved.
//

import SwiftUI

enum Direction: CGFloat {
    case leftToRight = 1
    case rightToLeft = -1
}

struct SlideView: View {
    @Binding var index: Int
    var direction = Direction.leftToRight
    var offsetFactor: CGFloat = 1
    @State var dragOffset: CGFloat = 0
    var padding: CGFloat = 10
    var views: [AnyView]
    var draggable: [Bool]
    @State var lastDragPosition: DragGesture.Value? = nil
    
    var body: some View {
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
                            if self.index == 0 {
                                if self.direction.rawValue * drag.translation.width < 0 {
                                    self.dragOffset = self.direction.rawValue * drag.translation.width
                                    self.lastDragPosition = drag
                                }
                            } else if self.index == self.views.count - 1 {
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
                            
                            if self.index > 0 && adjustedOffset > sWidth() * 0.5 {
                                withAnimation(.easeOut(duration: 0.3)) {
                                    self.dragOffset = 0
                                    self.index -= 1
                                    UIApplication.shared.endEditing()
                                }
                            } else if self.index < self.views.count - 1 && adjustedOffset < -sWidth() * 0.5 {
                                withAnimation(.easeOut(duration: 0.3)) {
                                    self.dragOffset = 0
                                    self.index += 1
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
    
    func offsetValue(_ index: Int) -> CGFloat {
        if index <= self.index - 1 {
            if index == self.index - 1 {
                return self.direction.rawValue * self.offsetFactor * (self.dragOffset - sWidth())
            } else {
                return self.direction.rawValue * self.offsetFactor * sWidth()
            }
        } else if index > self.index {
            if index == self.index + 1 {
                return self.direction.rawValue * (self.dragOffset + sWidth())
            } else {
                return self.direction.rawValue * sWidth()
            }
        } else {
            return self.direction.rawValue * self.offsetFactor * self.dragOffset
        }
    }
}
