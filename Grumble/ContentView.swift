//
//  ContentView.swift
//  Grumble
//
//  Created by Allen Chang on 3/21/20.
//  Copyright © 2020 Cylumn, Inc. All rights reserved.
//

import SwiftUI

//MARK: Constants
public let navBarHeight: CGFloat = sWidth() * 0.12
public let tabHeight: CGFloat = sHeight() * 0.085

public let navBarFont: Font = gFont(.ubuntuBold, 18)

//MARK: - Cookies
public class ContentCookie: ObservableObject {
    private static var instance: ContentCookie? = nil
    @Published fileprivate var panelIndex: Int = PanelIndex.listHome.rawValue
    
    //MARK: Initializer
    public static func cc() -> ContentCookie {
        if ContentCookie.instance == nil {
            ContentCookie.instance = ContentCookie()
        }
        return ContentCookie.instance!
    }
    
    //MARK: Enumerations
    fileprivate enum PanelIndex: Int {
        case listHome = 0
        case addFood = 1
    }
    
    //MARK: Slide Change Functions
    public func toListHome(_ animated: Bool) {
        if animated {
            withAnimation(gAnim(.easeOut)){
                self.panelIndex = PanelIndex.listHome.rawValue
            }
        } else {
            self.panelIndex = PanelIndex.listHome.rawValue
        }
        UIApplication.shared.endEditing()
        KeyboardObserver.reset(.listhome)
        SearchListCookie.slc().focused = false
    }
    
    public func toListHome() {
        self.toListHome(true)
    }
    
    public func toAddFood(_ currentFID: String? = nil) {
        withAnimation(gAnim(.easeOut)) {
            self.panelIndex = PanelIndex.addFood.rawValue
        }
        UIApplication.shared.endEditing()
        KeyboardObserver.reset(.addfood)
        Timer.scheduledTimer(withTimeInterval: 0.45, repeats: false) { timer in
            GFormRouter.gfr().callFirstResponder(.addFood)
        }
        
        switch currentFID {
        case nil:
            AddFood.clearFields()
        default:
            AddFoodCookie.afc().currentFID = currentFID
        }
    }
    
    fileprivate func slideChange(_ index: Int) {
        switch index {
        case PanelIndex.listHome.rawValue:
            self.toListHome()
        case PanelIndex.addFood.rawValue:
            self.toAddFood()
        default:
            break
        }
    }
}

//MARK: - Views
public struct ContentView: View {
    @ObservedObject private var cc: ContentCookie = ContentCookie.cc()
    @ObservedObject private var tr: TabRouter = TabRouter.tr()
    
    public var body: some View {
        ZStack(alignment: .bottom) {
            SlideView(index: self.$cc.panelIndex, offsetFactor: 0.3,
                views: [AnyView(ListView()),
                        AnyView(AddFood())],
                padding: 0, unDraggable: [ContentCookie.PanelIndex.listHome.rawValue],
                onSlideChange: self.cc.slideChange)
            
            if self.tr.tab() == .settings {
                SettingsView(self)
            }
        }.edgesIgnoringSafeArea(.bottom)
    }
}

//MARK: - Previews
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
