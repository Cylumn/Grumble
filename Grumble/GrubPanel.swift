//
//  GrubPanel.swift
//  Grumble
//
//  Created by Allen Chang on 4/6/20.
//  Copyright © 2020 Cylumn, Inc. All rights reserved.
//

import SwiftUI

public struct GrubPanel: View {
    private static var keysInOrder: [String] = []
    
    private var name: String?
    private var food: String
    private var price: String?
    private var address: String?
    private var tags: Set<String>? //set tag
    private var dateAdded: String?
    
    //Initializer
    public init(_ grub: Grub) {
        self.name = grub.restaurant
        self.food = grub.food
        self.price = grub.price == nil ? nil : "$" + String(format:"%.2f", grub.price!)
        self.address = grub.address
        self.tags = nil
        self.dateAdded = grub.date
    }
    
    public init(name: String, food: String, price: String? = nil, address: String? = nil, tags: Set<String>? = nil, dateAdded: String? = nil) {
        self.name = name
        self.food = food
        self.price = price
        self.address = address
        self.tags = tags
        self.dateAdded = dateAdded
    }
    
    //Getter Methods
    public static func key(_ index: Int) -> String {
        return self.keysInOrder[index]
    }
    
    public static func generateGrubs(foodList: [String: Grub]?) -> [AnyView] {
        guard let foodList = foodList else {
            return []
        }
        
        self.keysInOrder = []
        var grubs: [AnyView] = []
        for key in foodList.keys.shuffled() {
            self.keysInOrder.append(key)
            grubs.append(AnyView(GrubPanel(foodList[key]!)))
        }
        return grubs
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Spacer()
            
            HStack(alignment: .bottom, spacing: nil) {
                Text(self.food + ",")
                    .font(gFont(.ubuntuMedium, 30))

                Text(self.name ?? "")
                    .font(gFont(.ubuntuLightItalic, 15))
                
                Spacer()
                
                if self.price != nil {
                    Text(self.price!)
                        .font(gFont(.ubuntuMedium, 20))
                }
            }
            
            Text(self.address ?? " ")
                .font(gFont(.ubuntuLightItalic, 12))
        }.padding([.leading, .trailing], 30)
        .padding(.bottom, 10)
        .foregroundColor(Color.gray)
    }
}
