//
//  LoginView.swift
//  Grumble
//
//  Created by Allen Chang on 3/20/20.
//  Copyright © 2020 Cylumn, Inc. All rights reserved.
//

import SwiftUI
import GoogleSignIn
import Firebase

private let formID: GFormID = GFormID.login

public struct LoginView: View, GFieldDelegate {
    @ObservedObject private var ko: KeyboardObserver = KeyboardObserver.ko(formID)
    @ObservedObject private var gft: GFormText = GFormText.gft(formID)
    
    @State private var currentHeight: CGFloat = sHeight()
    @State private var movingOffset: CGFloat = sHeight()
    
    //Initializer
    public init() {
        KeyboardObserver.appendField(.login)
        self.gft.setName(FieldIndex.email.rawValue, "Email")
        self.gft.setName(FieldIndex.password.rawValue, "Password")
    }
    
    private enum FieldIndex: Int {
        case email = 0
        case password = 1
    }
    
    //Getter Methods
    private func canSubmit() -> Bool {
        return !self.gft.text(FieldIndex.email.rawValue).isEmpty && !self.gft.text(FieldIndex.password.rawValue).isEmpty
    }
    
    //Function Methods
    private func forgotPassword() {
        
    }
    
    private func attemptSignup() {
        withAnimation(gAnim(.spring)) {
            self.$movingOffset.wrappedValue = 0
            self.$currentHeight.wrappedValue = 0
            
            KeyboardObserver.removeField(.login)
            KeyboardObserver.appendField(.signup, true)
            GFormRouter.gfr().callCurrentResponder(.signup)
        }
    }
    
    public func attemptLogin(email: String, pass: String) {
        Auth.auth().signIn(withEmail: email, password: pass) { authResult, error in
            if let error = error as NSError? {
                switch error.code {
                    case AuthErrorCode.invalidEmail.rawValue:
                        self.gft.setError(FieldIndex.email.rawValue, "Invalid Email")
                    default:
                        self.gft.setError(FieldIndex.email.rawValue, "Incorrect Password")
                }
                return
            }
            onLogin()
        }
    }
    
    private func attemptLogin() {
        attemptLogin(email: self.gft.text(FieldIndex.email.rawValue), pass: self.gft.text(FieldIndex.password.rawValue))
    }
    
    private func attemptLoginGoogle() {
        GIDSignIn.sharedInstance()?.signIn()
    }
    
    //GFieldDelegate Implementation Methods
    public func style(_ index: Int, _ textField: GTextField) {
        textField.backgroundColor = gColor(.lightTurquoise).withAlphaComponent(0.5)
        textField.setInsets(top: 10, left: 13, bottom: 10, right: 13)
        textField.attributedPlaceholder = NSAttributedString(string: self.gft.name(index), attributes: [NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(0.8)])
        textField.font = gFont(.ubuntuLight, .width, 2.5)
        textField.textColor = UIColor.white
        textField.textContentType = .newPassword
        if index == FieldIndex.password.rawValue {
            textField.isSecureTextEntry = true
            textField.returnKeyType = .continue
        }
    }
    
    public func proceedField() -> Bool {
        switch GFormRouter.gfr().index(formID) {
            case FieldIndex.email.rawValue:
                return GFormRouter.gfr().callNextResponder(formID)
            case FieldIndex.password.rawValue:
                attemptLogin()
                return false
            default:
                return false
        }
    }
    
    public func parseInput(_ index: Int, _ textField: UITextField, _ string: String) -> String {
        self.gft.setError(FieldIndex.email.rawValue, "")
        return textField.text! + string
    }
 
    public var body: some View {
        ZStack {
            gGradient()
                .edgesIgnoringSafeArea(.all)
                .gesture(DragGesture().onChanged() { _ in
                    UIApplication.shared.endEditing()
                })
            
            VStack(spacing: sHeight() * 0.03) {
                Spacer().frame(height: sHeight() * (self.ko.visible() ? 0.07 : 0.05))
                
                VStack(spacing: 0){
                    if !self.ko.visible() {
                        Image("Logo")
                            .resizable()
                            .frame(width: 80, height: 80)
                        Spacer().frame(height: sHeight() * 0.04)
                    }
                    Text("Grumble")
                        .font(gFont(.ubuntuBold, .height, 3))
                }
                
                Spacer()
                
                if !self.ko.visible() {
                    HStack(spacing: nil) {
                        Button(action: self.attemptSignup, label: {
                            Text("Sign Up")
                                .padding(13)
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.white, lineWidth: 1))
                                .font(gFont(.ubuntuMedium, .width, 2))
                        }).background(gColor(.blue2))
                        
                        Spacer()
                        
                        Button(action: self.attemptLoginGoogle, label: {
                            HStack(spacing: 15) {
                                Image("GoogleIcon")
                                    .frame(width: sWidth() * 0.04, height: sWidth() * 0.04)
                                Text("Login with Google")
                                    .font(gFont(.ubuntuBold, .width, 2))
                                    .foregroundColor(Color.gray)
                                    .lineLimit(1)
                            }
                        }).padding(13)
                        .background(Color.white)
                        .cornerRadius(8)
                        .buttonStyle(PlainButtonStyle())
                    }
                }

                VStack(spacing: sHeight() * 0.02) {
                    VStack(spacing: sHeight() * 0.01) {
                        HStack(spacing: nil) {
                            Text(self.gft.error(FieldIndex.email.rawValue))
                                .padding(3)
                                .foregroundColor(gColor(.lightTurquoise))
                                .font(gFont(.tekoSemiBold, .width, 2.5))
                                .animation(gAnim(.spring))
                            
                            Spacer()
                        }.frame(height: sHeight() * 0.02)
                        
                        GField(formID, FieldIndex.email.rawValue, self)
                            .frame(height: 48)
                            .cornerRadius(8)
                    }
                    
                    GField(formID, FieldIndex.password.rawValue, self)
                        .frame(height: 48)
                        .cornerRadius(8)
                    
                    VStack(spacing: sHeight() * 0.02) {
                        UserButton(action: self.attemptLogin, disabled: !self.canSubmit(), text: "Log In")
                        
                        Button(action: self.forgotPassword, label: {
                            Text("Forgot Password? [wip]")
                                .padding(5)
                                .font(gFont(.ubuntuMedium, .width, 2.5))
                        })
                    }
                }
                
                Spacer().frame(height: self.ko.height(tabbedView: false) + sHeight() * (self.ko.visible() ? 0.01 : 0.04))
            }.frame(width: sWidth() * 0.85)
            .foregroundColor(Color.white)
            
            SignupSheetView(currentHeight: self.$currentHeight, movingOffset: self.$movingOffset, onDragStateChanged: { pos in
                switch pos {
                    case .up:
                        KeyboardObserver.removeField(.login)
                        KeyboardObserver.appendField(.signup, true)
                        GFormRouter.gfr().callCurrentResponder(.signup)
                    case .down:
                        UIApplication.shared.endEditing()
                        KeyboardObserver.removeField(.signup)
                        KeyboardObserver.appendField(.login, false)
                }
            }, login: self.attemptLogin)
        }
    }
}

#if DEBUG
struct LoginView_Previews: PreviewProvider {
   static var previews: some View {
      Group {
         MainView()
            .previewDevice(PreviewDevice(rawValue: "iPhone SE"))
            .previewDisplayName("iPhone SE")

         MainView()
            .previewDevice(PreviewDevice(rawValue: "iPhone XS Max"))
            .previewDisplayName("iPhone XS Max")
      }
   }
}
#endif
