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
            }

            self.selected.removeAll()
            self.available = Set(1 ..< tagTitles.count)
            self.gft.setText(0, "")
            
            UIApplication.shared.endEditing()
            KeyboardObserver.observe(.addFood)
            KeyboardObserver.ignore(formID)
        }
    }
    
    //Implemented GFieldDelegate Methods
    public func style(_ index: Int, _ textField: GTextField, _ placeholderText: @escaping (String) -> Void) {
        placeholderText("Find Tag")
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
            Color(white: 0.97)
            
            if self.isPresented.wrappedValue {
                ScrollView {
                    Spacer().frame(height: 60)
                    
                    VStack(spacing: 15) {
                        if self.gft.text(0).count > 0 {
                            Text("Showing results for: \"" + self.gft.text(0) + "\"")
                                .font(gFont(.ubuntuLight, .width, 2))
                                .foregroundColor(Color(white: 0.2))
                                .offset(y: -5)
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
                                    Color.white
                                    
                                    HStack(spacing: nil) {
                                        Text(capFirst(tagTitles[tag]))
                                            .font(gFont(.ubuntuLight, 15))
                                            .foregroundColor(tagColors[tag])
                                        
                                        Spacer()
                                        
                                        Image(systemName: self.selected.contains(tag) ? "plus.square.fill" : "square")
                                            .foregroundColor(self.selected.contains(tag) ? gColor(.blue0) : Color.gray)
                                    }.padding(10)
                                    .padding([.leading, .trailing], 5)
                                    .foregroundColor(Color(white: 0.2))
                                }.frame(height: 45)
                                .cornerRadius(10)
                                .shadow(color: Color.black.opacity(0.1), radius: 5)
                            }).padding([.leading, .trailing], 15)
                        }
                        
                        Spacer().frame(minHeight: sHeight() * 0.4)
                    }
                }.contentShape(Rectangle())
                .gesture(DragGesture())
                .offset(y: 20)
            }
            
            ZStack {
                Color(white: 0.97)
                
                HStack(alignment: .bottom, spacing: 0) {
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(white: 0.93))
                        
                        Image(systemName: "magnifyingglass")
                            .padding(10)
                            .foregroundColor(Color(white: 0.2))
                        
                        GField(formID, 0, self)
                    }.padding([.top, .bottom], 10)
                    .padding(.leading, 20)
                    Button(action: self.endSearch, label: {
                        Text("Cancel")
                            .frame(maxWidth: sWidth() * 0.2, maxHeight: .infinity)
                            .font(gFont(.ubuntuLight, .width, 2))
                            .foregroundColor(gColor(.blue0))
                    })
                }
            }.frame(height: 60)
            .padding(.top, 5)
            .cornerRadius(5)
            
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
                .offset(y: min(-self.ko.height(), -40))
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
