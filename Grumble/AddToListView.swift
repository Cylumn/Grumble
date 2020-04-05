//
//  AddToListView.swift
//  Grumble
//
//  Created by Allen Chang on 3/22/20.
//  Copyright © 2020 Cylumn, Inc. All rights reserved.
//

import SwiftUI

private let formID: GFormID = GFormID.addFood

public struct AddToListView: View, GFieldDelegate {
    @ObservedObject private var uc: UserCookie = UserCookie.uc()
    private var contentView: ContentView
    
    private var safeAreaTop: CGFloat
    private var navBarHeight: CGFloat
    
    @ObservedObject private var gft: GFormText = GFormText.gft(formID)
    
    //Initializer
    public init(_ contentView: ContentView){
        self.contentView = contentView
        
        self.safeAreaTop = 20
        self.navBarHeight = 0.12
    }
    
    //Field Enums
    private enum FieldIndex: Int {
        case name = 0
        case food = 1
        case price = 2
        case address = 3
    }
    
    //Getter Methods
    private func canSubmit() -> Bool {
        return !self.gft.text(FieldIndex.name.rawValue).isEmpty && !self.gft.text(FieldIndex.food.rawValue).isEmpty
    }
    
    //Proceed Methods
    private func addItem(){
        var foodItem = [:] as [String: Any]
        foodItem["address"] = !self.gft.text(FieldIndex.address.rawValue).isEmpty ? self.gft.text(FieldIndex.address.rawValue) : nil
        foodItem["food"] = !self.gft.text(FieldIndex.food.rawValue).isEmpty ? self.gft.text(FieldIndex.food.rawValue) : "undefined"
        foodItem["price"] = parsePriceField(self.gft.text(FieldIndex.price.rawValue))
        
        let name = self.gft.text(FieldIndex.name.rawValue)
        let foodDictionary = foodItem as NSDictionary
        self.uc.appendFoodList(name, Restaurant(foodDictionary))
        appendLocalFood(name, foodDictionary)
        appendCloudFood(name, foodDictionary)
        contentView.toListHome()
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
        textField.setInsets(top: 5, left: 30, bottom: 5, right: 15)
        textField.font = UIFont(name: "Teko-SemiBold", size: sWidth() / 17)
        textField.textColor = gColor(.blue2)
        switch index {
            case FieldIndex.price.rawValue:
                textField.setInsets(top: 5, left: 35, bottom: 5, right: 15)
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
                    case FieldIndex.name.rawValue:
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
    
    public var body: some View {
        ZStack{
            Color.white
        VStack(spacing: 30){
            ZStack{
                HStack{
                    Button(action: self.contentView.toListHome, label: {
                        Image(systemName: "chevron.left")
                            .foregroundColor(Color.white)
                            .padding(.leading, 5)
                    }).frame(width: 50, height: sWidth() * self.navBarHeight)
                    
                    Spacer()
                }
                
                Text("Add to My List")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(Color.white)
                    .padding(12)
            }
            .padding(.top, self.safeAreaTop)
            .frame(width: sWidth(), height: sWidth() * self.navBarHeight + self.safeAreaTop)
            .background(gColor(.blue0))
            
            VStack(alignment: .leading, spacing: 30){
                HStack{
                VStack(alignment: .leading, spacing: 0){
                    Text("Restaurant Name *")
                        .foregroundColor(gColor(.blue0))
                    .font(.custom("Ubuntu-Medium", size: sWidth() / 25))
                    
                    ZStack{
                        VStack(spacing: 0){
                            HStack(spacing: 0){
                                Image(systemName: "pencil.tip")
                                .font(.system(size: sWidth() / 25 + 3))
                                    .padding(.leading, 5)
                                    .padding(.top, 10)
                                    .padding(.bottom, 15)
                                    .foregroundColor(gColor(.blue0))

                                Spacer()
                            }.offset(y: 3)

                            Rectangle().fill(gColor(.blue0)).frame(height: 5)
                        }
                        
                        GField(formID, 0, self)
                            .frame(width: sWidth() * 0.7, height: 50)
                    }
                }.frame(width: sWidth() * 0.7)
                    Spacer()
                }
                
                HStack{
                VStack(alignment: .leading, spacing: 0){
                    Text("Food *")
                    .foregroundColor(gColor(.blue0))
                    .font(.custom("Ubuntu-Medium", size: sWidth() / 25))
                    
                    ZStack{
                        VStack(spacing: 0){
                            HStack(spacing: 0){
                                Image(systemName: "flame")
                                .font(.system(size: sWidth() / 25 + 3))
                                    .padding(.leading, 5)
                                    .padding(.top, 10)
                                    .padding(.bottom, 15)
                                .foregroundColor(gColor(.blue0))

                                Spacer()
                            }.offset(y: 3)

                            Rectangle().fill(gColor(.blue0)).frame(height: 5)
                        }
                        
                        GField(formID, 1, self)
                            .frame(width: sWidth() * 0.45, height: 50)
                    }
                }.frame(width: sWidth() * 0.45)
                
                Spacer()
                    
                VStack(alignment: .leading, spacing: 0){
                    Text("Price")
                    .foregroundColor(gColor(.blue0))
                    .font(.custom("Ubuntu-Medium", size: sWidth() / 25))
                    
                    ZStack{
                        VStack(spacing: 0){
                            HStack(spacing: 0){
                                Image(systemName: "tag")
                                .font(.system(size: sWidth() / 25 + 3))
                                    .padding(.leading, 5)
                                    .padding(.top, 10)
                                    .padding(.bottom, 15)
                                .foregroundColor(gColor(.blue0))

                                Spacer()
                            }.offset(y: 3)

                            Rectangle().fill(gColor(.blue0)).frame(height: 5)
                        }
                        
                        ZStack{
                            GField(formID, 2, self)
                                .frame(width: 150, height: 50)
                        }.frame(width: sWidth() * 0.35)
                    }
                }.frame(width: sWidth() * 0.35)
                }
                
                HStack{
                VStack(alignment: .leading, spacing: 0){
                    Text("Address")
                    .foregroundColor(gColor(.blue0))
                    .font(.custom("Ubuntu-Medium", size: sWidth() / 25))
                    
                    ZStack{
                        VStack(spacing: 0){
                            HStack(spacing: 0){
                                Image(systemName: "mappin.and.ellipse")
                                .font(.system(size: sWidth() / 25 + 3))
                                    .padding(.leading, 5)
                                    .padding(.top, 10)
                                    .padding(.bottom, 15)
                                .foregroundColor(gColor(.blue0))

                                Spacer()
                            }.offset(y: 3)

                            Rectangle().fill(gColor(.blue0)).frame(height: 5)
                        }
                        
                        GField(formID, 3, self).frame(width: sWidth() * 0.9, height: 50)
                    }
                }.frame(width: sWidth() * 0.9)
                }
            }.frame(width: sWidth() * 0.9)
            
            Button(action: self.addItem, label:{
                Text("+ ADD ITEM")
                    .font(.custom("Ubuntu-Bold", size: sWidth() / 25))
                    .padding(10)
                    .frame(width: sWidth() * 0.7)
                    .animation(nil)
                    .foregroundColor(!self.canSubmit() ? gColor(.lightTurquoise).opacity(0.3) : gColor(.blue4))
                    .overlay(RoundedRectangle(cornerRadius: 8)
                        .stroke(!self.canSubmit() ? gColor(.lightTurquoise).opacity(0.3) : gColor(.blue4), lineWidth: 8))
                    .animation(.easeInOut(duration: 0.1))
            }).background(!self.canSubmit() ? gColor(.lightTurquoise).opacity(0.3) : gColor(.lightTurquoise).opacity(0.7))
            .cornerRadius(8)
            .disabled(!self.canSubmit())
            
            Spacer()
        }
        }.contentShape(Rectangle())
        .edgesIgnoringSafeArea(.all)
    }
}

#if DEBUG
struct AddToListView_Previews: PreviewProvider {
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
