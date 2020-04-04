//
//  ContentView.swift
//  Grumble
//
//  Created by Allen Chang on 3/21/20.
//  Copyright © 2020 Cylumn, Inc. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject private var uc: UserCookie = UserCookie.uc()
    @ObservedObject private var tr: TabRouter = TabRouter.tr()
    @State private var index: Int = 0
    
    func onAppear(perform action: (() -> Void)? = nil) {
        action?()
        self.toList()
    }
    
    var body: some View {
        GeometryReader{ geometry in
        VStack(spacing: 0){
            if self.tr.tab() == .list {
                SlideView(index: self.$index, offsetFactor: 0.3, padding: 0, views: [
                    AnyView(ListView(geometry, self)),
                    AnyView(AddToListView(geometry, self))],
                          draggable: [false, true])
            } else if self.tr.tab() == .settings {
                SettingsView(geometry)
            }
            
            if self.tr.tab() == .list || self.tr.tab() == .settings { //always true
                TabView(geometry, self)
            }
        }
        }.edgesIgnoringSafeArea(.bottom)
    }
    
    func toList(){
        self.toList(true)
    }
    
    func toList(_ withAnim: Bool = true){
        if withAnim {
            withAnimation{
                   self.index = 0
            }
        } else {
            self.index = 0
        }
        
        UIApplication.shared.endEditing()
    }
    
    func toAddToList(){
        withAnimation(.easeOut(duration: 0.3)) {
            self.index = 1
        }
        
        UIApplication.shared.endEditing()
        
        Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { timer in
            GFormRouter.gfr().callFirstResponder(.addFood)
        }
    }
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        sendAction(#selector(UIView.endEditing), to: nil, from: nil, for: nil)
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
