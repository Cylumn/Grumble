//
//  AddImage.swift
//  Grumble
//
//  Created by Allen Chang on 5/6/20.
//  Copyright © 2020 Cylumn, Inc. All rights reserved.
//

import SwiftUI
import Photos

public let grubImageAspectRatio: CGFloat = 0.75

private let cameraHeight: CGFloat = sHeight() + ImageViewController.buttonOffset * 2 - navBarHeight - safeAreaInset(.top)
private let borderHeight: CGFloat = (cameraHeight - sWidth() * grubImageAspectRatio) * 0.5

private let libraryColumns: Int = 4

public class AddImageCookie: ObservableObject {
    private static var instance: AddImageCookie? = nil
    public var currentFID: String? = nil
    @Published public var image: Image? = nil
    @Published public var aspectRatio: CGFloat = 4 / 3
    @Published public var isPresented: Bool = false
    @Published public var libraryAuthorized: Bool = true
    @Published public var cameraAuthorized: Bool = true
    
    public var phManager: PHCachingImageManager = PHCachingImageManager()
    @Published public var photoAssets: [PHAsset] = []
    @Published public var photos: [UIImage] = []
    
    public var capture: () -> Void = { }
    public var run: (Bool) -> Void = { _ in }
    
    public static func aic() -> AddImageCookie {
        if AddImageCookie.instance == nil {
            AddImageCookie.instance = AddImageCookie()
        }
        return AddImageCookie.instance!
    }
}

public struct AddImage: View {
    public static var bgColor: Color = gColor(.blue0)
    public static var accentColor: Color = Color.white
    public static var textColor: Color = Color.white
    
    @ObservedObject private var aic: AddImageCookie = AddImageCookie.aic()
    private var present: (Bool) -> Void
    private var toAddFood: (String?) -> Void
    
    @State private var tab: Pages = Pages.capture
    
    @GestureState(initialValue: CGFloat(0.8), resetTransaction: Transaction(animation: gAnim(.springSlow))) private var holdData
    
    @State private var isDragging: Bool = false
    @State private var dragOffset: CGFloat = 0
    @State private var currentOffset: CGFloat = 0
    
    //Initializer
    public init(present: @escaping (Bool) -> Void, toAddFood: @escaping (String?) -> Void) {
        self.present = present
        self.toAddFood = toAddFood
        
        AddFoodCookie.afc().presentAddImage = self.present
    }
    
    //Page Enums
    private enum Pages {
        case library
        case capture
    }
    
    //Getter Methods
    private func presentImagePicker() -> Bool {
        return self.aic.isPresented && self.aic.image == nil && self.tab == .capture
    }
    
    private func adjustImageScreen() -> Bool {
        return self.aic.image != nil && self.tab == .capture
    }
    
    private var header: some View {
        ZStack {
            HStack {
                Button(action: {
                    withAnimation(gAnim(.easeOut)) {
                        self.present(false)
                        self.dragOffset = 0
                        self.currentOffset = 0
                    }
                    self.tab = .capture
                    self.aic.image = nil
                }, label: {
                    Text("Cancel")
                }).font(gFont(.ubuntuLight, 18))
                
                Spacer()
            }
            
            if self.adjustImageScreen() {
                Text("Adjust Image")
            } else {
                Text("Take Image of Grub")
            }
        }
    }
    
    private func adjustImagePage(imageWidth: CGFloat, imageHeight: CGFloat) -> some View {
        ZStack(alignment: .top) {
            Color.clear
            
            if self.tab == .capture {
                VStack(spacing: 0) {
                    Color.white
                        .frame(width: sWidth(), height: navBarHeight + borderHeight)
                    
                    Spacer()
                        .frame(width: sWidth(), height: sWidth() * grubImageAspectRatio)
                    
                    Color.white
                        .frame(maxWidth: sWidth(), maxHeight: .infinity)
                }.opacity((self.adjustImageScreen() && !self.isDragging) ? 1 : 0.8)
            }
        }.contentShape(Rectangle())
        .gesture(DragGesture().onChanged { drag in
            if self.adjustImageScreen() {
                withAnimation(gAnim(.easeOut)) {
                    self.isDragging = true
                }
                
                let maxDrag: CGFloat = navBarHeight + borderHeight
                let minDrag: CGFloat = imageHeight - cameraHeight - navBarHeight + borderHeight
                self.dragOffset = max(min(drag.translation.height + self.currentOffset, maxDrag), -minDrag)
            } else if self.tab == .library {
                let maxDrag: CGFloat = (imageHeight - sWidth() * grubImageAspectRatio) * 0.5
                let minDrag: CGFloat = maxDrag
                self.dragOffset = max(min(drag.translation.height + self.currentOffset, maxDrag), -minDrag)
            }
        }.onEnded { drag in
            if self.adjustImageScreen() || self.tab == .library {
                self.currentOffset = self.dragOffset
            }
            withAnimation(gAnim(.easeOut)) {
                self.isDragging = false
            }
        })
    }
    
    private var authorizePage: some View {
        VStack(spacing: 20) {
            Spacer()
                .frame(height: navBarHeight + borderHeight)
            
            Text("Grumble does not have permission to access your camera.")
                .font(gFont(.ubuntuLight, .width, 1.8))
                .foregroundColor(Color.white)
            
            Button(action: {
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                    return
                }

                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl)
                }
            }, label: {
                Text("Enable")
                    .font(gFont(.ubuntuMedium, .width, 2.5))
                    .padding(sWidth() * 0.04)
                    .foregroundColor(Color.white)
            }).background(gColor(.blue0))
            .cornerRadius(100)
            
            Spacer()
                .frame(height: abs(ImageViewController.buttonOffset * 2))
        }
    }
    
    private var library: some View {
        let rows = 0 ..< Int(ceil(CGFloat(self.aic.photos.count) / CGFloat(libraryColumns)))
        
        let size: CGFloat = (sWidth() - CGFloat(libraryColumns) + 1) / CGFloat(libraryColumns)
       
        return ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 1) {
                ForEach(rows, id: \.self) { row in
                    HStack(spacing: 1) {
                        ForEach((row * libraryColumns ..< min((row + 1) * libraryColumns, self.aic.photos.count)), id: \.self) { index in
                            ImageItem(self.aic.photoAssets[index], self.aic.photos[index], size: size,
                                      Binding<CGFloat>(get: {
                                        self.dragOffset
                                      }, set: {
                                        self.dragOffset = $0
                                        self.currentOffset = $0
                                      }))
                        }
                    }
                }
            }.offset(y: 1)
        }
    }
    
    private var captureButton: some View {
        ZStack {
            Ellipse()
                .fill(AddImage.accentColor)
                .frame(width: ImageViewController.buttonSize, height: ImageViewController.buttonSize)
            
            Ellipse()
                .fill(AddImage.bgColor)
                .frame(width: ImageViewController.buttonSize * 0.9, height: ImageViewController.buttonSize * 0.9)
            
            Ellipse()
                .fill(AddImage.accentColor)
                .frame(width: ImageViewController.buttonSize * self.holdData, height: ImageViewController.buttonSize * self.holdData)
        }.position(x: sWidth() * 0.5, y: sHeight() + ImageViewController.buttonOffset - tabHeight)
        .gesture(LongPressGesture(minimumDuration: 1, maximumDistance: ImageViewController.buttonSize)
            .updating(self.$holdData) { value, state, transaction in
                transaction.animation = gAnim(.springSlow)
                state = 0.5
                
                let impactLight = UIImpactFeedbackGenerator(style: .light)
                impactLight.impactOccurred()
        }.onEnded { _ in
            self.aic.capture()
            
            let impactLight = UIImpactFeedbackGenerator(style: .light)
            impactLight.impactOccurred()
        }.simultaneously(with: TapGesture().onEnded {
            self.aic.capture()
            
            let impactLight = UIImpactFeedbackGenerator(style: .light)
            impactLight.impactOccurred()
        }))
    }
    
    private var adjustImageBody: some View {
        HStack {
            Button(action: {
                self.aic.image = nil
                self.dragOffset = 0
                self.currentOffset = 0
            }, label: {
                Text("Retake")
                    .padding([.leading, .trailing], sWidth() * 0.1)
                    .font(gFont(.ubuntuLight, .width, 2))
            })
            
            Spacer()
            
            Button(action: {
                self.toAddFood(nil)
            }, label: {
                Text("Next")
                    .padding(10)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(gColor(.blue0))
            }).background(Color.white)
            .cornerRadius(10)
        }
    }
    
    private func tabButton(_ label: String, _ page: Pages, _ action: @escaping () -> Void = {}) -> some View {
        Button(action: {
            self.tab = page
            action()
        }, label: {
            Text(label)
        }).frame(maxWidth: .infinity)
        .foregroundColor(self.tab == page ? Color.white : Color(white: 0.9))
    }
    
    private var bodyOverlay: some View {
        VStack(spacing: 0) {
            self.header
                .padding([.leading, .trailing], 20)
                .frame(height: navBarHeight)
                .background(gColor(.blue0))
                .font(navBarFont)
            
            Spacer()
            
            if self.adjustImageScreen() {
                self.adjustImageBody
                    .padding(20)
                    .frame(height: abs(ImageViewController.buttonOffset * 2))
                    .font(gFont(.ubuntuMedium, .width, 2.5))
            }
            
            HStack {
                self.tabButton("Library", .library)
                self.tabButton("Capture", .capture)
            }.padding([.top, .bottom], 10)
            .frame(height: tabHeight)
            .background(gColor(.blue0))
            .font(gFont(.ubuntuBold, .width, 2.5))
        }
    }
    
    public var body: some View {
        let imageWidth: CGFloat = self.aic.aspectRatio < grubImageAspectRatio ? grubImageAspectRatio * sWidth() / self.aic.aspectRatio : sWidth()
        let imageHeight: CGFloat = self.aic.aspectRatio < grubImageAspectRatio ? grubImageAspectRatio * sWidth() : self.aic.aspectRatio * sWidth()
        
        return ZStack {
            Color.black
                .edgesIgnoringSafeArea(.bottom)
            
            ZStack(alignment: .top) {
                Color.clear
                
                if self.tab == .capture {
                    self.aic.image?
                        .resizable()
                        .frame(width: imageWidth, height: imageHeight)
                        .offset(y: self.dragOffset)
                } else {
                    self.aic.image?
                        .resizable()
                        .frame(width: imageWidth, height: imageHeight)
                        .position(x: sWidth() * 0.5, y: navBarHeight + grubImageAspectRatio * sWidth() * 0.5 + self.dragOffset)
                }
                
                gColor(.blue0)
                    .frame(height: safeAreaInset(.top))
                    .edgesIgnoringSafeArea(.top)
            }.frame(width: sWidth())
            
            ImagePicker()
                .opacity(self.presentImagePicker() ? 1 : 0)
                .disabled(!self.presentImagePicker())
            
            self.adjustImagePage(imageWidth: imageWidth, imageHeight: imageHeight)
            
            if self.tab == .capture && !self.aic.cameraAuthorized {
                self.authorizePage
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(white: 0.2))
            }
            
            ZStack(alignment: .bottom) {
                Color.clear
                
                Rectangle()
                    .fill(AddImage.bgColor)
                    .frame(height: abs(ImageViewController.buttonOffset * 2))
                
                if self.tab == .library {
                    self.library
                        .frame(height: (abs(ImageViewController.buttonOffset) + borderHeight) * 2 - tabHeight)
                        .background(Color.white)
                        .offset(y: -tabHeight)
                }
            }
            
            self.captureButton
                .opacity(self.presentImagePicker() ? 1 : 0)
                .disabled(!self.presentImagePicker())
            
            self.bodyOverlay
                .foregroundColor(AddImage.textColor)
        }
    }
}

struct AddImage_Previews: PreviewProvider {
    static var previews: some View {
        AddImage(present: { _ in }, toAddFood: { _ in })
    }
}
