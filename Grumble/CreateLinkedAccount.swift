//
//  CreateLinkedAccount.swift
//  Grumble
//
//  Created by Allen Chang on 4/30/20.
//  Copyright © 2020 Cylumn, Inc. All rights reserved.
//

import SwiftUI
import Firebase

private let formID: GFormID = GFormID.createPass

public struct CreateLinkedAccount: View, GFieldDelegate {
    @ObservedObject private var gft: GFormText = GFormText.gft(formID)
    @ObservedObject private var ko: KeyboardObserver = KeyboardObserver.ko(formID)
    @State private var processing: Bool = false
    
    public init() {
        self.gft.setName(FieldIndex.newPass.rawValue, "New Password")
        self.gft.setName(FieldIndex.confirmPass.rawValue, "Confirm New Password")
    }
    
    private enum FieldIndex: Int {
        case newPass = 0
        case confirmPass = 1
    }
    
    //Getter Methods
    private func underLineColor(_ index: Int) -> Color {
        var success: Bool = true
        switch index {
        case FieldIndex.newPass.rawValue:
            if !self.gft.error(index).isEmpty {
                return Color.red
            }
            success = self.gft.text(index).count >= minPasswordLength
        default:
            let text = self.gft.text(index)
            success = text.count >= minPasswordLength && text == self.gft.text(FieldIndex.newPass.rawValue)
        }
        
        return success ? gColor(.blue0) : Color(white: 0.8)
    }
    
    private func canSubmit() -> Bool {
        for index in 0 ..< size(formID) {
            if self.gft.text(index).isEmpty {
                return false
            }
        }
        
        let newPassword = self.gft.text(FieldIndex.newPass.rawValue)
        if newPassword.count < minPasswordLength || newPassword != self.gft.text(FieldIndex.confirmPass.rawValue) {
            return false
        }
        
        return true
    }
    
    //Function Methods
    private func submit() {
        if !self.processing {
            UIApplication.shared.endEditing()
            withAnimation(gAnim(.spring)) {
                self.processing = true
            }
            
            changePassword(old: UserCookie.uc().accountLinkToken()!, new: self.gft.text(FieldIndex.newPass.rawValue)) { error in
                if error == AuthErrorCode.weakPassword {
                    self.gft.setError(FieldIndex.newPass.rawValue, "Weak Password")
                    self.processing = false
                    self.gft.setText(FieldIndex.newPass.rawValue, "")
                    self.gft.setText(FieldIndex.confirmPass.rawValue, "")
                } else {
                    UserCookie.uc().setLinkToken(nil)
                    writeLocalData(DataListKeys.linkToken, nil)
                    writeCloudData(DataListKeys.linkToken, nil)
                    
                    Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { _ in
                        self.processing = false
                    }
                }
            }
        }
    }
    
    //Implemented GFieldDelegate Methods
    public func style(_ index: Int, _ textField: GTextField, _ placeholderText: @escaping (String) -> Void) {
        textField.setInsets(top: 0, left: 0, bottom: 0, right: 0)
        textField.textContentType = .oneTimeCode
        textField.isSecureTextEntry = true
        if index == FieldIndex.confirmPass.rawValue {
            textField.returnKeyType = .continue
        }
    }
    
    public func proceedField() -> Bool {
        switch GFormRouter.gfr().index(formID) {
        case FieldIndex.confirmPass.rawValue:
            if canSubmit() {
                submit()
            }
            return false
        default:
            return GFormRouter.gfr().callNextResponder(formID)
        }
    }
    
    public func parseInput(_ index: Int, _ textField: UITextField, _ string: String) -> String {
        self.gft.setError(index, "")
        return parsePassword(textField.text!, string)
    }
    
    public var body: some View {
        ZStack {
            Color(white: 0.98)
                .onTapGesture {
                    UIApplication.shared.endEditing()
                }.gesture(DragGesture().onChanged({ drag in
                    if self.ko.visible() && drag.translation.height > 0 {
                        UIApplication.shared.endEditing()
                    }
                })).edgesIgnoringSafeArea(.bottom)
            
            VStack(spacing: 0) {
                VStack(spacing: 15) {
                    Text("Create Password")
                        .font(gFont(.ubuntuLight, .width, 2.5))
                        .foregroundColor(Color(white: 0.2))
                    
                    Text("This password will be associated with your new Grumble account. You'll still be able to login with Google.")
                        .font(gFont(.ubuntuLight, .width, 1.5))
                        .foregroundColor(Color(white: 0.3))
                        .multilineTextAlignment(.center)
                    
                    Divider()
                        .hidden()
                    
                    ForEach(0 ..< size(formID), id: \.self) { index in
                        VStack(alignment: .leading, spacing: 5) {
                            Text(self.gft.name(index))
                                .foregroundColor(Color(white: 0.3))
                            
                            ZStack(alignment: .bottomLeading) {
                                GField(formID, index, self)
                            
                                Rectangle()
                                    .fill(self.underLineColor(index))
                                    .animation(gAnim(.spring))
                                    .frame(height: 3)
                                
                                ZStack(alignment: .leading) {
                                    Color.clear
                                    
                                    Text(self.gft.error(index))
                                        .foregroundColor(Color.red.opacity(0.8))
                                        .font(gFont(.ubuntu, .width, 2))
                                }
                            }.frame(height: 35)
                        }
                    }.font(gFont(.ubuntuLight, .width, 1.8))
                }.padding([.top, .bottom], 30)
                
                Spacer().frame(height: 20)
                
                HStack(spacing: 0) {
                    if self.processing {
                        Text("...")
                            .foregroundColor(Color(white: 0.7))
                            .font(gFont(.ubuntuBold, .width, 3))
                    } else {
                        Button(action: self.submit, label: {
                            Text("Confirm")
                                .padding(10)
                                .padding([.leading, .trailing], 30)
                                .font(gFont(.ubuntuBold, .width, 2.5))
                                .lineLimit(1)
                                .background(self.canSubmit() ? gColor(.blue2) : Color(white: 0.8))
                                .animation(gAnim(.spring))
                                .foregroundColor(Color.white)
                                .cornerRadius(10)
                        }).disabled(!self.canSubmit())
                    }
                }.frame(height: sWidth() * 2.5 / 50 + 20)
                Spacer().frame(height: 60 + self.ko.height())
            }.frame(width: sWidth() * 0.8)
        }
    }
}

struct CreateLinkedAccount_Previews: PreviewProvider {
    static var previews: some View {
        CreateLinkedAccount()
    }
}
