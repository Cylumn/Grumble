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
