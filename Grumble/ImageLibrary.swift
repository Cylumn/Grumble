//
//  ImageLibrary.swift
//  Grumble
//
//  Created by Allen Chang on 5/15/20.
//  Copyright © 2020 Cylumn, Inc. All rights reserved.
//

import SwiftUI

private let libraryColumns: Int = 4

public struct ImageLibrary: View {
    @ObservedObject private var aic: AddImageCookie = AddImageCookie.aic()
    private static var instance: ImageLibrary? = nil
    
    private init() {}
    
    public static func library() -> ImageLibrary {
        if ImageLibrary.instance == nil {
            ImageLibrary.instance = ImageLibrary()
        }
        return ImageLibrary.instance!
    }
    
    public var body: some View {
        let rows = 0 ..< Int(ceil(CGFloat(self.aic.photoAssets.count) / CGFloat(libraryColumns)))
        let size: CGFloat = (sWidth() - CGFloat(libraryColumns) + 1) / CGFloat(libraryColumns)
        return ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 1) {
                ForEach(rows, id: \.self) { row in
                    HStack(spacing: 1) {
                        ForEach((row * libraryColumns ..< min((row + 1) * libraryColumns, self.aic.photoAssets.count)), id: \.self) { index in
                            ZStack {
                                ImageItem(self.aic.photoAssets[index]!, self.aic.photos[self.aic.photoAssets[index]!]!, size: size, index: index)
                                
                                Color.white
                                    .opacity(index == self.aic.selectedIndex ? 0.6 : 0)
                            }.frame(width: size, height: size)
                        }
                    }
                }
            }.offset(y: 1)
        }
    }
}
