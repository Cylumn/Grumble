//
//  SettingsView.swift
//  Grumble
//
//  Created by Allen Chang on 3/21/20.
//  Copyright © 2020 Cylumn, Inc. All rights reserved.
//

import SwiftUI

public struct SettingsView: View {
    
    //Function Methods
    private func logOutUser(){
        withAnimation(gAnim(.spring)) {
            onLogout()
        }
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: nil) {
                Text("Settings")
                    .font(.custom("Ubuntu-Bold", size: sWidth() / 13))
                    .foregroundColor(gColor(.blue0))
                    .padding(20)
                
                Spacer()
                
                Image("ColoredLogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 50)
                    .padding([.leading, .trailing], 20)
            }.padding(.bottom, 10)
            List{
                Section(header: Text("General [WIP]")){
                    Text("About [WIP]")
                    Text("Security [WIP]")
                }
                Section{
                    Text("Social [WIP]")
                }
                Section{
                    Button(action: self.logOutUser, label: {
                        Text("Log Out")
                    }).foregroundColor(Color.white)
                }.listRowBackground(gColor(.blue4))
            }.listStyle(GroupedListStyle())
            Spacer()
        }.font(gFont(.ubuntuLight, 15))
    }
}

#if DEBUG
struct SettingsView_Previews: PreviewProvider {
   static var previews: some View {
      Group {
         SettingsView()
            .previewDevice(PreviewDevice(rawValue: "iPhone SE"))
            .previewDisplayName("iPhone SE")

         SettingsView()
            .previewDevice(PreviewDevice(rawValue: "iPhone XS Max"))
            .previewDisplayName("iPhone XS Max")
      }
   }
}
#endif
