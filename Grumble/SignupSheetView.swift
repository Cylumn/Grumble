//
//  SignupSheetView.swift
//  Grumble
//
//  Created by Allen Chang on 3/29/20.
//  Copyright © 2020 Cylumn, Inc. All rights reserved.
//

import SwiftUI
import Firebase

private let formID = GFormID.signup

public struct SignupSheetView: View {
    private var currentHeight: Binding<CGFloat>
    private var movingOffset: Binding<CGFloat>
    private var onDragEnd: (Position) -> ()
    
    @ObservedObject private var ko: KeyboardObserver = KeyboardObserver.ko()
    @State private var slideIndex: Int = 0
    private var login: (String, String) -> Void
    
    //Initializer
    public init(currentHeight: Binding<CGFloat>, movingOffset: Binding<CGFloat>, onDragEnd: @escaping (Position) -> (), login: @escaping (String, String) -> Void) {
        self.currentHeight = currentHeight
        self.movingOffset = movingOffset
        self.onDragEnd = onDragEnd
        
        self.login = login

        GFormText.gft().setNames(formID, ["Email", "Password", "Confirm Password", "Full Name", "Username"])
        GFormText.gft().setSymbols(formID, ["envelope.fill", "lock.fill", "lock.shield", "person", "person.crop.circle"])
    }
    
    //Signup Enums
    enum PanelIndex: Int {
        case first = 0
        case final = 1
    }
    
    enum FieldIndex: Int {
        case email = 0
        case password = 1
        case confPass = 2
        case name = 3
        case username = 4
    }
    
    //Panel Control Methods
    func nextPanel(_ proceed: @escaping () -> Void) {
        if self.slideIndex < PanelIndex.final.rawValue {
            GFormRouter.gfr().setIndex(formID, FieldIndex.name.rawValue)
            GFormRouter.gfr().callCurrentResponder(formID)
            withAnimation(gAnim(.easeOut)) {
                self.slideIndex += 1
            }
            proceed()
        } else {
            Auth.auth().createUser(withEmail: GFormText.gft().text(formID, FieldIndex.email.rawValue), password: GFormText.gft().text(formID, FieldIndex.password.rawValue)) { authResult, error in
                if let error = error as NSError? {
                    switch error.code {
                        case AuthErrorCode.invalidEmail.rawValue:
                            GFormText.gft().setError(formID, FieldIndex.email.rawValue, "Invalid Email")
                        case AuthErrorCode.emailAlreadyInUse.rawValue:
                            GFormText.gft().setError(formID, FieldIndex.email.rawValue, "Email Already In Use")
                        case AuthErrorCode.weakPassword.rawValue:
                            GFormText.gft().setError(formID, FieldIndex.password.rawValue, "Weak Password")
                        default:
                            GFormText.gft().setError(formID, FieldIndex.email.rawValue, "Unknown Error")
                    }
                    self.previousPanel()
                    proceed()
                    return
                }
                let user = Auth.auth().currentUser!.createProfileChangeRequest()
                user.displayName = GFormText.gft().text(formID, FieldIndex.username.rawValue)
                user.commitChanges() { error in
                    if let error = error {
                        print("error:\(error)")
                    } else {
                        self.login(GFormText.gft().text(formID, FieldIndex.email.rawValue), GFormText.gft().text(formID, FieldIndex.password.rawValue))
                    }
                }
                proceed()
            }
        }
    }
    
    func previousPanel() {
        if self.slideIndex > PanelIndex.first.rawValue {
            GFormRouter.gfr().setIndex(.signup, FieldIndex.email.rawValue)
            GFormRouter.gfr().callCurrentResponder(.signup)
            withAnimation(gAnim(.easeOut)) {
                self.slideIndex -= 1
            }
        }
    }
    
    struct SignupPanelView: View {
        @ObservedObject private var gft: GFormText = GFormText.gft()
        var startIndex: Int
        var length: Int
        var nextPanel: (@escaping () -> Void) -> Void
        @State var disableButton = false
        
        //Getter Methods
        func canNextPanel() -> Bool {
            for index in self.startIndex..<self.startIndex + self.length {
                if self.gft.text(formID, index).isEmpty || !self.gft.error(formID, index).isEmpty {
                    return false
                }
            }
            return true
        }
        
        //Panel Control Methods
        func proceed() -> Bool {
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
        
        func onNextButton() {
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
        func calculateError(_ text: String) {
            let i = GFormRouter.gfr().index(formID)
            switch(i) {
                case FieldIndex.email.rawValue:
                    Auth.auth().fetchSignInMethods(forEmail: text, completion: { (providers, error) in
                        guard let _ = error else {
                            self.gft.setError(formID, i, "")
                            return
                        }
                        self.gft.setError(formID, i, "Invalid Email Address")
                    })
                case FieldIndex.password.rawValue:
                    if text.count < 6 {
                        self.gft.setError(formID, i, "Password Must Be At Least 6 Characters")
                    } else {
                        self.gft.setError(formID, i, "")
                    }
                    if !self.gft.text(formID, FieldIndex.confPass.rawValue).isEmpty && self.gft.text(formID, FieldIndex.confPass.rawValue) != text {
                        self.gft.setError(formID, FieldIndex.confPass.rawValue, "Passwords Must Match")
                    } else {
                        self.gft.setError(formID, FieldIndex.confPass.rawValue, "")
                    }
                case FieldIndex.confPass.rawValue:
                    if self.gft.text(formID, FieldIndex.password.rawValue) != text {
                        self.gft.setError(formID, i, "Passwords Must Match")
                    } else {
                        self.gft.setError(formID, i, "")
                    }
                case FieldIndex.name.rawValue:
                    //errorField.wrappedValue = "Bad Name"
                    self.gft.setError(formID, i, "")
                case FieldIndex.username.rawValue:
                    //errorField.wrappedValue = "Bad Username"
                    self.gft.setError(formID, i, "")
                default:
                    self.gft.setError(formID, i, "Error")
            }
        }
        
        struct SignupFieldDelegate: GFieldDelegate {
            var proceed: () -> Bool
            var calcError: (String) -> Void
            
            //Implemented GFieldDelegate Methods
            func style(_ index: Int, _ textField: GTextField) {
                textField.attributedPlaceholder = NSAttributedString(string: "", attributes: [NSAttributedString.Key.foregroundColor: gColor(.blue0).withAlphaComponent(0.5)])
                textField.font = gFont(.ubuntu, .width, 2.5)
                textField.setInsets(top: 5, left: 30, bottom: 5, right: 15)
                textField.backgroundColor = UIColor.clear
                textField.layer.borderWidth = 0
                textField.layer.borderColor = CGColor(srgbRed: 0, green: 0, blue: 0, alpha: 0)
                textField.textColor = gColor(.blue0)
                if index == 1 || index == 2 {
                    textField.isSecureTextEntry = true
                }
                textField.keyboardType = .alphabet
                textField.keyboardAppearance = .light
                textField.autocorrectionType = UITextAutocorrectionType.no
                textField.setContentCompressionResistancePriority(.sceneSizeStayPut, for: .horizontal)
                textField.frame.size.height = 20
                
                switch(index){
                    case 0:
                        textField.textContentType = .newPassword
                    case 1, 2:
                        textField.textContentType = .newPassword
                    case 3:
                        textField.textContentType = .name
                    case 4:
                        textField.textContentType = .nickname
                    default:
                        textField.textContentType = .none
                }
                
                if index != 4 {
                    textField.returnKeyType = .next
                } else {
                    textField.returnKeyType = .continue
                }
            }
            
            func proceedField() -> Bool {
                return self.proceed()
            }
            
            func parseInput(_ index: Int, _ textField: UITextField, _ string: String) -> String {
                if string.isEmpty {
                    textField.text?.removeLast()
                } else if string == " " {
                    if index != 3 || (textField.text?.last ?? " " as Character) == " " {
                        return textField.text!
                    }
                } else if textField.text?.count ?? 0 > 15 {
                    switch(index){
                        case 0:
                            if textField.text?.count ?? 0 > 30 {
                                return textField.text!
                            }
                        case 1..<2:
                            return textField.text!
                        default:
                            return textField.text!
                    }
                }
                
                textField.text = textField.text! + string
                self.calcError(textField.text!)
                return textField.text!
            }
        }
        
        var body: some View {
            VStack(spacing: 0){
                VStack(spacing: 20){
                    ForEach(self.startIndex..<self.startIndex + self.length) { index in
                        ZStack(alignment: .leading) {
                            Image(systemName: self.gft.symbol(formID, index)).foregroundColor(Color(white: 0.6)).offset(x: 2)
                            HStack{
                                Text(self.gft.name(formID, index)).font(gFont(.tekoSemiBold, .width, 2)).foregroundColor(Color(white: 0.3))
                                Spacer()
                                Text(self.gft.error(formID, index)).font(gFont(.tekoSemiBold, .width, 2)).foregroundColor(gColor(.blue4))
                            }.offset(y: -25)
                            Rectangle().frame(height:2).offset(y: 23)
                            GField(formID, index, SignupFieldDelegate(proceed: self.proceed, calcError: self.calculateError)).frame(height: 50)
                        }.foregroundColor(Color(white: 0.5))
                    }
                }.frame(width: sWidth() * 0.85)
                Spacer()
                UserButton(action: self.onNextButton, empty: !self.canNextPanel(), text: self.disableButton ? "..." : (startIndex == 0) ? "Next" : "Submit", fgEmpty: gColor(.blue0).opacity(0.3), fgFull: Color.white, bgFull: self.disableButton ? gColor(.blue0).opacity(0.3) : gColor(.blue0), padding: 15)
                    .disabled(self.disableButton)
            }.frame(width: sWidth())
        }
    }
    
    public var body: some View {
        SheetView(currentHeight: self.currentHeight, movingOffset: self.movingOffset, smallHeight: sHeight() * 0.9, onDragEnd: self.onDragEnd) {
            VStack(spacing: 15) {
                Rectangle()
                    .frame(width: 80, height: 7)
                    .cornerRadius(5)
                    .foregroundColor(Color(white: 0.8))
                ZStack{
                    VStack(spacing: 0){
                        Text("New User?")
                            .font(gFont(.ubuntuBold, .width, 3))
                            .foregroundColor(gColor(.blue0))
                        Text("Create Account")
                            .font(gFont(.ubuntuMedium, .width, 1.5))
                            .foregroundColor(Color(white: 0.4))
                            .offset(y: 5)
                    }
                    if self.slideIndex != 0 {
                        HStack{
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
                    .frame(height: self.ko.visible(.signup) ? 290 : 450)
                Spacer()
            }.padding(.bottom, isX() ? 60 : 50)
            .padding(.top, 15)
            .frame(height: sHeight())
        }
    }
}
