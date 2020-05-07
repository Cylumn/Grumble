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
        if self.tr.tab() != .list {
            self.tr.changeTab(.list)
            self.contentView.toListHome(false)
        }
    }
    
    private func toSettings() {
        if self.tr.tab() != .settings {
            self.tr.changeTab(.settings)
        }
    }
    
    private func tabIcon(_ iconName: String, _ tab: Tab, _ onClick: @escaping () -> Void) -> some View {
        ZStack {
            Image(systemName: iconName)
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
        .foregroundColor(self.tr.tab() == tab ? gColor(.blue2) : Color.black)
        .contentShape(Rectangle())
        .onTapGesture{
            onClick()
        }
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            VStack(spacing: 0) {
                Rectangle()
                    .fill(Color(white: 0.8))
                    .frame(width: sWidth(), height: 1)
                HStack(spacing: 0) {
                    self.tabIcon("cube.box", .list, self.toList)
                    
                    self.tabIcon("gear", .settings, self.toSettings)
                }
            }.frame(width: sWidth(), height: tabHeight)
            .background(Color.white)
        }.font(.system(size: sWidth() * 0.06))
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
