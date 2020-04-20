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
public let tagBGs: [String] = ["food", "burger", "salad", "soup"]
public let tagSprites: [String] = ["foodIcon", "burgerIcon", "saladIcon", "soupIcon"]
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
    
    //Initializer
    public init(_ foodItem: NSDictionary?){
        self.food = foodItem?.value(forKey: "food") as! String
        self.price = foodItem?.value(forKey: "price") as? Double
        self.restaurant = foodItem?.value(forKey: "restaurant") as? String
        self.address = foodItem?.value(forKey: "address") as? String
        self.tags = foodItem?.value(forKey: "tags") as! [String: Int]
        self.date = foodItem?.value(forKey: "date") as! String
    }
    
    //Function Methods
    fileprivate static func sortByDate(_ grubList: [String: Grub]) -> [(String, Grub)] {
        var newGrubs: [(String, Grub)] = []
        newGrubs.reserveCapacity(grubList.capacity)
        for element in grubList {
            if newGrubs.count == 0 {
                newGrubs.append(element)
            } else {
                var index = 0
                while index < newGrubs.count && getDate(element.value.date).compare(getDate(newGrubs[index].1.date)) == .orderedAscending {
                    index += 1
                }
                newGrubs.insert(element, at: index)
            }
        }
        return newGrubs
    }
    
    public static func removeFood(_ fid: String) {
        UserCookie.uc().removeFoodList(fid)
        removeLocalFood(fid)
        removeCloudFood(fid)
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
    @Published private var grubsByDate: [(String, Grub)] = []
    @Published public var loadingStatus: LoadingStatus = LoadingStatus.loading
    
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
    
    public func foodListByDate() -> [(String, Grub)] {
        return self.grubsByDate
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
    
    public func sortFoodListByDate() {
        self.grubsByDate = Grub.sortByDate(self.fList)
    }
}
