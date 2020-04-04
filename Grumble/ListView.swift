//
//  ListView.swift
//  Grumble
//
//  Created by Allen Chang on 3/20/20.
//  Copyright © 2020 Cylumn, Inc. All rights reserved.
//

import SwiftUI

struct ListView: View {
    @ObservedObject private var uc: UserCookie = UserCookie.uc()
    @State private var token: String = ""
    private var geometry: GeometryProxy
    private var contentView: ContentView
    
    var bgColor = Color(white: 0.98)
    var fontColor = Color.black
    @State var listDescription: String = "Loading..."
    
    init(_ geometry: GeometryProxy, _ contentView: ContentView){
        self.geometry = geometry
        self.contentView = contentView
    }
    
    var body: some View {
        ZStack{
            Image("Background").resizable().edgesIgnoringSafeArea(.all)
            
            ScrollView(showsIndicators: true){
                Spacer().frame(height: self.geometry.size.height / 15)
                
                HStack{
                    Text("My List")
                        .font(.custom("Ubuntu-Bold", size: self.geometry.size.width / 13))
                        .foregroundColor(Color.white)
                    
                    Spacer()
                }.padding([.leading, .trailing], 20)
                
                VStack(spacing: 10){
                    HStack{
                        ZStack(alignment: .leading) {
                            Image(systemName: "magnifyingglass")
                            .padding(15)
                            .foregroundColor(Color(white: 0.3))
                            
                            if self.token.isEmpty {
                                Text("Filter List")
                                    .foregroundColor(Color(white: 0.5))
                                    .padding([.leading, .trailing], 40)
                                    .padding([.top, .bottom], 10)
                                    .font(.custom("Ubuntu-Light", size: self.geometry.size.width / 22))
                            }
                            TextField("", text: self.$token)
                                .padding(.leading, 40)
                                .padding(.trailing, 15)
                                .padding([.top, .bottom], 10)
                                .font(.custom("Ubuntu-Light", size: self.geometry.size.width / 22))
                                .foregroundColor(Color(white: 0.2))
                                .frame(minWidth: 30, maxWidth: self.geometry.size.width * 0.55)
                        }.background(gColor(.inputDefault))
                        .cornerRadius(8)
                        
                        Spacer()
                        
                        Button(action: self.contentView.toAddToList, label: {
                            Text("+ Add Location")
                                .padding(15)
                                .font(.custom("Ubuntu-Bold", size: self.geometry.size.width / 35))
                                .foregroundColor(Color.white)
                                .overlay(RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.white, lineWidth: 2))
                        })
                    }.frame(width: self.geometry.size.width * 0.9)
                        .padding(.bottom, 13)
                        .offset(y: -self.geometry.size.width / 40)
                    
                    if !self.uc.foodList().isEmpty {
                        ForEach(self.uc.foodList().keys.sorted(), id: \.self) { key in
                            RestaurantView(self.geometry, key, address: self.uc.foodList()[key]?.address, food: self.uc.foodList()[key]?.food ?? "unlisted", price: self.uc.foodList()[key]?.price)
                        }
                    } else {
                        Text(self.listDescription)
                    }
                }.frame(width: self.geometry.size.width)
                .onAppear{
                    loadCloudData() { data in
                        guard let foodList = data?["foodList"] as? NSDictionary else {
                            self.listDescription = "List is Empty!"
                            return
                        }
                        if foodList.count == 0 {
                            self.listDescription = "List is Empty!"
                        }
                    }
                }
                
                Spacer().frame(height: self.geometry.size.height / 30)
            }.edgesIgnoringSafeArea(.all)
        }
    }
}

struct RestaurantView: View{
    @ObservedObject var uc: UserCookie = UserCookie.uc()
    private var geometry: GeometryProxy
    private var name: String
    private var address: String?
    private var food: String
    private var price: Double?
    
    @State private var offset: CGFloat = 0
    @State private var baseOffset: CGFloat = 0
    @State private var lastDragPosition: DragGesture.Value?
    private var draggableOffset: CGFloat = 0.25
    
    init(_ geometry: GeometryProxy, _ name: String, address: String? = nil, food: String, price: Double? = nil){
        self.geometry = geometry
        self.name = name
        self.address = address
        self.food = food
        self.price = price
    }
    
    var drag: some Gesture {
        DragGesture()
            .onChanged { gesture in
                if (self.geometry.size.width * self.baseOffset + gesture.translation.width < 0 && self.geometry.size.width * self.baseOffset + gesture.translation.width > -self.geometry.size.width * self.draggableOffset){
                    self.offset = gesture.translation.width
                }
                
                self.lastDragPosition = gesture
            }
            .onEnded { gesture in
                let timeDiff = gesture.time.timeIntervalSince(self.lastDragPosition!.time)
                let speed = (gesture.translation.width - self.offset) / CGFloat(timeDiff)
                
                withAnimation(Animation.linear(duration: Double(min((30.0 / abs(speed)), 0.3)))) {
                    if speed < 0 && self.offset < (-self.draggableOffset / 2 - self.baseOffset) * self.geometry.size.width || speed < -130 {
                        self.baseOffset = -self.draggableOffset
                    } else {
                        self.baseOffset = 0
                    }
                    
                    self.offset = 0
                }
            }
    }
    
    var body: some View {
        ZStack{
            Color.red
            HStack{
                Spacer()
                
                Button(action: self.removeFood, label: {
                    Text("Delete")
                    .font(.custom("Ubuntu-Bold", size: self.geometry.size.width / 20))
                    .foregroundColor(Color.white)
                    .padding(.trailing, 15)
                })
            }
            
            HStack{
                VStack(alignment: .leading){
                    Text(self.name)
                        .font(.custom("Ubuntu-Bold", size: self.geometry.size.width / 23))
                        .foregroundColor(Color.black)
                    
                    if self.address != nil {
                        Spacer().frame(height: self.geometry.size.width / 50)
                        
                        Text(self.address!)
                            .font(.custom("Ubuntu-LightItalic", size: self.geometry.size.width / 35))
                            .foregroundColor(Color.black)
                    }
                    
                    Divider().frame(width: self.geometry.size.width * 0.3, height: 1).background(Color.gray)
                
                    HStack{
                        Text(self.food)
                            .font(.custom("Ubuntu-Medium", size: self.geometry.size.width / 30))
                            .foregroundColor(Color.black)
                        
                        if self.price != nil {
                            Spacer()
                            
                            Text("$" + String(format:"%.2f", self.price!))
                                .font(.custom("Ubuntu-Medium", size: self.geometry.size.width / 20))
                                .foregroundColor(Color.black)
                        }
                    }
                    
                    Spacer()
                    .frame(height: self.geometry.size.width / 40)
                }
                
                Spacer()
            }.padding(15)
            .background(Color.white)
            .offset(x: offset + self.geometry.size.width * baseOffset)
        }.frame(width: self.geometry.size.width * 0.9)
        .cornerRadius(10)
        .shadow(color: Color(white: 0,opacity: 0.1), radius: 5)
        .gesture(drag)
    }
    
    func removeFood() {
        self.uc.removeFoodList(self.name)
        removeLocalFood(self.name)
        removeCloudFood(self.name)
    }
}

#if DEBUG
struct ListView_Previews: PreviewProvider {
   static var previews: some View {
      Group {
         ContentView()
            .previewDevice(PreviewDevice(rawValue: "iPhone SE"))
            .previewDisplayName("iPhone SE")

         ContentView()
            .previewDevice(PreviewDevice(rawValue: "iPhone XS Max"))
            .previewDisplayName("iPhone XS Max")
      }
   }
}
#endif
