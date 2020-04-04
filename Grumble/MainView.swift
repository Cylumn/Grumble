//
//  MainView.swift
//  Grumble
//
//  Created by Allen Chang on 3/20/20.
//  Copyright © 2020 Cylumn, Inc. All rights reserved.
//

import SwiftUI
import Firebase

struct MainView: View {
    @ObservedObject private var uc: UserCookie = UserCookie.uc()
    
    var body: some View {
        GeometryReader{ geometry in
            ZStack{
                if self.uc.loggedIn() {
                    ContentView()
                } else {
                    LoginView(geometry)
                }
            }
        }.edgesIgnoringSafeArea(.all)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
