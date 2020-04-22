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

public let maxOverlayOpacity: CGFloat = 0.5

public struct ListView: View, GFieldDelegate {
    @ObservedObject private var uc: UserCookie = UserCookie.uc()
    private var contentView: ContentView
    
    @State private var searchFocused: Bool = false
    @ObservedObject private var ko: KeyboardObserver = KeyboardObserver.ko()
    @ObservedObject private var gft: GFormText = GFormText.gft(formID)
    
    @State private var selectedFID: String? = nil
    @State private var showGrubSheet: Bool = false
    @State private var onGrubSheetHide: () -> Void = {}
    
    @State private var showGrumbleSheet: Bool = false
    @State private var ghorblinType: GrumbleSheet.GhorblinType = .classic
    @State private var ghorblinList: [String] = UserCookie.uc().foodList().keys.shuffled()
    
    //Initializer
    public init(_ contentView: ContentView){
        self.contentView = contentView
    }
    
    //Function Methods
    private func showGrumbleSheet(_ ghorblinType: GrumbleSheet.GhorblinType) {
        withAnimation(gAnim(.easeOut)) {
            self.showGrumbleSheet = true
            TabRouter.tr().hide(true)
        }
        
        self.ghorblinType = ghorblinType
        self.ghorblinList = self.uc.foodList().keys.shuffled()
        GhorblinAnimations.ga().startIdleAnimation()
        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { _ in
            GhorblinAnimations.ga().setDrip(1)
        }
    }
    
    private func grubContainsToken(_ grub: Grub) -> Bool {
        let text = self.gft.text(0).lowercased()
        let food = grub.food.lowercased()
        if text.isEmpty || food.contains(text) {
            return true
        }
        
        var tags = grub.tags
        tags["smallestTag"] = nil
        for tag in tags {
            if tag.key.contains(text) {
                return true
            }
        }
        
        return false
    }
    
    //GFieldDelegate Method Implementations
    public func style(_ index: Int, _ textField: GTextField) {
        textField.attributedPlaceholder = NSAttributedString(string: "Filter List", attributes: [NSAttributedString.Key.foregroundColor: UIColor.black.withAlphaComponent(0.5)])
        textField.setInsets(top: 5, left: 45, bottom: 5, right: 10)
        textField.textColor = UIColor.black
        textField.returnKeyType = .default
    }
    
    public func proceedField() -> Bool {
        self.searchFocused = false
        self.gft.setText(0, "")
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
            .shadow(color: color.opacity(0.3), radius: 5)
        }))
    }
    
    private var listHeader: some View {
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
        }
    }
    
    private var searchBar: some View {
        ZStack(alignment: .leading) {
            Image(systemName: "magnifyingglass")
            .padding(15)
            .foregroundColor(Color(white: 0.3))
            
            GField(formID, 0, self)
        }
    }
    
    private var grumbleButtons: some View {
        HStack(spacing: 10) {
            VStack(spacing: 10) {
                self.grumbleButton("Classic Grumble", gColor(.blue4)) {
                    self.showGrumbleSheet(.classic)
                }
                
                self.grumbleButton("Similar Grub", gColor(.dandelion)) {
                    self.showGrumbleSheet(.similar)
                }
            }
            
            VStack(spacing: 10) {
                self.grumbleButton("Daring Alternative", gColor(.coral)) {
                    self.showGrumbleSheet(.defiant)
                }
                
                self.grumbleButton("Grumbologist", gColor(.magenta)) {
                    self.showGrumbleSheet(.grubologist)
                }
            }
        }
    }
    
    public var body: some View {
        ZStack(alignment: .bottom) {
            Color(white: 0.98)
            
            ScrollView(.vertical) {
                VStack(alignment: .leading, spacing: 20) {
                    if !self.searchFocused && !self.ko.visible(formID) {
                        self.listHeader
                            .frame(height: titleHeight)
                    }
                    
                    HStack(spacing: 20) {
                        self.searchBar
                            .background(Color(white: 0.93))
                            .cornerRadius(8)
                            .frame(height: searchHeight)
                        
                        if self.searchFocused || self.ko.visible(formID) {
                            Button(action: {
                                withAnimation(gAnim(.spring)) {
                                    self.searchFocused = false
                                    self.gft.setText(0, "")
                                    UIApplication.shared.endEditing()
                                }
                            }, label: {
                                Text("Cancel")
                                    .font(gFont(.ubuntuLight, .width, 2))
                                    .foregroundColor(gColor(.blue0))
                            })
                        }
                    }
                    
                    ZStack(alignment: .top) {
                        if !self.searchFocused && !self.ko.visible(formID) {
                            VStack(alignment: .leading, spacing: 20) {
                                self.grumbleButtons
                                
                                Text("My List")
                                    .font(gFont(.ubuntuBold, .width, 3))
                                    .frame(height: myListTitleHeight)
                                    .foregroundColor(Color(white: 0.2))
                            }.animation(nil)
                        }
                        
                        if self.searchFocused || self.ko.visible(formID) {
                            Color.clear
                                .frame(minHeight: sHeight())
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    withAnimation(gAnim(.spring)) {
                                        self.searchFocused = false
                                        self.gft.setText(0, "")
                                    }
                                }
                            
                            VStack(alignment: .leading, spacing: 20) {
                                Text(self.gft.text(0).isEmpty ? "Showing all results..." :
                                    "Showing results for: \"" + self.gft.text(0) + "\"")
                                    .font(gFont(.ubuntuLight, .width, 2))
                                    .foregroundColor(Color(white: 0.4))
                                
                                ForEach((0 ..< self.uc.foodListByDate().count).reversed().filter {
                                    self.grubContainsToken(self.uc.foodListByDate()[$0].1)
                                }, id: \.self) {
                                    index in
                                    GrubSearchItem(self.$searchFocused, GrubItem(fid: self.uc.foodListByDate()[index].0, self.uc.foodListByDate()[index].1, self.$selectedFID, self.$showGrubSheet, onGrubSheetHide: self.$onGrubSheetHide))
                                }
                                
                                Spacer().frame(maxWidth: .infinity, minHeight: self.ko.height(formID) + sHeight() * 0.1)
                            }
                        }
                    }
                }.padding([.top, .leading, .trailing], 20)
                
                if !self.searchFocused && !self.ko.visible(formID){
                    ScrollView(.horizontal) {
                        HStack(spacing: 20) {
                            if !self.uc.foodList().isEmpty {
                                ForEach((0 ..< self.uc.foodListByDate().count).reversed(), id: \.self) { index in
                                    GrubItem(fid: self.uc.foodListByDate()[index].0, self.uc.foodListByDate()[index].1, self.$selectedFID, self.$showGrubSheet, onGrubSheetHide: self.$onGrubSheetHide)
                                }
                            } else {
                                Text(self.uc.loadingStatus == .loading ? "Loading..." : "List is Empty!")
                                    .font(gFont(.ubuntu, .width, 2))
                                    .foregroundColor(Color(white: 0.2))
                            }
                            
                            Spacer()
                        }.padding(.leading, 20)
                        .padding(.bottom, 40)
                        .frame(minWidth: sWidth())
                    }.frame(width: sWidth())
                }
                
                Spacer()
            }
            
            ZStack(alignment: .top) {
                Color.clear
                
                gColor(.blue0)
                    .frame(width: sWidth(), height: safeAreaInset(.top))
            }.edgesIgnoringSafeArea(.all)
            
            Color.black.opacity(self.showGrubSheet ? Double(maxOverlayOpacity) : 0)
                
            GrumbleSheet(self.ghorblinType, show: self.$showGrumbleSheet, self.ghorblinList, selectedFID: self.$selectedFID, showSheet: self.$showGrubSheet, onGrubSheetHide: self.$onGrubSheetHide)
                .offset(y: self.showGrumbleSheet ? 0 : sHeight() * 1.2)
            
            GrubSheet(self.$selectedFID, self.$showGrubSheet, self.contentView, onHide: self.$onGrubSheetHide)
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
