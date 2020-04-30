//
//  SettingsView.swift
//  Grumble
//
//  Created by Allen Chang on 3/21/20.
//  Copyright © 2020 Cylumn, Inc. All rights reserved.
//

import SwiftUI
import Firebase

public struct SettingsView: View {
    @State private var page: PageForm? = nil
    
    private enum PageForm {
        case security
    }
    
    //Function Methods
    private func logOutUser(){
        withAnimation(gAnim(.spring)) {
            onLogout()
        }
    }
    
    private var settings: some View {
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
                Section(header: Text("General [WIP]")) {
                    Text("About [WIP]")
                    if (Auth.auth().currentUser!.providerData[0].providerID == EmailAuthProviderID) {
                        Button(action: {
                            withAnimation(gAnim(.easeOut)) {
                                self.page = .security
                                TabRouter.tr().hide(true)
                                KeyboardObserver.appendField(.security)
                            }
                        }, label: {
                            Text("Security")
                        })
                    }
                }
                Section(header: Text("Social [WIP]")) {
                    Text("Privacy [WIP]")
                }
                Section {
                    Button(action: self.logOutUser, label: {
                        Text("Log Out")
                    }).foregroundColor(Color.white)
                }.listRowBackground(gColor(.blue4))
            }.listStyle(GroupedListStyle())
            Spacer()
        }.font(gFont(.ubuntuLight, 15))
    }
    
    public var body: some View {
        ZStack {
            self.settings
            
            SecurityForm(Binding<Bool>(get: {
                self.page == .security
            }, set: {
                self.page = $0 ? .security : nil
                TabRouter.tr().hide($0)
                
                if !$0 {
                    UIApplication.shared.endEditing()
                    KeyboardObserver.clearFields()
                }
            })).offset(x: self.page == .security ? 0 : sWidth())
        }
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
