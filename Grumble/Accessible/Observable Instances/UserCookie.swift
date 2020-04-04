//
//  UserCookie.swift
//  Grumble
//
//  Created by Allen Chang on 4/2/20.
//  Copyright © 2020 Cylumn, Inc. All rights reserved.
//

import Foundation
import SwiftUI
import Firebase

public struct Restaurant: Decodable {
    var address: String?
    var food: String
    var price: Double?
    
    init(_ foodItem: NSDictionary?){
        self.address = foodItem?.value(forKey: "address") as? String
        self.food = foodItem?.value(forKey: "food") as? String ?? "undefined"
        self.price = foodItem?.value(forKey: "price") as? Double
    }
}

public class UserCookie: ObservableObject {
    private static var instance: UserCookie?
    @Published private var hasCurrentUser: Bool = false
    @Published private var fList: [String: Restaurant] = [:]
    
    //Getter Methods
    public static func uc() -> UserCookie {
        if UserCookie.instance == nil {
            UserCookie.instance = UserCookie()
        }
        return UserCookie.instance!
    }
    
    public func loggedIn() -> Bool {
        return self.hasCurrentUser
    }
    
    public func foodList() -> [String: Restaurant] {
        return self.fList
    }
    
    //FList Modifier Methods
    public func setLoggedIn(_ loggedIn: Bool) {
        self.hasCurrentUser = loggedIn
    }
    
    public func setFoodList(_ foodList: [String: Restaurant]) {
        self.fList = foodList
    }
    
    public func appendFoodList(_ key: String, _ value: Restaurant) {
        self.fList[key] = value
    }
    
    public func removeFoodList(_ key: String) {
        self.fList[key] = nil
    }
}
