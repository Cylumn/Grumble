//
//  LoadingProfile.swift
//  Grumble
//
//  Created by Allen Chang on 5/17/20.
//  Copyright © 2020 Cylumn, Inc. All rights reserved.
//

import SwiftUI

//MARK: Views
public struct LoadingProfile: View {
    @State private var imageScale: CGFloat = 0.8
    @State private var timer: Timer? = nil
    
    public var body: some View {
        ZStack {
            Color(white: 0.95)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 40) {
                ZStack {
                    Image("LoadingIcon")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: sWidth() * 0.7 * self.imageScale)
                        .onAppear {
                            withAnimation(gAnim(.springSlow)) {
                                self.imageScale = 1
                            }
                            
                            self.timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { _ in
                                withAnimation(.easeInOut(duration: 2)) {
                                    if self.imageScale < 1 {
                                        self.imageScale = 1
                                    } else {
                                        self.imageScale = 0.8
                                    }
                                }
                            }
                        }
                }.frame(width: sWidth() * 0.7, height: sWidth() * 0.7)
            
                Text(".. Loading Profile ..")
                    .font(gFont(.ubuntuLight, .width, 3.5))
                    .foregroundColor(Color(white: 0.2))
            }.position(x: sWidth() * 0.5, y: sHeight() * 0.4)
        }
    }
}

struct LoadingProfile_Previews: PreviewProvider {
    static var previews: some View {
        LoadingProfile()
    }
}
