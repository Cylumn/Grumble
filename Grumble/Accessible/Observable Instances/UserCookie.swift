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

public typealias GrubTag = String
public let food: GrubTag = "food"
public let bread: GrubTag = "bread"
public let burger: GrubTag = "burger"
public let dairy: GrubTag = "dairy"
public let dessert: GrubTag = "dessert"
public let egg: GrubTag = "egg"
public let fried: GrubTag = "fried"
public let fruit: GrubTag = "fruit"
public let grain: GrubTag = "grain"
public let meat: GrubTag = "meat"
public let noodles: GrubTag = "noodles"
public let salad: GrubTag = "salad"
public let seafood: GrubTag = "seafood"
public let soup: GrubTag = "soup"
public let gTags: [GrubTag] = [food, bread, burger, dairy, dessert, egg, fried, fruit, grain, meat, noodles, salad, seafood, soup]

public let gTagColors: [GrubTag: Color] =
    [food: gColor(.blue2),
     bread: gColor(.pumpkin),
     burger: gColor(.dandelion),
     dairy: gColor(.indigo),
     dessert: gColor(.coral),
     egg: gColor(.yolk),
     fried: gColor(.poppy),
     fruit: gColor(.grass),
     grain: gColor(.dew),
     meat: gColor(.crimson),
     noodles: gColor(.cerulean),
     salad: gColor(.neon),
     seafood: gColor(.wolfsbane),
     soup: gColor(.magenta)]

private let gTagIcons: [GrubTag: (CGSize, CGFloat, CGFloat) -> AnyView] =
    [food: GFood.genericInit,
     bread: GFood.genericInit,
     burger: GBurger.genericInit,
     dairy: GFood.genericInit,
     dessert: GFood.genericInit,
     egg: GFood.genericInit,
     fried: GFood.genericInit,
     fruit: GFood.genericInit,
     grain: GFood.genericInit,
     meat: GFood.genericInit,
     noodles: GFood.genericInit,
     salad: GSalad.genericInit,
     seafood: GFood.genericInit,
     soup: GSoup.genericInit]

public func gTagView(_ tag: GrubTag, _ boundingSize: CGSize, idleData: CGFloat, tossData: CGFloat) -> AnyView {
    return gTagIcons[tag]!(boundingSize, idleData, tossData)
}

public struct Grub: Decodable {
    public static var images: [String: Image] = [:]
    public var fid: String
    
    public var food: String
    public var price: Double?
    public var restaurant: String?
    public var address: String?
    public var tags: [GrubTag: Double]
    public var priorityTag: GrubTag
    public var date: String
    
    enum GrubKeys: String, CodingKey {
        case fid, food, price, restaurant, address, tags, priorityTag, date
    }
    
    //Initializer
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: GrubKeys.self)
        self.fid = try values.decode(String.self, forKey: .fid)
        self.food = try values.decode(String.self, forKey: .food)
        self.price = try values.decodeIfPresent(Double.self, forKey: .price)
        self.restaurant = try values.decodeIfPresent(String.self, forKey: .restaurant)
        self.address = try values.decodeIfPresent(String.self, forKey: .address)
        self.tags = try values.decode([GrubTag: Double].self, forKey: .tags)
        self.priorityTag = try values.decode(GrubTag.self, forKey: .priorityTag)
        self.date = try values.decode(String.self, forKey: .date)
        
        Grub.images[self.fid] = Image(uiImage: grubImage(self.fid))
    }
    
    public init(fid: String, _ foodItem: NSDictionary?, image: UIImage? = nil) {
        self.fid = fid
        
        self.food = foodItem?.value(forKey: "food") as! String
        self.price = foodItem?.value(forKey: "price") as? Double
        self.restaurant = foodItem?.value(forKey: "restaurant") as? String
        self.address = foodItem?.value(forKey: "address") as? String
        self.tags = foodItem?.value(forKey: "tags") as! [GrubTag: Double]
        self.priorityTag = foodItem?.value(forKey: "priorityTag") as! GrubTag
        self.date = foodItem?.value(forKey: "date") as! String

        Grub.images[self.fid] = image == nil ? Image(uiImage: grubImage(self.fid)) : Image(uiImage: image!)
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
    
    public func image() -> Image {
        return Grub.images[self.fid]!
    }
    
    @available(*, deprecated) //remove in future
    public static func testGrub() -> Grub {
        var grubTest: [String: Any] = [:]
        grubTest["food"] = "Ramen"
        grubTest["price"] = 10.0
        grubTest["restaurant"] = "Ippudo"
        grubTest["address"] = "Saratoga Avenue"
        let tags = ["food": 1, soup: 1]
        grubTest["tags"] = tags
        grubTest["priorityTag"] = soup
        grubTest["date"] = getDate()
        
        return Grub(fid: "", grubTest as NSDictionary, image: UIImage(imageLiteralResourceName: "ExplainTraining"))
    }
}

public class UserCookie: ObservableObject {
    private static var instance: UserCookie?
    @Published private var hasCurrentUser: Bool = false
    @Published private var linkToken: String? = nil
    @Published private var ghorblinName: String? = nil
    @Published private var fList: [String: Grub] = [:]
    @Published private var grubsByDate: [(String, Grub)] = []
    @Published public var loadingStatus: LoadingStatus = LoadingStatus.loading
    
    //Getter Methods
    public static func uc() -> UserCookie {
        if UserCookie.instance == nil {
            UserCookie.instance = UserCookie()
            loadLocalData()
        }
        return UserCookie.instance!
    }
    
    public func loggedIn() -> Bool {
        return self.hasCurrentUser
    }
    
    public func linkedAccount() -> Bool {
        return self.linkToken == nil
    }
    
    public func accountLinkToken() -> String? {
        return self.linkToken
    }
    
    public func newUser() -> Bool {
        return self.ghorblinName == nil
    }
    
    public func ghorblin() -> String? {
        return self.ghorblinName
    }
    
    public func foodList() -> [String: Grub] {
        return self.fList
    }
    
    public func foodListByDate() -> [(String, Grub)] {
        return self.grubsByDate
    }
    
    //FList Modifier Methods
    public func setLoggedIn(_ user: User?) {
        if user == nil {
            self.hasCurrentUser = false
        } else {
            self.hasCurrentUser = true
        }
    }
    
    public func setLinkToken(_ token: String?) {
        self.linkToken = token
    }
    
    public func setGhorblinName(_ name: String?) {
        if self.ghorblinName != name {
            self.ghorblinName = name
        }
    }
    
    public func setFoodList(_ foodList: [String: Grub]) {
        self.fList = foodList
        GrubItemCookie.gic().reset()
    }
    
    public func appendFoodList(_ key: String, _ value: Grub) {
        self.fList[key] = value
    }
    
    public func removeFoodList(_ key: String) {
        self.fList[key] = nil
        GrubItemCookie.gic().reset()
    }
    
    public func sortFoodListByDate() {
        self.grubsByDate = Grub.sortByDate(self.fList)
    }
}
