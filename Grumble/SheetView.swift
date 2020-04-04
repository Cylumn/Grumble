//
//  SheetView.swift
//  Grumble
//
//  Created by Allen Chang on 3/29/20.
//  Copyright © 2020 Cylumn, Inc. All rights reserved.
//

import SwiftUI

public enum Position {
    case up
    case down
}

struct SheetView<Content>: View where Content: View {
    @Binding var currentHeight: CGFloat
    @Binding var movingOffset: CGFloat
    @State var lastDragPosition: DragGesture.Value?
    var extraRoom: CGFloat = 0.2
    var position = Position.up
    var smallHeight: CGFloat = 50
    var onDragEnd: ((_ position: Position)->()) = {_ in }
    var content: () -> Content
    
    var body: some View {
        Group(content: self.content)
            .background(ZStack {
                            Color.white
                                .frame(height: sHeight() * (1 + self.extraRoom))
                                .cornerRadius(40)
                        }.frame(height: sHeight())
                        .offset(y: sHeight() * self.extraRoom / 2))
            .frame(minHeight: 0.0, maxHeight: .infinity, alignment: .bottom)
            .offset(y: sHeight() - self.smallHeight + self.movingOffset)
                .gesture(
                DragGesture()
                .onChanged({ drag in
                    if drag.translation.height + self.currentHeight > self.smallHeight - sHeight() {
                        self.movingOffset = drag.translation.height + self.currentHeight
                    } else {
                        self.movingOffset = self.smallHeight - sHeight()
                    }
                    
                    self.lastDragPosition = drag
                }).onEnded({ drag in
                    var adjustedOffset = self.movingOffset
                    if let ldp = self.lastDragPosition {
                        let timeDiff = drag.time.timeIntervalSince(ldp.time)
                        let speed = (drag.translation.height - ldp.translation.height) / CGFloat(timeDiff)
                        adjustedOffset = self.movingOffset + speed * 1.3
                    }
                    
                    if adjustedOffset > self.smallHeight * 0.6 {
                        withAnimation(.spring(dampingFraction: 0.7)) {
                            self.movingOffset = self.smallHeight
                            self.onDragEnd(.down)
                        }
                    } else {
                        //go to top
                        withAnimation(.spring(dampingFraction: 1.5)) {
                            self.movingOffset = 0.0
                            self.onDragEnd(.up)
                        }
                        /*keep where its going
                        withAnimation(.spring(dampingFraction: 3)) {
                            self.movingOffset = adjustedOffset
                        }*/
                    }
                    
                    self.currentHeight = self.movingOffset
                })
                ).clipped()
                .shadow(color: Color.gray.opacity(0.2), radius: 20, x: 0.0, y: -5)
    }
}

#if DEBUG
struct SheetView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
           SheetView(currentHeight: .constant(0.0), movingOffset: .constant(0.0)) {
               Rectangle().foregroundColor(Color.red).frame(height: 500)
           }.previewDevice(PreviewDevice(rawValue: "iPhone SE"))
           .previewDisplayName("iPhone SE")

           SheetView(currentHeight: .constant(0.0), movingOffset: .constant(0.0)) {
               Rectangle().foregroundColor(Color.red).frame(height: 500)
           }.previewDevice(PreviewDevice(rawValue: "iPhone XS Max"))
           .previewDisplayName("iPhone XS Max")
        }
    }
}
#endif
