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

public class TagBoxHolder: ObservableObject {
    private static var instance: TagBoxHolder? = nil
    @Published private var tags: [AddFood.TagBox] = []
    
    //Getter Methods
    public static func tbh() -> TagBoxHolder {
        if TagBoxHolder.instance == nil {
            TagBoxHolder.instance = TagBoxHolder()
        }
        return TagBoxHolder.instance!
    }
    
    public func tagBoxes() -> [AddFood.TagBox] {
        return self.tags
    }
    
    //Setter Methods
    public func setTagBoxes(_ newTags: [AddFood.TagBox]) {
        self.tags = newTags
    }
    
    public func appendTagBox(_ newTag: AddFood.TagBox) {
        self.tags.append(newTag)
    }
}

public struct AddFood: View, GFieldDelegate {
    @ObservedObject private var uc: UserCookie = UserCookie.uc()
    @ObservedObject private var tr: TabRouter = TabRouter.tr()
    private var contentView: ContentView
    public static var currentFID: String? = nil
    
    @ObservedObject private var gft: GFormText = GFormText.gft(formID)
    @ObservedObject private var tbh: TagBoxHolder = TagBoxHolder.tbh()
    @ObservedObject private var ko: KeyboardObserver = KeyboardObserver.ko()
    @State private var showTagSearch: Bool = false
    
    //Initializer
    public init(_ contentView: ContentView){
        self.contentView = contentView
        
        self.gft.setNames(["Food", "Price", "Restaurant", "Address"])
        self.gft.setSymbols(["flame.fill", "", "rosette", "mappin.and.ellipse"])
        self.gft.setError(FieldIndex.price.rawValue, "(Optional)")
        self.gft.setError(FieldIndex.restaurant.rawValue, "(Optional)")
        self.gft.setError(FieldIndex.address.rawValue, "(Optional)")
        self.tbh.setTagBoxes([TagBox("Food", id: 0)])
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
    
    //Setter Methods
    public static func clearFields() {
        GFormText.gft(formID).setText(FieldIndex.food.rawValue, "")
        GFormText.gft(formID).setText(FieldIndex.price.rawValue, "")
        GFormText.gft(formID).setText(FieldIndex.restaurant.rawValue, "")
        GFormText.gft(formID).setText(FieldIndex.address.rawValue, "")
        var tagBoxes = TagBoxHolder.tbh().tagBoxes()
        tagBoxes.removeSubrange(1 ..< tagBoxes.count)
        TagBoxHolder.tbh().setTagBoxes(tagBoxes)
        AddFood.currentFID = nil
    }
    
    //Proceed Methods
    private func addItem(){
        var foodItem = [:] as [String: Any]
        foodItem["food"] = self.gft.text(FieldIndex.food.rawValue)
        foodItem["price"] = parsePriceField(self.gft.text(FieldIndex.price.rawValue))
        foodItem["restaurant"] = !self.gft.text(FieldIndex.restaurant.rawValue).isEmpty ? self.gft.text(FieldIndex.restaurant.rawValue) : nil
        foodItem["address"] = !self.gft.text(FieldIndex.address.rawValue).isEmpty ? self.gft.text(FieldIndex.address.rawValue) : nil
        var tagIDs: Set<Int> = []
        var smallestTag: Int? = nil
        for tagBox in self.tbh.tagBoxes() {
            let tag = tagBox.tag()
            tagIDs.insert(tag)
            if tag != 0 {
                if smallestTag == nil {
                    smallestTag = tag
                } else if tag < smallestTag! {
                    smallestTag = tag
                }
            }
        }
        var tagDictionary: [String: Int] = [:]
        for tag in tagIDs.sorted() {
            tagDictionary[tagTitles[tag]] = tag
        }
        tagDictionary["smallestTag"] = smallestTag ?? 0
        foodItem["tags"] = tagDictionary
        switch AddFood.currentFID {
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
            foodItem["date"] = UserCookie.uc().foodList()[AddFood.currentFID!]!.date
            let foodDictionary = foodItem as NSDictionary
            
            self.uc.appendFoodList(AddFood.currentFID!, Grub(foodDictionary))
            self.uc.sortFoodListByDate()
            appendLocalFood(AddFood.currentFID!, foodDictionary)
            appendCloudFood(AddFood.currentFID!, foodDictionary)
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
    public func style(_ index: Int, _ textField: GTextField) {
        textField.attributedPlaceholder = NSAttributedString(string: self.gft.error(index), attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray.withAlphaComponent(0.8)])
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
    
    public struct TagBox: View {
        fileprivate static var width: CGFloat = sWidth() * sWidth() * 0.001
        fileprivate static var height: CGFloat = width * 1.0
        private var name: String
        private var id: Int
        
        //Initializer
        public init(_ name: String, id: Int) {
            self.name = name
            self.id = id
        }
        
        //Getters
        public func tag() -> Int {
            return self.id
        }
        
        public var body: some View {
            ZStack(alignment: .center) {
                ZStack {
                    Rectangle()
                        .fill(tagColors[self.id])
                    
                    Image(tagSprites[self.id])
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    
                    if self.id != 0 {
                        LinearGradient(gradient: Gradient(colors: [Color.clear, tagColors[self.id].opacity(0.4)]), startPoint: .top, endPoint: .bottom)
                    }
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
                            var boxes = TagBoxHolder.tbh().tagBoxes()
                            boxes.removeAll(where: {$0.name == self.name})
                            TagBoxHolder.tbh().setTagBoxes(boxes)
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
        ZStack(alignment: .topLeading) {
            gColor(.blue0)
                .edgesIgnoringSafeArea(.top)
            
            Color(white: 0.98)
                .edgesIgnoringSafeArea(.bottom)
            
            VStack(alignment: .leading, spacing: 0) {
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
                }.padding(10)
                .frame(width: sWidth(), height: navBarHeight)
                .background(gColor(.blue0))
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
                }.frame(width: sWidth())
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
                        ForEach(0 ..< self.tbh.tagBoxes().count, id: \.self) { index in
                            self.tbh.tagBoxes()[index]
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
                .offset(y: -self.ko.height(formID, tabbedView: false))
            }.frame(height: sHeight() - safeAreaInset(.top))
            
            ZStack(alignment: .center) {
                Color(white: 0.98)
                
                SearchTag(self.$showTagSearch)
                .clipped()
                
                if !self.showTagSearch {
                    Color(white: 0.9)
                    
                    Button(action: {
                        withAnimation(gAnim(.easeOut)) {
                            self.showTagSearch.toggle()
                            
                            UIApplication.shared.endEditing()
                            GFormRouter.gfr().callFirstResponder(.searchTag)
                            
                            self.ko.removeField(formID)
                            self.ko.appendField(.searchTag, true)
                        }
                    }, label: {
                        Image(systemName: "plus")
                            .padding(15)
                            .foregroundColor(Color(white: 0.2))
                            .font(.system(size: 15, weight: .black))
                    })
                }
            }.frame(width: self.showTagSearch ? sWidth() : sWidth() * 0.1, height: self.showTagSearch ? sHeight() - tabHeight : sWidth() * 0.08)
            .cornerRadius(self.showTagSearch ? 0 : 30)
            .offset(x: self.showTagSearch ? 0 : sWidth() * 0.23, y: self.showTagSearch ? 0 : navBarHeight + formHeight + tagTitleHeight * 0.5 - sWidth() * 0.03)
        }.onTapGesture {
            if !self.showTagSearch {
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
