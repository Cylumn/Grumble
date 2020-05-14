//
//  MainView.swift
//  Grumble
//
//  Created by Allen Chang on 3/20/20.
//  Copyright © 2020 Cylumn, Inc. All rights reserved.
//

import SwiftUI

public struct MainView: View {
    private var uac: UserAccessCookie = UserAccessCookie.uac()
    
    private var bg: some View {
        ZStack {
            gColor(.blue0)
                .edgesIgnoringSafeArea(.top)
            
            Color.white
                .edgesIgnoringSafeArea(.bottom)
        }
    }
    
    public var body: some View {
        ZStack {
            if self.uac.loggedIn() {
                self.bg
                
                if !self.uac.linkedAccount() {
                    CreateLinkedAccount()
                } else if self.uac.newUser() {
                    Welcome()
                } else {
                    ContentView()
                }
            } else {
                LoginView().transition(.move(edge: .bottom))
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        return MainView()
    }
}
