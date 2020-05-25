//
//  GrumbleHideModal.swift
//  Grumble
//
//  Created by Allen Chang on 5/24/20.
//  Copyright © 2020 Cylumn, Inc. All rights reserved.
//

import SwiftUI

public struct GrumbleHideModal: View {
    @ObservedObject private var gc: GrumbleCookie = GrumbleCookie.gc()
    @ObservedObject private var ggc: GrumbleGrubCookie = GrumbleGrubCookie.ggc()
    private var hideSheet: () -> Void
    
    public init(_ hideSheet: @escaping () -> Void) {
        self.hideSheet = hideSheet
    }
    
    private func completeGrubSheet() {
        if self.gc.listCount() > 0 && !self.gc.grub()!.immutable {
            Grub.removeFood(self.gc.grub()!.fid)
        }
        self.hideSheet()
    }
    
    public var body: some View {
        ZStack {
            if self.gc.presentHideModal == PresentHideModal.shown {
                ZStack(alignment: .bottom) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white)
                        .frame(maxWidth: .infinity)
                    
                    ZStack(alignment: .top) {
                        Color.clear
                        
                        VStack(alignment: .center, spacing: 10) {
                            if self.gc.listCount() > 0 {
                                Text("Enjoy Your")
                                
                                Text(self.gc.grub()?.food ?? "")
                                    .multilineTextAlignment(.center)
                            } else {
                                Text("Empty Stomach!")
                                
                                Spacer().frame(height: 10)
                                
                                Text("Your ghorblin needs more virtual grub...")
                                    .font(gFont(.ubuntuLight, .width, 2.5))
                                    .multilineTextAlignment(.center)
                            }
                        }.font(gFont(.ubuntuLight, .width, 3.5))
                        .foregroundColor(Color(white: 0.2))
                        .padding(.top, 30)
                        .padding(20)
                    }
                    
                    Button(action: self.completeGrubSheet, label: {
                        Text(self.gc.listCount() > 0 ? "Directions" : "Back")
                            .padding(5)
                            .padding([.leading, .trailing], 10)
                            .background(gColor(.blue0))
                            .font(gFont(.ubuntuBold, .width, 2.5))
                            .foregroundColor(Color.white)
                            .cornerRadius(20)
                    }).padding(.bottom, 20)
                }.padding([.leading, .trailing], 50)
                .frame(height: 400)
            } else if self.gc.presentHideModal == PresentHideModal.hidden && !self.ggc.expandedInfo {
                Button(action: self.hideSheet, label: {
                    Image(systemName: "chevron.down.circle.fill")
                        .padding(25)
                        .foregroundColor(self.gc.coverDragState == .covered || self.gc.coverDragState == .cancelled ? Color.black.opacity(0.5) : Color.white.opacity(0.8))
                        .font(.system(size: 30))
                }).offset(y: 20)
            }
        }
    }
}

struct GrumbleHideModal_Previews: PreviewProvider {
    static var previews: some View {
        GrumbleHideModal({})
    }
}
