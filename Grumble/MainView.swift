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
            if self.uc.loggedIn() {
                if !self.uc.linkedAccount() || self.uc.newUser() {
                    self.bg
                }
                
                if !self.uc.linkedAccount() {
                    CreateLinkedAccount()
                } else if self.uc.newUser() {
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
