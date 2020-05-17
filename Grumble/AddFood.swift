//
//  AddFood.swift
//  Grumble
//
//  Created by Allen Chang on 3/22/20.
//  Copyright © 2020 Cylumn, Inc. All rights reserved.
//

import SwiftUI

private let formID: GFormID = GFormID.addFood
private let fieldHeight: CGFloat = sHeight() * 0.02 + 35
private let formHeight: CGFloat = fieldHeight * CGFloat(size(formID) - 1)
private let tagTitleHeight: CGFloat = sHeight() * 0.08

//MARK: - Cookies
public class AddFoodCookie: ObservableObject {
    private static var instance: AddFoodCookie? = nil
    @Published public var currentFID: String? = nil
    @Published public var tags: [GrubTag: Double] = [food: 1]
    public var image: UIImage? = nil
    public var tagsEdited: Bool = false
    
    public var presentAddImage: (Bool, Bool) -> Void
    
    private init() {
        self.presentAddImage = { _, _ in }
    }
    
    public static func afc() -> AddFoodCookie {
        if AddFoodCookie.instance == nil {
            AddFoodCookie.instance = AddFoodCookie()
        }
        return AddFoodCookie.instance!
    }
    
    //MARK: Function Methods
    public func resetForNewGrub() {
        self.currentFID = nil
        self.tags = [food: 1]
        self.tagsEdited = false
    }
    
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
    
    fileprivate func addItem(){
        let gft = GFormText.gft(formID)
        var foodItem = [:] as [String: Any]
        foodItem["food"] = gft.text(AddFood.FieldIndex.food.rawValue)
        foodItem["price"] = parsePriceField(gft.text(AddFood.FieldIndex.price.rawValue))
        foodItem["restaurant"] = !gft.text(AddFood.FieldIndex.restaurant.rawValue).isEmpty ? gft.text(AddFood.FieldIndex.restaurant.rawValue) : nil
        foodItem["address"] = !gft.text(AddFood.FieldIndex.address.rawValue).isEmpty ? gft.text(AddFood.FieldIndex.address.rawValue) : nil
        foodItem["tags"] = self.tags
        
        var priorityTag: (String, Double) = (food, 0)
        for tag in self.tags {
            if tag.key != food && tag.value > priorityTag.1 {
                priorityTag.0 = tag.key
                priorityTag.1 = tag.value
            }
        }
        foodItem["priorityTag"] = priorityTag.0
        switch self.currentFID {
        case nil:
            foodItem["date"] = getDate()
            let date = dateComponent()
            let prefix = String(trim(foodItem["food"] as! String).lowercased().prefix(3))
            let fid = prefix + randomString(length: 4) + String(date.hour!) + "_" + String(date.minute!) + "_" + String(date.second!)
            foodItem["fid"] = fid
            let foodDictionary = foodItem as NSDictionary
            
            UserCookie.uc().appendFoodList(fid, Grub(fid: fid, foodDictionary, image: self.image!))
            appendLocalFood(fid, foodDictionary)
            appendCloudFood(fid, foodDictionary, self.image!)
            
            if self.tagsEdited {
                queueImageTraining(fid, self.tags)
            }
        default:
            foodItem["date"] = UserCookie.uc().foodList()[self.currentFID!]!.date
            foodItem["fid"] = self.currentFID!
            let foodDictionary = foodItem as NSDictionary
            
            UserCookie.uc().appendFoodList(self.currentFID!, Grub(fid: self.currentFID!, foodDictionary))
            appendLocalFood(self.currentFID!, foodDictionary)
            appendCloudFood(self.currentFID!, foodDictionary)
            
            if self.tagsEdited {
                queueImageTraining(self.currentFID!, self.tags)
            }
        }
        
        self.presentAddImage(false, false)
        ContentCookie.cc().toListHome()
        
        AddFood.clearFields()
        self.image = nil
    }
}

public class SearchTagButtonCookie: ObservableObject {
    private static var instance: SearchTagButtonCookie? = nil
    @Published public var isPresented: Bool = false
    
    public static func stbc() -> SearchTagButtonCookie {
        if SearchTagButtonCookie.instance == nil {
            SearchTagButtonCookie.instance = SearchTagButtonCookie()
        }
        return SearchTagButtonCookie.instance!
    }
}

//MARK: - Views
fileprivate struct SearchTagButton: View {
    @ObservedObject private var stbc: SearchTagButtonCookie = SearchTagButtonCookie.stbc()
    private var searchTag: SearchTag
    private var buttonIcon: AnyView
    
    fileprivate init() {
        self.searchTag = SearchTag()
        self.buttonIcon = AnyView(Image(systemName: "plus")
        .padding(15)
        .foregroundColor(Color(white: 0.2))
        .font(.system(size: 15, weight: .black)))
    }
    
    //MARK: Getter Methods
    private func width() -> CGFloat {
        return sWidth() * (self.stbc.isPresented ? 1 : 0.1)
    }
    
    private func height() -> CGFloat? {
        let small: CGFloat = sWidth() * 0.08
        let big: CGFloat? = nil
        return self.stbc.isPresented ? big : small
    }
    
    private func offset() -> CGSize {
        let width: CGFloat = self.stbc.isPresented ? 0 : sWidth() * 0.23
        let height: CGFloat = self.stbc.isPresented ? 0 : navBarHeight + formHeight + tagTitleHeight * 0.5 - sWidth() * 0.03
        return CGSize(width: width, height: height)
    }
    
    public var body: some View {
        return ZStack(alignment: .center) {
            self.searchTag
                .allowsHitTesting(self.stbc.isPresented)
            
            if !self.stbc.isPresented {
                Color(white: 0.9)
                
                Button(action: {
                    withAnimation(gAnim(.easeOut)) {
                        self.stbc.isPresented = true
                    }
                    GFormRouter.gfr().callFirstResponder(.searchTag)
                    
                    KeyboardObserver.ignore(formID)
                    KeyboardObserver.observe(.searchTag, true)
                }, label: {
                    self.buttonIcon
                })
            }
        }.frame(width: self.width(), height: self.height())
        .contentShape(Rectangle().inset(by: -15))
        .cornerRadius(self.stbc.isPresented ? 0 : 30)
        .offset(self.offset())
    }
}

fileprivate struct ConfirmButton: View {
    @ObservedObject private var gft: GFormText = GFormText.gft(formID)
    @ObservedObject private var ko: KeyboardObserver = KeyboardObserver.ko(formID)
    private var button: Button<AnyView>
    
    fileprivate init() {
        self.button = Button(action: AddFoodCookie.afc().addItem, label:{
            AnyView(Text("Confirm")
                .font(gFont(.ubuntuMedium, .width, 2.5))
                .padding(sWidth() * 0.04)
                .frame(width: sWidth() * 0.4)
                .foregroundColor(Color.white))
        })
    }
    
    //MARK: Getter Methods
    private func canSubmit() -> Bool {
        return !self.gft.text(AddFood.FieldIndex.food.rawValue).isEmpty
    }
    
    public var body: some View {
        HStack(spacing: nil) {
            Spacer()
            
            self.button
                .background(self.canSubmit() ? gColor(.blue0) : Color(white: 0.9))
                .cornerRadius(100)
                .disabled(!self.canSubmit())
                .animation(gAnim(.easeOut))
        }.padding(20)
        .frame(width: sWidth())
        .shadow(color: Color.black.opacity(0.2), radius: 12, y: 15)
        .offset(y: min(-self.ko.height(), -40))
    }
}

public struct AddFood: View, GFieldDelegate {
    private var uc: UserCookie = UserCookie.uc()
    private var toListHome: () -> Void
    
    private var symbols: [AnyView]
    private var backButton: AnyView
    private var searchTagButton: SearchTagButton
    private var confirmButton: ConfirmButton
    
    @ObservedObject private var gft: GFormText = GFormText.gft(formID)
    @ObservedObject private var afc: AddFoodCookie = AddFoodCookie.afc()
    
    //MARK: Initializers
    public init(){
        self.toListHome = ContentCookie.cc().toListHome
        
        //MARK: Subviews
        let gftSymbols = ["flame.fill", "rosette", "mappin.and.ellipse", ""]
        var tempSymbols: [AnyView?] = Array(repeating: nil, count: gftSymbols.count)
        for index in 0 ..< gftSymbols.count {
            tempSymbols[index] = AnyView(Image(systemName: gftSymbols[index]).font(.system(size: 25)))
        }
        self.symbols = tempSymbols as! [AnyView]
        self.backButton = AnyView(Button(action: self.toListHome, label: {
            Image(systemName: "chevron.left")
                .foregroundColor(Color.white)
                .padding(.leading, 5)
        }).frame(width: 50, height: navBarHeight))
        self.searchTagButton = SearchTagButton()
        self.confirmButton = ConfirmButton()
        
        //MARK: GFT Initialization
        self.gft.setNames(["Food", "Restaurant", "Address", "Price"])
        self.gft.setSymbols(gftSymbols)
        self.gft.setError(FieldIndex.restaurant.rawValue, "(Optional)")
        self.gft.setError(FieldIndex.address.rawValue, "(Optional)")
        self.gft.setError(FieldIndex.price.rawValue, "(Optional)")
    }
    
    //Field Enums
    public enum FieldIndex: Int {
        case food = 0
        case restaurant = 1
        case address = 2
        case price = 3
    }
    
    //Edit Enums
    public enum AddFoodMode {
        case add
        case edit
    }
    
    //Setter Methods
    public static func clearFields() {
        GFormText.gft(formID).setText(FieldIndex.food.rawValue, "")
        GFormText.gft(formID).setText(FieldIndex.price.rawValue, "")
        GFormText.gft(formID).setText(FieldIndex.restaurant.rawValue, "")
        GFormText.gft(formID).setText(FieldIndex.address.rawValue, "")
        AddFoodCookie.afc().resetForNewGrub()
    }
    
    //Implemented GFieldDelegate Methods
    public func style(_ index: Int, _ textField: GTextField, _ placeholderText: @escaping (String) -> Void) {
        placeholderText(self.gft.error(index))
        textField.setInsets(top: 23, left: 10, bottom: 5, right: 10)
        textField.font = gFont(.ubuntuLight, .width, 2)
        textField.textColor = gColor(.blue2)
        switch index {
            case FieldIndex.address.rawValue:
                textField.returnKeyType = .default
            case FieldIndex.price.rawValue:
                textField.keyboardType = .numberPad
                textField.textAlignment = .right
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
                        text = cut(text, maxLength: 15)
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
                self.backButton
                
                Spacer()
            }
            
            Text("Add Grub to List")
                .font(navBarFont)
                .fontWeight(.bold)
                .foregroundColor(Color.white)
                .padding(12)
        }
    }
    
    private func field(_ index: Int, _ width: CGFloat = .infinity) -> some View {
        ZStack(alignment: .topLeading) {
            Color.clear
            
            Rectangle()
                .fill(Color(white: 0.8))
                .frame(width: 1, height: fieldHeight)
            
            Rectangle()
                .fill(Color(white: 0.8))
                .frame(height: 1)
            
            Text(self.gft.name(index))
                .padding(7)
                .font(gFont(.ubuntuMedium, .width, 1.5))
            
            GField(formID, index, self)
        }.frame(maxWidth: width, maxHeight: fieldHeight)
    }
    
    private var form: some View {
        HStack(spacing: 0) {
            VStack(spacing: 0) {
                ForEach(0 ..< size(formID)) { index in
                    if !self.gft.symbol(index).isEmpty {
                        ZStack {
                            self.symbols[index]
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
                    self.field(FieldIndex.food.rawValue)
                    self.field(FieldIndex.price.rawValue, sWidth() * 0.35)
                }.frame(height: fieldHeight)
                self.field(FieldIndex.restaurant.rawValue)
                self.field(FieldIndex.address.rawValue)
            }.foregroundColor(Color(white: 0.3))
            .frame(idealWidth: .infinity, maxWidth: .infinity)
        }
    }
    
    private struct TagBox: View {
        private static var instances: [GrubTag: TagBox] = [:]
        fileprivate static var width: CGFloat = sWidth() * sWidth() * 0.001
        fileprivate static var height: CGFloat = width * 1.0
        private var id: GrubTag
        
        //Initializer
        private init(id: GrubTag) {
            self.id = id
        }
        
        public static func box(id: GrubTag) -> TagBox {
            if TagBox.instances[id] == nil {
                TagBox.instances[id] = TagBox(id: id)
            }
            return TagBox.instances[id]!
        }
        
        //Getters
        public func tag() -> GrubTag {
            return self.id
        }
        
        public var body: some View {
            ZStack(alignment: .center) {
                ZStack(alignment: .bottom) {
                    GTagIcon.icon(tag: self.id, id: .tagBox, size: CGSize(width: TagBox.width, height: TagBox.height))
                    
                    LinearGradient(gradient: Gradient(colors: [gTagColors[self.id]!.opacity(0), gTagColors[self.id]!]),
                                   startPoint: .top, endPoint: .bottom)
                        .frame(height: TagBox.height * 0.5)
                }.frame(width: TagBox.width, height: TagBox.height)
                .cornerRadius(20)
                .shadow(color: gTagColors[self.id]!.opacity(0.5), radius: 8, y: 10)
                
                ZStack(alignment: .bottom) {
                    Color.clear
                    
                    Text(capFirst(self.id))
                        .font(gFont(.ubuntuBold, .width, 3))
                        .foregroundColor(Color.white)
                        .padding(10)
                }
                
                if self.id != food {
                    ZStack(alignment: .topTrailing) {
                        Color.clear
                        
                        Button(action: {
                            AddFoodCookie.afc().tags[self.id] = nil
                            AddFoodCookie.afc().tagsEdited = true
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
        var sortedTags: [GrubTag] = self.afc.tags.keys.sorted()
        sortedTags.remove(at: sortedTags.firstIndex(of: food)!)
        sortedTags.insert(food, at: 0)
        
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
                            TagBox.box(id: sortedTags[index])
                                .transition(.opacity)
                                .animation(gAnim(.spring))
                        }
                        
                        Spacer().frame(width: sWidth() * 0.5)
                    }.padding(.leading, sHeight() * 0.02)
                    .padding(.bottom, 30)
                }.frame(width: sWidth())
                .highPriorityGesture(DragGesture())
                Spacer()
                self.confirmButton
            }
            
            self.searchTagButton
        }.onTapGesture {
            if !SearchTagButtonCookie.stbc().isPresented {
                UIApplication.shared.endEditing()
            }
        }
    }
}

#if DEBUG
struct AddToListView_Previews: PreviewProvider {
   static var previews: some View {
      Group {
         AddFood()
            .previewDevice(PreviewDevice(rawValue: "iPhone SE"))
            .previewDisplayName("iPhone SE")

         AddFood()
            .previewDevice(PreviewDevice(rawValue: "iPhone XS Max"))
            .previewDisplayName("iPhone XS Max")
      }
   }
}
#endif
