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
private let cameraBodyHeight: CGFloat = abs(ImageViewController.buttonOffset * 2)

private let libraryColumns: Int = 4
private let libraryBodyHeight: CGFloat = (abs(ImageViewController.buttonOffset) + borderHeight) * 2 - tabHeight

public class AddImageCookie: ObservableObject {
    private static var instance: AddImageCookie? = nil
    public var currentFID: String? = nil
    @Published fileprivate var tab: AddImage.Pages = AddImage.Pages.capture
    @Published public var image: Image? = nil
    @Published public var aspectRatio: CGFloat = 4 / 3
    @Published public var selectedIndex: Int = 0
    
    @Published public var isPresented: Bool = false
    @Published public var libraryAuthorized: Bool = true
    @Published public var cameraAuthorized: Bool = true
    
    public var phManager: PHCachingImageManager = PHCachingImageManager()
    @Published public var photoAssets: [Int: PHAsset] = [:]
    @Published public var photos: [PHAsset: UIImage] = [:]
    @Published public var defaultLibraryPhotoAspectRatio: CGFloat = 4 / 3
    @Published public var defaultLibraryPhoto: Image? = nil
    
    @Published public var flash: Bool = false
    
    public var attemptResetDefaultPhoto: () -> Void = { }
    public var toggleFlash: (Bool) -> Void = { _ in }
    public var capture: () -> Void = { }
    public var run: (Bool) -> Void = { _ in }
    
    public static func aic() -> AddImageCookie {
        if AddImageCookie.instance == nil {
            AddImageCookie.instance = AddImageCookie()
        }
        return AddImageCookie.instance!
    }
}

public class CropImageCookie: ObservableObject {
    private static var instance: CropImageCookie? = nil
    @Published public var dragOffset: CGFloat = 0
    @Published public var currentOffset: CGFloat = 0
    
    public static func cic() -> CropImageCookie {
        if CropImageCookie.instance == nil {
            CropImageCookie.instance = CropImageCookie()
        }
        return CropImageCookie.instance!
    }
    
    public func resetOffset() {
        self.dragOffset = 0
        self.currentOffset = 0
    }
}

public struct AddImage: View {
    public static var bgColor: Color = gColor(.blue0)
    public static var accentColor: Color = Color.white
    public static var textColor: Color = Color.white
    
    @ObservedObject private var aic: AddImageCookie = AddImageCookie.aic()
    private var present: (Bool) -> Void
    private var toAddFood: (String?) -> Void
    
    @GestureState(initialValue: CGFloat(0.8), resetTransaction: Transaction(animation: gAnim(.springSlow))) private var holdData
    
    //Initializer
    public init(present: @escaping (Bool) -> Void, toAddFood: @escaping (String?) -> Void) {
        self.present = present
        self.toAddFood = toAddFood
        
        AddFoodCookie.afc().presentAddImage = self.present
        AddImageCookie.aic().attemptResetDefaultPhoto = self.attemptResetDefaultPhoto
    }
    
    //Page Enums
    fileprivate enum Pages {
        case library
        case capture
    }
    
    //Getter Methods
    private func presentImagePicker() -> Bool {
        return self.aic.isPresented && self.aic.image == nil && self.aic.tab == .capture
    }
    
    private func cropImageScreen() -> Bool {
        return self.aic.image != nil && self.aic.tab == .capture
    }
    
    //Function Methods
    private func attemptResetDefaultPhoto() {
        if self.aic.tab == .library {
            self.aic.selectedIndex = 0
            self.aic.image = self.aic.defaultLibraryPhoto
            self.aic.aspectRatio = self.aic.defaultLibraryPhotoAspectRatio
            CropImageCookie.cic().resetOffset()
        }
    }
    
    private var header: some View {
        ZStack {
            HStack {
                Button(action: {
                    withAnimation(gAnim(.easeOut)) {
                        self.present(false)
                        CropImageCookie.cic().resetOffset()
                    }
                    self.aic.tab = .capture
                    self.aic.image = nil
                }, label: {
                    Text("Cancel")
                }).font(gFont(.ubuntuLight, 18))
                
                Spacer()
                
                if self.aic.image != nil {
                    Button(action: {
                        self.toAddFood(nil)
                    }, label: {
                        Text("Next")
                    })
                }
            }
            
            if self.cropImageScreen() {
                Text("Adjust Image")
            } else if self.aic.tab == .capture {
                Text("Take Image of Grub")
            } else if self.aic.tab == .library {
                Text("Select Image of Grub")
            }
        }
    }
    
    private var authorizePage: some View {
        VStack(spacing: 50) {
            Spacer()
                .frame(height: navBarHeight + (self.aic.tab == .capture ? borderHeight : 0))
            
            Text("Grumble does not have permission to access your " + (self.aic.tab == .capture ? "camera." : "camera roll."))
                .padding([.leading, .trailing], sWidth() * 0.1)
                .font(gFont(.ubuntuLight, .width, 1.8))
                .foregroundColor(Color.white)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.center)
            
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
                .frame(height: self.aic.tab == .capture ? cameraBodyHeight : libraryBodyHeight)
        }
    }
    
    private var emptyCameraRoll: some View {
        VStack(spacing: 50) {
            Spacer()
                .frame(height: navBarHeight)
            
            Text("Your camera roll is empty!")
                .padding([.leading, .trailing], sWidth() * 0.1)
                .font(gFont(.ubuntuLight, .width, 1.8))
                .foregroundColor(Color.white)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.center)
            
            Spacer()
                .frame(height: self.aic.tab == .capture ? cameraBodyHeight : libraryBodyHeight)
        }
    }
    
    private var library: some View {
        let rows = 0 ..< Int(ceil(CGFloat(self.aic.photoAssets.count) / CGFloat(libraryColumns)))
        
        let size: CGFloat = (sWidth() - CGFloat(libraryColumns) + 1) / CGFloat(libraryColumns)
        return ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 1) {
                ForEach(rows, id: \.self) { row in
                    HStack(spacing: 1) {
                        ForEach((row * libraryColumns ..< min((row + 1) * libraryColumns, self.aic.photoAssets.count)), id: \.self) { index in
                            ImageItem(self.aic.photoAssets[index]!, self.aic.photos[self.aic.photoAssets[index]!]!, size: size, index: index)
                        }
                    }
                }
            }.offset(y: 1)
        }
    }
    
    private var flashButton: some View {
        Button(action: {
            self.aic.toggleFlash(!self.aic.flash)
        }, label: {
            Image(systemName: self.aic.flash ? "bolt.fill" : "bolt")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: ImageViewController.buttonSize * 0.5, height: ImageViewController.buttonSize * 0.5)
        }).foregroundColor(Color.white)
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
    
    private func tabButton(_ label: String, _ page: Pages, _ action: @escaping () -> Void = {}) -> some View {
        Button(action: {
            if self.aic.tab != page {
                self.aic.image = nil
                CropImageCookie.cic().resetOffset()
            }
            self.aic.tab = page
            action()
        }, label: {
            Text(label)
        }).frame(maxWidth: .infinity)
        .foregroundColor(self.aic.tab == page ? Color.white : Color(white: 0.9))
    }
    
    private var bodyOverlay: some View {
        VStack(spacing: 0) {
            self.header
                .padding([.leading, .trailing], 20)
                .frame(height: navBarHeight)
                .background(gColor(.blue0))
                .font(navBarFont)
            
            Spacer()
            
            HStack {
                self.tabButton("Library", .library) {
                    self.aic.aspectRatio = self.aic.defaultLibraryPhotoAspectRatio
                    self.aic.image = self.aic.defaultLibraryPhoto
                }
                self.tabButton("Capture", .capture)
            }.padding([.top, .bottom], 10)
            .frame(height: tabHeight)
            .background(gColor(.blue0))
            .font(gFont(.ubuntuBold, .width, 2.5))
        }
    }
    
    fileprivate struct CropImage: View {
        @ObservedObject private var cic: CropImageCookie = CropImageCookie.cic()
        private var aic: AddImageCookie = AddImageCookie.aic()
        private var parent: AddImage
        
        @State private var isDragging: Bool = false
        
        fileprivate init(_ parent: AddImage) {
            self.parent = parent
        }
        
        public var body: some View {
            let imageWidth: CGFloat = self.aic.aspectRatio < grubImageAspectRatio ? grubImageAspectRatio * sWidth() / self.aic.aspectRatio : sWidth()
            let imageHeight: CGFloat = self.aic.aspectRatio < grubImageAspectRatio ? grubImageAspectRatio * sWidth() : self.aic.aspectRatio * sWidth()

            return ZStack(alignment: .top) {
                    Color.clear
                    
                    if self.aic.tab == .capture {
                        self.aic.image?
                            .resizable()
                            .frame(width: imageWidth, height: imageHeight)
                            .offset(y: self.cic.dragOffset)
                    } else {
                        self.aic.image?
                            .resizable()
                            .frame(width: imageWidth, height: imageHeight)
                            .position(x: sWidth() * 0.5, y: navBarHeight + grubImageAspectRatio * sWidth() * 0.5 + self.cic.dragOffset)
                    }
                    
                    gColor(.blue0)
                        .frame(height: safeAreaInset(.top))
                        .edgesIgnoringSafeArea(.top)
                    
                if self.aic.tab == .capture {
                        VStack(spacing: 0) {
                            Color.white
                                .frame(width: sWidth(), height: navBarHeight + borderHeight)
                            
                            Spacer()
                                .frame(width: sWidth(), height: sWidth() * grubImageAspectRatio)
                            
                            Color.white
                                .frame(maxWidth: sWidth(), maxHeight: .infinity)
                        }.opacity((self.parent.cropImageScreen() && !self.isDragging) ? 1 : 0.8)
                    }
            }.frame(width: sWidth())
            .contentShape(Rectangle())
            .gesture(DragGesture().onChanged { drag in
                if self.parent.cropImageScreen() {
                    withAnimation(gAnim(.easeOut)) {
                        self.isDragging = true
                    }
                    
                    let maxDrag: CGFloat = navBarHeight + borderHeight
                    let minDrag: CGFloat = imageHeight - cameraHeight - navBarHeight + borderHeight
                    self.cic.dragOffset = max(min(drag.translation.height + self.cic.currentOffset, maxDrag), -minDrag)
                } else if self.aic.tab == .library {
                    let maxDrag: CGFloat = (imageHeight - sWidth() * grubImageAspectRatio) * 0.5
                    let minDrag: CGFloat = maxDrag
                    self.cic.dragOffset = max(min(drag.translation.height + self.cic.currentOffset, maxDrag), -minDrag)
                }
            }.onEnded { drag in
                if self.parent.cropImageScreen() || self.aic.tab == .library {
                    self.cic.currentOffset = self.cic.dragOffset
                }
                withAnimation(gAnim(.easeOut)) {
                    self.isDragging = false
                }
            })
        }
    }
    
    public var body: some View {
        ZStack {
            Color.black
                .edgesIgnoringSafeArea(.bottom)
            
            GCamera()
                .opacity(self.presentImagePicker() ? 1 : 0)
                .disabled(!self.presentImagePicker())
            
            CropImage(self)
            
            if self.aic.tab == .capture && !self.aic.cameraAuthorized ||
                self.aic.tab == .library && !self.aic.libraryAuthorized {
                self.authorizePage
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(white: 0.2))
            }
            
            if self.aic.tab == .library && self.aic.libraryAuthorized && self.aic.photoAssets.count == 0 {
                self.emptyCameraRoll
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(white: 0.2))
            }
            
            ZStack(alignment: .bottom) {
                Color.clear
                
                Rectangle()
                    .fill(AddImage.bgColor)
                    .frame(height: self.aic.tab == .capture ? cameraBodyHeight : libraryBodyHeight)
                
                self.library
                    .frame(height: libraryBodyHeight)
                    .background(Color.white)
                    .offset(y: -tabHeight)
                    .opacity(self.aic.tab == .library ? 1 : 0)
                    .disabled(self.aic.tab != .library)
            }
            
            ZStack {
                self.flashButton
                    .position(x: sWidth() * 0.9, y: navBarHeight + borderHeight + sWidth() * grubImageAspectRatio - sWidth() * 0.1)
                
                self.captureButton
            }.opacity(self.presentImagePicker() ? 1 : 0)
            .disabled(!self.presentImagePicker())
            
            self.bodyOverlay
                .foregroundColor(AddImage.textColor)
            
            if self.cropImageScreen() {
                Button(action: {
                    self.aic.image = nil
                    CropImageCookie.cic().resetOffset()
                }, label: {
                    Image(systemName: "camera.circle")
                        .resizable()
                        .frame(width: ImageViewController.buttonSize, height: ImageViewController.buttonSize)
                }).frame(width: ImageViewController.buttonSize, height: ImageViewController.buttonSize)
                .foregroundColor(AddImage.textColor)
                .position(x: sWidth() * 0.5, y: sHeight() + ImageViewController.buttonOffset - tabHeight)
            }
        }
    }
}

struct AddImage_Previews: PreviewProvider {
    static var previews: some View {
        AddImage(present: { _ in }, toAddFood: { _ in })
    }
}
