//
//  GrubSheet.swift
//  Grumble
//
//  Created by Allen Chang on 4/10/20.
//  Copyright © 2020 Cylumn, Inc. All rights reserved.
//

import SwiftUI

//MARK: - Constants
private let baseImageFraction: CGFloat = sWidth() * grubImageAspectRatio / sHeight() //0.35
private let dragFraction: CGFloat = 0.5
private let safeImagePadding: CGFloat = 10
private let minDragFraction: CGFloat = 0

private let headerHeight: CGFloat = sWidth() * 0.23
private let grubContentPadding: CGFloat = 20
private let editHeight: CGFloat = 40
private let restaurantHeight: CGFloat = 150
private let addressHeight: CGFloat = 220
private let tagBuilderHeight: CGFloat = 25
private let tagBuilderPadding: CGFloat = 10
private let deleteHeight: CGFloat = 40

//MARK: - Views
fileprivate struct GrubSheetContent: View {
    private var lc: ListCookie
    private var selectedFID: String
    private var grub: Grub
    private var toAddFood: (String?) -> Void
    @State private var presentDeleteAlert: Bool = false
    
    //MARK: Initializers
    fileprivate init(_ selectedFID: String, _ grub: Grub) {
        self.lc = ListCookie.lc()
        self.selectedFID = selectedFID
        self.grub = grub
        
        self.toAddFood = ContentCookie.cc().toAddFood
    }
    
    //MARK: Getter Methods
    fileprivate func height() -> CGFloat {
        var height: CGFloat = 0
        if !self.grub.immutable {
            height += editHeight + grubContentPadding
        }
        
        if self.grub.restaurant != nil {
            height += restaurantHeight + grubContentPadding
        }
        if self.grub.address != nil {
            height += addressHeight + grubContentPadding
        }
        
        let tagLines = ceil(Double(self.grub.tags.count - 1) / 3.0)
        height += (tagBuilderHeight + tagBuilderPadding) * CGFloat(tagLines) - tagBuilderPadding + grubContentPadding
        
        if !self.grub.immutable {
            height += deleteHeight
        }
        
        return height
    }
    
    //MARK: Subviews
    fileprivate var header: some View {
        HStack(alignment: .bottom, spacing: nil) {
            VStack(alignment: .leading, spacing: nil) {
                Text("Food")
                    .font(gFont(.ubuntuLight, .width, 2))
                
                Text(self.grub.food)
            }
            
            Spacer()
            
            if self.grub.price != nil {
                VStack(spacing: nil) {
                    Text("Price")
                    .font(gFont(.ubuntuLight, .width, 2))
                    
                    Text("$" + String(format:"%.2f", self.grub.price!))
                }
            }
        }.padding(10)
        .padding([.leading, .trailing], 10)
        .frame(height: headerHeight)
        .background(Color.white)
        .font(gFont(.ubuntuMedium, .width, 3.5))
        .shadow(color: Color.black.opacity(0.1), radius: 5, y: 2)
    }
    
    private var editButton: some View {
        return Button(action: {
            GFormText.gft(.addFood).setText(AddFood.FieldIndex.food.rawValue, self.grub.food)
            GFormText.gft(.addFood).setText(AddFood.FieldIndex.price.rawValue, self.grub.price == nil ? "" : "$" + String(format:"%.2f", self.grub.price!))
            GFormText.gft(.addFood).setText(AddFood.FieldIndex.restaurant.rawValue, self.grub.restaurant ?? "")
            GFormText.gft(.addFood).setText(AddFood.FieldIndex.address.rawValue, self.grub.address ?? "")
            AddFoodCookie.afc().resetForNewGrub()
            AddFoodCookie.afc().tags = self.grub.tags
            
            self.toAddFood(self.selectedFID)
        }, label: {
            Text("Edit Grub")
                .frame(maxWidth: .infinity)
                .padding(10)
        })
    }
    
    private var restaurantInfo: some View {
        HStack(alignment: .top, spacing: nil) {
            VStack(alignment: .leading, spacing: 10) {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Restaurant")
                        .font(gFont(.ubuntuLight, .width, 1.5))
                    Text(self.grub.restaurant!)
                        .font(gFont(.ubuntuBold, .width, 2))
                }
                
                VStack(alignment: .leading, spacing: 5) {
                    Text("Phone Number")
                        .font(gFont(.ubuntuLight, .width, 1.5))
                    Text("+1 (XXX) XXX-XXXX")
                        .font(gFont(.ubuntuBold, .width, 2))
                }
            }
            
            Spacer()
            
            VStack(spacing: 5) {
                Text("Call")
                    .font(gFont(.ubuntuLight, .width, 2))
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(gColor(.blue4))
                        .frame(width: 70, height: 70)
                        .shadow(color: gColor(.blue4).opacity(0.1), radius: 5, y: 10)
                    
                    Image(systemName: "phone")
                        .font(.system(size: 50))
                }.foregroundColor(Color.white)
            }
        }
    }
    
    private var addressInfo: some View {
        HStack(alignment: .top, spacing: nil) {
            VStack(alignment: .leading, spacing: 5) {
                Text("Address")
                    .font(gFont(.ubuntuLight, .width, 1.5))
                Text(self.grub.address!)
                    .font(gFont(.ubuntuBold, .width, 2))
                    .lineLimit(5)
            }
            
            Spacer()
            
            VStack(spacing: 5) {
                Text("Map")
                    .font(gFont(.ubuntuLight, .width, 2))
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(gColor(.blue0))
                        .frame(width: 150, height: 150)
                        .shadow(color: gColor(.blue0).opacity(0.1), radius: 5, y: 10)
                    
                    Image(systemName: "map")
                        .font(.system(size: 50))
                }.foregroundColor(Color.white)
            }
        }
    }
    
    private var tagBuilder: some View {
        var tags = self.grub.tags.keys.sorted()
        tags.remove(at: tags.firstIndex(of: food)!)
        tags.insert(food, at: 0)
        
        return VStack(alignment: .center, spacing: tagBuilderPadding) {
            ForEach(0 ... tags.count / 3, id: \.self) { line in
                HStack(spacing: tagBuilderPadding) {
                    ForEach(line * 3 ..< min((line + 1) * 3, tags.count), id: \.self) { index in
                            Text(tags[index])
                            .padding([.leading, .trailing], 15)
                            .padding(5)
                            .frame(height: tagBuilderHeight)
                            .background(Color.white)
                            .font(gFont(.ubuntuMedium, .width, 2))
                            .foregroundColor(gTagColors[tags[index]])
                            .cornerRadius(20)
                    }
                }
            }
        }.frame(maxWidth: .infinity)
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: grubContentPadding) {
            if !self.grub.immutable {
                self.editButton
                    .frame(height: editHeight)
                    .background(Color.white)
                    .foregroundColor(gTagColors[self.grub.priorityTag])
                    .font(gFont(.ubuntuMedium, .width, 2.5))
                    .cornerRadius(10)
            }
            
            if self.grub.restaurant != nil {
                self.restaurantInfo
                    .padding(20)
                    .frame(height: restaurantHeight)
                    .background(Color.white)
                    .cornerRadius(20)
            }
            
            if self.grub.address != nil {
                self.addressInfo
                    .padding(20)
                    .frame(height: addressHeight)
                    .background(Color.white)
                    .cornerRadius(20)
            }
            
            self.tagBuilder
            
            if !self.grub.immutable {
                Button(action: { self.presentDeleteAlert.toggle() }, label: {
                    Text("Delete")
                    .padding(10)
                    .frame(height: deleteHeight)
                    .background(Color.white)
                    .cornerRadius(8)
                    .font(gFont(.ubuntuBold, .width, 2))
                    .foregroundColor(gColor(.coral))
                }).alert(isPresented: self.$presentDeleteAlert) {
                    Alert(title: Text("Delete Grub?"), primaryButton: Alert.Button.default(Text("Cancel")), secondaryButton: Alert.Button.destructive(Text("Delete")) {
                        self.lc.selectedGrub = nil
                        Grub.removeFood(self.selectedFID)
                    })
                }
            }
        }.padding([.leading, .trailing], 20)
        .foregroundColor(Color(white: 0.2))
        .shadow(color: Color.black.opacity(0.1), radius: 3)
    }
}

public struct GrubSheet: View {
    private var selectedFID: String
    private var grub: Grub
    
    private var hideSheet: () -> Void
    
    private var hideSheetButton: Button<AnyView>
    private var grubContent: GrubSheetContent
    
    @State private var imageFraction: CGFloat = baseImageFraction
    @State private var currentImageFraction: CGFloat = baseImageFraction
    @State private var offsetGrubContent: CGFloat = 0
    @State private var currentOffsetGrubContent: CGFloat = 0
    
    @State private var impactOccurred: Bool = false
    
    //MARK: Initializers
    public init(_ selectedGrub: Grub) {
        self.selectedFID = selectedGrub.fid
        self.grub = selectedGrub
        
        //MARK: Function Methods
        self.hideSheet = {
            withAnimation(gAnim(.easeInOut)) {
                ListCookie.lc().selectedGrub = nil
            }
        }
        
        //MARK: Subviews
        self.hideSheetButton = Button(action: self.hideSheet, label: {
            AnyView(Image(systemName: "chevron.down.circle.fill")
                .padding(20)
                .foregroundColor(Color.white.opacity(0.9))
                .font(.system(size: 30)))
        })
        self.grubContent = GrubSheetContent(self.selectedFID, self.grub)
    }
    
    //MARK: Subviews
    private var imageDragContent: some View {
        Color.clear
            .contentShape(Rectangle())
            .gesture(DragGesture().onChanged { drag in
                withAnimation(gAnim(.spring)) {
                    self.imageFraction = max(drag.translation.height, 0) / sHeight() * dragFraction + baseImageFraction
                }
                if !self.impactOccurred && drag.translation.height > sHeight() * 0.4 {
                    self.impactOccurred = true
                    
                    let impactLight = UIImpactFeedbackGenerator(style: .light)
                    impactLight.impactOccurred()
                } else if drag.translation.height < sHeight() * 0.4 {
                    self.impactOccurred = false
                }
            }.onEnded { drag in
                withAnimation(gAnim(.spring)) {
                    self.imageFraction = baseImageFraction
                }
                if drag.translation.height > sHeight() * 0.4 {
                    self.hideSheet()
                }
            })
    }
    
    private var contentGesture: some Gesture {
        DragGesture().onChanged { drag in
            withAnimation(gAnim(.easeOut)) {
                if self.offsetGrubContent == 0 {
                    self.imageFraction = max(min(drag.translation.height / sHeight() + self.currentOffsetGrubContent / sHeight() + self.currentImageFraction, baseImageFraction), minDragFraction)
                }
                
                if self.imageFraction == minDragFraction {
                    let attemptedOffset = min(drag.translation.height + self.currentImageFraction * sHeight() + safeAreaInset(.top) + self.currentOffsetGrubContent, 0)
                    self.offsetGrubContent = max(attemptedOffset, min(sHeight() * ( 1 - baseImageFraction) + headerHeight - self.grubContent.height(), 0))
                }
            }
        }.onEnded { drag in
            self.currentImageFraction = self.imageFraction
            self.currentOffsetGrubContent = self.offsetGrubContent
        }
    }
    
    public var body: some View {
        let minScale: CGFloat = 0.8
        let scale: CGFloat = max(self.imageFraction / baseImageFraction, minScale) / minScale
        return ZStack(alignment: .topTrailing) {
            ZStack(alignment: .top) {
                gTagColors[self.grub.priorityTag]
                    .edgesIgnoringSafeArea(.all)
                
                self.grub.image()?
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: sWidth() * scale)
                    .offset(y: -safeAreaInset(.top))
            }.frame(width: sWidth())
            
            self.imageDragContent
            
            self.hideSheetButton
            
            gTagColors[self.grub.priorityTag]
                .edgesIgnoringSafeArea(.all)
                .opacity(1 - Double(min((self.imageFraction - minDragFraction) * 10, 1)))
            
            ZStack(alignment: .topLeading) {
                Color(white: 0.95)
                
                VStack(spacing: 20) {
                    Spacer().frame(height: headerHeight)
                    
                    self.grubContent
                        .offset(y: self.offsetGrubContent)
                }
                
                self.grubContent.header
            }.frame(maxHeight: sHeight() - safeAreaInset(.top), alignment: .top)
            .foregroundColor(Color.black)
            .offset(y: sHeight() * self.imageFraction)
        }.frame(width: sWidth())
        .gesture(self.contentGesture)
    }
}

struct GrubSheet_Previews: PreviewProvider {
    static var previews: some View {
        return GrubSheet(Grub.testGrub())
    }
}
