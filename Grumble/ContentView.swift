//
//  ContentView.swift
//  Grumble
//
//  Created by Allen Chang on 3/21/20.
//  Copyright © 2020 Cylumn, Inc. All rights reserved.
//

import SwiftUI

public struct ContentView: View {
    @ObservedObject private var uc: UserCookie = UserCookie.uc()
    @ObservedObject private var tr: TabRouter = TabRouter.tr()
    @State private var slideIndex: Int = PanelIndex.listHome.rawValue
    
    //Initializer
    public init() {
        self.tr.changeTab(.list)
    }
    
    private enum PanelIndex: Int {
        case listHome = 0
        case addFood = 1
    }
    
    //Slide changes
    public func toListHome(_ withAnim: Bool = true) {
        if withAnim {
            withAnimation(gAnim(.easeOut)){
                self.slideIndex = PanelIndex.listHome.rawValue
            }
        } else {
            self.slideIndex = PanelIndex.listHome.rawValue
        }
        UIApplication.shared.endEditing()
    }
    
    public func toListHome() {
        self.toListHome(true)
    }
    
    public func toAddFood() {
        withAnimation(gAnim(.easeOut)) {
            self.slideIndex = PanelIndex.addFood.rawValue
        }
        UIApplication.shared.endEditing()
        
        Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { timer in
            GFormRouter.gfr().callFirstResponder(.addFood)
        }
    }
    
    private var tab: some View {
        switch self.tr.tab() {
            case .list:
                return AnyView(SlideView(index: self.$slideIndex, offsetFactor: 0.3,
                                         views: [AnyView(ListView(self)),
                                                AnyView(AddToListView(self))],
                                         padding: 0, draggable: [false, true]))
            case .settings:
                return AnyView(SettingsView())
        }
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            self.tab
            TabView(self)
        }.edgesIgnoringSafeArea(.bottom)
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
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
