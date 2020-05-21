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

//MARK: - Decodable Structures
private struct DataList: Decodable {
    var foodList: [String: Grub]?
    var ghorblinName: String?
    var linkToken: String?
}

//MARK: - Enumerations
public enum DataListKeys: String {
    case foodList = "foodList"
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
        let attributes = try FileManager.default.attributesOfItem(atPath: filePath)
        return (UIImage(contentsOfFile: imageURL.path)!, attributes[FileAttributeKey.modificationDate] as! Date)
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
            return data.foodList
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
            (rootDataDictionary[DataListKeys.foodList.rawValue] as! NSDictionary).setValue(foodItem, forKey: key)
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

public func removeLocalFood(_ key: String) {
    removeLocalGrubImage(key)
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

//MARK: - Cloud Observers
/* 1. Check if file exists
 * 2. -- if exists, download & compare Metadatas
 * 3. ---- if updated, create food item
 * 3. ---- if not updated, download & create food item
 * 2. -- if doesn't exist, download & create food item
 */
public func onCloudFoodAdded(_ snapshot: DataSnapshot) {
    let createItem: (UIImage?) -> Void = { image in
        if let foodItem = snapshot.value as? NSDictionary {
            UserCookie.uc().appendFoodList(snapshot.key, Grub(fid: snapshot.key, foodItem, image: image))
            appendLocalFood(snapshot.key, foodItem, image)
        }
    }
    
    let downloadItem: () -> Void = {
        let storage = Storage.storage().reference()
        let imageRef = storage.child(imagePath + snapshot.key + ".jpg")
        imageRef.getData(maxSize: .max) { (metadata, error) in
            guard error == nil else {
                print("error:\(error!)")
                return
            }
            
            if let foodItem = snapshot.value as? NSDictionary {
                let image = UIImage(data: metadata!)!
                UserCookie.uc().appendFoodList(snapshot.key, Grub(fid: snapshot.key, foodItem, image: image))
                appendLocalFood(snapshot.key, foodItem, image)
            }
        }
    }
    
    DispatchQueue.global(qos: .utility).async {
        let foodItem = snapshot.value as! NSDictionary
        let storage = Storage.storage().reference()
        let imageRef = storage.child(imagePath + snapshot.key + ".jpg")
        if let (_, modifyDate) = grubImage(foodItem[Grub.GrubKeys.img.rawValue] as! String) {
            //File Exists
            imageRef.getMetadata { metadata, error in
                guard error == nil else {
                    print("error:\(error!)")
                    return
                }
                
                if metadata!.updated!.advanced(by: 60 * 5) <= modifyDate {
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
    removeLocalFood(snapshot.key)
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
        
        loadCloudData() { data in
            let foodList: NSDictionary? = data?[DataListKeys.foodList.rawValue] as? NSDictionary
            if foodList != nil && foodList!.count > 0 {
                var fList: [String: Grub] = [:]
                for food in foodList! {
                    fList[food.key as! String] = Grub(fid: food.key as! String, food.value as? NSDictionary)
                }
                UserCookie.uc().setFoodList(fList)
            }
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
