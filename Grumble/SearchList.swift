//
//  SearchList.swift
//  Grumble
//
//  Created by Allen Chang on 4/24/20.
//  Copyright © 2020 Cylumn, Inc. All rights reserved.
//

import SwiftUI

private let formID: GFormID = GFormID.filterList

public struct SearchList: View, GFieldDelegate {
    @ObservedObject private var uc: UserCookie = UserCookie.uc()
    @ObservedObject private var gft: GFormText = GFormText.gft(formID)
    @ObservedObject private var ko: KeyboardObserver = KeyboardObserver.ko(formID)
    private var expanded: () -> Bool
    
    //Initializer
    public init(expanded: @escaping () -> Bool) {
        self.expanded = expanded
    }
    
    //Function Methods
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
        ListCookie.lc().searchFocused = false
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
            HStack(spacing: 20) {
                self.searchBar
                    .background(Color(white: 0.93))
                    .cornerRadius(8)
                    .frame(height: searchHeight)
                
                if self.expanded() {
                    Button(action: {
                        withAnimation(gAnim(.spring)) {
                            ListCookie.lc().searchFocused = false
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
            
            if self.expanded() {
                ZStack {
                    Color.clear
                        .frame(minHeight: sHeight())
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation(gAnim(.spring)) {
                                ListCookie.lc().searchFocused = false
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
                            GrubSearchItem(GrubItem(fid: self.uc.foodListByDate()[index].0, self.uc.foodListByDate()[index].1))
                        }
                        
                        Spacer().frame(maxWidth: .infinity, minHeight: self.ko.height() + sHeight() * 0.1)
                    }
                }
            }
        }.padding([.leading, .trailing], 20)
    }
}

struct SearchList_Previews: PreviewProvider {
    static var previews: some View {
        SearchList(expanded: { return true })
    }
}
