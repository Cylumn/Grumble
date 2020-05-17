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
    private var thumbnail: AnyView
    private var size: CGFloat
    
    public init(_ asset: PHAsset, _ thumbnail: UIImage, size: CGFloat) {
        self.asset = asset
        self.thumbnail = AnyView(Image(uiImage: thumbnail).resizable()
        .aspectRatio(contentMode: .fill)
        .frame(width: size, height: size))
        self.size = size
    }
    
    public var body: some View {
        ZStack {
            self.thumbnail
                .onTapGesture {
                    AddImageCookie.aic().selectedAsset = self.asset
                    
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
