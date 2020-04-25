//
//  SearchTag.swift
//  Grumble
//
//  Created by Allen Chang on 4/8/20.
//  Copyright © 2020 Cylumn, Inc. All rights reserved.
//

import SwiftUI

private let formID: GFormID = GFormID.searchTag

public struct SearchTag: View, GFieldDelegate {
    @ObservedObject private var gft: GFormText = GFormText.gft(formID)
    @ObservedObject private var ko: KeyboardObserver = KeyboardObserver.ko(formID)
    @State private var available: Set<Int> = Set(1 ..< tagTitles.count)
    @State private var selected: Set<Int> = []
    private var added: Set<Int>
    private var isPresented: Binding<Bool>
    
    //Initializer
    public init(_ isPresented: Binding<Bool>) {
        self.added = AddFoodCookie.afc().tags
        self.isPresented = isPresented
    }
    
    //Function Methods
    private func endSearch() {
        if self.isPresented.wrappedValue {
            withAnimation(gAnim(.easeOut)) {
                self.isPresented.wrappedValue = false
                self.selected.removeAll()
                self.available = Set(1 ..< tagTitles.count)
                self.gft.setText(0, "")
                
                UIApplication.shared.endEditing()
            }
            
            KeyboardObserver.removeField(formID)
            KeyboardObserver.appendField(.addFood)
        }
    }
    
    //Implemented GFieldDelegate Methods
    public func style(_ index: Int, _ textField: GTextField) {
        textField.attributedPlaceholder = NSAttributedString(string: "Find Tag", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray.withAlphaComponent(0.8)])
        textField.setInsets(top: 5, left: 40, bottom: 5, right: 30)
        textField.returnKeyType = .default
    }
    
    public func proceedField() -> Bool {
        return true
    }
    
    public func parseInput(_ index: Int, _ textField: UITextField, _ string: String) -> String {
        let token = textField.text! + string
        if token.count > 0 {
            var available: Set<Int> = []
            for title in tagTitles {
                if title != tagTitles[0] && title.contains(token.lowercased()) {
                    available.insert(tagIDMap[title]!)
                }
            }
            self.available = available
        } else {
            self.available = Set(1 ..< tagTitles.count)
        }
        return textField.text! + string
    }
    
    public var body: some View {
        ZStack(alignment: .top) {
            Color.clear
            
            if self.isPresented.wrappedValue {
                ScrollView {
                    Spacer().frame(height: 60)
                    
                    VStack(spacing: 10) {
                        if self.gft.text(0).count > 0 {
                            Text("Showing results for: \"" + self.gft.text(0) + "\"")
                                .font(gFont(.ubuntuLight, .width, 2))
                                .foregroundColor(Color(white: 0.2))
                        }
                        
                        ForEach((1 ..< tagTitles.count).filter({
                            self.available.contains($0) && !self.added.contains($0)
                        }), id: \.self) { tag in
                            Button(action: {
                                if self.selected.contains(tag) {
                                    self.selected.remove(tag)
                                } else {
                                    self.selected.insert(tag)
                                }
                            }, label: {
                                ZStack {
                                    Capsule()
                                        .fill(tagColors[tag])
                                        .frame(height: 45)
                                        .padding(7)
                                    
                                    Rectangle()
                                        .fill(Color.white)
                                        .frame(width: sWidth() * 0.5)
                                        .offset(x: -sWidth() * 0.25)
                                    
                                    Ellipse()
                                        .fill(Color.white)
                                        .rotationEffect(Angle.init(degrees: -30))
                                        .frame(width: sWidth() * 0.5)
                                    
                                    ZStack {
                                        Circle()
                                            .fill(Color.white.opacity(0.2))
                                            .frame(width: sWidth() * 0.5)
                                    }.offset(x: sWidth() * 0.4)
                                    
                                    HStack(spacing: nil) {
                                        Text(capFirst(tagTitles[tag]))
                                            .font(gFont(.ubuntuLight, 15))
                                        
                                        Spacer()
                                        
                                        Image(systemName: self.selected.contains(tag) ? "plus.circle.fill" : "circle")
                                            .foregroundColor(self.selected.contains(tag) ? gColor(.blue0) : Color.white)
                                            .shadow(color: Color.white, radius: 5)
                                    }.padding(30)
                                        .foregroundColor(Color(white: 0.2))
                                }.padding(.trailing, 15)
                                .frame(height: 45)
                                .clipped()
                                .shadow(color: tagColors[tag].opacity(0.2), radius: 10, y: 10)
                            })
                        }
                        
                        Spacer().frame(minHeight: sHeight() * 0.4)
                    }
                }.contentShape(Rectangle())
                .gesture(DragGesture())
                .offset(y: 20)
            }
            
            ZStack(alignment: .top) {
                Rectangle()
                    .fill(Color.white)
                    .frame(height: 30)
                
                Capsule()
                    .fill(Color.white)
                
                HStack(alignment: .bottom, spacing: 0) {
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color(white: 0.9))
                        
                        Image(systemName: "magnifyingglass")
                            .padding(10)
                            .foregroundColor(Color(white: 0.2))
                        
                        GField(formID, 0, self)
                    }.padding([.leading, .top, .bottom], 10)
                    Image(systemName: "chevron.down")
                        .frame(maxWidth: sWidth() * 0.2, maxHeight: .infinity)
                        .font(.system(size: 15, weight: .black))
                        .foregroundColor(gColor(.blue0))
                        .simultaneousGesture(TapGesture().onEnded {
                            self.endSearch()
                        })
                }.contentShape(Rectangle())
                .gesture(DragGesture().onChanged { drag in
                    if abs(drag.startLocation.y - drag.location.y) > 30 {
                        self.endSearch()
                    }
                })
            }.frame(height: 60)
            .cornerRadius(5)
            .clipped()
            .shadow(color: Color.gray.opacity(0.2), radius: 10, y: 10)
            
            ZStack(alignment: .bottomTrailing) {
                Color.clear

                Button(action: {
                    AddFoodCookie.afc().tags = AddFoodCookie.afc().tags.union(self.selected)
                    self.endSearch()
                }, label:{
                    Text("Add Tags")
                        .font(gFont(.ubuntuMedium, .width, 2))
                        .padding(sWidth() * 0.04)
                        .frame(width: sWidth() * 0.4)
                        .foregroundColor(Color.white)
                }).background(self.selected.count > 0 ? gColor(.blue0) : Color(white: 0.9))
                .cornerRadius(100)
                .shadow(color: Color.black.opacity(0.2), radius: 12, y: 15)
                .offset(y: -self.ko.height() - 20)
                .disabled(self.selected.count == 0)
                .animation(gAnim(.easeOut))
            }.padding(20)
        }
    }
}

struct SearchTag_Previews: PreviewProvider {
    static var previews: some View {
        SearchTag(Binding.constant(true))
    }
}
