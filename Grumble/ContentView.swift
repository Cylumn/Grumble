//
//  ContentView.swift
//  Grumble
//
//  Created by Allen Chang on 3/21/20.
//  Copyright © 2020 Cylumn, Inc. All rights reserved.
//

import SwiftUI

public let tabHeight: CGFloat = sHeight() * 0.085

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
        KeyboardObserver.observe(.filterList, false)
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
        KeyboardObserver.ignore(.filterList)
        KeyboardObserver.ignore(.searchTag)
        Timer.scheduledTimer(withTimeInterval: 0.43, repeats: false) { timer in
            GFormRouter.gfr().callFirstResponder(.addFood)
        }
        self.tr.hide(true)
        
        switch currentFID {
        case nil:
            AddFood.clearFields()
            ListCookie.lc().onAddFoodHide = { self.tr.hide(false) }
        default:
            AddFoodCookie.afc().currentFID = currentFID
            ListCookie.lc().onAddFoodHide = { }
        }
    }
    
    private func slideChange(_ index: Int) {
        switch index {
        case PanelIndex.listHome.rawValue:
            toListHome()
            ListCookie.lc().onAddFoodHide()
        case PanelIndex.addFood.rawValue:
            toAddFood()
        default:
            break
        }
    }
    
    private var tab: some View {
        switch self.tr.tab() {
        case .list:
            return AnyView(SlideView(index: self.$slideIndex, offsetFactor: 0.3,
                          views: [AnyView(ListView(self.toAddFood)),
                                  AnyView(AddFood(self.toListHome))],
                                         padding: 0, unDraggable: [PanelIndex.listHome.rawValue],
                                         onSlideChange: self.slideChange))
        case .settings:
            return AnyView(SettingsView())
        }
    }
    
    public var body: some View {
        ZStack(alignment: .bottom) {
            self.tab
            
            if !self.tr.hidden() {
                TabView(self)
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
