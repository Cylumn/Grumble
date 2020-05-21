//
//  GrubItem.swift
//  Grumble
//
//  Created by Allen Chang on 4/10/20.
//  Copyright © 2020 Cylumn, Inc. All rights reserved.
//

import SwiftUI

//MARK: - Cookies
public class GrubItemCookie: ObservableObject {
    private static var instance: GrubItemCookie?
    @Published public var textSize: CGFloat = 2.5
    
    public static func gic() -> GrubItemCookie {
        if GrubItemCookie.instance == nil {
            GrubItemCookie.instance = GrubItemCookie()
        }
        return GrubItemCookie.instance!
    }
    
    public func calibrateText(_ foodList: [String: Grub]) {
        var textSize: CGFloat = 2.5
        for grub in foodList.values {
            textSize = max(min(27.0 / CGFloat(grub.food.count), textSize), 2)
        }
        if textSize != self.textSize {
            self.textSize = textSize
        }
    }
    
    public func reset() {
        self.textSize = 2.5
    }
}

public class ObservedImage: ObservableObject {
    private static var instances: [String: ObservedImage] = [:]
    @Published public var image: Image? = nil
    
    fileprivate static func oi(_ fid: String) -> ObservedImage {
        if ObservedImage.instances[fid] == nil {
            ObservedImage.instances[fid] = ObservedImage()
        }
        return ObservedImage.instances[fid]!
    }
    
    public static func updateImage(_ grub: Grub) {
        ObservedImage.oi(grub.img).image = grub.image()
    }
}

//MARK: - Views
public struct GrubItem: View {
    @ObservedObject private var gic: GrubItemCookie = GrubItemCookie.gic()
    private var lc: ListCookie = ListCookie.lc()
    fileprivate var fid: String
    fileprivate var grub: Grub
    @ObservedObject private var oi: ObservedImage
    
    //MARK: Initializer
    public init(_ grub: Grub) {
        self.fid = grub.fid
        self.grub = grub
        self.oi = ObservedImage.oi(grub.img)
    }
    
    //MARK: Function Methods
    private func onClick() {
        withAnimation(gAnim(.easeOut)) {
            self.lc.selectedFID = self.fid
        }
        UIApplication.shared.endEditing()
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Button(action: {}, label: {
                ZStack(alignment: .bottom) {
                    Rectangle().fill(gTagColors[self.grub.priorityTag]!)
                    
                    self.oi.image?
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                    
                    HStack(alignment: .bottom) {
                        Text(self.grub.food)
                            .padding(10)
                            .font(gFont(.ubuntuBold, .width, self.gic.textSize))
                            .foregroundColor(Color.white)
                            .lineLimit(1)
                    
                        Spacer()
                        
                        if self.grub.price != nil {
                            Text("$" + String(format:"%.2f", self.grub.price!))
                                .padding(10)
                                .font(gFont(.ubuntuBold, .width, self.gic.textSize))
                                .foregroundColor(Color.white)
                        }
                    }.background(LinearGradient(gradient: Gradient(colors: [gTagColors[self.grub.priorityTag]!.opacity(0), gTagColors[self.grub.priorityTag]!]), startPoint: .top, endPoint: .bottom))
                }.frame(width: 200, height: 150)
                .cornerRadius(10)
                .onTapGesture {
                    self.onClick()
                }.onLongPressGesture(minimumDuration: 0.7) {
                    self.onClick()
                }
            }).buttonStyle(PlainButtonStyle())
                .shadow(color: gTagColors[self.grub.priorityTag]!.opacity(0.2), radius: 10, y: 10)
            
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

private struct GrubSearchItemTags: View {
    @ObservedObject private var gft: GFormText = GFormText.gft(.filterList)
    private var grub: Grub
    
    public init(_ grub: Grub) {
        self.grub = grub
    }
    
    //MARK: Getter Methods
    public func shownIDs() -> [GrubTag] {
        var sorted = self.grub.tags.sorted(by: { $0.0 > $1.0 })
        sorted.remove(at: sorted.firstIndex(where: { $0.0 == food })!)
        sorted.append((food, 0))
        var shownIDs: [(GrubTag, Double)] = []
        if self.gft.text(0).isEmpty {
            for index in (sorted.count < 3 ? 0 : 1) ..< min(sorted.count, 3) {
                shownIDs.append(sorted[index])
            }
        } else {
            let token = self.gft.text(0).lowercased()
            //add all that contains search key
            for id in sorted {
                if id.key.contains(token) {
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
                    if sorted[index].value < shownIDs[0].1 {
                        shownIDs.insert(sorted[index], at: 0)
                    } else if sorted[index].value > shownIDs[0].1 {
                        shownIDs.append(sorted[index])
                    }
                    
                    index += 1
                }
            default:
                break
            }
        }
        
        var shownTags: [GrubTag] = []
        for tag in shownIDs {
            shownTags.append(tag.0)
        }
        return shownTags
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
        let shownIDs: [GrubTag] = self.shownIDs()
        
        return HStack(spacing: 10) {
            ForEach(shownIDs, id: \.self) { tag in
                self.tokenText(tag)
            }
            
            Spacer()
        }
    }
}

public struct GrubSearchItem: View {
    private var fid: String
    private var grub: Grub
    private var tags: GrubSearchItemTags
    @State private var presentDeleteAlert: Bool = false
    
    //MARK: Initializer
    public init(_ grub: Grub) {
        self.fid = grub.fid
        self.grub = grub
        self.tags = GrubSearchItemTags(self.grub)
    }
    
    //MARK: Function Methods
    private func onClick() {
        withAnimation(gAnim(.easeOut)) {
            ListCookie.lc().selectedFID = self.fid
        }
        UIApplication.shared.endEditing()
    }
    
    public var body: some View {
        HStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 10) {
                Text(self.grub.food)
                    .font(gFont(.ubuntuMedium, .width, 1.8))
                    .lineLimit(1)
                    
                self.tags
            }
            
            Spacer()
            
            Button(action: {}, label: {
                Text("View")
                .padding(10)
                .font(gFont(.ubuntuBold, .width, 1.5))
                .foregroundColor(gColor(.blue4))
                .overlay(RoundedRectangle(cornerRadius: 8)
                .stroke(gColor(.blue4), lineWidth: 2))
                .onTapGesture {
                    SearchListCookie.slc().focused = true
                    self.onClick()
                }
            })
            
            Button(action: {}, label: {
                Text("Delete")
                .padding(10)
                .font(gFont(.ubuntuBold, .width, 1.5))
                .foregroundColor(gColor(.coral))
                .onTapGesture {
                    SearchListCookie.slc().focused = true
                    UIApplication.shared.endEditing()
                    self.presentDeleteAlert.toggle()
                }.overlay(RoundedRectangle(cornerRadius: 8)
                .stroke(gColor(.coral), lineWidth: 2))
            }).alert(isPresented: self.$presentDeleteAlert) {
                Alert(title: Text("Delete Grub?"), primaryButton: Alert.Button.default(Text("Cancel")), secondaryButton: Alert.Button.destructive(Text("Delete")) {
                    Grub.removeFood(self.fid)
                })
            }
        }.padding(10)
        .padding(.trailing, 20)
        .frame(width: sWidth() - 40, height: 60)
        .background(Color.white)
        .foregroundColor(Color(white: 0.2))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 3)
    }
}

//MARK: - Previews
struct GrubItem_Previews: PreviewProvider {
    static var previews: some View {
        GrubItem(Grub.testGrub())
    }
}
