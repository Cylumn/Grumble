//
//  LibraryObserver.swift
//  Grumble
//
//  Created by Allen Chang on 5/8/20.
//  Copyright © 2020 Cylumn, Inc. All rights reserved.
//

import Foundation
import Photos
import UIKit
import SwiftUI

public let minThumbnailSize: CGFloat = 200

public class LibraryObserver: NSObject, PHPhotoLibraryChangeObserver {
    private static var instance: LibraryObserver? = nil
    
    private var collection: PHAssetCollection?
    public var lastFetchResult: PHFetchResult<PHAsset>?
    
    private override init() {
        super.init()
        self.collection = PHAssetCollection.fetchAssetCollections(with:.smartAlbum, subtype:.smartAlbumUserLibrary, options: nil).firstObject
        self.lastFetchResult = nil
    }
    
    public static func lo() -> LibraryObserver {
        if LibraryObserver.instance == nil {
            LibraryObserver.instance = LibraryObserver()
            PHPhotoLibrary.shared().register(LibraryObserver.instance!)
        }
        return LibraryObserver.instance!
    }
    
    public func photoLibraryDidChange(_ changeInstance: PHChange) {
        self.collection = PHAssetCollection.fetchAssetCollections(with:.smartAlbum, subtype:.smartAlbumUserLibrary, options: nil).firstObject
        guard var assetCollection = self.collection else {
            return
        }
        // Change notifications may be made on a background queue.
        // Re-dispatch to the main queue to update the UI.
        DispatchQueue.main.sync {
            // Check for changes to the displayed album itself
            // (its existence and metadata, not its member assets).
            if let albumChanges = changeInstance.changeDetails(for: assetCollection) {
                // Fetch the new album and update the UI accordingly.
                assetCollection = albumChanges.objectAfterChanges!
            }
            // Check for changes to the list of assets (insertions, deletions, moves, or updates).
            if let changes = changeInstance.changeDetails(for: self.lastFetchResult!) {
                // Keep the new fetch result for future use.
                self.lastFetchResult = changes.fetchResultAfterChanges
                if changes.hasIncrementalChanges {
                    var origAssets: [Int: PHAsset] = AddImageCookie.aic().photoAssets
                    var assets: [PHAsset] = []
                    var photos: [PHAsset: UIImage] = AddImageCookie.aic().photos
                    
                    //Reverse
                    for index in origAssets.keys.sorted() {
                        assets.append(origAssets[origAssets.count - 1 - index]!)
                    }
                    
                    // For indexes to make sense, updates must be in this order:
                    // delete, insert, reload, move
                    for removed in (changes.removedIndexes ?? IndexSet()).reversed() {
                        photos[assets[removed]] = nil
                        assets.remove(at: removed)
                    }
                    
                    var iterator = changes.insertedIndexes?.makeIterator()
                    for inserted in changes.insertedObjects {
                        let index = iterator!.next()!
                        assets.insert(inserted, at: index)
                        
                        let ratio = minThumbnailSize / CGFloat(min(inserted.pixelWidth, inserted.pixelHeight))
                        let size = CGSize(width: CGFloat(inserted.pixelWidth) * ratio,
                                          height: CGFloat(inserted.pixelHeight) * ratio)
                        let options = PHImageRequestOptions()
                        options.deliveryMode = .highQualityFormat
                        options.isSynchronous = true
                        AddImageCookie.aic().phManager.requestImage(for: inserted, targetSize: size, contentMode: .aspectFill, options: options) { (image, info) in
                            if info?["PHImageResultIsDegradedKey"] as! Int == 0 {
                                photos[inserted] = image!
                            }
                        }
                    }
                    
                    for changed in changes.changedIndexes ?? IndexSet() {
                        let asset = assets[changed]
                        
                        let ratio = minThumbnailSize / CGFloat(min(asset.pixelWidth, asset.pixelHeight))
                        let size = CGSize(width: CGFloat(asset.pixelWidth) * ratio,
                                          height: CGFloat(asset.pixelHeight) * ratio)
                        let options = PHImageRequestOptions()
                        options.deliveryMode = .highQualityFormat
                        options.isSynchronous = true
                        AddImageCookie.aic().phManager.requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: options) { (image, info) in
                            if info?["PHImageResultIsDegradedKey"] as! Int == 0 {
                                photos[asset] = image!
                            }
                        }
                    }
                    
                    //Reverse
                    origAssets = [:]
                    for index in 0 ..< assets.count {
                        origAssets[assets.count - 1 - index] = assets[index]
                    }
                    
                    AddImageCookie.aic().photoAssets = origAssets
                    AddImageCookie.aic().photos.merge(photos, uniquingKeysWith: { (_, new) in new })
                    
                    if origAssets.count > 0 {
                        let size: CGSize = CGSize(width: origAssets[0]!.pixelWidth, height: origAssets[0]!.pixelHeight)
                        AddImageCookie.aic().phManager.requestImage(for: origAssets[0]!, targetSize: size, contentMode: .aspectFill, options: nil, resultHandler: { image, info in
                            if info?["PHImageResultIsDegradedKey"] as! Int == 0 {
                                let image = Image(uiImage: image!)
                                AddImageCookie.aic().defaultLibraryPhotoAspectRatio = size.height / size.width
                                AddImageCookie.aic().defaultLibraryPhoto = image
                                AddImageCookie.aic().attemptResetDefaultPhoto()
                            }
                        })
                    }
                } else {
                    // Reload the collection view if incremental diffs are not available.
                    loadImages()
                }
            }
        }
    }
}
