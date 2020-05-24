//
//  ListView.swift
//  Grumble
//
//  Created by Allen Chang on 3/20/20.
//  Copyright © 2020 Cylumn, Inc. All rights reserved.
//

import SwiftUI

//MARK: - Constants
private let formID: GFormID = GFormID.filterList
private let titleHeight: CGFloat = 40
public let searchHeight: CGFloat = sWidth() * 0.1
private let grumbleButtonHeight: CGFloat = 40
private let myListTitleHeight: CGFloat = 30

private let maxOverlayOpacity: Double = 0.5

//MARK: - Cookies
public class ListCookie: ObservableObject {
    private static var instance: ListCookie? = nil
    @Published public var selectedGrub: Grub? = nil
    
    public static func lc() -> ListCookie {
        if ListCookie.instance == nil {
            ListCookie.instance = ListCookie()
        }
        return ListCookie.instance!
    }
    
    public func presentGrubSheet() -> Bool {
        return self.selectedGrub != nil
    }
}

//MARK: - Views
public struct ListView: View {
    @ObservedObject private var uc: UserCookie = UserCookie.uc()
    @ObservedObject private var lc: ListCookie = ListCookie.lc()
    
    private var searchList: SearchList
    
    @State private var presentGrumbleSheet: Bool = false
    
    @State private var presentAddImage: Bool = false
    
    public init() {
        self.searchList = SearchList(titleHeight: titleHeight)
    }
    
    //MARK: Function Methods
    private func showGrumbleSheet(_ ghorblinType: GhorblinType) {
        GrumbleCookie.gc().setIndex(0)
        GrumbleTypeCookie.gtc().type = ghorblinType
        if ghorblinType == .grumble {
            GrumbleCookie.gc().setGrubList(UserCookie.uc().foodList().shuffled())
        } else {
            let unobserved = GrumbleCookie.gc().unobservedGrubList()
            requestImmutableGrub(unobserved, count: max(10 - unobserved.count, 0)) { list in
                GrumbleCookie.gc().setGrubList(unobserved + list.shuffled())
            }
            GrumbleCookie.gc().setGrubList(Array(unobserved))
        }
        
        withAnimation(gAnim(.easeOut)) {
            self.presentGrumbleSheet = true
        }
        GrumbleCookie.gc().startIdleAnimation()
    }
    
    private func showAddImage(isPresented: Bool, animate: Bool) {
        let animatedTask = {
            self.presentAddImage = isPresented
            AddImageCookie.aic().run(isPresented)
        }
        if animate {
            withAnimation(gAnim(.easeOut)) {
                animatedTask()
            }
        } else {
            animatedTask()
        }
        
        AddImageCookie.aic().tab = AddImage.Pages.capture
        AddImageCookie.aic().setImage(nil)
    }
    
    //MARK: Subviews
    private func grumbleButton(_ title: String, _ color: Color, action: @escaping () -> Void) -> some View {
        return Button(action: action, label: {
            ZStack(alignment: .leading) {
                color
                
                Text(title)
                    .padding(10)
                    .font(gFont(.ubuntu, .width, 2))
            }.frame(maxWidth: .infinity, maxHeight: grumbleButtonHeight)
            .foregroundColor(Color.white)
            .cornerRadius(8)
            .shadow(color: color.opacity(0.3), radius: 5)
        })
    }
    
    private var listHeader: some View {
        HStack(spacing: nil) {
            Text("Feeling Grumbly?")
                .font(gFont(.ubuntuBold, .width, 4))
                .foregroundColor(Color(white: 0.2))
            
            Spacer()
            
            Button(action: {
                self.showAddImage(isPresented: true, animate: true)
            }, label: {
                ZStack {
                    Text("+ Add")
                        .padding(10)
                        .font(gFont(.ubuntuBold, .width, 1.5))
                        .foregroundColor(gColor(.blue0))
                        .overlay(RoundedRectangle(cornerRadius: 8)
                        .stroke(gColor(.blue0), lineWidth: 2))
                }
            })
        }
    }
    
    private var grumbleButtons: some View {
        HStack(spacing: 10) {
            VStack(spacing: 10) {
                self.grumbleButton("Grumble", gColor(.blue4)) {
                    self.showGrumbleSheet(.grumble)
                }
                
                self.grumbleButton("Orthodox [WIP]", gColor(.dandelion)) {
                    self.showGrumbleSheet(.orthodox)
                }
            }
            
            VStack(spacing: 10) {
                self.grumbleButton("Defiant [WIP]", gColor(.coral)) {
                    self.showGrumbleSheet(.defiant)
                }
                
                self.grumbleButton("Grumbologist [WIP]", gColor(.magenta)) {
                    self.showGrumbleSheet(.grubologist)
                }
            }
        }
    }
    
    private var listContent: some View {
        ScrollView(.vertical) {
            ZStack(alignment: .top) {
                VStack {
                    ZStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 20) {
                            self.listHeader
                                .frame(height: titleHeight)
                            
                            Spacer()
                                .frame(height: searchHeight)
                            
                            self.grumbleButtons
                            
                            Text("My List")
                                .font(gFont(.ubuntuBold, .width, 3))
                                .frame(height: myListTitleHeight)
                                .foregroundColor(Color(white: 0.2))
                        }.padding([.leading, .trailing], 20)
                    }.padding(.top, 20)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 20) {
                            if !self.uc.foodList().isEmpty {
                                ForEach((0 ..< self.uc.foodListByDate().count).reversed(), id: \.self) { index in
                                    GrubItem(self.uc.foodListByDate()[index].1)
                                }
                            } else {
                                Text(self.uc.loadingStatus == .loading ? "Loading..." : "List is Empty!")
                                    .font(gFont(.ubuntu, .width, 2))
                                    .foregroundColor(Color(white: 0.2))
                            }
                            
                            Spacer()
                        }.padding(.leading, 20)
                        .padding(.bottom, 40)
                        .frame(minWidth: sWidth())
                    }.frame(width: sWidth())
                    
                    Spacer()
                }
                
                self.searchList
                    .padding(.top, 20)
            }
        }
    }
    
    public var body: some View {
        ZStack(alignment: .bottom) {
            Color(white: 0.98)
            
            Group {
                self.listContent
                
                TabView()
            }.offset(x: self.presentAddImage ? sWidth() * -0.3 : 0)
            
            ZStack(alignment: .top) {
                Color.clear
                
                gColor(.blue0)
                    .frame(width: sWidth(), height: safeAreaInset(.top))
            }.edgesIgnoringSafeArea(.all)
            
            Color.black.opacity(self.lc.presentGrubSheet() ? maxOverlayOpacity : 0)
            
            if self.presentGrumbleSheet {
                GrumbleSheet(show: self.$presentGrumbleSheet)
                    .transition(.move(edge: .bottom))
                    .zIndex(1)
                    .edgesIgnoringSafeArea(.all)
            }
            
            if self.lc.presentGrubSheet() {
                GrubSheet(self.lc.selectedGrub!)
                    .transition(.move(edge: .bottom))
                    .zIndex(1)
            }
            
            AddImage(present: self.showAddImage)
                .offset(x: self.presentAddImage ? 0 : sWidth())
        }
    }
}

#if DEBUG
struct ListView_Previews: PreviewProvider {
   static var previews: some View {
      Group {
         ContentView()
            .previewDevice(PreviewDevice(rawValue: "iPhone SE"))
            .previewDisplayName("iPhone SE")

         ContentView()
            .previewDevice(PreviewDevice(rawValue: "iPhone XS Max"))
            .previewDisplayName("iPhone XS Max")
      }
   }
}
#endif
