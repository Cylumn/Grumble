//
//  ContentView.swift
//  Grumble
//
//  Created by Allen Chang on 3/21/20.
//  Copyright © 2020 Cylumn, Inc. All rights reserved.
//

import SwiftUI

public let navBarHeight: CGFloat = sWidth() * 0.12
public let tabHeight: CGFloat = sHeight() * 0.085

public let navBarFont: Font = gFont(.ubuntuBold, 18)

public struct ContentView: View {
    @ObservedObject private var uc: UserCookie = UserCookie.uc()
    @ObservedObject private var tr: TabRouter = TabRouter.tr()
    @State private var slideIndex: Int = PanelIndex.listHome.rawValue
    @State private var slideOffset: CGFloat = 0
    
    //Panel Enums
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
        KeyboardObserver.reset(.listhome)
        ListCookie.lc().searchFocused = false
    }
    
    public func toListHome() {
        self.toListHome(true)
    }
    
    public func toAddFood(_ currentFID: String? = nil) {
        withAnimation(gAnim(.easeOut)) {
            self.slideIndex = PanelIndex.addFood.rawValue
        }
        UIApplication.shared.endEditing()
        KeyboardObserver.reset(.addfood)
        Timer.scheduledTimer(withTimeInterval: 0.43, repeats: false) { timer in
            GFormRouter.gfr().callFirstResponder(.addFood)
        }
        
        switch currentFID {
        case nil:
            AddFood.clearFields()
        default:
            AddFoodCookie.afc().currentFID = currentFID
        }
    }
    
    private func slideChange(_ index: Int) {
        switch index {
        case PanelIndex.listHome.rawValue:
            toListHome()
        case PanelIndex.addFood.rawValue:
            toAddFood()
        default:
            break
        }
    }
    
    public var body: some View {
        ZStack(alignment: .bottom) {
            SlideView(index: self.$slideIndex, offsetFactor: 0.3,
                views: [AnyView(ListView(self)),
                        AnyView(AddFood(self.toListHome))],
                padding: 0, unDraggable: [PanelIndex.listHome.rawValue],
                onSlideChange: self.slideChange)
            
            if self.tr.tab() == .settings {
                SettingsView(self)
            }
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
