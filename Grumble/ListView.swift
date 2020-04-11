//
//  ListView.swift
//  Grumble
//
//  Created by Allen Chang on 3/20/20.
//  Copyright © 2020 Cylumn, Inc. All rights reserved.
//

import SwiftUI

private let formID: GFormID = GFormID.filterList
private let titleHeight: CGFloat = 40
private let searchHeight: CGFloat = sWidth() * 0.1
private let grumbleButtonHeight: CGFloat = 40
private let myListTitleHeight: CGFloat = 30

public struct ListView: View, GFieldDelegate {
    @ObservedObject private var uc: UserCookie = UserCookie.uc()
    private var contentView: ContentView
    @State private var listDescription: String = "Loading..."
    
    @State private var selectedGrub: (String, Grub)? = nil
    @State private var showGrubSheet: Bool = false
    @State private var overlayOpacity: Double = 0
    
    @State private var currentHeight: CGFloat = sHeight()
    @State private var movingOffset: CGFloat = sHeight()
    @State private var grubs: [AnyView] = GrubPanel.generateGrubs(foodList: UserCookie.uc().foodList())
    
    //Initializer
    public init(_ contentView: ContentView){
        self.contentView = contentView
    }
    
    //Function Methods
    private func shuffleGrubs() {
        self.grubs = GrubPanel.generateGrubs(foodList: self.uc.foodList())
    }
    
    //GFieldDelegate Method Implementations
    public func style(_ index: Int, _ textField: GTextField) {
        textField.attributedPlaceholder = NSAttributedString(string: "Filter List", attributes: [NSAttributedString.Key.foregroundColor: UIColor.black.withAlphaComponent(0.5)])
        textField.setInsets(top: 5, left: 45, bottom: 5, right: 10)
        textField.textColor = UIColor.black
    }
    
    public func proceedField() -> Bool {
        return true
    }
    
    public func parseInput(_ index: Int, _ textField: UITextField, _ string: String) -> String {
        return textField.text! + string
    }
    
    //View Methods
    private func grumbleButton(_ title: String, _ color: Color, action: @escaping () -> Void) -> AnyView {
        return AnyView(Button(action: action, label: {
            ZStack(alignment: .leading) {
                color
                
                Text(title)
                    .padding(10)
                    .font(gFont(.ubuntu, .width, 2))
            }.frame(maxWidth: .infinity, maxHeight: grumbleButtonHeight)
            .foregroundColor(Color.white)
            .cornerRadius(8)
            .shadow(color: color.opacity(0.2), radius: 10, y: 10)
        }))
    }
    
    public var body: some View {
        ZStack(alignment: .bottom) {
            Color(white: 0.98)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HStack(spacing: nil) {
                        Text("Feeling Grumbly?")
                            .font(gFont(.ubuntuBold, .width, 4))
                            .foregroundColor(Color(white: 0.2))
                        
                        Spacer()
                        
                        Button(action: self.contentView.toAddFood, label: {
                            ZStack {
                                Text("+ Add")
                                    .padding(10)
                                    .font(gFont(.ubuntuBold, .width, 1.5))
                                    .foregroundColor(gColor(.blue0))
                                    .overlay(RoundedRectangle(cornerRadius: 8)
                                        .stroke(gColor(.blue0), lineWidth: 2))
                            }
                        })
                    }.frame(height: titleHeight)
                    
                    ZStack(alignment: .leading) {
                        Image(systemName: "magnifyingglass")
                        .padding(15)
                        .foregroundColor(Color(white: 0.3))
                        
                        GField(formID, 0, self)
                    }.background(Color(white: 0.93))
                    .cornerRadius(8)
                    .frame(height: searchHeight)
                    
                    HStack(spacing: 10) {
                        VStack(spacing: 10) {
                            self.grumbleButton("Classic Grumble", gColor(.blue4)) {
                                withAnimation(gAnim(.springSlow)) {
                                    self.currentHeight = 0
                                    self.movingOffset = 0
                                    
                                    self.shuffleGrubs()
                                }
                            }
                            
                            self.grumbleButton("Similar Grub", gColor(.dandelion)) {}
                        }
                        
                        VStack(spacing: 10) {
                            self.grumbleButton("Daring Alternative", gColor(.coral)) {}
                            
                            self.grumbleButton("Grumbologist", gColor(.magenta)) {}
                        }
                    }
                    
                    Text("My List")
                        .font(gFont(.ubuntuBold, .width, 3))
                        .frame(height: myListTitleHeight)
                        .foregroundColor(Color(white: 0.2))
                }.padding([.top, .leading, .trailing], 20)
                
                ScrollView(.horizontal) {
                    HStack(spacing: 20) {
                        if !self.uc.foodList().isEmpty {
                            ForEach(self.uc.foodList().keys.sorted(), id: \.self) { key in
                                GrubItem(fid: key, self.uc.foodList()[key]!, self.$selectedGrub, self.$showGrubSheet)
                            }
                        } else {
                            Text(self.listDescription)
                        }
                        
                        Spacer()
                    }.padding(.leading, 20)
                    .padding(.bottom, 40)
                    .frame(minWidth: sWidth())
                }.frame(width: sWidth())
                .onAppear{
                    loadCloudData() { data in
                        guard let foodList = data?["foodList"] as? NSDictionary else {
                            self.listDescription = "List is Empty!"
                            return
                        }
                        if foodList.count == 0 {
                            self.listDescription = "List is Empty!"
                        } else {
                            Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { timer in
                                self.listDescription = "List is Empty!"
                            }
                        }
                    }
                }
                
                Spacer()
            }
            
            gColor(.blue0)
                .frame(width: sWidth(), height: safeAreaInset(.top))
                .position(x: sWidth() * 0.5, y: -safeAreaInset(.top) * 0.5)
            
            Color.black.opacity(min(self.overlayOpacity + Double((sHeight() - self.movingOffset) / sHeight()), 0.8))
            
            GrubSheet(self.$selectedGrub, self.$showGrubSheet, self.$overlayOpacity)
            
            GrumblerSheet(currentHeight: self.$currentHeight, movingOffset: self.$movingOffset, onDragEnd: {_ in}, grubs: self.$grubs)
        }
    }
}

#if DEBUG
struct ListView_Previews: PreviewProvider {
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
