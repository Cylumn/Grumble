//
//  SearchTag.swift
//  Grumble
//
//  Created by Allen Chang on 4/8/20.
//  Copyright © 2020 Cylumn, Inc. All rights reserved.
//

import SwiftUI

private let formID: GFormID = GFormID.searchTag

//MARK: - Cookies
public class SearchTagCookie: ObservableObject {
    private static var instance: SearchTagCookie? = nil
    @Published fileprivate var available: Set<GrubTag> = Set(gTags.dropFirst())
    @Published fileprivate var selected: Set<GrubTag> = []
    
    public static func stc() -> SearchTagCookie {
        if SearchTagCookie.instance == nil {
            SearchTagCookie.instance = SearchTagCookie()
        }
        return SearchTagCookie.instance!
    }
    
    fileprivate func endSearch() {
        if SearchTagButtonCookie.stbc().isPresented {
            withAnimation(gAnim(.easeOut)) {
                SearchTagButtonCookie.stbc().isPresented = false
            }

            let selected = self.selected
            self.selected.removeAll()
            SearchTag.resetTagButtons(changedTags: selected)
            self.available = Set(gTags.dropFirst())
            GFormText.gft(formID).setText(0, "")
            
            UIApplication.shared.endEditing()
            KeyboardObserver.observe(.addFood)
            KeyboardObserver.ignore(formID)
        }
    }
}

//MARK: - Views
private struct AddTagButton: View {
    @ObservedObject private var stc: SearchTagCookie = SearchTagCookie.stc()
    @ObservedObject private var ko: KeyboardObserver = KeyboardObserver.ko(formID)
    
    public var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Color.clear

            Button(action: {
                var tags: [GrubTag: Double] = AddFoodCookie.afc().tags
                for tag in self.stc.selected {
                    tags[tag] = 1
                }
                AddFoodCookie.afc().tags = tags
                AddFoodCookie.afc().tagsEdited = true
                self.stc.endSearch()
            }, label:{
                Text("Add Tags")
                    .font(gFont(.ubuntuMedium, .width, 2))
                    .padding(sWidth() * 0.04)
                    .frame(width: sWidth() * 0.4)
                    .foregroundColor(Color.white)
            }).background(self.stc.selected.count > 0 ? gColor(.blue0) : Color(white: 0.9))
            .cornerRadius(100)
            .shadow(color: Color.black.opacity(0.2), radius: 12, y: 15)
            .offset(y: min(-self.ko.height(), -40))
            .disabled(self.stc.selected.count == 0)
            .animation(gAnim(.easeOut))
        }.padding(20)
    }
}

public struct SearchTag: View, GFieldDelegate {
    private static var unselectedIcon: AnyView = AnyView(Image(systemName: "square").foregroundColor(Color.gray))
    private static var selectedIcon: AnyView = AnyView(Image(systemName: "plus.square.fill").foregroundColor(gColor(.blue0)))
    private static var tagButtons: [GrubTag: AnyView] = [:]
    
    @ObservedObject private var stc: SearchTagCookie = SearchTagCookie.stc()
    @ObservedObject private var gft: GFormText = GFormText.gft(formID)
    private var addTagButton: AddTagButton
    
    public init() {
        if SearchTag.tagButtons.isEmpty {
            SearchTag.resetTagButtons()
        }
        self.addTagButton = AddTagButton()
    }
    
    //MARK: Implemented GFieldDelegate Methods
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
            var available: Set<GrubTag> = []
            for title in gTags.dropFirst() {
                if title.contains(token.lowercased()) {
                    available.insert(title)
                }
            }
            self.stc.available = available
        } else {
            self.stc.available = Set(gTags.dropFirst())
        }
        return textField.text! + string
    }
    
    //MARK: Subviews
    fileprivate static func resetTagButtons(changedTags: Set<GrubTag>? = nil) {
        for tag in changedTags ?? Set(gTags.dropFirst()) {
            SearchTag.tagButtons[tag] = AnyView(SearchTag.makeButton(tag))
        }
    }
    
    private static func makeButton(_ tag: GrubTag) -> some View {
        Button(action: {}, label: {
            ZStack {
                Color.white
                
                HStack(spacing: nil) {
                    Text(capFirst(tag))
                        .font(gFont(.ubuntuLight, 15))
                        .foregroundColor(gTagColors[tag])
                    
                    Spacer()
                    
                    if SearchTagCookie.stc().selected.contains(tag) {
                        SearchTag.selectedIcon
                    } else {
                        SearchTag.unselectedIcon
                    }
                }.padding(10)
                .padding([.leading, .trailing], 5)
                .foregroundColor(Color(white: 0.2))
            }.frame(height: 45)
            .cornerRadius(10)
            .onTapGesture {
                if SearchTagCookie.stc().selected.contains(tag) {
                    SearchTagCookie.stc().selected.remove(tag)
                } else {
                    SearchTagCookie.stc().selected.insert(tag)
                }
                SearchTag.tagButtons[tag] = AnyView(SearchTag.makeButton(tag))
            }
        }).padding([.leading, .trailing], 15)
        .frame(width: sWidth())
    }
    
    public var body: some View {
        let shownTags = gTags.dropFirst().filter({
            self.stc.available.contains($0) && !AddFoodCookie.afc().tags.keys.contains($0)
        })
        return ZStack(alignment: .top) {
            Color(white: 0.95)
            
            ScrollView {
                Spacer().frame(height: 60)
                
                VStack(spacing: 15) {
                    if self.gft.text(0).count > 0 {
                        Text("Showing results for: \"" + self.gft.text(0) + "\"")
                            .font(gFont(.ubuntuLight, .width, 2))
                            .foregroundColor(Color(white: 0.2))
                            .offset(y: -5)
                    }
                    
                    ForEach(shownTags, id: \.self) { tag in
                        SearchTag.tagButtons[tag]
                    }
                    
                    Spacer().frame(minHeight: sHeight() * 0.4)
                }
            }.contentShape(Rectangle())
            .gesture(DragGesture())
            .offset(y: 20)
            
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
                    Button(action: self.stc.endSearch, label: {
                        Text("Cancel")
                            .frame(maxWidth: sWidth() * 0.2, maxHeight: .infinity)
                            .font(gFont(.ubuntuLight, .width, 2))
                            .foregroundColor(gColor(.blue0))
                    })
                }
            }.padding(.top, 5)
            .frame(height: 60)
            .cornerRadius(5)
            
            self.addTagButton
        }
    }
}

struct SearchTag_Previews: PreviewProvider {
    static var previews: some View {
        SearchTag()
    }
}
