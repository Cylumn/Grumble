//
//  UserButton.swift
//  Grumble
//
//  Created by Allen Chang on 3/30/20.
//  Copyright © 2020 Cylumn, Inc. All rights reserved.
//

import SwiftUI

struct UserButton: View {
    var action: () -> Void
    var empty: Bool
    var text: String
    var fgEmpty = Color.white.opacity(0.4)
    var fgFull = Color.white
    var bgEmpty = Color.clear
    var bgFull = gColor(.blue4).opacity(0.4)
    var padding: CGFloat = 15
    
    var body: some View {
        ZStack{
            Button(action: self.action, label: {
                Text(self.text)
                    .font(gFont(.ubuntuMedium, .width, 2.5))
                    .padding(self.padding)
                    .frame(width: sWidth() * 0.85)
                    .background(self.empty ? self.bgEmpty : self.bgFull)
                    .cornerRadius(8)
                    .animation(.easeInOut)
            })
            .disabled(self.empty)
                .foregroundColor(self.empty ? self.fgEmpty : self.fgFull)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(self.empty ? self.fgEmpty : self.fgFull, lineWidth: 2))
        }.shadow(color: Color.clear, radius: 0)
    }
}
