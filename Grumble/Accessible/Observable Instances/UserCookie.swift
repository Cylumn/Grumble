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

//MARK: - Grub
public struct Grub: Decodable, Equatable {
    private static var images: [String: Image] = [:]
    
    public var fid: String
    public var img: String
    public var food: String
    public var price: Double?
    public var restaurant: String?
    public var address: String?
    public var tags: [GrubTag: Double]
    public var priorityTag: GrubTag
    public var date: String
    
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
        
        Grub.images[self.img] = Image(uiImage: grubImage(self.img)!.0)
        ObservedImage.updateImage(self)
        GrumbleGrubImageDisplay.cacheImage(self.img, value: self.image())
    }
    
    public init(fid: String, _ foodItem: NSDictionary?, image: UIImage? = nil) {
        self.fid = fid
        self.img = foodItem?.value(forKey: "img") as! String
        self.food = foodItem?.value(forKey: "food") as! String
        self.price = foodItem?.value(forKey: "price") as? Double
        self.restaurant = foodItem?.value(forKey: "restaurant") as? String
        self.address = foodItem?.value(forKey: "address") as? String
        self.tags = foodItem?.value(forKey: "tags") as! [GrubTag: Double]
        self.priorityTag = foodItem?.value(forKey: "priorityTag") as! GrubTag
        self.date = foodItem?.value(forKey: "date") as! String

        if let image = image {
            Grub.images[self.img] = Image(uiImage: image)
        } else if Grub.images[self.img] == nil {
            if let (uiImage, _) = grubImage(self.img) {
                Grub.images[self.img] = Image(uiImage: uiImage)
            }
        }
        ObservedImage.updateImage(self)
        GrumbleGrubImageDisplay.cacheImage(self.img, value: self.image())
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
    
    public static func removeFood(_ fid: String) {
        UserCookie.uc().removeFoodList(fid)
        removeLocalFood(fid)
        removeCloudFood(fid)
    }
    
    @available(*, deprecated) //remove in future
    public static func testGrub() -> Grub {
        var grubTest: [String: Any] = [:]
        grubTest["img"] = ""
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
    
    //MARK: Getter Methods
    public func image() -> Image? {
        return Grub.images[self.img]
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
    @Published private var fList: [String: Grub] = loadLocalData(.foodList) as! [String: Grub]
    private var grubsByDate: [(String, Grub)] = []
    @Published public var loadingStatus: LoadingStatus = LoadingStatus.loading
    
    //Getter Methods
    public static func uc() -> UserCookie {
        if UserCookie.instance == nil {
            UserCookie.instance = UserCookie()
            GrubItemCookie.gic().calibrateText(UserCookie.instance!.fList)
            UserCookie.instance!.sortFoodListByDate()
        }
        return UserCookie.instance!
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
    public func setGhorblinName(_ name: String?) {
        if self.ghorblinName != name {
            self.ghorblinName = name
            UserAccessCookie.uac().newAccount = self.ghorblinName == nil
        }
    }
    
    public func setFoodList(_ foodList: [String: Grub]) {
        if self.fList != foodList {
            self.fList = foodList
            GrubItemCookie.gic().reset()
            GrubItemCookie.gic().calibrateText(self.fList)
            self.sortFoodListByDate()
        }
    }
    
    public func appendFoodList(_ key: String, _ value: Grub) {
        if self.fList[key] != value {
            self.fList[key] = value
            GrubItemCookie.gic().calibrateText(self.fList)
            self.sortFoodListByDate()
        }
    }
    
    public func removeFoodList(_ key: String) {
        self.fList[key] = nil
        GrubItemCookie.gic().reset()
        GrubItemCookie.gic().calibrateText(self.fList)
        self.sortFoodListByDate()
    }
    
    private func sortFoodListByDate() {
        self.grubsByDate = Grub.sortByDate(self.fList)
    }
}
