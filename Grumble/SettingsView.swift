//
//  SettingsView.swift
//  Grumble
//
//  Created by Allen Chang on 3/21/20.
//  Copyright © 2020 Cylumn, Inc. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    private var geometry: GeometryProxy
    
    init(_ geometry: GeometryProxy){
        self.geometry = geometry
    }
    
    var body: some View {
        VStack(alignment: .leading){
            Spacer().frame(height: self.geometry.size.height / 13)
            
            HStack{
                Text("Settings")
                    .font(.custom("Ubuntu-Bold", size: self.geometry.size.width / 13))
                    .foregroundColor(gColor(.blue0))
                
                Spacer()
                Image("ColoredLogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
            }.padding([.leading, .trailing], 20)
            
            List{
                Section(header: Text("General")){
                    Text("About")
                    Text("Security")
                }
                Section{
                    Text("Social")
                }
                Section{
                    Button(action: self.logOutUser, label: {
                        Text("Log Out")
                    })
                }.listRowBackground(gColor(.blue4))
            }.listStyle(GroupedListStyle())
            
            Spacer()
        }.font(.custom("Ubuntu-Light", size: 15))
        .edgesIgnoringSafeArea(.all)
    }
    
    func logOutUser(){
        withAnimation {
            onLogout()
        }
    }
}

#if DEBUG
struct SettingsView_Previews: PreviewProvider {
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
