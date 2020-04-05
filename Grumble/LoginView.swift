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
    @ObservedObject private var ko: KeyboardObserver = KeyboardObserver.ko()
    @ObservedObject private var gft: GFormText = GFormText.gft(formID)
    
    @State private var currentHeight: CGFloat = sHeight()
    @State private var movingOffset: CGFloat = sHeight()
    
    //Initializer
    public init() {
        self.ko.appendField(.login)
        self.gft.setError(FieldIndex.email.rawValue, " ")
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
            
            self.ko.removeField(.login)
            self.ko.appendField(.signup, true)
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
        textField.setInsets(top: 15, left: 15, bottom: 15, right: 15)
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
        self.gft.setError(FieldIndex.email.rawValue, " ")
        return textField.text! + string
    }
 
    public var body: some View {
        ZStack{
            Image("Background")
            .resizable()
            .edgesIgnoringSafeArea(.all)
            .gesture(DragGesture().onChanged(){_ in
                UIApplication.shared.endEditing()
            })
            
            VStack{
                VStack(spacing: sHeight() / (self.ko.visible(.login) ? 40: 25)){
                    if self.ko.visible(.login) {
                        Spacer().frame(height: sHeight() * 0.05)
                    } else {
                        Image("Logo")
                            .resizable()
                            .frame(width: 80, height: 80)
                    }
                    
                    Text("Grumble")
                        .font(.custom("Ubuntu-Bold", size: sHeight() / 17))
                        .fontWeight(.bold)
                        .foregroundColor(Color.white)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                }.padding(.top, sHeight() / (self.ko.visible(.login) ? 40: 15))
                
                if !self.ko.visible(.login) {
                    Spacer()
                
                    HStack{
                        Button(action: self.attemptSignup, label: {
                            Text("Sign Up")
                                .padding(15)
                                .font(.custom("Ubuntu-Medium", size: sWidth() / 22))
                                .foregroundColor(Color(red: 1, green: 1, blue: 1, opacity: 1))
                                .overlay(RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(red: 1, green: 1, blue: 1, opacity: 1), lineWidth: 1))
                        })
                        
                        Spacer()
                        
                        Button(action: self.attemptLoginGoogle, label: {
                            HStack{
                                Image("GoogleIcon")
                                    .frame(width: sWidth() / 22, height: sWidth() / 22)
                                Text("Log in with Google")
                                    .font(.custom("Ubuntu-Bold", size: sWidth() / 22))
                                    .foregroundColor(Color.gray)
                                .lineLimit(1)
                            }
                        })
                            .padding(EdgeInsets(top: 15, leading: sWidth() / 30, bottom: 15, trailing: sWidth() / 30))
                            .background(Color.white)
                            .cornerRadius(8.0)
                            .buttonStyle(PlainButtonStyle())
                    }.frame(width: sWidth() * 0.85)
                } else {
                    Spacer().frame(height: sHeight() / (self.ko.visible(.login) ? 40 : 20))
                }
                
                HStack{
                    Text(self.gft.error(FieldIndex.email.rawValue))
                        .frame(height: sWidth() / 22)
                        .padding(3)
                        .foregroundColor(gColor(.lightTurquoise))
                        .font(.custom("Teko-SemiBold", size: sWidth() / 22))
                    
                    Spacer()
                }.frame(height: sWidth() / 30)
                .offset(y: self.ko.visible(.login) ? 10 : 5)
                
                VStack(spacing: sHeight() / (self.ko.visible(.login) ? 60 : 40)){
                    ZStack(alignment: .leading) {
                        if self.gft.text(FieldIndex.email.rawValue).isEmpty {
                            Text("Email")
                                .foregroundColor(Color(red: 1, green: 1, blue: 1, opacity: 0.7))
                                .padding(15)
                                .font(.custom("Ubuntu-Light", size: sWidth() / 22))
                        }
                        GField(formID, FieldIndex.email.rawValue, self).frame(width: sWidth() * 0.85, height: 50)
                    }.background(gColor(.lightTurquoise).opacity(0.7))
                    .cornerRadius(8)
                    
                    ZStack(alignment: .leading) {
                        if self.gft.text(FieldIndex.password.rawValue).isEmpty {
                            Text("Password")
                                .foregroundColor(Color(red: 1, green: 1, blue: 1, opacity: 0.7))
                                .padding(15)
                                .font(.custom("Ubuntu-Light", size: sWidth() / 22))
                        }
                        GField(formID, FieldIndex.password.rawValue, self).frame(width: sWidth() * 0.85, height: 50)
                    }.background(gColor(.lightTurquoise).opacity(0.7))
                    .cornerRadius(8)
                    
                    UserButton(action: self.attemptLogin, disabled: !self.canSubmit(), text: "Log In")
                }
                
                Spacer().frame(height: sHeight() / 50)
                
                Button(action: self.forgotPassword, label: {
                    Text("Forgot Password? [wip]")
                        .padding(5)
                        .font(.custom("Ubuntu-Medium", size: sWidth() / 22))
                        .foregroundColor(Color.white)
                })
                
                if self.ko.visible(.login) {
                    Spacer().frame(height: self.ko.height(.login))
                } else {
                    Spacer().frame(height: sHeight() / 30)
                }
            }.padding(sHeight() / 25)
            
            SignupSheetView(currentHeight: self.$currentHeight, movingOffset: self.$movingOffset, onDragEnd: { pos in
                if pos == .down {
                    UIApplication.shared.endEditing()
                    self.ko.removeField(.signup)
                    self.ko.appendField(.login, false)
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
