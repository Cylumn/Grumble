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
    
    @State private var image: Image? = nil
    @State private var aspectRatio: CGFloat? = nil
    
    private var dragOffset: Binding<CGFloat>
    
    public init(_ asset: PHAsset, _ thumbnail: UIImage, size: CGFloat, _ dragOffset: Binding<CGFloat>) {
        self.asset = asset
        self.thumbnail = Image(uiImage: thumbnail)
        self.size = size
        self.dragOffset = dragOffset
    }
    
    public var body: some View {
        ZStack {
            self.thumbnail
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: size, height: size)
                .onTapGesture {
                    if self.image == nil {
                        let size: CGSize = CGSize(width: self.asset.pixelWidth, height: self.asset.pixelHeight)
                        PHImageManager.default().requestImage(for: self.asset, targetSize: size, contentMode: .aspectFill, options: nil, resultHandler: { image, info in
                            if info?["PHImageResultIsDegradedKey"] as! Int == 0 {
                                let image = Image(uiImage: image!)
                                AddImageCookie.aic().aspectRatio = size.height / size.width
                                AddImageCookie.aic().image = image
                                self.aspectRatio = size.height / size.width
                                self.image = image
                                self.dragOffset.wrappedValue = 0
                            }
                        })
                    } else {
                        AddImageCookie.aic().aspectRatio = self.aspectRatio!
                        AddImageCookie.aic().image = self.image
                        self.dragOffset.wrappedValue = 0
                    }
                }
        }.frame(width: size, height: size)
        .clipped()
    }
}
