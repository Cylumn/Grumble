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
    @Published public var isPresented: Bool = false
    
    public static func aic() -> AddImageCookie {
        if AddImageCookie.instance == nil {
            AddImageCookie.instance = AddImageCookie()
        }
        return AddImageCookie.instance!
    }
}

public struct AddImage: View {
    @ObservedObject private var aic: AddImageCookie = AddImageCookie.aic()
    private var present: (Bool) -> Void
    private var toAddFood: (String?) -> Void
    
    public init(present: @escaping (Bool) -> Void, toAddFood: @escaping (String?) -> Void) {
        self.present = present
        self.toAddFood = toAddFood
        
        AddFoodCookie.afc().presentAddImage = self.present
    }
    
    public var body: some View {
        ZStack {
            Color.black
                .edgesIgnoringSafeArea(.all)
            
            self.aic.image?
                .resizable()
            
            ImagePicker(isPresented: Binding(get: {self.aic.isPresented}, set: { _ in }), image: Binding(get: {self.aic.image}, set: { self.aic.image = $0 }))
            
            HStack(spacing: 50) {
                Button(action: {
                    withAnimation(gAnim(.easeOut)) {
                        self.present(false)
                    }
                }, label: {
                    Text("back")
                })
                
                Button(action: {
                    self.toAddFood(nil)
                    ListCookie.lc().onAddFoodHide = {}
                }, label: {
                    Text("toAddFood")
                })
            }
        }
    }
}

struct AddImage_Previews: PreviewProvider {
    static var previews: some View {
        AddImage(present: { _ in }, toAddFood: { _ in })
    }
}
