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

struct LoginView: View {
    @ObservedObject private var ko = KeyboardObserver.ko()
    @State private var email: String = ""
    @State private var pass: String = ""
    private var geometry: GeometryProxy
    @State private var loginError: String = " "
    @State private var errorColor: Color = gColor(.lightTurquoise)
    
    @State private var currentHeight: CGFloat = sHeight()
    @State private var movingOffset: CGFloat = sHeight()
    
    init(_ geometry: GeometryProxy){
        self.geometry = geometry
        
        self.ko.appendField(.login)
    }
 
    var body: some View {
        ZStack{
            Image("Background")
            .resizable()
            .edgesIgnoringSafeArea(.all)
            .gesture(DragGesture().onChanged(){_ in
                UIApplication.shared.endEditing()
            })
            
            VStack{
                VStack(spacing: self.geometry.size.height / (self.ko.visible(.login) ? 40: 25)){
                    if self.ko.visible(.login) {
                        Spacer().frame(height: self.geometry.size.height * 0.05)
                    } else {
                        Image("Logo")
                            .resizable()
                            .frame(width: 80, height: 80)
                    }
                    
                    Text("Grumble")
                        .font(.custom("Ubuntu-Bold", size: self.geometry.size.height / 17))
                        .fontWeight(.bold)
                        .foregroundColor(Color.white)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                }.padding(.top, self.geometry.size.height / (self.ko.visible(.login) ? 40: 15))
                
                if !self.ko.visible(.login) {
                    Spacer()
                
                    HStack{
                        Button(action: self.attemptSignup, label: {
                            Text("Sign Up")
                                .padding(15)
                                .font(.custom("Ubuntu-Medium", size: self.geometry.size.width / 22))
                                .foregroundColor(Color(red: 1, green: 1, blue: 1, opacity: 1))
                                .overlay(RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(red: 1, green: 1, blue: 1, opacity: 1), lineWidth: 1))
                        })
                        
                        Spacer()
                        
                        Button(action: self.attemptLoginGoogle, label: {
                            HStack{
                                Image("GoogleIcon")
                                    .frame(width: self.geometry.size.width / 22, height: self.geometry.size.width / 22)
                                Text("Log in with Google")
                                    .font(.custom("Ubuntu-Bold", size: self.geometry.size.width / 22))
                                    .foregroundColor(Color.gray)
                                .lineLimit(1)
                            }
                        })
                            .padding(EdgeInsets(top: 15, leading: self.geometry.size.width / 30, bottom: 15, trailing: self.geometry.size.width / 30))
                            .background(Color.white)
                            .cornerRadius(8.0)
                            .buttonStyle(PlainButtonStyle())
                    }.frame(width: self.geometry.size.width * 0.85)
                } else {
                    Spacer().frame(height: self.geometry.size.height / (self.ko.visible(.login) ? 40 : 20))
                }
                
                HStack{
                    Text(self.loginError)
                        .padding(3)
                        .foregroundColor(self.errorColor)
                        .font(.custom("Teko-SemiBold", size: self.geometry.size.width / 22))
                    
                    Spacer()
                }.frame(height: self.geometry.size.width / 30)
                .offset(y: self.ko.visible(.login) ? 10 : 5)
                
                VStack(spacing: self.geometry.size.height / (self.ko.visible(.login) ? 60 : 40)){
                    ZStack(alignment: .leading) {
                        if self.email.isEmpty {
                            Text("Email")
                                .foregroundColor(Color(red: 1, green: 1, blue: 1, opacity: 0.7))
                                .padding(15)
                                .font(.custom("Ubuntu-Light", size: self.geometry.size.width / 22))
                        }
                        TextField("", text: Binding<String>(get:{
                            self.email
                        }, set: {
                            self.loginError = " "
                            self.email = $0
                        }))
                            .textContentType(.oneTimeCode)
                            .padding(15)
                            .frame(width: self.geometry.size.width * 0.85)
                            .font(.custom("Ubuntu-Light", size: self.geometry.size.width / 22))
                            .foregroundColor(Color.white)
                    }.background(gColor(.lightTurquoise).opacity(0.7))
                    .cornerRadius(8)
                    
                    ZStack(alignment: .leading) {
                        if self.pass.isEmpty {
                            Text("Password")
                                .foregroundColor(Color(red: 1, green: 1, blue: 1, opacity: 0.7))
                                .padding(15)
                                .font(.custom("Ubuntu-Light", size: self.geometry.size.width / 22))
                        }
                        SecureField("", text: Binding<String>(get:{
                            self.pass
                        }, set: {
                            self.loginError = " "
                            self.pass = $0
                        }))
                            .textContentType(.oneTimeCode)
                            .padding(15)
                            .frame(width: self.geometry.size.width * 0.85)
                            .font(.custom("Ubuntu-Light", size: self.geometry.size.width / 22))
                            .foregroundColor(Color.white)
                    }.background(gColor(.lightTurquoise).opacity(0.7))
                    .cornerRadius(8)
                    
                    UserButton(action: self.attemptLogin, empty: (self.email.isEmpty || self.pass.isEmpty), text: "Log In")
                }
                
                Spacer().frame(height: self.geometry.size.height / 50)
                
                Button(action: self.forgotPassword, label: {
                    Text("Forgot Password? [wip]")
                        .padding(5)
                        .font(.custom("Ubuntu-Medium", size: self.geometry.size.width / 22))
                        .foregroundColor(Color.white)
                })
                
                if self.ko.visible(.login) {
                    Spacer().frame(height: self.ko.height(.login))
                } else {
                    Spacer().frame(height: self.geometry.size.height / 30)
                }
            }.padding(self.geometry.size.height / 25)
            
            SignupSheetView(currentHeight: self.$currentHeight, movingOffset: self.$movingOffset, onDragEnd: { pos in
                if pos == .down {
                    UIApplication.shared.endEditing()
                    self.ko.removeField(.signup)
                    self.ko.appendField(.login, false)
                }
            }, login: self.attemptLogin)
        }
    }
    
    func attemptSignup() {
        withAnimation(.spring(dampingFraction: 0.7)) {
            self.$movingOffset.wrappedValue = 0
            self.$currentHeight.wrappedValue = 0
            
            self.ko.removeField(.login)
            self.ko.appendField(.signup, true)
            GFormRouter.gfr().callCurrentResponder(.signup)
        }
    }
    
    func attemptLogin(){
        attemptLogin(email: self.email, pass: self.pass)
    }
    
    func attemptLogin(email: String, pass: String) {
        Auth.auth().signIn(withEmail: email, password: pass) { authResult, error in
            if let error = error as NSError? {
                self.loginError = "Incorrect Password"
                if error.code == AuthErrorCode.invalidEmail.rawValue {
                    self.loginError = "Invalid Email"
                }
                
                self.errorColor = gColor(.lightTurquoise)
                
                /* if future use, make so that timer cant be set off multiple times
                Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { _ in
                    self.errorColor = Color.clear
                }*/
                return
            }
            
            onLogin()
        }
    }
    
    func attemptLoginGoogle() {
        GIDSignIn.sharedInstance()?.signIn()
    }
    
    func forgotPassword() {
        
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
