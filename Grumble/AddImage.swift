//
//  AddImage.swift
//  Grumble
//
//  Created by Allen Chang on 5/6/20.
//  Copyright © 2020 Cylumn, Inc. All rights reserved.
//

import SwiftUI

public class AddImageCookie: ObservableObject {
    private static var instance: AddImageCookie? = nil
    public var currentFID: String? = nil
    @Published public var image: Image? = nil
    @Published public var aspectRatio: CGFloat = 1
    @Published public var isPresented: Bool = false
    
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
        return self.aic.isPresented && self.aic.image == nil
    }
    
    private func tabButton(_ label: String, _ page: Pages) -> some View {
        Button(action: {
            self.tab = page
        }, label: {
            Text(label)
        }).frame(maxWidth: .infinity)
        .foregroundColor(self.tab == page ? Color.white : Color(white: 0.9))
    }
    
    public var body: some View {
        ZStack {
            Color.black
                .edgesIgnoringSafeArea(.bottom)
            
            ZStack(alignment: .top) {
                Color.clear
                
                self.aic.image?
                    .resizable()
                    .frame(width: sWidth(), height: self.aic.aspectRatio * sWidth())
            }.frame(width: sWidth())
            
            ImagePicker()
                .opacity(self.presentImagePicker() ? 1 : 0)
                .disabled(!self.presentImagePicker())
            
            ZStack(alignment: .bottom) {
                Color.clear
                
                Rectangle()
                    .fill(AddImage.bgColor)
                    .frame(height: abs(ImageViewController.buttonOffset * 2))
            }
            
            if self.aic.image == nil {
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
            
            VStack(spacing: 0) {
                HStack {
                    Button(action: {
                        withAnimation(gAnim(.easeOut)) {
                            self.present(false)
                            self.tab = .capture
                        }
                        self.aic.image = nil
                    }, label: {
                        Text("Cancel")
                    })
                    
                    Spacer()
                }.padding([.leading, .trailing], 20)
                .frame(height: navBarHeight)
                .background(gColor(.blue0))
                .font(gFont(.ubuntuLight, 18))
                
                Spacer()
                
                if self.aic.image == nil {
                    HStack {
                        self.tabButton("Library", .library)
                        self.tabButton("Capture", .capture)
                    }.padding([.top, .bottom], 10)
                    .frame(height: tabHeight)
                    .background(gColor(.blue0))
                    .font(gFont(.ubuntuBold, .width, 2.5))
                } else {
                    HStack {
                        Button(action: {
                            self.aic.image = nil
                        }, label: {
                            Text("Retake")
                        }).frame(maxWidth: .infinity)
                        
                        Spacer()
                        
                        Button(action: {
                            self.toAddFood(nil)
                        }, label: {
                            Text("Next")
                        }).frame(maxWidth: .infinity)
                    }.frame(height: abs(ImageViewController.buttonOffset * 2))
                    .font(gFont(.ubuntuMedium, .width, 2.5))
                }
            }.foregroundColor(AddImage.textColor)
        }
    }
}

struct AddImage_Previews: PreviewProvider {
    static var previews: some View {
        AddImage(present: { _ in }, toAddFood: { _ in })
    }
}
