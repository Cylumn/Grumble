//
//  RestaurantListItem.swift
//  Grumble
//
//  Created by Allen Chang on 4/4/20.
//  Copyright © 2020 Cylumn, Inc. All rights reserved.
//

import SwiftUI

public struct RestaurantListItem: View {
    private var name: String
    private var address: String?
    private var food: String
    private var price: Double?
    
    @State private var offset: CGFloat = 0
    @State private var baseOffset: CGFloat = 0
    @State private var lastDragPosition: DragGesture.Value? = nil
    private var draggableOffset: CGFloat
    
    //Initializer
    public init(_ name: String, address: String? = nil, food: String, price: Double? = nil){
        self.name = name
        self.address = address
        self.food = food
        self.price = price
        
        self.draggableOffset = 0.25
    }
    
    //Managing Methods
    func removeFood() {
        UserCookie.uc().removeFoodList(self.name)
        removeLocalFood(self.name)
        removeCloudFood(self.name)
    }
    
    private var drag: some Gesture {
        DragGesture().onChanged { gesture in
                let dragConstant = CGFloat(gesture.translation.width < 0 ? 1.2 : 0.5)
                if (sWidth() * self.baseOffset + gesture.translation.width * dragConstant < 0){
                    if sWidth() * self.baseOffset + gesture.translation.width * dragConstant > -sWidth() * self.draggableOffset {
                        self.offset = gesture.translation.width * dragConstant
                    } else {
                        if self.baseOffset == 0 {
                            self.offset = (gesture.translation.width * dragConstant + self.draggableOffset * sWidth()) * 0.2 - self.draggableOffset * sWidth()
                        } else {
                            self.offset = gesture.translation.width * dragConstant * 0.2
                        }
                    }
                }
                self.lastDragPosition = gesture
            }.onEnded { gesture in
                var adjustedOffset = self.offset
                if let ldp = self.lastDragPosition {
                    let timeDiff = gesture.time.timeIntervalSince(ldp.time)
                    let speed = (gesture.translation.width - ldp.translation.width) / CGFloat(timeDiff)
                    adjustedOffset = self.offset + speed * 0.5
                }
                withAnimation(gAnim(.easeOut)) {
                    if adjustedOffset < (-self.draggableOffset / 2 - self.baseOffset) * sWidth() {
                        self.baseOffset = -self.draggableOffset
                    } else {
                        self.baseOffset = 0
                    }
                    self.offset = 0
                }
            }
    }
    
    public var body: some View {
        ZStack{
            Color.red
            HStack{
                Spacer()
                
                Button(action: self.removeFood, label: {
                    Text("Delete")
                    .font(.custom("Ubuntu-Bold", size: sWidth() / 20))
                    .foregroundColor(Color.white)
                    .padding(.trailing, 15)
                })
            }
            
            HStack{
                VStack(alignment: .leading){
                    Text(self.name)
                        .font(.custom("Ubuntu-Bold", size: sWidth() / 23))
                        .foregroundColor(Color.black)
                    
                    if self.address != nil {
                        Spacer().frame(height: sWidth() / 50)
                        
                        Text(self.address!)
                            .font(.custom("Ubuntu-LightItalic", size: sWidth() / 35))
                            .foregroundColor(Color.black)
                    }
                    
                    Divider().frame(width: sWidth() * 0.3, height: 1).background(Color.gray)
                
                    HStack{
                        Text(self.food)
                            .font(.custom("Ubuntu-Medium", size: sWidth() / 30))
                            .foregroundColor(Color.black)
                        
                        if self.price != nil {
                            Spacer()
                            
                            Text("$" + String(format:"%.2f", self.price!))
                                .font(.custom("Ubuntu-Medium", size: sWidth() / 20))
                                .foregroundColor(Color.black)
                        }
                    }
                    
                    Spacer()
                    .frame(height: sWidth() / 40)
                }
                
                Spacer()
            }.padding(15)
            .background(Color.white)
            .offset(x: offset + sWidth() * baseOffset)
        }.frame(width: sWidth() * 0.9)
        .cornerRadius(10)
        .shadow(color: Color(white: 0,opacity: 0.1), radius: 5)
        .gesture(drag)
    }
}
