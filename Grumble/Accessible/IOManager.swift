//
//  IOManager.swift
//  Grumble
//
//  Created by Allen Chang on 3/21/20.
//  Copyright © 2020 Cylumn, Inc. All rights reserved.
//

import SwiftUI
import Firebase
import Photos

//MARK: - Constants
private let imagePath: String = "images/"
private let immutableImagePath: String = "immutableGrub/"
public let immutableGrubImagePrefix: String = "ig."

//MARK: - Decodable Structures
private struct DataList: Decodable {
    var foodList: [String: Grub]?
    var archivedList: [String: Grub]?
    var ghorblinName: String?
    var linkToken: String?
}

//MARK: - Enumerations
public enum DataListKeys: String {
    case foodList = "foodList"
    case archivedList = "archivedList"
    case ghorblinName = "ghorblinName"
    case linkToken = "linkToken"
}

public enum LoadingStatus {
    case loading
    case loaded
}

//MARK: - Helper Functions
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

//MARK: - Grub Image Functions
public func grubImage(_ filename: String) -> (UIImage, Date)? {
    let grubImagePath: String = filename.contains(".jpg") ? filename : filename + ".jpg"
    let docPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
    let filePath = docPath.appendingPathComponent(imagePath + grubImagePath)
    let imageURL = URL(fileURLWithPath: filePath)
    do {
        if FileManager.default.fileExists(atPath: filePath) {
            let attributes = try FileManager.default.attributesOfItem(atPath: filePath)
            return (UIImage(contentsOfFile: imageURL.path)!, attributes[FileAttributeKey.modificationDate] as! Date)
        } else {
            return nil
        }
    } catch {
        print("error:\(error)")
        return nil
    }
}

public func writeLocalGrubImage(_ filename: String, image: UIImage) {
    DispatchQueue.global(qos: .utility).async {
        let docPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
        let docURL = URL(fileURLWithPath: docPath as String)
        let fileURL = docURL.appendingPathComponent(imagePath + filename + ".jpg")
        if let data = image.jpegData(compressionQuality:  1.0) {
            do {
                // writes the image data to disk
                try data.write(to: fileURL, options: .atomic)
            } catch {
                print("error:\(error)")
            }
        }
    }
}

public func removeLocalGrubImage(_ filename: String) {
    let docPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
    let fileManager = FileManager.default
    do {
        let filePath = docPath.appendingPathComponent(imagePath + filename + ".jpg")
        if fileManager.fileExists(atPath: filePath) {
            try fileManager.removeItem(atPath: filePath)
        }
    } catch {
        print("error:\(error)")
    }
}

public func clearLocalGrubImages() {
    let docPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
    let fileManager = FileManager.default
    do {
        let dirURL = URL(fileURLWithPath: docPath.appendingPathComponent(imagePath))
        let files = try fileManager.contentsOfDirectory(atPath: dirURL.path)
        for filePath in files {
            try fileManager.removeItem(atPath: dirURL.appendingPathComponent(filePath).path)
        }
    } catch {
        print("error:\(error)")
    }
}

//MARK: - Data Functions
private var data: DataList? = nil
public func loadLocalData() {
    if data == nil {
        data = loadPropertyList(URL(string: dataPath()), DataList.self)
    }
    if let data = data {
        UserCookie.uc().setGhorblinName(data.ghorblinName)
        UserAccessCookie.uac().setLinkToken(data.linkToken)
        
        DispatchQueue.main.async {
            UserCookie.uc().setFoodList(data.foodList ?? [:] as [String: Grub])
            UserCookie.uc().setArchivedList(data.archivedList ?? [:] as [String: Grub])
        }
    }
}

public func loadLocalData(_ key: DataListKeys) -> Any? {
    if data == nil {
        data = loadPropertyList(URL(string: dataPath()), DataList.self)
    }
    if let data = data {
        switch key {
        case .foodList:
            return data.foodList ?? [:]
        case .archivedList:
            return data.archivedList ?? [:]
        case .ghorblinName:
            return data.ghorblinName
        case .linkToken:
            return data.linkToken
        }
    }
    return nil
}

public func writeLocalData(_ key: DataListKeys, _ value: Any?) {
    DispatchQueue.global(qos: .utility).async {
        if let rootDataDictionary = NSMutableDictionary(contentsOfFile: dataPath()) {
            rootDataDictionary.setValue(value, forKey: key.rawValue)
            rootDataDictionary.write(toFile: dataPath(), atomically: true)
        }
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

//MARK: - FoodList Functions
public func appendLocalFood(_ key: String, _ foodItem: NSDictionary, _ image: UIImage? = nil) {
    if image != nil {
        writeLocalGrubImage(foodItem[Grub.GrubKeys.img.rawValue] as! String, image: image!)
    }
    DispatchQueue.global(qos: .utility).async {
        if let rootDataDictionary = NSMutableDictionary(contentsOfFile: dataPath()) {
            if rootDataDictionary.value(forKey: DataListKeys.foodList.rawValue) == nil {
                rootDataDictionary.setValue([:] as [String: NSDictionary], forKey: DataListKeys.foodList.rawValue)
            }
            
            (rootDataDictionary.value(forKey: DataListKeys.foodList.rawValue) as! NSDictionary).setValue(foodItem, forKey: key)
            rootDataDictionary.write(toFile: dataPath(), atomically: true)
        }
    }
}

public func appendCloudFood(_ key: String, _ foodItem: NSDictionary) {
    if let uid = Auth.auth().currentUser?.uid {
        Database.database().reference().child("users").child(uid).child(DataListKeys.foodList.rawValue).child(key).setValue(foodItem)
    }
}

public func appendCloudFood(_ key: String, _ foodItem: NSDictionary, _ image: UIImage) {
    let storage = Storage.storage().reference()
    let imageRef = storage.child(imagePath + key + ".jpg")
    imageRef.putData(image.jpegData(compressionQuality: 1)!, metadata: nil) { (metadata, error) in
        guard error == nil else {
            print("error:\(error!)")
            return
        }
        
        //Upload actual grub
        appendCloudFood(key, foodItem)
    }
}

public func appendLocalArchive(_ key: String, _ foodItem: NSDictionary, _ image: UIImage? = nil) {
    if image != nil {
        writeLocalGrubImage(foodItem[Grub.GrubKeys.img.rawValue] as! String, image: image!)
    }
    
    DispatchQueue.global(qos: .utility).async {
        if let rootDataDictionary = NSMutableDictionary(contentsOfFile: dataPath()) {
            if rootDataDictionary.value(forKey: DataListKeys.archivedList.rawValue) == nil {
                rootDataDictionary.setValue([:] as [String: NSDictionary], forKey: DataListKeys.archivedList.rawValue)
            }
            
            (rootDataDictionary.value(forKey: DataListKeys.archivedList.rawValue) as! NSDictionary).setValue(foodItem, forKey: key)
            rootDataDictionary.write(toFile: dataPath(), atomically: true)
        }
    }
}

public func appendCloudArchive(_ key: String, _ foodItem: NSDictionary) {
    if let uid = Auth.auth().currentUser?.uid {
        Database.database().reference().child("users").child(uid).child(DataListKeys.archivedList.rawValue).child(key).setValue(foodItem)
    }
}

public func removeLocalFood(_ key: String, deleteImage: Bool) {
    if let rootDataDictionary = NSMutableDictionary(contentsOfFile: dataPath()) {
        let fList = (rootDataDictionary[DataListKeys.foodList.rawValue] as! NSMutableDictionary)
        if deleteImage {
            removeLocalGrubImage((fList[key] as! NSDictionary)[Grub.GrubKeys.img.rawValue] as! String)
        }
        fList.removeObject(forKey: key)
        rootDataDictionary.write(toFile: dataPath(), atomically: true)
    }
}

public func removeCloudFood(_ key: String) {
    if let uid = Auth.auth().currentUser?.uid {
        Database.database().reference().child("users").child(uid).child(DataListKeys.foodList.rawValue).child(key).removeValue()
    }
}

public func removeLocalArchive(_ key: String, deleteImage: Bool) {
    if let rootDataDictionary = NSMutableDictionary(contentsOfFile: dataPath()) {
        let aList = (rootDataDictionary[DataListKeys.archivedList.rawValue] as! NSMutableDictionary)
        if deleteImage {
            removeLocalGrubImage((aList[key] as! NSDictionary)[Grub.GrubKeys.img.rawValue] as! String)
        }
        aList.removeObject(forKey: key)
        rootDataDictionary.write(toFile: dataPath(), atomically: true)
    }
}

public func removeCloudArchive(_ key: String) {
    if let uid = Auth.auth().currentUser?.uid {
        Database.database().reference().child("users").child(uid).child(DataListKeys.archivedList.rawValue).child(key).removeValue()
    }
}

//MARK: - Cloud Observers
/* 1. Check if file exists
 * 2. -- if exists, download & compare Metadatas
 * 3. ---- if updated, create food item
 * 3. ---- if not updated, download & create food item
 * 2. -- if doesn't exist, download & create food item
 */
public func onCloudListItemAdded(_ list: UserCookie.ListType, _ snapshot: DataSnapshot) {
    let createItem: (UIImage?) -> Void = { image in
        if let foodItem = snapshot.value as? NSDictionary {
            UserCookie.uc().appendList(list, snapshot.key, Grub(fid: snapshot.key, foodItem, image: image))
            switch list {
            case .foodList:
                appendLocalFood(snapshot.key, foodItem, image)
            case .archivedList:
                appendLocalArchive(snapshot.key, foodItem, image)
            }
        }
    }
    
    let downloadItem: () -> Void = {
        let storage = Storage.storage().reference()
        let img = (snapshot.value as! NSDictionary)[Grub.GrubKeys.img.rawValue] as! String
        let path = img.contains(immutableGrubImagePrefix) ?
            immutableImagePath + img.replacingOccurrences(of: immutableGrubImagePrefix, with: "") :
            imagePath + img
        let imageRef = storage.child(path + ".jpg")
        imageRef.getData(maxSize: .max) { (metadata, error) in
            guard error == nil else {
                print("error:\(error!)")
                return
            }
            
            createItem(UIImage(data: metadata!))
        }
    }
    
    DispatchQueue.global(qos: .utility).async {
        let foodItem = snapshot.value as! NSDictionary
        let storage = Storage.storage().reference()
        let path = (foodItem[Grub.GrubKeys.img.rawValue] as! String).contains(immutableGrubImagePrefix) ?
            immutableImagePath + (foodItem[Grub.GrubKeys.img.rawValue] as! String).replacingOccurrences(of: immutableGrubImagePrefix, with: "") :
            imagePath + (foodItem[Grub.GrubKeys.img.rawValue] as! String)
        let imageRef = storage.child(path + ".jpg")
        if let (_, modifyDate) = grubImage(foodItem[Grub.GrubKeys.img.rawValue] as! String) {
            //File Exists
            imageRef.getMetadata { metadata, error in
                guard error == nil else {
                    print("error:\(error!)")
                    return
                }
                
                if metadata!.timeCreated!.advanced(by: 60 * -5) <= modifyDate {
                    //Updated
                    createItem(nil)
                } else {
                    //Not Updated
                    downloadItem()
                }
            }
        } else {
            //File Does Not Exist
            downloadItem()
        }
    }
}

public func onCloudFoodAdded(_ snapshot: DataSnapshot) {
    onCloudListItemAdded(.foodList, snapshot)
}

public func onCloudArchiveAdded(_ snapshot: DataSnapshot) {
    onCloudListItemAdded(.archivedList, snapshot)
}

public func onCloudDataAdded(_ snapshot: DataSnapshot) {
    switch snapshot.key {
    case DataListKeys.ghorblinName.rawValue:
        UserCookie.uc().setGhorblinName(snapshot.value as? String)
        writeLocalData(DataListKeys.ghorblinName, snapshot.value as? String)
    case DataListKeys.linkToken.rawValue:
        UserAccessCookie.uac().setLinkToken(snapshot.value as? String)
        writeLocalData(DataListKeys.linkToken, snapshot.value as? String)
    default:
        return
    }
}


public func onCloudFoodRemoved(_ snapshot: DataSnapshot) {
    UserCookie.uc().removeFoodList(snapshot.key)
    removeLocalFood(snapshot.key, deleteImage: false)
}

public func onCloudArchiveRemoved(_ snapshot: DataSnapshot) {
    UserCookie.uc().removeArchivedList(snapshot.key)
    removeLocalArchive(snapshot.key, deleteImage: true)
}

public func onCloudDataRemoved(_ snapshot: DataSnapshot) {
    switch snapshot.key {
    case DataListKeys.ghorblinName.rawValue:
        UserCookie.uc().setGhorblinName(nil)
        writeLocalData(DataListKeys.ghorblinName, nil)
    case DataListKeys.linkToken.rawValue:
        UserAccessCookie.uac().setLinkToken(nil)
        writeLocalData(DataListKeys.linkToken, nil)
    default:
        return
    }
}

public func onCloudFoodChanged(_ snapshot: DataSnapshot) {
    if let foodItem = snapshot.value as? NSDictionary {
        UserCookie.uc().appendFoodList(snapshot.key, Grub(fid: snapshot.key, foodItem))
        appendLocalFood(snapshot.key, foodItem)
    }
}

public func onCloudArchiveChanged(_ snapshot: DataSnapshot) {
    if let foodItem = snapshot.value as? NSDictionary {
        UserCookie.uc().appendArchivedList(snapshot.key, Grub(fid: snapshot.key, foodItem))
        appendLocalArchive(snapshot.key, foodItem)
    }
}

public func onCloudDataChanged(_ snapshot: DataSnapshot) {
    switch snapshot.key {
    case DataListKeys.ghorblinName.rawValue:
        UserCookie.uc().setGhorblinName(snapshot.value as? String)
        writeLocalData(DataListKeys.ghorblinName, snapshot.value as? String)
    case DataListKeys.linkToken.rawValue:
        UserAccessCookie.uac().setLinkToken(snapshot.value as? String)
        writeLocalData(DataListKeys.linkToken, snapshot.value as? String)
    default:
        return
    }
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
    
    ref.child("users").child(DataListKeys.archivedList.rawValue).removeAllObservers()
    ref.child("users").child(uid).child(DataListKeys.archivedList.rawValue).observe(DataEventType.childAdded, with: onCloudArchiveAdded)
    ref.child("users").child(uid).child(DataListKeys.archivedList.rawValue).observe(DataEventType.childRemoved, with: onCloudArchiveRemoved)
    ref.child("users").child(uid).child(DataListKeys.archivedList.rawValue).observe(DataEventType.childChanged, with: onCloudArchiveChanged)
}

//MARK: - App Requests
private func getPostString(_ params: [String: Any]) -> String {
    var data: [String] = []
    for (key, value) in params {
        data.append(key + "=\(value)")
    }
    return data.map{String($0)}.joined(separator: "&")
}

private func post(path: String, formData: [String: Any] = [:], _ onCompletion: @escaping (String?) -> Void) {
    let url = URL(string: "https://grumbleserver.uc.r.appspot.com/" + path)!
    var request = URLRequest(url: url)
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    request.httpMethod = "POST"
    var formData = formData
    var secret: String
    do {
        let secretURL = Bundle.main.url(forResource: "clientSecret", withExtension: "txt")!
        secret = try String(contentsOf: secretURL, encoding: .utf8)
        secret = trim(secret, char: "\n")
    }
    catch {
        print("error:\(error)")
        return
    }
    formData["user"] = Auth.auth().currentUser!.uid
    formData["client_secret"] = secret
    print("form data: " + getPostString(formData))
    request.httpBody = getPostString(formData).data(using: .utf8)

    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        guard let data = data,
            let response = response as? HTTPURLResponse,
            error == nil else {                                              // check for fundamental networking error
            print("error", error ?? "Unknown error")
            return
        }

        guard (200 ... 299) ~= response.statusCode else {                    // check for http errors
            print("statusCode should be 2xx, but is \(response.statusCode)")
            print("response = \(response)")
            return
        }

        let responseString = String(data: data, encoding: .utf8)
        onCompletion(responseString)
    }

    DispatchQueue.global(qos: .utility).async {
        task.resume()
    }
}

//MARK: - Gather Immutable Grub
public func requestImmutableGrub(_ existing: ArraySlice<(String, Grub)> = [], count: Int, _ withCompletion: @escaping ([String: Grub]) -> Void) {
    if UserAccessCookie.uac().loggedIn() == .loggedIn {
        if count == 0 {
            withCompletion([:])
            return()
        }
        
        post(path: "request-immutable-fid") { response in
            if let fids = try? JSONSerialization.jsonObject(with: response!.data(using: .utf8)!) as? [String: Bool] {
                var grubset = fids
                for (fid, _) in existing {
                    grubset.removeValue(forKey: fid)
                }
                
                let size = grubset.count
                let keys = grubset.keys.shuffled().prefix(min(count, size))
                var immutableList: [String: Grub] = [:]
                
                let ref = Database.database().reference().child("immutableGrub")
                for key in keys {
                    let storage = Storage.storage().reference()
                    let imageRef = storage.child(immutableImagePath + key + ".jpg")
                    imageRef.getData(maxSize: .max) { (metadata, error) in
                        let image = UIImage(data: metadata!)
                        ref.child(key).observeSingleEvent(of: .value) { snapshot in
                            immutableList[key] = Grub(fid: key, snapshot.value as! NSDictionary, immutable: true, image: image)
                            if immutableList.count == keys.count {
                                withCompletion(immutableList)
                            }
                        }
                    }
                }
            }
        }
    }
}

//MARK: - Request Preferences
public func requestPreferences(imageIDs: [String], tagList: [[GrubTag: Double]], _ withCompletion: @escaping ([Double]) -> Void) {
    if UserAccessCookie.uac().loggedIn() == .loggedIn {
        var rawTagList: [[Double]] = []
        for tagDict in tagList {
            var tags = Array(repeating: 0.0, count: 14)
            for tag in tagDict.keys {
                tags[gTagMap[tag]!] = tagDict[tag]!
            }
            rawTagList.append(tags)
        }
        
        let formData: [String: Any] = ["image_ids": imageIDs, "tags": rawTagList]
        post(path: "predict-preference", formData: formData) { response in
            if let preferences = try? JSONSerialization.jsonObject(with: response!.data(using: .utf8)!) as? [Double] {
                withCompletion(preferences)
            } else {
                print(response)
            }
        }
    }
}

//MARK: - Machine Learning Input/Output
public func queueImageTraining(_ fid: String, _ tags: [GrubTag: Double]) {
    var modifiedTags = tags
    modifiedTags[food] = nil
    if UserAccessCookie.uac().loggedIn() == .loggedIn && modifiedTags.count > 0 {
        Database.database().reference().child("trainingQueue").child(fid).setValue(modifiedTags)
    }
}

//MARK: - User Login/Logout
public func onLogin(requireCloud: Bool) {
    if let uid = Auth.auth().currentUser?.uid {
        if requireCloud {
            UserAccessCookie.uac().setLoggedIn(.inProgress)
        } else {
            UserAccessCookie.uac().setLoggedIn(Auth.auth().currentUser)
        }
        
        Database.database().reference().child("userList").child(uid).setValue(true)
        
        loadCloudData() { data in
            let dictionaryLists: [NSDictionary?] = [data?[DataListKeys.foodList.rawValue] as? NSDictionary,
                                         data?[DataListKeys.archivedList.rawValue] as? NSDictionary]
            var lists: [[String: Grub]] = [[:], [:]]
            for index in 0 ..< dictionaryLists.count {
                if dictionaryLists[index] != nil && dictionaryLists[index]!.count > 0 {
                    for food in dictionaryLists[index]! {
                        lists[index][food.key as! String] = Grub(fid: food.key as! String, food.value as! NSDictionary)
                    }
                }
            }
            UserCookie.uc().setLists(lists)
            UserCookie.uc().loadingStatus = .loaded
            setObservers(uid: uid)
            
            UserCookie.uc().setGhorblinName(data?[DataListKeys.ghorblinName.rawValue] as? String)
            UserAccessCookie.uac().setLinkToken(data?[DataListKeys.linkToken.rawValue] as? String)
            
            UserAccessCookie.uac().setLoggedIn(Auth.auth().currentUser)
            TabRouter.tr().changeTab(.list)
            KeyboardObserver.reset(.listhome)
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
        UserAccessCookie.uac().setLoggedIn(nil)
        UserCookie.uc().setFoodList([:] as [String: Grub])
        UserCookie.uc().setArchivedList([:] as [String: Grub])
        UserAccessCookie.uac().setLinkToken(nil)
        UserCookie.uc().setGhorblinName(nil)
        UserCookie.uc().loadingStatus = LoadingStatus.loading
        clearLocalData()
        clearLocalGrubImages()
        
        GFormText.reset()
        KeyboardObserver.reset(.useraccess)
    } catch {
        print("error:\(error)")
    }
}

//MARK: - Profile Changes
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
                UserAccessCookie.uac().setLinkToken(nil)
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

//MARK: - Photo Library
public func loadImages() {
    let authorized: Bool = PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized
    AddImageCookie.aic().libraryAuthorized = authorized
    if !authorized {
        PHPhotoLibrary.requestAuthorization { handler in
            if handler == PHAuthorizationStatus.authorized {
                loadImages()
            }
        }
        return
    }
    
    var assets: [Int: PHAsset] = [:]
    var photos: [PHAsset: UIImage] = [:]
    
    let options = PHFetchOptions()
    let cameraRoll = PHAssetCollection.fetchAssetCollections(with:.smartAlbum, subtype:.smartAlbumUserLibrary, options: options).firstObject
    
    options.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
    let collection = PHAsset.fetchAssets(in: cameraRoll!, options: options)
    
    let imageManager = AddImageCookie.aic().phManager
    let last = collection.count - 1
    collection.enumerateObjects(options: NSEnumerationOptions.reverse) { (asset, count, stop) in
        assets[last - count] = asset
        let ratio = minThumbnailSize / CGFloat(min(asset.pixelWidth, asset.pixelHeight))
        let imageSize = CGSize(width: CGFloat(asset.pixelWidth) * ratio,
                               height: CGFloat(asset.pixelHeight) * ratio)

        // For faster performance, and maybe degraded image
        let options = PHImageRequestOptions()
        options.deliveryMode = .fastFormat
        options.isSynchronous = true

        imageManager.requestImage(for: asset, targetSize: imageSize, contentMode: .aspectFill, options: options) { (image, info) in
            photos[asset] = image!
        }
    }
    
    AddImageCookie.aic().photoAssets = assets
    AddImageCookie.aic().unionPhotos(photos)
        
    if assets.count > 0 {
        let size: CGSize = CGSize(width: assets[0]!.pixelWidth, height: assets[0]!.pixelHeight)
        AddImageCookie.aic().phManager.requestImage(for: assets[0]!, targetSize: size, contentMode: .aspectFill, options: nil, resultHandler: { image, info in
            if info?["PHImageResultIsDegradedKey"] as! Int == 0 {
                AddImageCookie.aic().defaultLibraryPhotoAspectRatio = size.height / size.width
                AddImageCookie.aic().defaultLibraryPhoto = image!
                AddImageCookie.aic().attemptResetDefaultPhoto()
            }
        })
    }
        
    DispatchQueue.global(qos: .utility).async {
        let updatePhotosPerCount: Int = Int.max
        var updateCount: Int = 0
        for index in assets.keys {
            let asset = assets[index]!
            let ratio = minThumbnailSize / CGFloat(min(asset.pixelWidth, asset.pixelHeight))
            let imageSize = CGSize(width: CGFloat(asset.pixelWidth) * ratio,
                                   height: CGFloat(asset.pixelHeight) * ratio)
            let options = PHImageRequestOptions()
            options.deliveryMode = .highQualityFormat
            
            imageManager.requestImage(for: asset, targetSize: imageSize, contentMode: .aspectFill, options: options) { (image, info) in
                photos[asset] = image!
                updateCount += 1
                
                if updateCount % updatePhotosPerCount == 0 || updateCount == photos.count {
                    DispatchQueue.main.async {
                        AddImageCookie.aic().unionPhotos(photos)
                    }
                }
            }
        }
        
        LibraryObserver.lo().lastFetchResult = collection
    }
}
