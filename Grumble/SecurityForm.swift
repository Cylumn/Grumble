//
//  SecurityForm.swift
//  Grumble
//
//  Created by Allen Chang on 4/27/20.
//  Copyright © 2020 Cylumn, Inc. All rights reserved.
//

import SwiftUI
import Firebase

private let formID: GFormID = GFormID.security

public struct SecurityForm: View, GFieldDelegate {
    @ObservedObject private var gft: GFormText = GFormText.gft(formID)
    @ObservedObject private var ko: KeyboardObserver = KeyboardObserver.ko(.security)
    private var isPresented: Binding<Bool>
    @State private var state: FormState = .form
    @State private var lockScale: CGFloat = 0
    
    public init(_ isPresented: Binding<Bool>) {
        self.isPresented = isPresented
        
        self.gft.setName(FieldIndex.currentPass.rawValue, "Current Password")
        self.gft.setName(FieldIndex.newPass.rawValue, "New Password")
        self.gft.setName(FieldIndex.confirmPass.rawValue, "Confirm New Password")
    }
    
    private enum FieldIndex: Int {
        case currentPass = 0
        case newPass = 1
        case confirmPass = 2
    }
    
    private enum FormState {
        case form
        case processing
        case success
    }
    
    //Getter Methods
    private func underLineColor(_ index: Int) -> Color {
        var success: Bool = true
        switch index {
        case FieldIndex.currentPass.rawValue:
            if !self.gft.error(index).isEmpty {
                return Color.red
            }
            success = !self.gft.text(index).isEmpty
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
    private func toSettings() {
        withAnimation(gAnim(.easeOut)) {
            self.isPresented.wrappedValue = false
        }
        
        for index in 0 ..< size(formID) {
            self.gft.setText(index, "")
            self.gft.setError(index, "")
        }
        self.state = .form
        self.lockScale = 0
    }
    
    private func submit() {
        if self.state == .form {
            UIApplication.shared.endEditing()
            withAnimation(gAnim(.spring)) {
                self.state = .processing
            }
            
            changePassword(old: self.gft.text(FieldIndex.currentPass.rawValue), new: self.gft.text(FieldIndex.newPass.rawValue)) { error in
                if error == AuthErrorCode.wrongPassword {
                    self.gft.setError(FieldIndex.currentPass.rawValue, "Wrong Password")
                    self.state = .form
                    self.gft.setText(FieldIndex.currentPass.rawValue, "")
                } else if error == AuthErrorCode.weakPassword {
                    self.gft.setError(FieldIndex.newPass.rawValue, "Weak Password")
                    self.state = .form
                    self.gft.setText(FieldIndex.newPass.rawValue, "")
                    self.gft.setText(FieldIndex.confirmPass.rawValue, "")
                } else {
                    self.state = .success
                    Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
                        if self.state == .success {
                            self.lockScale = 1
                        }
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
                })).edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                VStack(spacing: 15) {
                    Text("Change Password")
                        .font(gFont(.ubuntuLight, .width, 2.5))
                        .foregroundColor(Color(white: 0.2))
                    
                    Divider()
                        .hidden()
                    
                    if self.state == .success {
                        Text("Password Changed")
                            .font(gFont(.ubuntuLight, .width, 2))
                            .foregroundColor(Color(white: 0.3))
                        
                        ZStack {
                            Image(systemName: "lock")
                                .foregroundColor(gColor(.blue2))
                                .font(.system(size: sWidth() * 0.25))
                                .scaleEffect(self.lockScale)
                                .animation(gAnim(.springSlow))
                        }.frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
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
                                }
                            }
                        }.font(gFont(.ubuntuLight, .width, 1.8))
                    }
                }.animation(nil)
                .padding(30)
                .frame(height: sHeight() * 0.45)
                .background(Color.white)
                .cornerRadius(20)
                .clipped()
                .shadow(color: Color.black.opacity(0.2), radius: 5)
                
                Spacer().frame(height: 20)
                
                HStack(spacing: 0) {
                    Spacer()
                    if self.state == .form {
                        Button(action: self.toSettings, label: {
                            Text("Cancel")
                                .padding(10)
                        }).foregroundColor(gColor(.blue0))
                        .font(gFont(.ubuntuLight, .width, 2))
                        Spacer()
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
                    } else if self.state == .processing {
                        Text("...")
                            .foregroundColor(Color(white: 0.7))
                            .font(gFont(.ubuntuBold, .width, 3))
                        Spacer()
                    } else if self.state == .success {
                        Button(action: self.toSettings, label: {
                            Text("Back")
                                .padding(10)
                                .padding([.leading, .trailing], 30)
                                .font(gFont(.ubuntuBold, .width, 2.5))
                                .background(gColor(.blue2))
                                .foregroundColor(Color.white)
                                .cornerRadius(10)
                        })
                        Spacer()
                    }
                }.frame(height: sWidth() * 2.5 / 50 + 20)
                Spacer().frame(height: 60 + self.ko.height())
            }.frame(width: sWidth() * 0.75)
        }
    }
}

struct SecurityForm_Previews: PreviewProvider {
    static var previews: some View {
        SecurityForm(Binding.constant(true))
    }
}
