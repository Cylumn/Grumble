//
//  AddToListView.swift
//  Grumble
//
//  Created by Allen Chang on 3/22/20.
//  Copyright © 2020 Cylumn, Inc. All rights reserved.
//

import SwiftUI

struct AddToListView: View {
    @ObservedObject var viewRouter: ViewRouter
    @State var id: String = " "
    @State var food: String = " "
    @State var price: String =  " "
    @State var address: String = " "
    private var geometry: GeometryProxy
    private var contentView: ContentView
    
    var safeAreaTop: CGFloat = 40
    var navBarHeight: CGFloat = 0.12
    
    private var currencyFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .currency
        return f
    }()
    
    init(_ viewRouter: ViewRouter, _ geometry: GeometryProxy, _ contentView: ContentView){
        self.viewRouter = viewRouter
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
            .background(getBlue(0))
            
            VStack(alignment: .leading, spacing: 30){
                HStack{
                VStack(alignment: .leading, spacing: 0){
                    Text("Restaurant Name")
                    .foregroundColor(getBlue(0))
                    .font(.custom("Ubuntu-Medium", size: self.geometry.size.width / 25))
                    
                    ZStack{
                        VStack(spacing: 0){
                            HStack(spacing: 0){
                                Image(systemName: "pencil.tip")
                                .font(.system(size: self.geometry.size.width / 25 + 3))
                                    .padding(.leading, 5)
                                    .padding(.top, 10)
                                    .padding(.bottom, 15)
                                .foregroundColor(getBlue(0))

                                Spacer()
                            }.offset(y: 3)

                            Rectangle().fill(getBlue(0)).frame(height: 5)
                        }
                        
                        TextField("",text: self.$id)
                        .padding(.leading, 30)
                        .padding(.trailing, 15)
                        .padding([.top, .bottom], 5)
                        .font(.custom("Teko-SemiBold", size: self.geometry.size.width / 17))
                        .foregroundColor(getBlue(2))
                        .frame(height: 50)
                        .onAppear { self.id = "" }
                    }
                }.frame(width: self.geometry.size.width * 0.7)
                    Spacer()
                }
                
                HStack{
                VStack(alignment: .leading, spacing: 0){
                    Text("Food")
                    .foregroundColor(getBlue(0))
                    .font(.custom("Ubuntu-Medium", size: self.geometry.size.width / 25))
                    
                    ZStack{
                        VStack(spacing: 0){
                            HStack(spacing: 0){
                                Image(systemName: "flame")
                                .font(.system(size: self.geometry.size.width / 25 + 3))
                                    .padding(.leading, 5)
                                    .padding(.top, 10)
                                    .padding(.bottom, 15)
                                .foregroundColor(getBlue(0))

                                Spacer()
                            }.offset(y: 3)

                            Rectangle().fill(getBlue(0)).frame(height: 5)
                        }
                        
                        TextField("", text: self.$food)
                        .padding(.leading, 30)
                        .padding(.trailing, 15)
                        .padding([.top, .bottom], 5)
                        .font(.custom("Teko-SemiBold", size: self.geometry.size.width / 17))
                        .foregroundColor(getBlue(2))
                        .frame(height: 50)
                        .onAppear { self.food = "" }
                    }
                }.frame(width: self.geometry.size.width * 0.45)
                
                Spacer()
                    
                VStack(alignment: .leading, spacing: 0){
                    Text("Price")
                    .foregroundColor(getBlue(0))
                    .font(.custom("Ubuntu-Medium", size: self.geometry.size.width / 25))
                    
                    ZStack{
                        VStack(spacing: 0){
                            HStack(spacing: 0){
                                Image(systemName: "tag")
                                .font(.system(size: self.geometry.size.width / 25 + 3))
                                    .padding(.leading, 5)
                                    .padding(.top, 10)
                                    .padding(.bottom, 15)
                                .foregroundColor(getBlue(0))

                                Spacer()
                            }.offset(y: 3)

                            Rectangle().fill(getBlue(0)).frame(height: 5)
                        }
                        
                        ZStack{
                            PriceFieldContainer("", text: self.$price, geometry
                            ).frame(width: 150, height: 50)
                            .onAppear { self.price = "" }
                        }.frame(width: self.geometry.size.width * 0.35)
                    }
                }.frame(width: self.geometry.size.width * 0.35)
                }
                
                HStack{
                VStack(alignment: .leading, spacing: 0){
                    Text("Address")
                    .foregroundColor(getBlue(0))
                    .font(.custom("Ubuntu-Medium", size: self.geometry.size.width / 25))
                    
                    ZStack{
                        VStack(spacing: 0){
                            HStack(spacing: 0){
                                Image(systemName: "mappin.and.ellipse")
                                .font(.system(size: self.geometry.size.width / 25 + 3))
                                    .padding(.leading, 5)
                                    .padding(.top, 10)
                                    .padding(.bottom, 15)
                                .foregroundColor(getBlue(0))

                                Spacer()
                            }.offset(y: 3)

                            Rectangle().fill(getBlue(0)).frame(height: 5)
                        }
                        
                        TextField("", text: self.$address)
                        .padding(.leading, 30)
                        .padding(.trailing, 15)
                        .padding([.top, .bottom], 5)
                        .font(.custom("Teko-SemiBold", size: self.geometry.size.width / 17))
                        .foregroundColor(getBlue(2))
                        .frame(height: 50)
                        .onAppear { self.address = "" }
                    }
                }.frame(width: self.geometry.size.width * 0.9)
                }
            }.frame(width: self.geometry.size.width * 0.9)
            
            Button(action: self.addItem, label:{
                Text("+ ADD ITEM")
                    .foregroundColor(getBlue(4))
                    .font(.custom("Ubuntu-Bold", size: self.geometry.size.width / 25))
                    .padding(10)
                    .frame(width: geometry.size.width * 0.7)
                .overlay(RoundedRectangle(cornerRadius: 8)
                .stroke(getBlue(4), lineWidth: 8))
            }).background(getInputColor(1))
                .cornerRadius(8)
            
            Spacer()
        }
        }.contentShape(Rectangle())
        .edgesIgnoringSafeArea(.all)
    }
    
    func addItem(){
        self.id = ""
        self.food = ""
        self.price = ""
        self.address = ""
        
        contentView.toList()
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
