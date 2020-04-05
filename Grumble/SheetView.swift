//
//  SheetView.swift
//  Grumble
//
//  Created by Allen Chang on 3/29/20.
//  Copyright © 2020 Cylumn, Inc. All rights reserved.
//

import SwiftUI

public enum SheetPosition {
    case up
    case down
}

public struct SheetView<Content>: View where Content: View {
    private var currentHeight: Binding<CGFloat>
    private var movingOffset: Binding<CGFloat>
    @State private var lastDragPosition: DragGesture.Value? = nil
    
    private var position: SheetPosition
    private var gapFromTop: CGFloat
    private var backgroundExtension: CGFloat
    private var onDragEnd: ((SheetPosition) -> ())
    private var content: () -> Content
    
    //Initializer
    public init(currentHeight: Binding<CGFloat>, movingOffset: Binding<CGFloat>, startPosition: SheetPosition = SheetPosition.down, gapFromTop: CGFloat = 50, onDragEnd: @escaping (SheetPosition) -> () = {_ in}, _ content: @escaping () -> Content) {
        self.currentHeight = currentHeight
        self.movingOffset = movingOffset
        
        self.position = startPosition
        self.gapFromTop = gapFromTop
        self.backgroundExtension = 0.2
        self.onDragEnd = onDragEnd
        self.content = content
    }
    
    public var body: some View {
        Group(content: self.content)
            .background(ZStack {
                            Color.white
                                .frame(height: sHeight() * (1 + self.backgroundExtension))
                                .cornerRadius(40)
                        }.frame(height: sHeight())
                        .offset(y: sHeight() * self.backgroundExtension / 2))
            .frame(minHeight: 0.0, maxHeight: .infinity, alignment: .bottom)
            .offset(y: sHeight() - self.gapFromTop + self.movingOffset.wrappedValue)
                .gesture(
                DragGesture()
                .onChanged({ drag in
                    if drag.translation.height + self.currentHeight.wrappedValue > self.gapFromTop - sHeight() {
                        self.movingOffset.wrappedValue = drag.translation.height + self.currentHeight.wrappedValue
                    } else {
                        self.movingOffset.wrappedValue = self.gapFromTop - sHeight()
                    }
                    
                    self.lastDragPosition = drag
                }).onEnded({ drag in
                    var adjustedOffset = self.movingOffset.wrappedValue
                    if let ldp = self.lastDragPosition {
                        let timeDiff = drag.time.timeIntervalSince(ldp.time)
                        let speed = (drag.translation.height - ldp.translation.height) / CGFloat(timeDiff)
                        adjustedOffset = self.movingOffset.wrappedValue + speed * 1.3
                    }
                    
                    if adjustedOffset > self.gapFromTop * 0.6 {
                        withAnimation(.spring(dampingFraction: 0.7)) {
                            self.movingOffset.wrappedValue = self.gapFromTop
                            self.onDragEnd(.down)
                        }
                    } else {
                        //go to top
                        withAnimation(.spring(dampingFraction: 1.5)) {
                            self.movingOffset.wrappedValue = 0.0
                            self.onDragEnd(.up)
                        }
                    }
                    self.currentHeight.wrappedValue = self.movingOffset.wrappedValue
                })
                ).clipped()
                .shadow(color: Color.gray.opacity(0.2), radius: 20, x: 0.0, y: -5)
    }
}

#if DEBUG
struct SheetView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
           SheetView(currentHeight: Binding.constant(0.0), movingOffset: Binding.constant(0.0)) {
               Rectangle().foregroundColor(Color.red).frame(height: 500)
           }.previewDevice(PreviewDevice(rawValue: "iPhone SE"))
           .previewDisplayName("iPhone SE")

           SheetView(currentHeight: Binding.constant(0.0), movingOffset: Binding.constant(0.0)) {
               Rectangle().foregroundColor(Color.red).frame(height: 500)
           }.previewDevice(PreviewDevice(rawValue: "iPhone XS Max"))
           .previewDisplayName("iPhone XS Max")
        }
    }
}
#endif
