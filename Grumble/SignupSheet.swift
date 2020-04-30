//
//  SignupSheet.swift
//  Grumble
//
//  Created by Allen Chang on 3/29/20.
//  Copyright © 2020 Cylumn, Inc. All rights reserved.
//

import SwiftUI
import Firebase

private let formID: GFormID = GFormID.signup
public let minPasswordLength: Int = 6

public func parsePassword(_ text: String, _ toBeAdded: String) -> String {
    return cut(text + trim(toBeAdded), maxLength: 20)
}

public struct SignupSheet: View, GFieldDelegate {
    private var currentHeight: Binding<CGFloat>
    private var movingOffset: Binding<CGFloat>
    private var onDragStateChanged: (SheetPosition) -> ()
    
    @ObservedObject private var gft: GFormText = GFormText.gft(formID)
    @State private var state: PanelIndex = PanelIndex.first
    @State private var processing: Bool = false
    private var login: (String, String) -> Void
    
    //Initializer
    public init(currentHeight: Binding<CGFloat>, movingOffset: Binding<CGFloat>, onDragStateChanged: @escaping (SheetPosition) -> (), login: @escaping (String, String) -> Void) {
        self.currentHeight = currentHeight
        self.movingOffset = movingOffset
        self.onDragStateChanged = onDragStateChanged
        
        self.login = login

        GFormText.gft(formID).setNames(["Email", "Password", "Confirm Password", "Full Name", "Username"])
    }
    
    //Signup Enums
    private enum PanelIndex {
        case first
        case final
    }
    
    private enum FieldIndex: Int {
        case email = 0
        case password = 1
        case confPass = 2
        case name = 3
        case username = 4
    }
    
    //Getter Methods
    private func underlineColor(_ index: Int) -> Color {
        let success = !self.gft.text(index).isEmpty && self.gft.error(index).isEmpty && self.gft.symbol(index).isEmpty
        return success ? gColor(.blue0) : Color(white: 0.7)
    }
    
    private func canProceed(_ first: Int, _ last: Int) -> Bool {
        for index in first ... last {
            if self.gft.text(index).isEmpty || !self.gft.error(index).isEmpty || !self.gft.symbol(index).isEmpty {
                return false
            }
        }
        return true
    }
    
    //Function Methods
    private func toFirstPanel() {
        if state == .final {
            GFormRouter.gfr().setIndex(formID, FieldIndex.email.rawValue)
            GFormRouter.gfr().callCurrentResponder(formID)
            withAnimation(gAnim(.easeOut)) {
                self.state = .first
            }
        }
    }
    
    private func toFinalPanel() {
        if state == .first {
            GFormRouter.gfr().setIndex(formID, FieldIndex.name.rawValue)
            GFormRouter.gfr().callCurrentResponder(formID)
            withAnimation(gAnim(.easeOut)) {
                self.state = .final
            }
        }
    }
    
    private func submit() {
        withAnimation(gAnim(.spring)) {
            self.processing = true
        }
        
        let email = self.gft.text(FieldIndex.email.rawValue)
        let pass = self.gft.text(FieldIndex.password.rawValue)
        createAccount(email: email, pass: pass, displayName: self.gft.text(FieldIndex.username.rawValue)) { error in
            if let error = error {
                switch error.code {
                    case AuthErrorCode.invalidEmail.rawValue:
                        GFormText.gft(formID).setError(FieldIndex.email.rawValue, "Invalid Email")
                    case AuthErrorCode.emailAlreadyInUse.rawValue:
                        GFormText.gft(formID).setError(FieldIndex.email.rawValue, "Email Already in Use")
                    case AuthErrorCode.weakPassword.rawValue:
                        GFormText.gft(formID).setError(FieldIndex.password.rawValue, "Weak Password")
                    default:
                        GFormText.gft(formID).setError(FieldIndex.email.rawValue, "Unknown Error")
                }
                withAnimation(gAnim(.spring)) {
                    self.processing = false
                }
                self.toFirstPanel()
                return
            }
            
            if KeyboardObserver.ko(formID).visible() {
                UIApplication.shared.endEditing()
            }
            self.login(email, pass)
            
            Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { _ in
                self.processing = false
                for index in 0 ..< size(formID) {
                    self.gft.setText(index, "")
                    self.gft.setError(index, "")
                    self.gft.setSymbol(index, "")
                }
            }
        }
    }
    
    private func calcError(_ index: Int, _ updatedText: String) {
        self.gft.setText(index, updatedText)
        for i in 0 ..< size(formID) {
            let text: String = self.gft.text(i)
            switch i {
                case FieldIndex.email.rawValue:
                    self.gft.setError(i, "")
                    Auth.auth().fetchSignInMethods(forEmail: text, completion: { (providers, error) in
                        if error == nil {
                            self.gft.setSymbol(i, "")
                        } else {
                            self.gft.setSymbol(i, "Invalid Email")
                        }
                    })
                case FieldIndex.password.rawValue:
                    if !text.isEmpty && text.count < minPasswordLength {
                        self.gft.setError(i, "Password Is Too Short")
                    } else {
                        self.gft.setError(i, "")
                    }
                case FieldIndex.confPass.rawValue:
                    if self.gft.text(FieldIndex.password.rawValue) != text {
                        self.gft.setSymbol(i, "Passwords Must Match")
                    } else {
                        self.gft.setSymbol(i, "")
                    }
                case FieldIndex.name.rawValue:
                    //errorField.wrappedValue = "Bad Name"
                    self.gft.setError(i, "")
                case FieldIndex.username.rawValue:
                    //errorField.wrappedValue = "Bad Username"
                    self.gft.setError(i, "")
                default:
                    self.gft.setError(i, "Error")
            }
        }
    }
    
    public func style(_ index: Int, _ textField: GTextField, _ placeholderText: @escaping (String) -> Void) {
        textField.setInsets(top: 5, left: 0, bottom: 5, right: 0)
        switch index {
            case FieldIndex.email.rawValue:
                textField.textContentType = .newPassword
            case FieldIndex.password.rawValue, FieldIndex.confPass.rawValue:
                textField.textContentType = .newPassword
                textField.isSecureTextEntry = true
            case FieldIndex.name.rawValue:
                textField.textContentType = .name
            case FieldIndex.username.rawValue:
                textField.textContentType = .nickname
                textField.returnKeyType = .continue
            default:
                textField.textContentType = .none
        }
    }
    
    public func proceedField() -> Bool {
        let index = GFormRouter.gfr().index(formID)
        if index == FieldIndex.confPass.rawValue {
            if self.canProceed(FieldIndex.email.rawValue, index) {
                self.toFinalPanel()
            }
            return false
        } else if index == FieldIndex.username.rawValue {
            if self.canProceed(FieldIndex.email.rawValue, index) {
                self.submit()
            }
            return false
        }
        return GFormRouter.gfr().callNextResponder(formID)
    }
    
    public func parseInput(_ index: Int, _ textField: UITextField, _ string: String) -> String {
        var text = textField.text!
        var string = string
        switch index {
            case FieldIndex.email.rawValue:
                string = removeSpecialChars(string, allow: "@!.")
            case FieldIndex.password.rawValue, FieldIndex.confPass.rawValue:
                text = parsePassword(text, string)
                calcError(index, text)
                return text
            default:
                string = removeSpecialChars(string)
        }
        text += smartCase(text, appendInput: string)
        switch index {
            case FieldIndex.name.rawValue:
                text = trim(text, allowSingleChars: true)
            default:
                text = trim(text)
        }
        switch index {
            case FieldIndex.email.rawValue:
                text = text.lowercased()
                text = cut(text, maxLength: 30)
            default:
                text = cut(text, maxLength: 15)
        }
        
        self.calcError(index, text)
        return text
    }
    
    private func form(_ first: Int, _ last: Int) -> some View {
        VStack(spacing: 20) {
            ForEach(first ... last, id: \.self) { index in
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        Text(self.gft.name(index)).foregroundColor(Color(white: 0.3))
                        Spacer()
                        Text(self.gft.error(index)).foregroundColor(gColor(.blue4))
                    }.font(gFont(.ubuntuLight, .width, 2))
                    ZStack(alignment: .bottom) {
                        Rectangle()
                            .fill(self.underlineColor(index))
                            .animation(gAnim(.spring))
                            .frame(height:2)
                        GField(formID, index, self)
                    }.foregroundColor(Color(white: 0.5))
                }.frame(height: 45)
            }
            Spacer()
        }.frame(height: 175)
    }
    
    private func proceedButton(action: @escaping () -> Void, text: String, disabled: Bool) -> some View {
        Button(action: action, label: {
            Text("Next")
                .padding(15)
                .frame(maxWidth: .infinity)
                .background(disabled ? Color(white: 0.7) : gColor(.blue0))
                .animation(gAnim(.spring))
                .cornerRadius(10)
                .foregroundColor(Color.white)
                .font(gFont(.ubuntuBold, .width, 2.5))
        }).disabled(disabled)
    }
    
    private var firstPanel: some View {
        let first = FieldIndex.email.rawValue
        let last = FieldIndex.confPass.rawValue
        return VStack(spacing: 20) {
            self.form(first, last)
            self.proceedButton(action: self.toFinalPanel, text: "Next", disabled: !self.canProceed(first, last))
        }.frame(width: sWidth() * 0.85)
    }
    
    private var finalPanel: some View {
        let last = FieldIndex.username.rawValue
        return VStack(spacing: 20) {
            self.form(FieldIndex.name.rawValue, last)
            HStack {
                Spacer()
                if self.processing {
                    Text("...")
                        .foregroundColor(Color(white: 0.7))
                        .font(gFont(.ubuntuBold, .width, 3))
                    Spacer()
                } else {
                    Button(action: self.toFirstPanel, label: {
                        Text("Back")
                            .padding(10)
                    }).foregroundColor(gColor(.blue0))
                    .font(gFont(.ubuntuLight, .width, 2))
                    Spacer()
                    self.proceedButton(action: self.submit, text: "Submit", disabled: !self.canProceed(FieldIndex.email.rawValue, last))
                        .frame(width: sWidth() * 0.55)
                }
            }.frame(height: sWidth() * 2 / 50 + 10)
        }.frame(width: sWidth() * 0.85)
    }
    
    public var body: some View {
        SheetView(currentHeight: self.currentHeight, movingOffset: self.movingOffset, onDragStateChanged: self.onDragStateChanged) {
            VStack(spacing: 15) {
                Rectangle()
                    .frame(width: 80, height: 7)
                    .cornerRadius(5)
                    .foregroundColor(Color(white: 0.8))
                
                VStack(spacing: 5) {
                    Text("New User?")
                        .font(gFont(.ubuntuBold, .width, 3))
                        .foregroundColor(gColor(.blue0))
                    Text("Create Account")
                        .font(gFont(.ubuntuMedium, .width, 1.5))
                        .foregroundColor(Color(white: 0.4))
                }
                
                ZStack {
                    self.firstPanel
                        .offset(x: self.state == .first ? 0 : -sWidth())
                    
                    self.finalPanel
                        .offset(x: self.state == .final ? 0 : sWidth())
                }
                
                Spacer()
            }.padding(.top, 15)
            .padding(.bottom, isX() ? 60 : 50)
            .frame(width: sWidth(), height: sHeight())
        }
    }
}

struct SignupSheet_Previews: PreviewProvider {
    static var previews: some View {
        SignupSheet(currentHeight: Binding.constant(0), movingOffset: Binding.constant(0), onDragStateChanged: {_ in}, login: {email, pass in})
    }
}
