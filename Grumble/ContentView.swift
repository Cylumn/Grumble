//
//  ContentView.swift
//  Grumble
//
//  Created by Allen Chang on 3/21/20.
//  Copyright © 2020 Cylumn, Inc. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewRouter =  ViewRouter()
    @State var lastDragPosition: DragGesture.Value?
    @State private var baseOffset: CGFloat = 0
    @State private var dragOffset: CGFloat = 0
    
    var body: some View {
        GeometryReader{ geometry in
        VStack(spacing: 0){
            if self.viewRouter.currentView == "list" {
                HStack(spacing: 0){
                    ListView(self.viewRouter, geometry, self)
                        .offset(x: geometry.size.width / 2 +  0.2 * (self.dragOffset - self.baseOffset * geometry.size.width))
                        /*.gesture(
                            DragGesture()
                            .onChanged { gesture in
                                if (gesture.translation.width < 0 && gesture.translation.width > -geometry.size.width){
                                    self.dragOffset = gesture.translation.width
                                }
                                
                                self.lastDragPosition = gesture
                            }

                            .onEnded { gesture in
                                let timeDiff = gesture.time.timeIntervalSince(self.lastDragPosition!.time)
                                let speed = (self.dragOffset - gesture.translation.width) / CGFloat(timeDiff)
                                
                                withAnimation{
                                    if self.dragOffset < -geometry.size.width / 2 || speed > 130 {
                                        self.baseOffset = 1
                                    } else {
                                        self.baseOffset = 0
                                    }
                                    
                                    self.dragOffset = 0
                                }
                            }
                        )*/
                    
                    AddToListView(self.viewRouter, geometry, self)
                        .offset(x: geometry.size.width / 2 + self.dragOffset - self.baseOffset * geometry.size.width)
                        .gesture(
                            DragGesture()
                            .onChanged { gesture in
                                if (gesture.translation.width > 0 && gesture.translation.width < geometry.size.width){
                                    self.dragOffset = gesture.translation.width
                                }
                                
                                self.lastDragPosition = gesture
                            }

                            .onEnded { gesture in
                                let timeDiff = gesture.time.timeIntervalSince(self.lastDragPosition!.time)
                                let speed = (gesture.translation.width - self.dragOffset) / CGFloat(timeDiff)
                                
                                withAnimation{
                                    if self.dragOffset > geometry.size.width / 2 || speed > 130 {
                                        self.baseOffset = 0
                                        
                                        UIApplication.shared.endEditing()
                                    } else {
                                        self.baseOffset = 1
                                    }
                                    
                                    self.dragOffset = 0
                                }
                            }
                        )
                }
            } else if self.viewRouter.currentView == "settings" {
                SettingsView(geometry)
            }
            
            if self.viewRouter.currentView == "list" ||
                self.viewRouter.currentView == "settings" {
                TabView(self.viewRouter, geometry, self)
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
                self.baseOffset = 0
            }
        } else {
            self.baseOffset = 0
        }
        
        UIApplication.shared.endEditing()
    }
    
    func toAddToList(){
        withAnimation{
            self.baseOffset = 1
        }
        
        UIApplication.shared.endEditing()
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
