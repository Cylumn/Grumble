//
//  MainView.swift
//  Grumble
//
//  Created by Allen Chang on 3/20/20.
//  Copyright © 2020 Cylumn, Inc. All rights reserved.
//

import SwiftUI

public struct MainView: View {
    @ObservedObject private var uc: UserCookie = UserCookie.uc()
    
    public var body: some View {
        ZStack {
            if self.uc.loggedIn() {
                ContentView()
            } else {
                LoginView().transition(.move(edge: .bottom))
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
