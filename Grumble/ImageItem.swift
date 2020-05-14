//
//  ImageItem.swift
//  Grumble
//
//  Created by Allen Chang on 5/7/20.
//  Copyright © 2020 Cylumn, Inc. All rights reserved.
//

import SwiftUI
import Photos

public struct ImageItem: View {
    private var asset: PHAsset
    private var thumbnail: Image
    private var size: CGFloat
    private var index: Int
    
    public init(_ asset: PHAsset, _ thumbnail: UIImage, size: CGFloat, index: Int) {
        self.asset = asset
        self.thumbnail = Image(uiImage: thumbnail)
        self.size = size
        self.index = index
    }
    
    public var body: some View {
        ZStack {
            self.thumbnail
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: size, height: size)
                .onTapGesture {
                    AddImageCookie.aic().selectedIndex = self.index
                    
                    let size: CGSize = CGSize(width: self.asset.pixelWidth, height: self.asset.pixelHeight)
                    AddImageCookie.aic().phManager.requestImage(for: self.asset, targetSize: size, contentMode: .aspectFill, options: nil, resultHandler: { image, info in
                        if info?["PHImageResultIsDegradedKey"] as! Int == 0 {
                            AddImageCookie.aic().aspectRatio = size.height / size.width
                            AddImageCookie.aic().setImage(image!)
                            CropImageCookie.cic().resetOffset()
                        }
                    })
                }
        }.frame(width: size, height: size)
        .clipShape(Rectangle().size(CGSize(width: size, height: size)))
        .contentShape(Rectangle().size(CGSize(width: size, height: size)))
    }
}
