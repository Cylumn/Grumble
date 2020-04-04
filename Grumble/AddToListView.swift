//
//  AddToListView.swift
//  Grumble
//
//  Created by Allen Chang on 3/22/20.
//  Copyright © 2020 Cylumn, Inc. All rights reserved.
//

import SwiftUI

struct AddToListView: View {
    @ObservedObject private var uc: UserCookie = UserCookie.uc()
    @State var id: String = ""
    @State var food: String = ""
    @State var price: String =  ""
    @State var address: String = ""
    private var geometry: GeometryProxy
    private var contentView: ContentView
    
    var safeAreaTop: CGFloat = 40
    var navBarHeight: CGFloat = 0.12
    
    private var currencyFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .currency
        return f
    }()
    
    init(_ geometry: GeometryProxy, _ contentView: ContentView){
        self.geometry = geometry
        self.contentView = contentView
    }
    
    var body: some View {
        ZStack{
            Color.white
        VStack(spacing: 30){
            ZStack{
                HStack{
                    Button(action: self.contentView.toList, label: {
                        Image(systemName: "chevron.left")
                            .foregroundColor(Color.white)
                            .padding(.leading, 5)
                    }).frame(width: 50, height: self.geometry.size.width * self.navBarHeight)
                    
                    Spacer()
                }
                
                Text("Add to My List")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(Color.white)
                    .padding(12)
            }
            .padding(.top, self.safeAreaTop)
            .frame(width: self.geometry.size.width, height: self.geometry.size.width * self.navBarHeight + self.safeAreaTop)
            .background(gColor(.blue0))
            
            VStack(alignment: .leading, spacing: 30){
                HStack{
                VStack(alignment: .leading, spacing: 0){
                    Text("Restaurant Name *")
                        .foregroundColor(gColor(.blue0))
                    .font(.custom("Ubuntu-Medium", size: self.geometry.size.width / 25))
                    
                    ZStack{
                        VStack(spacing: 0){
                            HStack(spacing: 0){
                                Image(systemName: "pencil.tip")
                                .font(.system(size: self.geometry.size.width / 25 + 3))
                                    .padding(.leading, 5)
                                    .padding(.top, 10)
                                    .padding(.bottom, 15)
                                    .foregroundColor(gColor(.blue0))

                                Spacer()
                            }.offset(y: 3)

                            Rectangle().fill(gColor(.blue0)).frame(height: 5)
                        }
                        
                        FieldContainer("", text: self.$id, geometry, 0)
                            .frame(width: self.geometry.size.width * 0.7, height: 50)
                    }
                }.frame(width: self.geometry.size.width * 0.7)
                    Spacer()
                }
                
                HStack{
                VStack(alignment: .leading, spacing: 0){
                    Text("Food *")
                    .foregroundColor(gColor(.blue0))
                    .font(.custom("Ubuntu-Medium", size: self.geometry.size.width / 25))
                    
                    ZStack{
                        VStack(spacing: 0){
                            HStack(spacing: 0){
                                Image(systemName: "flame")
                                .font(.system(size: self.geometry.size.width / 25 + 3))
                                    .padding(.leading, 5)
                                    .padding(.top, 10)
                                    .padding(.bottom, 15)
                                .foregroundColor(gColor(.blue0))

                                Spacer()
                            }.offset(y: 3)

                            Rectangle().fill(gColor(.blue0)).frame(height: 5)
                        }
                        
                        FieldContainer("", text: self.$food, geometry, 1)
                            .frame(width: self.geometry.size.width * 0.45, height: 50)
                    }
                }.frame(width: self.geometry.size.width * 0.45)
                
                Spacer()
                    
                VStack(alignment: .leading, spacing: 0){
                    Text("Price")
                    .foregroundColor(gColor(.blue0))
                    .font(.custom("Ubuntu-Medium", size: self.geometry.size.width / 25))
                    
                    ZStack{
                        VStack(spacing: 0){
                            HStack(spacing: 0){
                                Image(systemName: "tag")
                                .font(.system(size: self.geometry.size.width / 25 + 3))
                                    .padding(.leading, 5)
                                    .padding(.top, 10)
                                    .padding(.bottom, 15)
                                .foregroundColor(gColor(.blue0))

                                Spacer()
                            }.offset(y: 3)

                            Rectangle().fill(gColor(.blue0)).frame(height: 5)
                        }
                        
                        ZStack{
                            FieldContainer("", text: self.$price, geometry, 2, isPriceField: true)
                                .frame(width: 150, height: 50)
                        }.frame(width: self.geometry.size.width * 0.35)
                    }
                }.frame(width: self.geometry.size.width * 0.35)
                }
                
                HStack{
                VStack(alignment: .leading, spacing: 0){
                    Text("Address")
                    .foregroundColor(gColor(.blue0))
                    .font(.custom("Ubuntu-Medium", size: self.geometry.size.width / 25))
                    
                    ZStack{
                        VStack(spacing: 0){
                            HStack(spacing: 0){
                                Image(systemName: "mappin.and.ellipse")
                                .font(.system(size: self.geometry.size.width / 25 + 3))
                                    .padding(.leading, 5)
                                    .padding(.top, 10)
                                    .padding(.bottom, 15)
                                .foregroundColor(gColor(.blue0))

                                Spacer()
                            }.offset(y: 3)

                            Rectangle().fill(gColor(.blue0)).frame(height: 5)
                        }
                        
                        FieldContainer("", text: self.$address, geometry, 4)
                            .frame(width: self.geometry.size.width * 0.9, height: 50)
                    }
                }.frame(width: self.geometry.size.width * 0.9)
                }
            }.frame(width: self.geometry.size.width * 0.9)
            
            Button(action: self.addItem, label:{
                Text("+ ADD ITEM")
                    .font(.custom("Ubuntu-Bold", size: self.geometry.size.width / 25))
                    .padding(10)
                    .frame(width: geometry.size.width * 0.7)
                    .animation(nil)
                    .foregroundColor((self.id.isEmpty || self.food.isEmpty) ? gColor(.lightTurquoise).opacity(0.3) : gColor(.blue4))
                    .overlay(RoundedRectangle(cornerRadius: 8)
                        .stroke((self.id.isEmpty || self.food.isEmpty) ? gColor(.lightTurquoise).opacity(0.3) : gColor(.blue4), lineWidth: 8))
                    .animation(.easeInOut(duration: 0.1))
            }).background((self.id.isEmpty || self.food.isEmpty) ? gColor(.lightTurquoise).opacity(0.3) : gColor(.lightTurquoise).opacity(0.7))
            .cornerRadius(8)
            .disabled(self.id.isEmpty || self.food.isEmpty)
            
            Spacer()
        }
        }.contentShape(Rectangle())
        .edgesIgnoringSafeArea(.all)
    }
    
    func addItem(){
        var foodItem = [:] as [String: Any]
        foodItem["address"] = !self.address.isEmpty ? self.address : nil
        foodItem["food"] = !self.food.isEmpty ? self.food : "undefined"
        foodItem["price"] = parsePriceField(self.price)
        
        let foodDictionary = foodItem as NSDictionary
        self.uc.appendFoodList(self.id, Restaurant(foodDictionary))
        appendLocalFood(self.id, foodDictionary)
        appendCloudFood(self.id, foodDictionary)
        
        self.id = ""
        self.food = ""
        self.price = ""
        self.address = ""
        
        contentView.toList()
    }
    
    func parsePriceField(_ text: String) -> Double? {
        var text = text
        
        text.removeAll(where: {$0 == "$" || $0 == "."})
        if let firstZero = text.firstIndex(where: {$0 != "0"}) {
            text.removeSubrange(text.startIndex..<firstZero)
        } else {
            text = ""
        }
        
        if text.isEmpty {
            return nil
        } else {
            while text.count < 3 {
                text = "0" + text
            }
            text.insert(contentsOf: ".", at: text.index(text.endIndex, offsetBy: -2))
            
            return Double(text)
        }
    }
}

#if DEBUG
struct AddToListView_Previews: PreviewProvider {
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
