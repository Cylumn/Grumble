//
//  ListView.swift
//  Grumble
//
//  Created by Allen Chang on 3/20/20.
//  Copyright © 2020 Cylumn, Inc. All rights reserved.
//

import SwiftUI

public struct ListView: View {
    @ObservedObject private var uc: UserCookie = UserCookie.uc()
    private var contentView: ContentView
    @State private var searchToken: String = ""
    @State var listDescription: String = "Loading..."
    
    //Initializer
    public init(_ contentView: ContentView){
        self.contentView = contentView
    }
    
    public var body: some View {
        ZStack{
            Image("Background").resizable().edgesIgnoringSafeArea(.all)
            
            ScrollView(showsIndicators: true){
                Spacer().frame(height: sHeight() / 15)
                
                HStack{
                    Text("My List")
                        .font(.custom("Ubuntu-Bold", size: sWidth() / 13))
                        .foregroundColor(Color.white)
                    
                    Spacer()
                }.padding([.leading, .trailing], 20)
                
                VStack(spacing: 10){
                    HStack{
                        ZStack(alignment: .leading) {
                            Image(systemName: "magnifyingglass")
                            .padding(15)
                            .foregroundColor(Color(white: 0.3))
                            
                            if self.searchToken.isEmpty {
                                Text("Filter List")
                                    .foregroundColor(Color(white: 0.5))
                                    .padding([.leading, .trailing], 40)
                                    .padding([.top, .bottom], 10)
                                    .font(.custom("Ubuntu-Light", size: sWidth() / 22))
                            }
                            TextField("", text: self.$searchToken)
                                .padding(.leading, 40)
                                .padding(.trailing, 15)
                                .padding([.top, .bottom], 10)
                                .font(.custom("Ubuntu-Light", size: sWidth() / 22))
                                .foregroundColor(Color(white: 0.2))
                                .frame(minWidth: 30, maxWidth: sWidth() * 0.55)
                        }.background(gColor(.inputDefault))
                        .cornerRadius(8)
                        
                        Spacer()
                        
                        Button(action: self.contentView.toAddFood, label: {
                            Text("+ Add Location")
                                .padding(15)
                                .font(.custom("Ubuntu-Bold", size: sWidth() / 35))
                                .foregroundColor(Color.white)
                                .overlay(RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.white, lineWidth: 2))
                        })
                    }.frame(width: sWidth() * 0.9)
                        .padding(.bottom, 13)
                        .offset(y: -sWidth() / 40)
                    
                    if !self.uc.foodList().isEmpty {
                        ForEach(self.uc.foodList().keys.sorted(), id: \.self) { key in
                            RestaurantListItem(key, address: self.uc.foodList()[key]?.address, food: self.uc.foodList()[key]?.food ?? "unlisted", price: self.uc.foodList()[key]?.price)
                        }
                    } else {
                        Text(self.listDescription)
                    }
                }.frame(width: sWidth())
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
                
                Spacer().frame(height: sHeight() / 30)
            }.edgesIgnoringSafeArea(.all)
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
