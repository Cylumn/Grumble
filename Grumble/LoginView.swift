//
//  LoginView.swift
//  Grumble
//
//  Created by Allen Chang on 3/20/20.
//  Copyright © 2020 Cylumn, Inc. All rights reserved.
//

import SwiftUI
import GoogleSignIn

struct LoginView: View {
    @EnvironmentObject var userID: UserID
    @State private var id: String = ""
    @State private var pass: String = ""
    private var geometry: GeometryProxy
    
    init(_ geometry: GeometryProxy){
        self.geometry = geometry
    }
 
    var body: some View {
        ZStack{
            Image("Background")
            .resizable()
            
            VStack{
                VStack(spacing: self.geometry.size.height / 15){
                    Image("Logo")
                        .resizable()
                        .frame(width: 80, height: 80)
                    
                    Text("Grumble")
                        .font(.custom("Ubuntu-Bold", size: self.geometry.size.height / 17))
                        .fontWeight(.bold)
                        .foregroundColor(Color.white)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                }.padding(.top, self.geometry.size.height / 15)
                
                Spacer()
                
                HStack{
                    Button(action: self.attemptLogin, label: {
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
                
                Spacer().frame(height: self.geometry.size.height / 20)
                
                VStack(spacing: self.geometry.size.height / 40){
                    ZStack(alignment: .leading) {
                        if self.id.isEmpty {
                            Text("Username")
                                .foregroundColor(Color(red: 1, green: 1, blue: 1, opacity: 0.7))
                                .padding(15)
                                .font(.custom("Ubuntu-Light", size: self.geometry.size.width / 22))
                        }
                        TextField("", text: self.$id)
                            .textContentType(.oneTimeCode)
                            .padding(15)
                            .frame(width: self.geometry.size.width * 0.85)
                            .font(.custom("Ubuntu-Light", size: self.geometry.size.width / 22))
                            .foregroundColor(Color.white)
                    }.background(getInputColor(1))
                    .cornerRadius(8)
                    
                    ZStack(alignment: .leading) {
                        if self.pass.isEmpty {
                            Text("Password")
                                .foregroundColor(Color(red: 1, green: 1, blue: 1, opacity: 0.7))
                                .padding(15)
                                .font(.custom("Ubuntu-Light", size: self.geometry.size.width / 22))
                        }
                        SecureField("", text: self.$pass)
                            .textContentType(.oneTimeCode)
                            .padding(15)
                            .frame(width: self.geometry.size.width * 0.85)
                            .font(.custom("Ubuntu-Light", size: self.geometry.size.width / 22))
                            .foregroundColor(Color.white)
                    }.background(getInputColor(1))
                    .cornerRadius(8)
                    
                    Button(action: self.attemptLogin, label: {
                        ZStack{
                            if !self.id.isEmpty && !self.pass.isEmpty {
                                Text("Log In")
                                    .padding(15)
                                    .frame(width: self.geometry.size.width * 0.85)
                                    .font(.custom("Ubuntu-Medium", size: self.geometry.size.width / 22))
                                    .background(Color(red: 61 / 255, green: 181 / 255, blue: 221 / 225, opacity: 0.4))
                                    .cornerRadius(8)
                                    .foregroundColor(Color.white)
                                .overlay(RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.white, lineWidth: 1))
                            } else {
                                Text("Log In")
                                .padding(15)
                                    .frame(width: self.geometry.size.width * 0.85)
                                    .font(.custom("Ubuntu-Medium", size: self.geometry.size.width / 22))
                                .foregroundColor(Color(red: 1, green: 1, blue: 1, opacity: 0.8))
                                .overlay(RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(red: 1, green: 1, blue: 1, opacity: 0.7), lineWidth: 1))
                            }
                        }
                    })
                }
                
                Spacer().frame(height: self.geometry.size.height / 50)
                
                Button(action: self.attemptLogin, label: {
                    Text("Forgot Password?")
                        .padding(5)
                        .font(.custom("Ubuntu-Medium", size: self.geometry.size.width / 22))
                        .foregroundColor(Color.white)
                })
                
                Spacer().frame(height: self.geometry.size.height / 30)
            }.padding(self.geometry.size.height / 25)
            .edgesIgnoringSafeArea(.all)
        }
    }
    
    func attemptLogin() {
        self.userID.loggedIn = true
    }
    
    func attemptLoginGoogle() {
        GIDSignIn.sharedInstance()?  .presentingViewController = UIApplication.shared.windows.last?.rootViewController
        GIDSignIn.sharedInstance()?.signIn()
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
