//
//  ListView.swift
//  Grumble
//
//  Created by Allen Chang on 3/20/20.
//  Copyright © 2020 Cylumn, Inc. All rights reserved.
//

import SwiftUI

struct ListView: View {
    @ObservedObject var viewRouter: ViewRouter
    @State private var token: String = ""
    private var geometry: GeometryProxy
    private var contentView: ContentView
    
    var bgColor = Color(white: 0.98)
    var fontColor = Color.black
    
    var mylist: [Restaurant]?
    
    init(_ viewRouter: ViewRouter, _ geometry: GeometryProxy, _ contentView: ContentView){
        self.viewRouter = viewRouter
        self.mylist = loadRestaurantJson(filename: "mylist")
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
                        }.background(getInputColor(0))
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
                    
                    if self.mylist != nil && !self.mylist!.isEmpty {
                        ForEach(self.mylist!) { restaurant in
                            RestaurantView(restaurant.id, sWidth: Double(self.geometry.size.width), address: restaurant.address, food: restaurant.food, price: restaurant.price)
                        }
                    } else {
                        Text("List is empty!")
                    }
                }.frame(width: self.geometry.size.width)
                
                Spacer().frame(height: self.geometry.size.height / 30)
            }.edgesIgnoringSafeArea(.all)
        }
    }
    
    func toAddToList(){
        self.viewRouter.currentView = "addtolist"
    }
}

struct RestaurantView: View{
    private var name: String
    private var address: String?
    private var food: String?
    private var price: Double?
    
    private var sWidth: Double
    
    init(_ name: String, sWidth: Double, address: String? = nil, food: String? = nil, price: Double? = nil){
        self.sWidth = sWidth
        self.name = name
        self.address = address
        self.food = food
        self.price = price
    }
    
    var body: some View {
        ZStack{
            HStack{
                VStack(alignment: .leading){
                    Text(self.name)
                        .font(.custom("Ubuntu-Bold", size: CGFloat(self.sWidth) / 23))
                        .foregroundColor(Color.black)
                    
                    if self.address != nil {
                        Spacer().frame(height: CGFloat(self.sWidth) / 50)
                        
                        Text(self.address!)
                            .font(.custom("Ubuntu-LightItalic", size: CGFloat(self.sWidth) / 35))
                            .foregroundColor(Color.black)
                    }
                    
                    if self.food != nil {
                        Divider().frame(width: CGFloat(self.sWidth) * 0.3, height: 1).background(Color.gray)
                    
                        HStack{
                            Text(self.food!)
                                .font(.custom("Ubuntu-Medium", size: CGFloat(self.sWidth) / 30))
                                .foregroundColor(Color.black)
                            
                            if self.price != nil {
                                Spacer()
                                
                                Text("$" + String(format:"%.2f", self.price!))
                                    .font(.custom("Ubuntu-Medium", size: CGFloat(self.sWidth) / 20))
                                    .foregroundColor(Color.black)
                            }
                        }
                    }
                    
                    if self.address == nil && self.food == nil{
                        Spacer()
                        .frame(height: CGFloat(self.sWidth) / 20)
                    } else {
                        Spacer()
                        .frame(height: CGFloat(self.sWidth) / 40)
                    }
                }
                
                Spacer()
            }.padding(15)
            .frame(width: CGFloat(sWidth) * 0.9)
            .background(Color.white)
            .cornerRadius(10)
            .shadow(color: Color(white: 0,opacity: 0.1), radius: 5)
        }
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
