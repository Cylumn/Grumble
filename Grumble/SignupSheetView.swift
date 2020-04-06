//
//  SignupSheetView.swift
//  Grumble
//
//  Created by Allen Chang on 3/29/20.
//  Copyright © 2020 Cylumn, Inc. All rights reserved.
//

import SwiftUI
import Firebase

private let formID: GFormID = GFormID.signup

public struct SignupSheetView: View {
    private var currentHeight: Binding<CGFloat>
    private var movingOffset: Binding<CGFloat>
    private var onDragEnd: (SheetPosition) -> ()
    
    @ObservedObject private var ko: KeyboardObserver = KeyboardObserver.ko()
    @State private var slideIndex: Int = 0
    private var login: (String, String) -> Void
    
    //Initializer
    public init(currentHeight: Binding<CGFloat>, movingOffset: Binding<CGFloat>, onDragEnd: @escaping (SheetPosition) -> (), login: @escaping (String, String) -> Void) {
        self.currentHeight = currentHeight
        self.movingOffset = movingOffset
        self.onDragEnd = onDragEnd
        
        self.login = login

        GFormText.gft(formID).setNames(["Email", "Password", "Confirm Password", "Full Name", "Username"])
        GFormText.gft(formID).setSymbols(["envelope.fill", "lock.fill", "lock.shield", "person", "person.crop.circle"])
    }

    
    //Signup Enums
    private enum PanelIndex: Int {
        case first = 0
        case final = 1
    }
    
    private enum FieldIndex: Int {
        case email = 0
        case password = 1
        case confPass = 2
        case name = 3
        case username = 4
    }
    
    //Panel Control Methods
    private func nextPanel(_ proceed: @escaping () -> Void) {
        if self.slideIndex < PanelIndex.final.rawValue {
            GFormRouter.gfr().setIndex(formID, FieldIndex.name.rawValue)
            GFormRouter.gfr().callCurrentResponder(formID)
            withAnimation(gAnim(.easeOut)) {
                self.slideIndex += 1
            }
            proceed()
        } else {
            Auth.auth().createUser(withEmail: GFormText.gft(formID).text(FieldIndex.email.rawValue), password: GFormText.gft(formID).text(FieldIndex.password.rawValue)) { authResult, error in
                if let error = error as NSError? {
                    switch error.code {
                        case AuthErrorCode.invalidEmail.rawValue:
                            GFormText.gft(formID).setError(FieldIndex.email.rawValue, "Invalid Email")
                        case AuthErrorCode.emailAlreadyInUse.rawValue:
                            GFormText.gft(formID).setError(FieldIndex.email.rawValue, "Email Already In Use")
                        case AuthErrorCode.weakPassword.rawValue:
                            GFormText.gft(formID).setError(FieldIndex.password.rawValue, "Weak Password")
                        default:
                            GFormText.gft(formID).setError(FieldIndex.email.rawValue, "Unknown Error")
                    }
                    self.previousPanel()
                    proceed()
                    return
                }
                let user = Auth.auth().currentUser!.createProfileChangeRequest()
                user.displayName = GFormText.gft(formID).text(FieldIndex.username.rawValue)
                user.commitChanges() { error in
                    if let error = error {
                        print("error:\(error)")
                    } else {
                        self.login(GFormText.gft(formID).text(FieldIndex.email.rawValue), GFormText.gft(formID).text(FieldIndex.password.rawValue))
                    }
                }
                proceed()
            }
        }
    }
    
    private func previousPanel() {
        if self.slideIndex > PanelIndex.first.rawValue {
            GFormRouter.gfr().setIndex(.signup, FieldIndex.email.rawValue)
            GFormRouter.gfr().callCurrentResponder(.signup)
            withAnimation(gAnim(.easeOut)) {
                self.slideIndex -= 1
            }
        }
    }
    
    fileprivate struct SignupPanelView: View, GFieldDelegate {
        @ObservedObject private var gft: GFormText = GFormText.gft(formID)
        private var startIndex: Int
        private var length: Int
        private var nextPanel: (@escaping () -> Void) -> Void
        @State private var disableButton = false
        
        //Initializer
        fileprivate init(startIndex: Int, length: Int, nextPanel: @escaping (@escaping () -> Void) -> Void) {
            self.startIndex = startIndex
            self.length = length
            self.nextPanel = nextPanel
        }
        
        //Getter Methods
        private func canNextPanel() -> Bool {
            for index in self.startIndex..<self.startIndex + self.length {
                if self.gft.text(index).isEmpty || !self.gft.error(index).isEmpty {
                    return false
                }
            }
            return true
        }
        
        //Panel Control Methods
        private func onNextButton() {
            if self.startIndex >= FieldIndex.name.rawValue {
                self.disableButton = true
            }
            self.nextPanel({
                if self.startIndex >= FieldIndex.name.rawValue {
                    Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { _ in
                        self.disableButton = false
                    }
                }
            })
        }
        
        //Parsing Methods
        private func calculateError(_ text: String) {
            let i = GFormRouter.gfr().index(formID)
            switch(i) {
                case FieldIndex.email.rawValue:
                    Auth.auth().fetchSignInMethods(forEmail: text, completion: { (providers, error) in
                        guard let _ = error else {
                            self.gft.setError(i, "")
                            return
                        }
                        self.gft.setError(i, "Invalid Email Address")
                    })
                case FieldIndex.password.rawValue:
                    if text.count < 6 {
                        self.gft.setError(i, "Password Must Be At Least 6 Characters")
                    } else {
                        self.gft.setError(i, "")
                    }
                    if !self.gft.text(FieldIndex.confPass.rawValue).isEmpty && self.gft.text(FieldIndex.confPass.rawValue) != text {
                        self.gft.setError(FieldIndex.confPass.rawValue, "Passwords Must Match")
                    } else {
                        self.gft.setError(FieldIndex.confPass.rawValue, "")
                    }
                case FieldIndex.confPass.rawValue:
                    if self.gft.text(FieldIndex.password.rawValue) != text {
                        self.gft.setError(i, "Passwords Must Match")
                    } else {
                        self.gft.setError(i, "")
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
        
        //Implemented GFieldDelegate Methods
        fileprivate func style(_ index: Int, _ textField: GTextField) {
            textField.setInsets(top: 5, left: 30, bottom: 5, right: 15)
            switch(index){
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
        
        fileprivate func proceedField() -> Bool {
            let index = GFormRouter.gfr().index(formID)
            if index == FieldIndex.confPass.rawValue || index == FieldIndex.username.rawValue {
                if self.canNextPanel() {
                    self.onNextButton()
                    return true
                }
                return false
            }
            return GFormRouter.gfr().callNextResponder(formID)
        }
        
        fileprivate func parseInput(_ index: Int, _ textField: UITextField, _ string: String) -> String {
            var text = textField.text!
            var string = string
            switch index {
                case FieldIndex.email.rawValue:
                    string = removeSpecialChars(string, allow: "@!.")
                case FieldIndex.password.rawValue, FieldIndex.confPass.rawValue:
                    text = cut(text + trim(string), maxLength: 20)
                    calculateError(text)
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
            
            self.calculateError(text)
            return text
        }
        
        fileprivate var body: some View {
            VStack(spacing: 0){
                VStack(spacing: 20){
                    ForEach(self.startIndex..<self.startIndex + self.length) { index in
                        ZStack(alignment: .leading) {
                            Image(systemName: self.gft.symbol(index)).foregroundColor(Color(white: 0.6)).offset(x: 2)
                            HStack{
                                Text(self.gft.name(index)).font(gFont(.tekoSemiBold, .width, 2)).foregroundColor(Color(white: 0.3))
                                Spacer()
                                Text(self.gft.error(index)).font(gFont(.tekoSemiBold, .width, 2)).foregroundColor(gColor(.blue4))
                            }.offset(y: -25)
                            Rectangle().frame(height:2).offset(y: 23)
                            GField(formID, index, self).frame(height: 50)
                        }.foregroundColor(Color(white: 0.5))
                    }
                }.frame(width: sWidth() * 0.85)
                Spacer()
                UserButton(action: self.onNextButton, disabled: !self.canNextPanel(), text: self.disableButton ? "..." : (startIndex == 0) ? "Next" : "Submit", fgEmpty: gColor(.blue0).opacity(0.3), fgFull: Color.white, bgFull: self.disableButton ? gColor(.blue0).opacity(0.3) : gColor(.blue0), padding: 15)
                    .disabled(self.disableButton)
            }.frame(width: sWidth())
        }
    }
    
    public var body: some View {
        SheetView(currentHeight: self.currentHeight, movingOffset: self.movingOffset, onDragEnd: self.onDragEnd) {
            VStack(spacing: 15) {
                Rectangle()
                    .frame(width: 80, height: 7)
                    .cornerRadius(5)
                    .foregroundColor(Color(white: 0.8))
                
                ZStack {
                    VStack(spacing: 0) {
                        Text("New User?")
                            .font(gFont(.ubuntuBold, .width, 3))
                            .foregroundColor(gColor(.blue0))
                        Text("Create Account")
                            .font(gFont(.ubuntuMedium, .width, 1.5))
                            .foregroundColor(Color(white: 0.4))
                            .offset(y: 5)
                    }
                    
                    if self.slideIndex != PanelIndex.first.rawValue {
                        HStack(spacing: nil) {
                            Button(action: self.previousPanel, label: {
                                HStack{
                                    Image(systemName: "chevron.left")
                                    Text("Back").font(gFont(.ubuntu, .width, 2))
                                }.foregroundColor(gColor(.blue0))
                            })
                            
                            Spacer()
                        }.padding(.leading, 20)
                    }
                }
                
                SlideView(index: self.$slideIndex, offsetFactor: 0.3, views: [
                    AnyView(SignupPanelView(startIndex: 0, length: 3, nextPanel: self.nextPanel)),
                    AnyView(SignupPanelView(startIndex: 3, length: 2, nextPanel: self.nextPanel))],
                    draggable: [false, false])
                    .frame(height: self.ko.visible(formID) ? 290 : 450)
                
                Spacer()
            }.padding(.top, 15)
            .padding(.bottom, isX() ? 60 : 50)
            .frame(height: sHeight())
        }
    }
}
