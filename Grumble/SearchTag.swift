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
    @ObservedObject private var ko: KeyboardObserver = KeyboardObserver.ko()
    @State private var selected: Set<Int> = []
    private var tags: Binding<[AddFood.TagBox]>
    private var added: Set<Int>
    private var showTagSearch: Binding<Bool>
    
    //Initializer
    public init(_ tags: Binding<[AddFood.TagBox]>, _ showTagSearch: Binding<Bool>) {
        self.tags = tags
        self.added = []
        for tag in self.tags.wrappedValue {
            self.added.insert(tag.tag())
        }
        self.showTagSearch = showTagSearch
    }
    
    //Function Methods
    private func endSearch() {
        if self.showTagSearch.wrappedValue {
            withAnimation(gAnim(.easeOut)) {
                self.showTagSearch.wrappedValue = false
                self.selected.removeAll()
                
                UIApplication.shared.endEditing()
            }
            
            KeyboardObserver.ko().removeField(formID)
            KeyboardObserver.ko().appendField(.addFood)
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
        return textField.text! + string
    }
    
    public var body: some View {
        ZStack(alignment: .top) {
            Color.clear
            
            if self.showTagSearch.wrappedValue {
                ScrollView {
                    Spacer().frame(height: 60)
                    
                    VStack(spacing: 10) {
                        ForEach(1 ..< tagTitles.count) { tag in
                            if !self.added.contains(tag) {
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
                    for tagID in self.selected {
                        self.tags.wrappedValue.append(AddFood.TagBox(capFirst(tagTitles[tagID]), color: tagColors[tagID], tags: self.tags))
                    }
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
                .offset(y: -self.ko.height(formID) - 20)
                .disabled(self.selected.count == 0)
                .animation(gAnim(.easeOut))
            }.padding(20)
        }
    }
}

struct SearchTag_Previews: PreviewProvider {
    static var previews: some View {
        SearchTag(Binding.constant([]), Binding.constant(true))
    }
}
