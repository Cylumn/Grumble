//
//  MainView.swift
//  Grumble
//
//  Created by Allen Chang on 3/20/20.
//  Copyright © 2020 Cylumn, Inc. All rights reserved.
//

import SwiftUI

//MARK: - Views
public struct MainView: View {
    @ObservedObject private var uac: UserAccessCookie = UserAccessCookie.uac()
    @State private var lagTest: CGFloat = 0
    @State private var timer: Timer? = nil
    
    private var loginView: LoginView
    private var loadingProfile: LoadingProfile
    private var createLinkedAccount: CreateLinkedAccount
    private var welcome: Welcome
    private var contentView: ContentView
    
    public init() {
        self.loginView = LoginView()
        self.loadingProfile = LoadingProfile()
        self.createLinkedAccount = CreateLinkedAccount()
        self.welcome = Welcome()
        self.contentView = ContentView()
    }
    
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
            if self.uac.loggedIn() == .loggedOut {
                self.loginView.transition(.move(edge: .bottom))
            } else if self.uac.loggedIn() == .inProgress {
                self.loadingProfile.transition(.opacity)
            } else if self.uac.loggedIn() == .loggedIn {
                self.bg
                
                if !self.uac.linkedAccount() {
                    self.createLinkedAccount
                } else if self.uac.newUser() {
                    self.welcome
                } else {
                    self.contentView
                }
            }
            
            /*Rectangle()
                .fill(Color.red.opacity(0.3 + Double(0.7 * self.lagTest / sWidth())))
                .frame(width: lagTest, height: 10)
                .position(x: sWidth() * 0.5, y: sHeight() - tabHeight)
                .onAppear() {
                    if self.timer == nil {
                        self.timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { _ in
                            withAnimation(.linear(duration: 3)) {
                                if self.lagTest < sWidth() {
                                    self.lagTest = sWidth()
                                } else {
                                    self.lagTest = 0
                                }
                            }
                        }
                        self.timer!.fire()
                    }
            }*/
        }
    }
}

//MARK: - Previews
struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        return MainView()
    }
}
