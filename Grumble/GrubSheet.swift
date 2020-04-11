//
//  GrubSheet.swift
//  Grumble
//
//  Created by Allen Chang on 4/10/20.
//  Copyright © 2020 Cylumn, Inc. All rights reserved.
//

import SwiftUI

public struct GrubSheet: View {
    private var selectedGrub: Binding<(String, Grub)?>
    private var grub: Grub?
    private var show: Binding<Bool>
    @State private var offset: CGFloat = 0
    private var overlayOpacity: Binding<Double>
    
    //Initializer
    public init(_ selectedGrub: Binding<(String, Grub)?>, _ show: Binding<Bool>, _ overlayOpacity: Binding<Double>) {
        self.selectedGrub = selectedGrub
        self.grub = self.selectedGrub.wrappedValue?.1
        self.show = show
        self.overlayOpacity = overlayOpacity
    }
    
    private var sheet: some View {
        var tags = self.grub!.tags
        let smallestTag = tags["smallestTag"]!
        tags["smallestTag"] = nil
        
        return ZStack(alignment: .bottom) {
            tagColors[smallestTag].edgesIgnoringSafeArea(.all)
            
            ZStack(alignment: .top) {
                Color.clear
                
                Image(tagSprites[smallestTag])
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(20)
                    .frame(height: sHeight() * 0.3)
                    .shadow(color: Color.black.opacity(0.2), radius: 10, y: 10)
                }
            
            LinearGradient(gradient: Gradient(colors: [Color.clear, Color.black]), startPoint: .top, endPoint: .bottom)
            
            ZStack(alignment: .topLeading) {
                Color(white: 0.98)
                
                VStack(spacing: 20) {
                    HStack(alignment: .bottom, spacing: nil) {
                        VStack(alignment: .leading, spacing: nil) {
                            Text("Food")
                                .font(gFont(.ubuntuLight, .width, 2))
                            
                            Text(self.grub!.food)
                        }
                        
                        Spacer()
                        
                        if self.grub!.price != nil {
                            VStack(spacing: nil) {
                                Text("Price")
                                .font(gFont(.ubuntuLight, .width, 2))
                                
                                Text("$" + String(format:"%.2f", self.grub!.price!))
                            }
                        }
                    }.font(gFont(.ubuntuMedium, .width, 3.5))
                    .padding(10)
                    .padding([.leading, .trailing], 10)
                    .background(Color.white)
                    .clipped()
                    
                    VStack(alignment: .center, spacing: 20) {
                        Button(action: {
                            
                        }, label: {
                            Text("Edit Grub")
                                .frame(maxWidth: .infinity)
                                .padding(10)
                        }).background(Color.white)
                        .foregroundColor(tagColors[smallestTag])
                        .font(gFont(.ubuntuMedium, .width, 2.5))
                        .cornerRadius(10)
                        .clipped()
                        
                        HStack(alignment: .top, spacing: nil) {
                            VStack(alignment: .leading, spacing: 10) {
                                VStack(alignment: .leading, spacing: 5) {
                                    Text("Restaurant")
                                        .font(gFont(.ubuntuLight, .width, 1.5))
                                    Text(self.grub!.restaurant ?? "(Unlisted)")
                                        .font(gFont(.ubuntuBold, .width, 2))
                                }
                                
                                VStack(alignment: .leading, spacing: 5) {
                                    Text("Address")
                                        .font(gFont(.ubuntuLight, .width, 1.5))
                                    Text(self.grub!.address ?? "(Unlisted)")
                                        .font(gFont(.ubuntuBold, .width, 2))
                                }
                            }
                            
                            Spacer()
                            
                            VStack(spacing: 5) {
                                Text("Map")
                                    .font(gFont(.ubuntuLight, .width, 2))
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(gColor(.blue0))
                                        .frame(width: 70, height: 70)
                                        .shadow(color: gColor(.blue0).opacity(0.2), radius: 10, y: 10)
                                    
                                    Image(systemName: "map")
                                        .font(.system(size: 50))
                                }.foregroundColor(Color.white)
                            }
                        }.padding(20)
                        .background(Color.white)
                        .cornerRadius(20)
                        .clipped()
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Tags")
                                .padding([.leading, .trailing], 15)
                                .padding(5)
                                .background(Color.white)
                                .font(gFont(.ubuntuLight, .width, 2))
                                .cornerRadius(20)
                            
                            HStack(spacing: 10) {
                                ForEach(tags.keys.sorted(), id: \.self) { key in
                                        Text(key)
                                        .padding([.leading, .trailing], 15)
                                        .padding(5)
                                        .background(Color.white)
                                        .font(gFont(.ubuntuMedium, .width, 2))
                                        .foregroundColor(tagColors[tags[key]!])
                                        .cornerRadius(20)
                                }
                                
                                Spacer()
                            }
                        }
                        
                        Spacer()
                    }.padding([.leading, .trailing], 20)
                    .foregroundColor(Color(white: 0.2))
                }.shadow(color: Color.black.opacity(0.1), radius: 20, y: 10)
            }.frame(height: sHeight() * 0.6)
            .foregroundColor(Color.black)
        }.offset(y: self.show.wrappedValue ? self.offset : sHeight() * 1.2)
        .gesture(DragGesture().onChanged { drag in
            self.offset = max(drag.translation.height, 0)
            self.overlayOpacity.wrappedValue = Double(min((sHeight() - self.offset) / sHeight(), 0.8))
        }.onEnded { drag in
            self.offset = max(drag.predictedEndTranslation.height, 0)
            if self.offset > sHeight() * 0.3 {
                withAnimation(gAnim(.easeOut)) {
                    self.show.wrappedValue = false
                    self.offset = 0
                    self.overlayOpacity.wrappedValue = 0
                }
                TabRouter.tr().hide(false)
            } else {
                withAnimation(gAnim(.easeOut)) {
                    self.offset = 0
                    self.overlayOpacity.wrappedValue = 0.8
                }
            }
        })
    }
    
    public var body: some View {
        if self.grub != nil {
            return AnyView(self.sheet)
        } else {
            return AnyView(Color.clear)
        }
    }
}

struct GrubSheet_Previews: PreviewProvider {
    static var previews: some View {
        GrubSheet(Binding.constant(("", Grub.testGrub())), Binding.constant(true), Binding.constant(0))
    }
}
