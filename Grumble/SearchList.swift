//
//  SearchList.swift
//  Grumble
//
//  Created by Allen Chang on 4/24/20.
//  Copyright © 2020 Cylumn, Inc. All rights reserved.
//

import SwiftUI

//MARK: - Constants
private let formID: GFormID = GFormID.filterList

//MARK: - Cookies
public class SearchListCookie: ObservableObject {
    private static var instance: SearchListCookie? = nil
    @Published public var focused: Bool = false
    
    public static func slc() -> SearchListCookie {
        if SearchListCookie.instance == nil {
            SearchListCookie.instance = SearchListCookie()
        }
        return SearchListCookie.instance!
    }
}

//MARK: - Views
private struct SearchListContent: View {
    @ObservedObject private var uc: UserCookie = UserCookie.uc()
    @ObservedObject private var gft: GFormText = GFormText.gft(formID)
    private var searchItems: [GrubSearchItem]
    
    public init() {
        self.searchItems = []
        for index in (0 ..< self.uc.foodListByDate().count) {
            self.searchItems.append(GrubSearchItem(self.uc.foodListByDate()[index].1))
        }
    }
    
    //MARK: Function Methods
    private func grubContainsToken(_ grub: Grub) -> Bool {
        let text = self.gft.text(0).lowercased()
        let food = grub.food.lowercased()
        if text.isEmpty || food.contains(text) {
            return true
        }
        
        for tag in grub.tags {
            if tag.key.contains(text) {
                return true
            }
        }
        
        return false
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(self.gft.text(0).isEmpty ? "Showing all results..." :
                "Showing results for: \"" + self.gft.text(0) + "\"")
                .font(gFont(.ubuntuLight, .width, 2))
                .foregroundColor(Color(white: 0.4))
            
            ForEach((0 ..< self.uc.foodListByDate().count).reversed().filter {
                self.grubContainsToken(self.uc.foodListByDate()[$0].1)
            }, id: \.self) {
                index in
                self.searchItems[index]
            }
            
            Spacer()
        }
    }
}

public struct SearchList: View, GFieldDelegate {
    private var slc: SearchListCookie = SearchListCookie.slc()
    @ObservedObject private var gft: GFormText = GFormText.gft(formID)
    @ObservedObject private var ko: KeyboardObserver = KeyboardObserver.ko(formID)
    private var titleHeight: CGFloat
    private var content: SearchListContent
    
    //MARK: Initializer
    public init(titleHeight: CGFloat) {
        self.titleHeight = titleHeight
        self.content = SearchListContent()
    }
    
    //MARK: Getter Methods
    private func expanded() -> Bool {
        return self.slc.focused || self.ko.visible()
    }
    
    //MARK: GFieldDelegate Method Implementations
    public func style(_ index: Int, _ textField: GTextField, _ placeholderText: @escaping (String) -> Void) {
        placeholderText("Filter List")
        textField.setInsets(top: 5, left: 45, bottom: 5, right: 10)
        textField.textColor = UIColor.black
        textField.returnKeyType = .default
    }
    
    public func proceedField() -> Bool {
        self.slc.focused = false
        self.gft.setText(0, "")
        return true
    }
    
    public func parseInput(_ index: Int, _ textField: UITextField, _ string: String) -> String {
        return textField.text! + string
    }
    
    private var searchBar: some View {
        ZStack(alignment: .leading) {
            Image(systemName: "magnifyingglass")
            .padding(15)
            .foregroundColor(Color(white: 0.3))
            
            GField(formID, 0, self)
        }
    }
    
    public var body: some View {
        VStack(spacing: 20) {
            if !self.expanded() {
                Spacer()
                    .frame(height: self.titleHeight)
            }
            
            ZStack {
                if self.expanded() {
                    Color.clear
                        .padding(.top, searchHeight)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation(gAnim(.spring)) {
                                self.slc.focused = false
                                self.gft.setText(0, "")
                            }
                        }
                }
                
                VStack(spacing: 20) {
                    HStack(spacing: 0) {
                        self.searchBar
                            .background(Color(white: 0.93))
                            .cornerRadius(8)
                            .frame(maxWidth: .infinity, maxHeight: searchHeight)
                        
                        if self.expanded() {
                            Button(action: {
                                withAnimation(gAnim(.spring)) {
                                    self.slc.focused = false
                                    UIApplication.shared.endEditing()
                                }
                                self.gft.setText(0, "")
                            }, label: {
                                Text("Cancel")
                                    .font(gFont(.ubuntuLight, .width, 2))
                                    .foregroundColor(gColor(.blue0))
                                    .padding([.leading, .trailing], 20)
                                    .padding([.top, .bottom], 15)
                            })
                        }
                    }.padding(.leading, 20)
                    .padding(.trailing, self.expanded() ? 0 : 20)
                    
                    if self.expanded() {
                        self.content
                        
                        Spacer().frame(minHeight: self.ko.height() + sHeight() * 0.1)
                    }
                }
            }.background(Color(white: 0.98))
        }
    }
}

struct SearchList_Previews: PreviewProvider {
    static var previews: some View {
        SearchList(titleHeight: 40)
    }
}
