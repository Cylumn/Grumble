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
        HStack(spacing: 0) {
            ZStack {
                Image(systemName: "bag")
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
                .foregroundColor(self.tr.tab() == .list ? gColor(.blue2) : Color.black)
            .contentShape(Rectangle())
            .onTapGesture{
                self.toList()
            }
            
            ZStack {
                Image(systemName: "gear")
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
            .foregroundColor(self.tr.tab() == .settings ? gColor(.blue2) : Color.black)
            .contentShape(Rectangle())
            .onTapGesture{
                self.toSettings()
            }
        }.frame(width: sWidth(), height: tabHeight)
        .background(Color.white)
        .font(.system(size: sWidth() * 0.07))
        .clipped()
        .shadow(color: Color.black.opacity(0.15), radius: 10)
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
