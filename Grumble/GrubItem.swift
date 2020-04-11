//
//  GrubItem.swift
//  Grumble
//
//  Created by Allen Chang on 4/10/20.
//  Copyright © 2020 Cylumn, Inc. All rights reserved.
//

import SwiftUI

public struct GrubItem: View {
    private var fid: String
    private var grub: Grub
    private var selectedGrub: Binding<(String, Grub)?>
    private var showSheet: Binding<Bool>
    @State private var onTap: Bool = false
    
    //Initializer
    public init(fid: String, _ grub: Grub, _ selectedGrub: Binding<(String, Grub)?>, _ showSheet: Binding<Bool>) {
        self.fid = fid
        self.grub = grub
        self.selectedGrub = selectedGrub
        self.showSheet = showSheet
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            
            ZStack(alignment: .bottom) {
                Rectangle().fill(tagColors[self.grub.tags["smallestTag"]!])
                
                Image(tagSprites[self.grub.tags["smallestTag"]!])
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(Color(white: 0.98))
                .padding(20)
                
                LinearGradient(gradient: Gradient(colors: [Color.clear, Color.black.opacity(0.4)]), startPoint: .top, endPoint: .bottom)
                    .frame(height: 70)
                
                HStack(alignment: .bottom) {
                    Text(self.grub.food)
                        .padding(10)
                        .font(gFont(.ubuntuBold, .width, 3))
                        .foregroundColor(Color.white)
                
                    Spacer()
                    
                    if self.grub.price != nil {
                        Text("$" + String(format:"%.2f", self.grub.price!))
                            .padding(10)
                            .font(gFont(.ubuntuBold, .width, 2.5))
                            .foregroundColor(Color.white)
                    }
                }
                
                if self.onTap {
                    Color.white.opacity(0.7)
                        .onAppear {
                            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
                                self.onTap = false
                            }
                        }
                }
            }.frame(width: 200, height: 150)
            .cornerRadius(10)
            .onTapGesture {
                self.selectedGrub.wrappedValue = (self.fid, self.grub)
                withAnimation(gAnim(.easeOut)) {
                    self.showSheet.wrappedValue = true
                    self.onTap = true
                }
                TabRouter.tr().hide(true)
            }.shadow(color: tagColors[self.grub.tags["smallestTag"]!].opacity(0.2), radius: 10, y: 10)
            
            Text(self.grub.restaurant ?? " ")
                .padding([.top, .leading], 10)
                .font(gFont(.ubuntuLight, .width, 2))
                .foregroundColor(Color.black)
            
            Text(self.grub.address ?? " ")
                .padding(.leading, 10)
                .font(gFont(.ubuntuLightItalic, .width, 1.5))
                .foregroundColor(Color(white: 0.1))
        }
    }
}

struct GrubItem_Previews: PreviewProvider {
    static var previews: some View {
        return GrubItem(fid: "", Grub.testGrub(), Binding.constant(nil), Binding.constant(false))
    }
}
