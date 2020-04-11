//
//  GrumblerSheet.swift
//  Grumble
//
//  Created by Allen Chang on 4/6/20.
//  Copyright © 2020 Cylumn, Inc. All rights reserved.
//

import SwiftUI

public struct GrumblerSheet: View {
    @ObservedObject private var uc: UserCookie = UserCookie.uc()
    private var currentHeight: Binding<CGFloat>
    private var movingOffset: Binding<CGFloat>
    private var onDragEnd: (SheetPosition) -> ()
    
    @State private var index: Int = 0
    private var grubs: Binding<[AnyView]>
    @State private var picked: Bool = false
    
    //Initializer
    public init(currentHeight: Binding<CGFloat>, movingOffset: Binding<CGFloat>, onDragEnd: @escaping (SheetPosition) -> (), grubs: Binding<[AnyView]>) {
        self.currentHeight = currentHeight
        self.movingOffset = movingOffset
        self.onDragEnd = onDragEnd
        
        self.grubs = grubs
    }
    
    //Function Method
    private func dragEnd(position: SheetPosition) {
        switch position {
        case .up:
            break
        case .down:
            self.index = 0
            self.picked = false
        }
        self.onDragEnd(position)
    }
    
    public var body: some View {
        SheetView(currentHeight: self.currentHeight, movingOffset: self.movingOffset, maxHeight: sHeight(), onDragEnd: self.dragEnd) {
            VStack(spacing: 15) {
                Rectangle()
                    .frame(width: 80, height: 7)
                    .cornerRadius(5)
                    .foregroundColor(Color(white: 0.8))
                
                ZStack {
                    VStack(spacing: 0) {
                        Text("Grumble")
                            .font(gFont(.ubuntuBold, .width, 3))
                            .foregroundColor(gColor(.blue0))
                        Text("Your Grumblin is Rumblin' ...")
                            .font(gFont(.ubuntuMedium, .width, 1.5))
                            .foregroundColor(Color(white: 0.4))
                            .offset(y: 5)
                    }
                }
                
                ZStack {
                    if self.picked {
                        VStack(spacing: 0) {
                            Spacer()
                            Text("Enjoy your " + self.uc.foodList()[GrubPanel.key(self.index)]!.food + "!")
                                .font(gFont(.ubuntuLight, 20))
                                .foregroundColor(Color.gray)
                            Spacer()
                        }.transition(.move(edge: .top))
                    } else {
                        VStack(spacing: 0) {
                            Divider()
                                .frame(width: sWidth(), height: 1)
                                .background(Color.gray)
                            ZStack(alignment: .topTrailing) {
                                SlideView(index: self.$index, bgColor: Color.clear,
                                          views: self.grubs.wrappedValue,
                                          height: sHeight() * 0.6)
                                    .background(Color.white)
                                
                                Text("<< Swipe for something else")
                                    .padding(10)
                                    .font(gFont(.ubuntuBold, 15))
                                    .foregroundColor(Color.gray)
                            }
                            Divider()
                            .frame(width: sWidth(), height: 1)
                            .background(Color.gray)
                            Spacer()
                            Button(action: {
                                if self.uc.foodList().isEmpty {
                                    return
                                }
                                
                                withAnimation(gAnim(.spring)) {
                                    self.picked = true
                                }
                                removeLocalFood(GrubPanel.key(self.index))
                                removeCloudFood(GrubPanel.key(self.index))
                                Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { timer in
                                    withAnimation(gAnim(.spring)) {
                                        self.dragEnd(position: SheetPosition.down)
                                        self.movingOffset.wrappedValue = sHeight()
                                        self.currentHeight.wrappedValue = sHeight()
                                    }
                                    
                                    self.uc.removeFoodList(GrubPanel.key(self.index))
                                }
                            }, label: {
                                Text("Bon Appetit")
                                    .font(gFont(.ubuntuMedium, 15))
                            }).frame(width: sWidth() * 0.8)
                            .padding(15)
                            .background(gColor(.blue4))
                            .foregroundColor(Color.white)
                            .cornerRadius(8)
                            .clipped()
                            Spacer()
                        }.padding(.bottom, tabHeight * 0.5)
                    }
                }
            }.padding(.top, 15)
            .padding(.bottom, isX() ? 60 : 50)
            .frame(width: sWidth(), height: sHeight())
        }
    }
}

