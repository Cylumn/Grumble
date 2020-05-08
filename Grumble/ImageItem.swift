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
    @ObservedObject private var aic: AddImageCookie = AddImageCookie.aic()
    private var asset: PHAsset
    private var thumbnail: Image
    private var size: CGFloat
    private var index: Int
    
    @State private var image: Image? = nil
    @State private var aspectRatio: CGFloat? = nil
    
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
                    self.aic.selectedIndex = self.index
                    
                    if self.image == nil {
                        let size: CGSize = CGSize(width: self.asset.pixelWidth, height: self.asset.pixelHeight)
                        self.aic.phManager.requestImage(for: self.asset, targetSize: size, contentMode: .aspectFill, options: nil, resultHandler: { image, info in
                            if info?["PHImageResultIsDegradedKey"] as! Int == 0 {
                                let image = Image(uiImage: image!)
                                self.aic.aspectRatio = size.height / size.width
                                self.aic.image = image
                                self.aspectRatio = size.height / size.width
                                self.image = image
                                CropImageCookie.cic().resetOffset()
                            }
                        })
                    } else {
                        self.aic.aspectRatio = self.aspectRatio!
                        self.aic.image = self.image
                        CropImageCookie.cic().resetOffset()
                    }
                }
            
            Color.white
                .opacity(self.index == self.aic.selectedIndex ? 0.6 : 0)
        }.frame(width: size, height: size)
        .clipShape(Rectangle().size(CGSize(width: size, height: size)))
        .contentShape(Rectangle().size(CGSize(width: size, height: size)))
    }
}
