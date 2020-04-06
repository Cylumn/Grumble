//
//  TabView.swift
//  Grumble
//
//  Created by Allen Chang on 3/22/20.
//  Copyright © 2020 Cylumn, Inc. All rights reserved.
//

import SwiftUI

public struct TabView: View {
    @ObservedObject private var tr: TabRouter = TabRouter.tr()
    private var contentView: ContentView
    private var iconHeight: CGFloat
    
    //Initializer
    public init(_ contentView: ContentView) {
        self.contentView = contentView
        self.iconHeight = 25
    }
    
    //Function Methods
    private func toList() {
        self.tr.changeTab(.list)
        self.contentView.toListHome(false)
    }
    
    private func toSettings() {
        self.tr.changeTab(.settings)
    }
    
    public var body: some View {
        HStack(spacing: nil) {
            Image(systemName: self.tr.tab() == .list ? "bag.fill" : "bag")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: sWidth() * 0.5, height: self.iconHeight)
                .contentShape(Rectangle())
                .onTapGesture{
                    self.toList()
                }
            
            Image(systemName: "gear")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: sWidth() * 0.5, height: self.iconHeight)
                .contentShape(Rectangle())
                .font(Font.title.weight(self.tr.tab() == .settings ? .black : .medium))
                .onTapGesture{
                    self.toSettings()
                }
        }.frame(width: sWidth(), height: sHeight() * 0.085)
        .background(Color.white)
        .foregroundColor(Color.black)
        .clipped()
        .shadow(color: Color.black.opacity(0.2), radius: 3)
        .edgesIgnoringSafeArea(.all)
    }
}

#if DEBUG
struct TabView_Previews: PreviewProvider {
   static var previews: some View {
      Group {
         ContentView()
            .previewDevice(PreviewDevice(rawValue: "iPhone SE"))
            .previewDisplayName("iPhone SE")

         ContentView()
            .previewDevice(PreviewDevice(rawValue: "iPhone XS Max"))
            .previewDisplayName("iPhone XS Max")
      }
   }
}
#endif
