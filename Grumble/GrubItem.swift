//
//  GrubItem.swift
//  Grumble
//
//  Created by Allen Chang on 4/10/20.
//  Copyright © 2020 Cylumn, Inc. All rights reserved.
//

import SwiftUI

public class GrubItemCookie: ObservableObject {
    private static var instance: GrubItemCookie?
    @Published public var textSize: CGFloat = 2.5
    
    public static func gic() -> GrubItemCookie {
        if GrubItemCookie.instance == nil {
            GrubItemCookie.instance = GrubItemCookie()
        }
        return GrubItemCookie.instance!
    }
    
    public func reset() {
        self.textSize = 2.5
    }
}

public struct GrubItem: View {
    @ObservedObject private var gic: GrubItemCookie = GrubItemCookie.gic()
    private var lc: ListCookie = ListCookie.lc()
    fileprivate var fid: String
    fileprivate var grub: Grub
    private var smallestTag: Int
    
    //Initializer
    public init(fid: String, _ grub: Grub) {
        self.fid = fid
        self.grub = grub
        self.smallestTag = self.grub.tags["smallestTag"]!
    }
    
    //Getter Methods
    private func textSize(_ text: String) -> CGFloat {
        let size = max(min(27.0 / CGFloat(text.count), self.gic.textSize), 2)
        if size != self.gic.textSize {
            self.gic.textSize = size
        }
        return self.gic.textSize
    }
    
    //Function Method
    fileprivate func onClick() {
        self.lc.selectedFID = self.fid
        withAnimation(gAnim(.easeOut)) {
            self.lc.presentGrubSheet = true
        }
        TabRouter.tr().hide(true)
        UIApplication.shared.endEditing()
        
        self.lc.onGrubSheetHide = { TabRouter.tr().hide(false) }
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Button(action: {}, label: {
                ZStack(alignment: .bottom) {
                    Rectangle().fill(tagColors[self.smallestTag])
                    
                    GTagIcon.icon(tag: self.smallestTag, id: .listBox, size: CGSize(width: 200, height: 150))
                    
                    HStack(alignment: .bottom) {
                        Text(self.grub.food)
                            .padding(10)
                            .font(gFont(.ubuntuBold, .width, textSize(self.grub.food)))
                            .foregroundColor(Color.white)
                            .lineLimit(1)
                    
                        Spacer()
                        
                        if self.grub.price != nil {
                            Text("$" + String(format:"%.2f", self.grub.price!))
                                .padding(10)
                                .font(gFont(.ubuntuBold, .width, textSize(self.grub.food)))
                                .foregroundColor(Color.white)
                        }
                    }.background(LinearGradient(gradient: Gradient(colors: [tagColors[self.smallestTag].opacity(0), tagColors[self.smallestTag]]), startPoint: .top, endPoint: .bottom))
                }.frame(width: 200, height: 150)
                .cornerRadius(10)
                .onTapGesture {
                    self.onClick()
                }.onLongPressGesture(minimumDuration: 0.7) {
                    self.onClick()
                }
            }).buttonStyle(PlainButtonStyle())
            .shadow(color: tagColors[self.grub.tags["smallestTag"]!].opacity(0.2), radius: 10, y: 10)
            
            Text(self.grub.restaurant ?? " ")
                .padding([.top, .leading], 10)
                .font(gFont(.ubuntuLight, .width, 2))
                .foregroundColor(Color.black)
                .lineLimit(1)
            
            Text(self.grub.address ?? " ")
                .padding(.leading, 10)
                .font(gFont(.ubuntuLightItalic, .width, 1.5))
                .foregroundColor(Color(white: 0.1))
                .lineLimit(1)
        }.frame(width: 200)
    }
}

public struct GrubSearchItem: View {
    private var item: GrubItem
    @State private var presentDeleteAlert: Bool = false
    
    //Initializer
    public init(_ item : GrubItem) {
        self.item = item
    }
    
    private func tokenText(_ text: String) -> some View {
        Text(text)
            .padding(3)
            .padding([.leading, .trailing], 4)
            .background(Color.white)
            .font(gFont(.ubuntuLight, .width, 1.8))
            .overlay(Capsule().stroke(Color(white: 0.8), lineWidth: 1))
    }
    
    public var body: some View {
        var tags = self.item.grub.tags
        tags["smallestTag"] = nil
        var shownIDs: [Int] = []
        if GFormText.gft(.filterList).text(0).isEmpty {
            let sorted = tags.values.sorted()
            for index in (sorted.count < 3 ? 0 : 1) ..< min(sorted.count, 3) {
                shownIDs.append(sorted[index])
            }
        } else {
            let token = GFormText.gft(.filterList).text(0).lowercased()
            let sorted = tags.values.sorted()
            //add all that contains search key
            for id in sorted {
                if tagTitles[id].contains(token) {
                    shownIDs.append(id)
                    
                    if shownIDs.count == 2 {
                        break
                    }
                }
            }
            
            //add remainder
            switch shownIDs.count {
            case 0:
                for index in 0 ..< min(sorted.count, 3) {
                    shownIDs.append(sorted[index])
                }
            case 1:
                var index = (sorted.count < 3 ? 0 : 1)
                while index < min(sorted.count, 3) && shownIDs.count < 2 {
                    if sorted[index] < shownIDs[0] {
                        shownIDs.insert(sorted[index], at: 0)
                    } else if sorted[index] > shownIDs[0] {
                        shownIDs.append(sorted[index])
                    }
                    
                    index += 1
                }
            default:
                break
            }
        }
        
        return HStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 10) {
                Text(self.item.grub.food)
                    .font(gFont(.ubuntuMedium, .width, 2.3))
                    .lineLimit(1)
                    
                HStack(spacing: 10) {
                    ForEach(shownIDs, id: \.self) { index in
                        self.tokenText(tagTitles[index])
                    }
                }
            }
            
            Spacer()
            
            Button(action: {}, label: {
                Text("View")
                .padding(10)
                .font(gFont(.ubuntuBold, .width, 1.5))
                .foregroundColor(gColor(.blue4))
                .onTapGesture {
                    ListCookie.lc().searchFocused = true
                    self.item.onClick()
                }
                .overlay(RoundedRectangle(cornerRadius: 8)
                .stroke(gColor(.blue4), lineWidth: 2))
            })
            
            Button(action: {}, label: {
                Text("Delete")
                .padding(10)
                .font(gFont(.ubuntuBold, .width, 1.5))
                .foregroundColor(gColor(.coral))
                .onTapGesture {
                    ListCookie.lc().searchFocused = true
                    UIApplication.shared.endEditing()
                    self.presentDeleteAlert.toggle()
                }.overlay(RoundedRectangle(cornerRadius: 8)
                .stroke(gColor(.coral), lineWidth: 2))
            }).alert(isPresented: self.$presentDeleteAlert) {
                Alert(title: Text("Delete Grub?"), primaryButton: Alert.Button.default(Text("Cancel")), secondaryButton: Alert.Button.destructive(Text("Delete")) {
                    Grub.removeFood(self.item.fid)
                })
            }
        }.padding(10)
        .padding(.trailing, 20)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .foregroundColor(Color(white: 0.2))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 3)
    }
}

struct GrubItem_Previews: PreviewProvider {
    static var previews: some View {
        GrubItem(fid: "", Grub.testGrub())
    }
}
