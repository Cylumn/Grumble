//
//  IOManager.swift
//  Grumble
//
//  Created by Allen Chang on 3/21/20.
//  Copyright © 2020 Cylumn, Inc. All rights reserved.
//

import SwiftUI
import Firebase

private struct DataList: Decodable {
    var foodList: [String: Grub]?
    var ghorblinName: String?
    var linkToken: String?
}

public enum DataListKeys: String {
    case foodList = "foodList"
    case ghorblinName = "ghorblinName"
    case linkToken = "linkToken"
}

public enum LoadingStatus {
    case loading
    case loaded
}

//Getter Functions
private func dataPath() -> String {
    let docPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
    let dataPListPath = docPath.appendingPathComponent("data.plist")
    let bundleDataPListURL = Bundle.main.url(forResource: "data", withExtension: "plist")
    do {
        if !FileManager.default.fileExists(atPath: dataPListPath) {
            if let dataBundleURL = bundleDataPListURL {
                //Write Bundle DataPList to DocPList
                let rawData = try Data(contentsOf: dataBundleURL)
                NSData(data: rawData).write(toFile: dataPListPath, atomically: true)
            } else {
                print("error: Bundle data.plist is missing")
            }
        }
        return dataPListPath
    } catch {
        print("error:\(error)")
        return bundleDataPListURL?.path ?? ""
    }
}

//Helper Functions
private func loadPropertyList<T>(_ url: URL?, _ decodable: T.Type) -> T? where T : Decodable {
    guard let url = url else {
        print("error: url is empty")
        return nil
    }
    do {
        if let rawData = FileManager.default.contents(atPath: url.path) {
            let decoder = PropertyListDecoder()
            let data = try decoder.decode(decodable, from: rawData)
            return data
        }
    } catch {
        print("error:\(error)")
    }
    return nil
}

//Data Functions
public func loadLocalData() {
    if let data = loadPropertyList(URL(string: dataPath()), DataList.self) {
        UserCookie.uc().setFoodList(data.foodList ?? [:] as [String: Grub])
        UserCookie.uc().sortFoodListByDate()
        UserCookie.uc().setGhorblinName(data.ghorblinName)
        UserCookie.uc().setLinkToken(data.linkToken)
    }
}

public func writeLocalData(_ key: DataListKeys, _ value: Any?) {
    if let rootDataDictionary = NSMutableDictionary(contentsOfFile: dataPath()) {
        rootDataDictionary.setValue(value, forKey: key.rawValue)
        rootDataDictionary.write(toFile: dataPath(), atomically: true)
    }
}

public func clearLocalData() {
    if let rootDataDictionary = NSMutableDictionary(contentsOfFile: dataPath()) {
        rootDataDictionary.removeAllObjects()
        rootDataDictionary.setValue([:], forKey: DataListKeys.foodList.rawValue)
        rootDataDictionary.write(toFile: dataPath(), atomically: true)
    }
}

public func loadCloudData(_ returnData: @escaping (NSDictionary?) -> Void) {
    if let uid = Auth.auth().currentUser?.uid {
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            returnData(snapshot.value as? NSDictionary)
        })
    }
}

public func writeCloudData(_ key: DataListKeys, _ value: Any?) {
    if let uid = Auth.auth().currentUser?.uid {
        Database.database().reference().child("users").child(uid).child(key.rawValue).setValue(value)
    }
}

//FoodList Functions
public func appendLocalFood(_ key: String, _ foodItem: NSDictionary) {
    if let rootDataDictionary = NSMutableDictionary(contentsOfFile: dataPath()) {
        (rootDataDictionary[DataListKeys.foodList.rawValue] as! NSDictionary).setValue(foodItem, forKey: key)
        rootDataDictionary.write(toFile: dataPath(), atomically: true)
    }
}

public func appendCloudFood(_ key: String, _ foodItem: NSDictionary) {
    if let uid = Auth.auth().currentUser?.uid {
        Database.database().reference().child("users").child(uid).child(DataListKeys.foodList.rawValue).child(key).setValue(foodItem)
    }
}

public func removeLocalFood(_ key: String) {
    if let rootDataDictionary = NSMutableDictionary(contentsOfFile: dataPath()) {
        (rootDataDictionary[DataListKeys.foodList.rawValue] as! NSMutableDictionary).removeObject(forKey: key)
        rootDataDictionary.write(toFile: dataPath(), atomically: true)
    }
}

public func removeCloudFood(_ key: String) {
    if let uid = Auth.auth().currentUser?.uid {
        Database.database().reference().child("users").child(uid).child(DataListKeys.foodList.rawValue).child(key).removeValue()
    }
}

//Cloud Observers
public func onCloudFoodAdded(_ snapshot: DataSnapshot) {
    if let foodItem = snapshot.value as? NSDictionary {
        UserCookie.uc().appendFoodList(snapshot.key, Grub(foodItem))
        UserCookie.uc().sortFoodListByDate()
        appendLocalFood(snapshot.key, foodItem)
    }
    UserCookie.uc().loadingStatus = .loaded
}

public func onCloudDataAdded(_ snapshot: DataSnapshot) {
    switch snapshot.key {
    case DataListKeys.ghorblinName.rawValue:
        UserCookie.uc().setGhorblinName(snapshot.value as? String)
        writeLocalData(DataListKeys.ghorblinName, snapshot.value as? String)
    case DataListKeys.linkToken.rawValue:
        UserCookie.uc().setLinkToken(snapshot.value as? String)
        writeLocalData(DataListKeys.linkToken, snapshot.value as? String)
    default:
        return
    }
    UserCookie.uc().loadingStatus = .loaded
}


public func onCloudFoodRemoved(_ snapshot: DataSnapshot) {
    UserCookie.uc().removeFoodList(snapshot.key)
    UserCookie.uc().sortFoodListByDate()
    removeLocalFood(snapshot.key)
    UserCookie.uc().loadingStatus = .loaded
}

public func onCloudDataRemoved(_ snapshot: DataSnapshot) {
    switch snapshot.key {
    case DataListKeys.ghorblinName.rawValue:
        UserCookie.uc().setGhorblinName(nil)
        writeLocalData(DataListKeys.ghorblinName, nil)
    case DataListKeys.linkToken.rawValue:
        UserCookie.uc().setLinkToken(nil)
        writeLocalData(DataListKeys.linkToken, nil)
    default:
        return
    }
    UserCookie.uc().loadingStatus = .loaded
}

public func onCloudFoodChanged(_ snapshot: DataSnapshot) {
    if let foodItem = snapshot.value as? NSDictionary {
        UserCookie.uc().appendFoodList(snapshot.key, Grub(foodItem))
        UserCookie.uc().sortFoodListByDate()
        appendLocalFood(snapshot.key, foodItem)
    }
    UserCookie.uc().loadingStatus = .loaded
}

public func onCloudDataChanged(_ snapshot: DataSnapshot) {
    switch snapshot.key {
    case DataListKeys.ghorblinName.rawValue:
        UserCookie.uc().setGhorblinName(snapshot.value as? String)
        writeLocalData(DataListKeys.ghorblinName, snapshot.value as? String)
    case DataListKeys.linkToken.rawValue:
        UserCookie.uc().setLinkToken(snapshot.value as? String)
        writeLocalData(DataListKeys.linkToken, snapshot.value as? String)
    default:
        return
    }
    UserCookie.uc().loadingStatus = .loaded
}

public func setObservers(uid: String) {
    let ref = Database.database().reference()
    
    ref.child("users").child(uid).removeAllObservers()
    ref.child("users").child(uid).observe(DataEventType.childAdded, with: onCloudDataAdded)
    ref.child("users").child(uid).observe(DataEventType.childRemoved, with: onCloudDataRemoved)
    ref.child("users").child(uid).observe(DataEventType.childChanged, with: onCloudDataChanged)
    
    ref.child("users").child(DataListKeys.foodList.rawValue).removeAllObservers()
    ref.child("users").child(uid).child(DataListKeys.foodList.rawValue).observe(DataEventType.childAdded, with: onCloudFoodAdded)
    ref.child("users").child(uid).child(DataListKeys.foodList.rawValue).observe(DataEventType.childRemoved, with: onCloudFoodRemoved)
    ref.child("users").child(uid).child(DataListKeys.foodList.rawValue).observe(DataEventType.childChanged, with: onCloudFoodChanged)
}

//User Login/Logout
public func onLogin() {
    if let uid = Auth.auth().currentUser?.uid {
        setObservers(uid: uid)
        
        loadCloudData() { data in
            let foodList: NSDictionary? = data?[DataListKeys.foodList.rawValue] as? NSDictionary
            if foodList == nil || foodList!.count == 0 {
                UserCookie.uc().loadingStatus = .loaded
            }
            
            UserCookie.uc().setGhorblinName(data?[DataListKeys.ghorblinName.rawValue] as? String)
            UserCookie.uc().setLinkToken(data?[DataListKeys.linkToken.rawValue] as? String)
            
            UserCookie.uc().setLoggedIn(Auth.auth().currentUser)
            TabRouter.tr().changeTab(.list)
            KeyboardObserver.reset()
        }
    }
}

public func onLogout() {
    do {
        if let uid = Auth.auth().currentUser?.uid {
            Database.database().reference().child("users").child(uid).removeAllObservers()
            Database.database().reference().child("users").child(uid).child(DataListKeys.foodList.rawValue).removeAllObservers()
        }
        
        try Auth.auth().signOut()
        UserCookie.uc().setLoggedIn(nil)
        UserCookie.uc().setFoodList([:] as [String: Grub])
        UserCookie.uc().setLinkToken(nil)
        UserCookie.uc().setGhorblinName(nil)
        UserCookie.uc().loadingStatus = LoadingStatus.loading
        clearLocalData()
        
        GFormText.reset()
        KeyboardObserver.reset()
    } catch {
        print("error:\(error)")
    }
}

//Profile Changes
public func createAccount(email: String, pass: String, displayName: String, _ finishedWithError: @escaping (NSError?) -> Void) {
    Auth.auth().createUser(withEmail: email, password: pass) { user, error in
        if let error = error as NSError? {
            finishedWithError(error)
            return
        }
        let user = Auth.auth().currentUser!.createProfileChangeRequest()
        user.displayName = displayName
        user.commitChanges() { error in
            if let error = error as NSError? {
                print("error:\(error)")
                finishedWithError(error)
            } else {
                UserCookie.uc().setLinkToken(nil)
                writeLocalData(DataListKeys.linkToken, nil)
                
                finishedWithError(nil)
            }
        }
    }
}

public func createLinkedAccount(pass: String, _ finishedWithError: @escaping (NSError?) -> Void = { _ in}) {
    let user = Auth.auth().currentUser!
    let email: String = user.email!
    let credential: AuthCredential = EmailAuthProvider.credential(withEmail: email, password: pass)
    user.link(with: credential) { _, error in
        guard error == nil else {
            print("error:\(error!)")
            finishedWithError(error as NSError?)
            return
        }
        
        finishedWithError(nil)
    }
}

public func changePassword(old: String, new: String, _ finishedWithError: @escaping (AuthErrorCode?) -> Void) {
    let user = Auth.auth().currentUser!
    let email: String = user.email!
    let credential: AuthCredential = EmailAuthProvider.credential(withEmail: email, password: old)
    user.reauthenticate(with: credential) { _, error in
        guard error == nil else {
            finishedWithError(AuthErrorCode.wrongPassword)
            return
        }
        
        user.updatePassword(to: new) { error in
            guard error == nil else {
                finishedWithError(AuthErrorCode.weakPassword)
                return
            }
            
            finishedWithError(nil)
        }
    }
}
