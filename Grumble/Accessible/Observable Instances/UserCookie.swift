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

//MARK: - GrubTags
public typealias GrubTag = String
public let food: GrubTag = "food"
public let bread: GrubTag = "bread"
public let burger: GrubTag = "burger"
public let dairy: GrubTag = "dairy"
public let dessert: GrubTag = "dessert"
public let egg: GrubTag = "egg"
public let fried: GrubTag = "fried"
public let fruit: GrubTag = "fruit"
public let grains: GrubTag = "grains"
public let meat: GrubTag = "meat"
public let noodles: GrubTag = "noodles"
public let salad: GrubTag = "salad"
public let seafood: GrubTag = "seafood"
public let soup: GrubTag = "soup"
public let gTags: [GrubTag] = [food, bread, burger, dairy, dessert, egg, fried, fruit, grains, meat, noodles, salad, seafood, soup]
public let gTagMap: [GrubTag: Int] =
    [food: 0,
    bread: 1,
    burger: 2,
    dairy: 3,
    dessert: 4,
    egg: 5,
    fried: 6,
    fruit: 7,
    grains: 8,
    meat: 9,
    noodles: 10,
    salad: 11,
    seafood: 12,
    soup: 13]


public let gTagColors: [GrubTag: Color] =
    [food: gColor(.blue2),
     bread: gColor(.pumpkin),
     burger: gColor(.dandelion),
     dairy: gColor(.indigo),
     dessert: gColor(.coral),
     egg: gColor(.yolk),
     fried: gColor(.poppy),
     fruit: gColor(.grass),
     grains: gColor(.dew),
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
     grains: GFood.genericInit,
     meat: GFood.genericInit,
     noodles: GFood.genericInit,
     salad: GSalad.genericInit,
     seafood: GFood.genericInit,
     soup: GSoup.genericInit]

public func gTagView(_ tag: GrubTag, _ boundingSize: CGSize, idleData: CGFloat, tossData: CGFloat) -> AnyView {
    return gTagIcons[tag]!(boundingSize, idleData, tossData)
}

//MARK: - Grub
public struct Grub: Decodable, Equatable {
    private static var images: [String: UIImage] = [:]
    
    public var fid: String
    public var img: String
    public var food: String
    public var price: Double?
    public var restaurant: String?
    public var address: String?
    public var tags: [GrubTag: Double]
    public var priorityTag: GrubTag
    public var date: String
    
    public var immutable: Bool
    
    enum GrubKeys: String, CodingKey {
        case fid = "fid"
        case img = "img"
        case food = "food"
        case price = "price"
        case restaurant = "restaurant"
        case address = "address"
        case tags = "tags"
        case priorityTag = "priorityTag"
        case date = "date"
        case immutable = "immutable"
    }
    
    //MARK: Initializers
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: GrubKeys.self)
        self.fid = try values.decode(String.self, forKey: .fid)
        self.img = try values.decode(String.self, forKey: .img)
        self.food = try values.decode(String.self, forKey: .food)
        self.price = try values.decodeIfPresent(Double.self, forKey: .price)
        self.restaurant = try values.decodeIfPresent(String.self, forKey: .restaurant)
        self.address = try values.decodeIfPresent(String.self, forKey: .address)
        self.tags = try values.decode([GrubTag: Double].self, forKey: .tags)
        self.priorityTag = try values.decode(GrubTag.self, forKey: .priorityTag)
        self.date = try values.decode(String.self, forKey: .date)
        self.immutable = try values.decodeIfPresent(Bool.self, forKey: .immutable) ?? false
        
        Grub.images[self.imgPath()] = grubImage(self.img)?.0
        ObservedImage.updateImage(self)
        GrumbleGrubImageDisplay.cacheImage(self.imgPath(), value: self.image())
    }
    
    public init(fid: String, _ foodItem: NSDictionary, immutable: Bool? = nil, image: UIImage? = nil) {
        self.fid = fid
        self.img = foodItem.value(forKey: GrubKeys.img.rawValue) as! String
        self.food = foodItem.value(forKey: GrubKeys.food.rawValue) as! String
        self.price = foodItem.value(forKey: GrubKeys.price.rawValue) as? Double
        self.restaurant = foodItem.value(forKey: GrubKeys.restaurant.rawValue) as? String
        self.address = foodItem.value(forKey: GrubKeys.address.rawValue) as? String
        self.tags = foodItem.value(forKey: GrubKeys.tags.rawValue) as! [GrubTag: Double]
        self.priorityTag = foodItem.value(forKey: GrubKeys.priorityTag.rawValue) as! GrubTag
        self.date = foodItem.value(forKey: GrubKeys.date.rawValue) as! String
        self.immutable = immutable ?? foodItem.value(forKey: GrubKeys.immutable.rawValue) as? Bool ?? false

        if let image = image {
            Grub.images[self.imgPath()] = image
        } else if Grub.images[self.imgPath()] == nil {
            if let (uiImage, _) = grubImage(self.img) {
                Grub.images[self.imgPath()] = uiImage
            }
        }
        ObservedImage.updateImage(self)
        GrumbleGrubImageDisplay.cacheImage(self.imgPath(), value: self.image())
    }
    
    public init(_ original: Grub) {
        self.fid = original.fid
        self.img = original.img
        self.food = original.food
        self.price = original.price
        self.restaurant = original.restaurant
        self.address = original.address
        self.tags = original.tags
        self.priorityTag = original.priorityTag
        self.date = original.date
        
        self.immutable = false
    }
    
    //MARK: Class Function Methods
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
    
    public static func removeFood(_ fid: String, deleteImage: Bool) {
        UserCookie.uc().removeFoodList(fid)
        removeLocalFood(fid, deleteImage: deleteImage)
        removeCloudFood(fid)
    }
    
    @available(*, deprecated) //remove in future
    public static func testGrub() -> Grub {
        var grubTest: [String: Any] = [:]
        grubTest[GrubKeys.img.rawValue] = ""
        grubTest[GrubKeys.food.rawValue] = "Ramen"
        grubTest[GrubKeys.price.rawValue] = 10.0
        grubTest[GrubKeys.restaurant.rawValue] = "Ippudo"
        grubTest[GrubKeys.address.rawValue] = "Saratoga Avenue"
        let tags = ["food": 1, soup: 1]
        grubTest[GrubKeys.tags.rawValue] = tags
        grubTest[GrubKeys.priorityTag.rawValue] = soup
        grubTest[GrubKeys.date.rawValue] = getDate()
        
        return Grub(fid: "", grubTest as NSDictionary, image: UIImage(imageLiteralResourceName: "ExplainTraining"))
    }
    
    //MARK: Getter Methods
    public func imgPath() -> String {
        return self.img.replacingOccurrences(of: immutableGrubImagePrefix, with: "")
    }
    
    public func uiImage() -> UIImage? {
        return Grub.images[self.imgPath()]
    }
    
    public func image() -> Image? {
        if let uiImage = self.uiImage() {
            return Image(uiImage: uiImage)
        } else {
            return nil
        }
    }
    
    public func dictionary() -> [String: Any] {
        var dictionary: [String: Any] = [:]
        dictionary[GrubKeys.fid.rawValue] = self.fid
        dictionary[GrubKeys.img.rawValue] = self.img
        dictionary[GrubKeys.food.rawValue] = self.food
        dictionary[GrubKeys.price.rawValue] = self.price
        dictionary[GrubKeys.restaurant.rawValue] = self.restaurant
        dictionary[GrubKeys.address.rawValue] = self.address
        dictionary[GrubKeys.tags.rawValue] = self.tags
        dictionary[GrubKeys.priorityTag.rawValue] = self.priorityTag
        dictionary[GrubKeys.date.rawValue] = self.date
        dictionary[GrubKeys.immutable.rawValue] = self.immutable
        return dictionary
    }
}

//MARK: - User Access Cookie
public class UserAccessCookie: ObservableObject {
    private static var instance: UserAccessCookie?
    @Published private var loginState: LoginState = Auth.auth().currentUser == nil ? .loggedOut : .loggedIn
    @Published private var linkToken: String? = loadLocalData(.linkToken) as? String
    @Published fileprivate var newAccount: Bool = loadLocalData(.ghorblinName) == nil
    
    //MARK: Initializers
    public static func uac() -> UserAccessCookie {
        if UserAccessCookie.instance == nil {
            UserAccessCookie.instance = UserAccessCookie()
        }
        return UserAccessCookie.instance!
    }
    
    //MARK: Enumerations
    public enum LoginState {
        case loggedOut
        case inProgress
        case loggedIn
    }
    
    //MARK: Getter Methods
    public func loggedIn() -> LoginState {
        return self.loginState
    }
    
    public func linkedAccount() -> Bool {
        return self.linkToken == nil
    }
    
    public func accountLinkToken() -> String? {
        return self.linkToken
    }
    
    public func newUser() -> Bool {
        return self.newAccount
    }
    
    //Setter Methods
    public func setLoggedIn(_ user: User?) {
        if user == nil {
            self.loginState = .loggedOut
        } else {
            self.loginState = .loggedIn
        }
    }
    
    public func setLoggedIn(_ state: LoginState) {
        self.loginState = state
    }
    
    public func setLinkToken(_ token: String?) {
        if self.linkToken != token {
            self.linkToken = token
        }
    }
}

//MARK: - User Stored Data
public class UserCookie: ObservableObject {
    private static var instance: UserCookie?
    @Published private var ghorblinName: String? = loadLocalData(.ghorblinName) as? String
    @Published private var lists: [[String: Grub]] = [loadLocalData(.foodList) as! [String: Grub], loadLocalData(.archivedList) as! [String: Grub]]
    private var grubsByDate: [[(String, Grub)]] = [[], []]
    @Published public var loadingStatus: LoadingStatus = LoadingStatus.loading
    
    //MARK: Enumerations
    public enum ListType: Int {
        case foodList = 0
        case archivedList = 1
    }
    
    //MARK: Getter Methods
    public static func uc() -> UserCookie {
        if UserCookie.instance == nil {
            UserCookie.instance = UserCookie()
            GrubItemCookie.gic().calibrateText(UserCookie.instance!.lists)
            UserCookie.instance!.sortListByDate(.foodList)
            UserCookie.instance!.sortListByDate(.archivedList)
        }
        return UserCookie.instance!
    }
    
    public func ghorblin() -> String? {
        return self.ghorblinName
    }
    
    public func foodList() -> [String: Grub] {
        return self.lists[ListType.foodList.rawValue]
    }
    
    public func foodListByDate() -> [(String, Grub)] {
        return self.grubsByDate[ListType.foodList.rawValue]
    }
    
    public func archivedList() -> [String: Grub] {
        return self.lists[ListType.archivedList.rawValue]
    }
    
    public func archivedListByDate() -> [(String, Grub)] {
        return self.grubsByDate[ListType.archivedList.rawValue]
    }
    
    //MARK: FList Modifier Methods
    public func setGhorblinName(_ name: String?) {
        if self.ghorblinName != name {
            self.ghorblinName = name
            UserAccessCookie.uac().newAccount = self.ghorblinName == nil
        }
    }
    
    public func setLists(_ lists: [[String: Grub]]) {
        if self.lists != lists {
            self.lists = lists
            for var (_, grub) in self.lists[ListType.archivedList.rawValue] {
                grub.immutable = true
            }
            GrubItemCookie.gic().reset()
            GrubItemCookie.gic().calibrateText(self.lists)
            self.sortListByDate(.foodList)
            self.sortListByDate(.archivedList)
        }
    }
    
    public func setList(_ type: ListType, _ list: [String: Grub]) {
        if self.lists[type.rawValue] != list {
            self.lists[type.rawValue] = list
            GrubItemCookie.gic().reset()
            GrubItemCookie.gic().calibrateText(self.lists)
            self.sortListByDate(type)
        }
    }
    
    public func setFoodList(_ foodList: [String: Grub]) {
        self.setList(.foodList, foodList)
    }
    
    public func setArchivedList(_ foodList: [String: Grub]) {
        self.setList(.archivedList, foodList)
    }
    
    public func appendList(_ type: ListType, _ key: String, _ value: Grub) {
        if self.lists[type.rawValue][key] != value {
            self.lists[type.rawValue][key] = value
            GrubItemCookie.gic().calibrateText(self.lists)
            self.sortListByDate(type)
        }
    }
    
    public func appendFoodList(_ key: String, _ value: Grub) {
        self.appendList(.foodList, key, value)
    }
    
    public func appendArchivedList(_ key: String, _ value: Grub) {
        self.appendList(.archivedList, key, value)
    }
    
    public func removeList(_ type: ListType, _ key: String) {
        self.lists[type.rawValue][key] = nil
        GrubItemCookie.gic().reset()
        GrubItemCookie.gic().calibrateText(self.lists)
        self.sortListByDate(type)
    }
    
    public func removeFoodList(_ key: String) {
        self.removeList(.foodList, key)
    }
    
    public func removeArchivedList(_ key: String) {
        self.removeList(.archivedList, key)
    }
    
    private func sortListByDate(_ type: ListType) {
        self.grubsByDate[type.rawValue] = Grub.sortByDate(self.lists[type.rawValue])
    }
}
