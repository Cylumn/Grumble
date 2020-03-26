//
//  MainView.swift
//  Grumble
//
//  Created by Allen Chang on 3/20/20.
//  Copyright © 2020 Cylumn, Inc. All rights reserved.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var userID: UserID

    var body: some View {
        GeometryReader{ geometry in
            ZStack{
                if self.userID.loggedIn {
                    ContentView()
                } else {
                    LoginView(geometry).environmentObject(self.userID)
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
