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

public let tagTitles: [String] = ["food", "burger", "salad", "soup"]
public let tagColors: [Color] = [gColor(.blue2),
                                        gColor(.dandelion),
                                        gColor(.neon),
                                        gColor(.magenta)]
public let tagSprites: [String] = ["", "hamburger", "salad", "soup"]
public var tagIDMap: [String: Int] {
    var map = [:] as [String: Int]
    for index in 0 ..< tagTitles.count {
        map[tagTitles[index]] = index
    }
    return map
}

//deprecate in the future
public enum GrubTags: Int {
    case food = 0
    case burger = 1
    case salad = 2
    case soup = 3
}

public struct Grub: Decodable {
    public var food: String
    public var price: Double?
    public var restaurant: String?
    public var address: String?
    public var tags: [String: Int]
    public var date: String
    
    public init(_ foodItem: NSDictionary?){
        self.food = foodItem?.value(forKey: "food") as! String
        self.price = foodItem?.value(forKey: "price") as? Double
        self.restaurant = foodItem?.value(forKey: "restaurant") as? String
        self.address = foodItem?.value(forKey: "address") as? String
        self.tags = foodItem?.value(forKey: "tags") as! [String: Int]
        self.date = foodItem?.value(forKey: "date") as! String
    }
    
    @available(*, deprecated) //remove in future
    public static func testGrub() -> Grub {
        var grubTest: [String: Any] = [:]
        grubTest["food"] = "Ramen"
        grubTest["price"] = 10.0
        grubTest["restaurant"] = "Ippudo"
        grubTest["address"] = "Saratoga Avenue"
        let tags = ["food": 0, "soup": 3, "smallestTag" : 3]
        grubTest["tags"] = tags
        grubTest["date"] = getDate()
        
        return Grub(grubTest as NSDictionary)
    }
}

public class UserCookie: ObservableObject {
    private static var instance: UserCookie?
    @Published private var hasCurrentUser: Bool = false
    @Published private var fList: [String: Grub] = [:]
    
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
    
    public func foodList() -> [String: Grub] {
        return self.fList
    }
    
    //FList Modifier Methods
    public func setLoggedIn(_ loggedIn: Bool) {
        self.hasCurrentUser = loggedIn
    }
    
    public func setFoodList(_ foodList: [String: Grub]) {
        self.fList = foodList
    }
    
    public func appendFoodList(_ key: String, _ value: Grub) {
        self.fList[key] = value
    }
    
    public func removeFoodList(_ key: String) {
        self.fList[key] = nil
    }
}
