//
//  SheetView.swift
//  Grumble
//
//  Created by Allen Chang on 3/29/20.
//  Copyright © 2020 Cylumn, Inc. All rights reserved.
//

import SwiftUI

private let dragSpeedConsidered: CGFloat = 1.3
private let hideKeyboardFraction: CGFloat = 0.5
private let hideFraction: CGFloat = 0.6

public enum SheetPosition {
    case up
    case down
}

public struct SheetView<Content>: View where Content: View {
    private var currentHeight: Binding<CGFloat>
    private var movingOffset: Binding<CGFloat>
    @State private var lastDragPosition: DragGesture.Value? = nil
    
    private var maxHeight: CGFloat
    private var backgroundExtension: CGFloat
    private var onDragEnd: ((SheetPosition) -> ())
    private var content: () -> Content
    
    @State private var position: SheetPosition = SheetPosition.down
    
    //Initializer
    public init(currentHeight: Binding<CGFloat>, movingOffset: Binding<CGFloat>, maxHeight: CGFloat = sHeight() * 0.95, onDragEnd: @escaping (SheetPosition) -> () = {_ in}, _ content: @escaping () -> Content) {
        self.currentHeight = currentHeight
        self.movingOffset = movingOffset
        
        self.maxHeight = maxHeight
        self.backgroundExtension = 0.2
        self.onDragEnd = onDragEnd
        self.content = content
        
        self.position = currentHeight.wrappedValue > maxHeight * hideFraction ? .down : .up
    }
    
    private var gesture: some Gesture {
        DragGesture()
        .onChanged { drag in
            self.movingOffset.wrappedValue = max(drag.translation.height + self.currentHeight.wrappedValue, self.maxHeight - sHeight())
            
            if self.position == .up && self.movingOffset.wrappedValue > self.maxHeight * hideKeyboardFraction {
                self.onDragEnd(.down)
                self.position = .down
            } else if self.position == .down && self.movingOffset.wrappedValue < self.maxHeight * hideKeyboardFraction {
                self.onDragEnd(.up)
                self.position = .up
            }
            self.lastDragPosition = drag
        }.onEnded { drag in
            var adjustedOffset = self.movingOffset.wrappedValue
            if let ldp = self.lastDragPosition {
                let timeDiff = drag.time.timeIntervalSince(ldp.time)
                let speed = (drag.translation.height - ldp.translation.height) / CGFloat(timeDiff)
                adjustedOffset = self.movingOffset.wrappedValue + speed * dragSpeedConsidered
            }
            
            if adjustedOffset > self.maxHeight * hideFraction {
                withAnimation(gAnim(.spring)) {
                    self.movingOffset.wrappedValue = self.maxHeight
                }
                if self.position == .up {
                    self.onDragEnd(.down)
                    self.position = .down
                }
            } else {
                withAnimation(gAnim(.springSlow)) {
                    self.movingOffset.wrappedValue = 0.0
                }
                if self.position == .down {
                    self.onDragEnd(.up)
                    self.position = .up
                }
            }
            self.currentHeight.wrappedValue = self.movingOffset.wrappedValue
        }
    }
    
    public var body: some View {
        Group(content: self.content)
            .background(ZStack {
                            Color.white
                                .frame(height: sHeight() * (1 + self.backgroundExtension))
                                .cornerRadius(40)
                        }.frame(height: sHeight())
                        .offset(y: sHeight() * self.backgroundExtension / 2))
            .frame(minHeight: 0, maxHeight: .infinity, alignment: .bottom)
            .offset(y: sHeight() + safeAreaInset(.top) - self.maxHeight + self.movingOffset.wrappedValue)
            .gesture(self.gesture)
            .clipped()
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
