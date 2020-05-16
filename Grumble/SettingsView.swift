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
    private var contentView: ContentView
    
    public init(_ contentView: ContentView) {
        self.contentView = contentView
        
        UITableView.appearance().backgroundColor = .clear
        UITableViewCell.appearance().selectionStyle = UITableViewCell.SelectionStyle.default
        let bg = UIView()
        bg.backgroundColor = UIColor(white: 0.9, alpha: 0.5)
        UITableViewCell.appearance().selectedBackgroundView = bg
    }
    
    private enum PageForm {
        case about
        case ghorblin
        case security
    }
    
    //Function Methods
    private func logOutUser() {
        withAnimation(gAnim(.spring)) {
            onLogout()
        }
    }
    
    private func sectionHeader(_ icon: String, _ label: String) -> some View {
        HStack {
            Image(systemName: icon)
            Text(label)
                .font(gFont(.ubuntuBold, .width, 2))
            Spacer()
        }.foregroundColor(Color(white: 0.2))
    }
    
    private func buttonLabel(_ label: String, _ action: @escaping () -> Void) -> some View {
        Button(action: {
            withAnimation(gAnim(.easeOut)) {
                action()
            }
        }, label: {
            HStack {
                Text(label)
                
                Spacer()
                
                Image(systemName: "chevron.right")
            }
        }).foregroundColor(gColor(.blue0))
    }
    
    private func isPagePresented(page: PageForm) -> Binding<Bool> {
        Binding<Bool>(get: {
            self.page == page
        }, set: {
            self.page = $0 ? page : nil
            
            if !$0 {
                UIApplication.shared.endEditing()
            }
        })
    }
    
    private var settings: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: nil) {
                Text("Settings")
                    .font(gFont(.ubuntuBold, .width, 4))
                    .foregroundColor(Color(white: 0.2))
                    .padding(20)
                
                Spacer()
                
                Image("ColoredLogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50)
                    .padding([.leading, .trailing], 20)
            }.background(Color.white)
            
            List {
                Section(header:
                self.sectionHeader("info.circle.fill", "General [WIP]")
                    .padding(.top, 30)) {
                    self.buttonLabel("About") {
                        self.page = .about
                    }
                    self.buttonLabel("Your Ghorblin") {
                        self.page = .ghorblin
                    }
                    self.buttonLabel("Security") {
                        self.page = .security
                    }
                }.listRowBackground(Color.white)
                
                Section(header: self.sectionHeader("person.2.fill", "Social [WIP]")) {
                    self.buttonLabel("Privacy [WIP]") {}
                }.listRowBackground(Color.white)
                
                Section {
                    Button(action: self.logOutUser, label: {
                        HStack {
                            Spacer()
                            Text("Log Out")
                            Spacer()
                        }
                    }).foregroundColor(Color.white)
                }.listRowBackground(gColor(.blue4))
            }.environment(\.horizontalSizeClass, .regular)
            .listStyle(GroupedListStyle())
            .font(gFont(.ubuntuLight, .width, 1.8))
            Spacer()
        }.background(Color(white: 0.95))
        .font(gFont(.ubuntuLight, 15))
    }
    
    public var body: some View {
        ZStack {
            self.settings
                .offset(x: self.page == nil ? 0 : sWidth() * -0.3)
                .zIndex(0)
            
            TabView()
            
            ZStack {
                if self.page == . about {
                    Welcome(startIndex: Welcome.Pages.introduction.rawValue, isPresented: self.isPagePresented(page: .about))
                        .transition(.move(edge: .trailing))
                }
                
                if self.page == .ghorblin {
                    Welcome(startIndex: Welcome.Pages.assignment.rawValue, endIndex: Welcome.Pages.assignment.rawValue, isPresented: self.isPagePresented(page: .about))
                        .transition(.move(edge: .trailing))
                }
                
                if self.page == .security {
                    SecurityForm(self.isPagePresented(page: .security))
                        .transition(.move(edge: .trailing))
                }
            }.zIndex(1)
        }
    }
}

#if DEBUG
struct SettingsView_Previews: PreviewProvider {
   static var previews: some View {
      Group {
         SettingsView(ContentView())
            .previewDevice(PreviewDevice(rawValue: "iPhone SE"))
            .previewDisplayName("iPhone SE")

         SettingsView(ContentView())
            .previewDevice(PreviewDevice(rawValue: "iPhone XS Max"))
            .previewDisplayName("iPhone XS Max")
      }
   }
}
#endif
