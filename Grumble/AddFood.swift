//
//  AddFood.swift
//  Grumble
//
//  Created by Allen Chang on 3/22/20.
//  Copyright © 2020 Cylumn, Inc. All rights reserved.
//

import SwiftUI

private let formID: GFormID = GFormID.addFood
private let navBarHeight: CGFloat = sWidth() * 0.12
private let fieldHeight: CGFloat = sHeight() * 0.05 + 20
private let formHeight: CGFloat = fieldHeight * CGFloat(size(formID) - 1)
private let tagTitleHeight: CGFloat = sHeight() * 0.08

public class AddFoodCookie: ObservableObject {
    private static var instance: AddFoodCookie? = nil
    @Published public var currentFID: String? = nil
    @Published public var tags: Set<Int> = [0]
    
    public static func afc() -> AddFoodCookie {
        if AddFoodCookie.instance == nil {
            AddFoodCookie.instance = AddFoodCookie()
        }
        return AddFoodCookie.instance!
    }
}

public struct AddFood: View, GFieldDelegate {
    private var uc: UserCookie = UserCookie.uc()
    private var contentView: ContentView
    
    @ObservedObject private var gft: GFormText = GFormText.gft(formID)
    @ObservedObject private var afc: AddFoodCookie = AddFoodCookie.afc()
    @ObservedObject private var ko: KeyboardObserver = KeyboardObserver.ko(formID)
    @State private var presentSearchTag: Bool = false
    
    //Initializer
    public init(_ contentView: ContentView){
        self.contentView = contentView
        
        self.gft.setNames(["Food", "Price", "Restaurant", "Address"])
        self.gft.setSymbols(["flame.fill", "", "rosette", "mappin.and.ellipse"])
        self.gft.setError(FieldIndex.price.rawValue, "(Optional)")
        self.gft.setError(FieldIndex.restaurant.rawValue, "(Optional)")
        self.gft.setError(FieldIndex.address.rawValue, "(Optional)")
    }
    
    //Field Enums
    public enum FieldIndex: Int {
        case food = 0
        case price = 1
        case restaurant = 2
        case address = 3
    }
    
    //Edit Enums
    public enum AddFoodMode {
        case add
        case edit
    }
    
    //Getter Methods
    private func canSubmit() -> Bool {
        return !self.gft.text(FieldIndex.food.rawValue).isEmpty
    }
    
    private func presentSearchWidth() -> CGFloat {
        return sWidth() * (self.presentSearchTag ? 1 : 0.1)
    }
    
    private func presentSearchHeight() -> CGFloat {
        let small: CGFloat = sWidth() * 0.08
        let big: CGFloat = sHeight() - tabHeight
        return self.presentSearchTag ? big : small
    }
    
    private func presentSearchOffset() -> CGSize {
        let width: CGFloat = self.presentSearchTag ? 0 : sWidth() * 0.23
        let height: CGFloat = self.presentSearchTag ? 0 : navBarHeight + formHeight + tagTitleHeight * 0.5 - sWidth() * 0.03
        return CGSize(width: width, height: height)
    }
    
    //Setter Methods
    public static func clearFields() {
        GFormText.gft(formID).setText(FieldIndex.food.rawValue, "")
        GFormText.gft(formID).setText(FieldIndex.price.rawValue, "")
        GFormText.gft(formID).setText(FieldIndex.restaurant.rawValue, "")
        GFormText.gft(formID).setText(FieldIndex.address.rawValue, "")
        AddFoodCookie.afc().tags = [0]
        AddFoodCookie.afc().currentFID = nil
    }
    
    //Proceed Methods
    private func addItem(){
        var foodItem = [:] as [String: Any]
        foodItem["food"] = self.gft.text(FieldIndex.food.rawValue)
        foodItem["price"] = parsePriceField(self.gft.text(FieldIndex.price.rawValue))
        foodItem["restaurant"] = !self.gft.text(FieldIndex.restaurant.rawValue).isEmpty ? self.gft.text(FieldIndex.restaurant.rawValue) : nil
        foodItem["address"] = !self.gft.text(FieldIndex.address.rawValue).isEmpty ? self.gft.text(FieldIndex.address.rawValue) : nil

        var tagDictionary: [String: Int] = [:]
        for tag in self.afc.tags.sorted() {
            tagDictionary[tagTitles[tag]] = tag
        }
        tagDictionary["smallestTag"] = self.afc.tags.filter({ $0 != 0 }).sorted().first ?? 0
        foodItem["tags"] = tagDictionary
        switch self.afc.currentFID {
        case nil:
            foodItem["date"] = getDate()
            let foodDictionary = foodItem as NSDictionary
            let date = dateComponent()
            
            let prefix = String(trim(foodItem["food"] as! String).lowercased().prefix(3))
            let fid = prefix + randomString(length: 4) + String(date.hour!) + "_" + String(date.minute!) + "_" + String(date.second!)
            self.uc.appendFoodList(fid, Grub(foodDictionary))
            self.uc.sortFoodListByDate()
            appendLocalFood(fid, foodDictionary)
            appendCloudFood(fid, foodDictionary)
        default:
            foodItem["date"] = UserCookie.uc().foodList()[self.afc.currentFID!]!.date
            let foodDictionary = foodItem as NSDictionary
            
            self.uc.appendFoodList(self.afc.currentFID!, Grub(foodDictionary))
            self.uc.sortFoodListByDate()
            appendLocalFood(self.afc.currentFID!, foodDictionary)
            appendCloudFood(self.afc.currentFID!, foodDictionary)
        }
        contentView.toListHome()
        
        AddFood.clearFields()
    }
    
    //Parsing Methods
    private func parsePriceField(_ text: String) -> Double? {
        var text = text
        text.removeAll(where: {$0 == "$" || $0 == "."})
        if let firstZero = text.firstIndex(where: {$0 != "0"}) {
            text.removeSubrange(text.startIndex..<firstZero)
        } else {
            text = ""
        }
        
        if text.isEmpty {
            return nil
        } else {
            while text.count < 3 {
                text = "0" + text
            }
            text.insert(contentsOf: ".", at: text.index(text.endIndex, offsetBy: -2))
            return Double(text)
        }
    }
    
    //Implemented GFieldDelegate Methods
    public func style(_ index: Int, _ textField: GTextField, _ placeholderText: @escaping (String) -> Void) {
        placeholderText(self.gft.error(index))
        textField.setInsets(top: 23, left: 10, bottom: 5, right: 10)
        textField.font = gFont(.ubuntuLight, .width, 2)
        textField.textColor = gColor(.blue2)
        switch index {
            case FieldIndex.price.rawValue:
                textField.keyboardType = .numberPad
                textField.textAlignment = .right
            case FieldIndex.address.rawValue:
                textField.returnKeyType = .default
            default:
                break
        }
    }
    
    public func proceedField() -> Bool {
        return GFormRouter.gfr().callNextResponder(formID)
    }
    
    public func parseInput(_ index: Int, _ textField: UITextField, _ string: String) -> String {
        switch index {
            case FieldIndex.price.rawValue:
                var text = textField.text! + string
                text = unparsePrice(text)
                text = cut(text, maxLength: 6)
                text = parsePrice(text)
                return text
            default:
                var text = textField.text!
                text = trim(text + smartCase(text, appendInput: removeSpecialChars(string)), allowSingleChars: true)
                text = trim(text, char: "'", allowSingleChars: true)
                switch index {
                    case FieldIndex.restaurant.rawValue:
                        text = cut(text, maxLength: 40)
                    case FieldIndex.food.rawValue:
                        text = cut(text, maxLength: 25)
                    case FieldIndex.address.rawValue:
                        text = cut(text, maxLength: 50)
                    default:
                        text = cut(text, maxLength: 30)
                }
                return text
        }
    }
    
    private var header: some View {
        ZStack {
            HStack(spacing: nil) {
                Button(action: self.contentView.toListHome, label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(Color.white)
                        .padding(.leading, 5)
                }).frame(width: 50, height: navBarHeight)
                
                Spacer()
            }
            
            Text("Add Grub to List")
                .font(gFont(.ubuntuBold, 18))
                .fontWeight(.bold)
                .foregroundColor(Color.white)
                .padding(12)
        }
    }
    
    private var form: some View {
        HStack(spacing: 0) {
            VStack(spacing: 0) {
                ForEach(0 ..< size(formID)) { index in
                    if !self.gft.symbol(index).isEmpty {
                        ZStack {
                            Image(systemName: self.gft.symbol(index))
                                .font(.system(size: 25))
                        }.frame(height: fieldHeight)
                        .foregroundColor(self.gft.text(index).isEmpty ? Color.gray : gColor(.blue0))
                    }
                }
            }.frame(width: 50)
            Rectangle()
                .fill(gColor(.blue2))
                .frame(width: 10, height: formHeight)
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 0) {
                    ForEach(0 ..< FieldIndex.restaurant.rawValue) { index in
                        ZStack(alignment: .topLeading) {
                            Color.clear
                            
                            if index > 0 {
                                Rectangle()
                                .fill(Color(white: 0.8))
                                .frame(width: 1, height: fieldHeight)
                            }
                            
                            Text(self.gft.name(index))
                                .padding(7)
                                .font(gFont(.ubuntuMedium, .width, 1.5))
                            
                            GField(formID, index, self)
                        }.frame(idealWidth: index == FieldIndex.price.rawValue ? sWidth() * 0.35 : .infinity, maxWidth: index == FieldIndex.price.rawValue ? sWidth() * 0.35 : .infinity)
                        .frame(height: fieldHeight)
                    }
                }
                ForEach(FieldIndex.restaurant.rawValue ..< size(formID)) { index in
                    ZStack(alignment: .topLeading) {
                        Color.clear
                        
                        Rectangle()
                            .fill(Color(white: 0.8))
                            .frame(height: 1)
                        
                        Text(self.gft.name(index))
                            .padding(7)
                            .font(gFont(.ubuntuMedium, .width, 1.5))
                        
                        GField(formID, index, self)
                    }.frame(idealWidth: .infinity, maxWidth: .infinity)
                    .frame(height: fieldHeight)
                }
            }.foregroundColor(Color(white: 0.3))
            .frame(idealWidth: .infinity, maxWidth: .infinity)
        }
    }
    
    private struct TagBox: View {
        fileprivate static var width: CGFloat = sWidth() * sWidth() * 0.001
        fileprivate static var height: CGFloat = width * 1.0
        private var name: String
        private var id: Int
        
        //Initializer
        public init(id: Int) {
            self.name = capFirst(tagTitles[id])
            self.id = id
        }
        
        //Getters
        public func tag() -> Int {
            return self.id
        }
        
        public var body: some View {
            ZStack(alignment: .center) {
                ZStack(alignment: .bottom) {
                    GTagIcon.icon(tag: self.id, id: .tagBox, size: CGSize(width: TagBox.width, height: TagBox.height))
                    
                    LinearGradient(gradient: Gradient(colors: [tagColors[self.id].opacity(0), tagColors[self.id]]), startPoint: .top, endPoint: .bottom)
                        .frame(height: TagBox.height * 0.5)
                }.frame(width: TagBox.width, height: TagBox.height)
                .cornerRadius(20)
                .shadow(color: tagColors[self.id].opacity(0.5), radius: 8, y: 10)
                
                ZStack(alignment: .bottom) {
                    Color.clear
                    
                    Text(self.name)
                        .font(gFont(.ubuntuBold, .width, 3))
                        .foregroundColor(Color.white)
                        .padding(10)
                }
                
                if self.name != "Food" {
                    ZStack(alignment: .topTrailing) {
                        Color.clear
                        
                        Button(action: {
                            AddFoodCookie.afc().tags.remove(self.id)
                        }, label: {
                            Image(systemName: "multiply")
                                .padding(4)
                                .background(Color.white)
                                .font(.headline)
                                .foregroundColor(Color(white: 0.2))
                                .cornerRadius(100)
                        }).padding(10)
                    }
                }
            }.frame(width: TagBox.width, height: TagBox.height)
        }
    }
    
    public var body: some View {
        let sortedTags: [Int] = self.afc.tags.sorted()
        
        return ZStack(alignment: .topLeading) {
            gColor(.blue0)
                .edgesIgnoringSafeArea(.top)
            
            Color(white: 0.98)
                .edgesIgnoringSafeArea(.bottom)
            
            VStack(alignment: .leading, spacing: 0) {
                self.header
                    .padding(10)
                    .frame(width: sWidth(), height: navBarHeight)
                    .background(gColor(.blue0))
                self.form
                    .frame(width: sWidth())
                    .background(Color.white)
                Rectangle()
                    .fill(Color(white: 0.5))
                    .frame(height: 1)
                Text("Tags")
                    .padding(.leading, sWidth() * 0.02)
                    .frame(height: tagTitleHeight)
                    .font(gFont(.ubuntuBold, .width, 4))
                    .foregroundColor(Color.black)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: sHeight() * 0.02) {
                        ForEach(0 ..< sortedTags.count, id: \.self) { index in
                            TagBox(id: sortedTags[index])
                                .transition(.opacity)
                                .animation(gAnim(.spring))
                        }
                        
                        Spacer().frame(width: sWidth() * 0.5)
                    }.padding(.leading, sHeight() * 0.02)
                    .padding(.bottom, 30)
                }.frame(width: sWidth())
                .highPriorityGesture(DragGesture())
                Spacer()
                HStack(spacing: nil) {
                    Spacer()
                    
                    Button(action: self.addItem, label:{
                        Text("Confirm")
                            .font(gFont(.ubuntuMedium, .width, 2.5))
                            .padding(sWidth() * 0.04)
                            .frame(width: sWidth() * 0.4)
                            .foregroundColor(Color.white)
                    }).background(self.canSubmit() ? gColor(.blue0) : Color(white: 0.9))
                    .cornerRadius(100)
                    .disabled(!self.canSubmit())
                    .animation(gAnim(.easeOut))
                }.padding(20)
                .frame(width: sWidth())
                .shadow(color: Color.black.opacity(0.2), radius: 12, y: 15)
                .offset(y: -self.ko.height(tabbedView: false))
            }
            
            ZStack(alignment: .center) {
                SearchTag(self.$presentSearchTag)
                    .clipped()
                
                if !self.presentSearchTag {
                    Color(white: 0.9)
                    
                    Button(action: {
                        withAnimation(gAnim(.easeOut)) {
                            self.presentSearchTag = true
                            
                            UIApplication.shared.endEditing()
                            GFormRouter.gfr().callFirstResponder(.searchTag)
            
                            KeyboardObserver.observe(.searchTag, true)
                        }
                    }, label: {
                        Image(systemName: "plus")
                            .padding(15)
                            .foregroundColor(Color(white: 0.2))
                            .font(.system(size: 15, weight: .black))
                    })
                }
            }.frame(width: self.presentSearchWidth(), height: self.presentSearchHeight())
            .cornerRadius(self.presentSearchTag ? 0 : 30)
            .offset(self.presentSearchOffset())
        }.onTapGesture {
            if !self.presentSearchTag {
                UIApplication.shared.endEditing()
            }
        }
    }
}

#if DEBUG
struct AddToListView_Previews: PreviewProvider {
   static var previews: some View {
      Group {
         AddFood(ContentView())
            .previewDevice(PreviewDevice(rawValue: "iPhone SE"))
            .previewDisplayName("iPhone SE")

         AddFood(ContentView())
            .previewDevice(PreviewDevice(rawValue: "iPhone XS Max"))
            .previewDisplayName("iPhone XS Max")
      }
   }
}
#endif
