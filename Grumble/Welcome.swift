//
//  Welcome.swift
//  Grumble
//
//  Created by Allen Chang on 4/29/20.
//  Copyright © 2020 Cylumn, Inc. All rights reserved.
//

import SwiftUI

private let formID: GFormID = GFormID.welcome

public struct Welcome: View, GFieldDelegate {
    @ObservedObject private var gft: GFormText = GFormText.gft(formID)
    @ObservedObject private var ko: KeyboardObserver = KeyboardObserver.ko(formID)
    @State private var index: Int = 0
    @State private var name: String = "ghorblin.name"
    
    private var introHeader: [String]
    private var introParagraph: [String]
    
    private var explainHeader: [String]
    private var explainParagraph: [String]
    
    public init() {
        self.introHeader =
        ["Where she came across",
        "The Ghorblin ...",
        "An ancestor",
        "... the World"]
        self.introParagraph =
        ["the first Ghorblin to be seen by mankind.",
        "she discovered to be a fusion of primordial and technological prowess",
        "to the modern stomach, the Ghorblins captured the explorer's awe, so she introduced them to ...",
        ""]
        
        self.explainHeader =
        ["[NAME]",
        "Like all artificial intelligence",
        "You can introduce yourself",
        "Once best friends,"]
        self.explainParagraph =
        ["is one of the many Ghorblins on Grumble, specifically providing personal food suggestions for you",
        "you will need to feed [NAME] your own food preferences before it can know you well",
        "to [NAME] by tossing it some virtual grubs",
        "you can start grumbling, swiping on [NAME]'s suggestions"]
    }
    
    //Page Enums
    private enum Pages: Int {
        case welcome = 0
        case introduction = 1
        case intro2 = 2
        case intro3 = 3
        case intro4 = 4
        case intro5 = 5
        case assignment = 6
        case explain1 = 7
        case explain2 = 8
        case explain3 = 9
        case explain4 = 10
        
        case size = 11
    }
    
    //Getter Methods
    private func page(_ index: Int) -> some View {
        switch index {
        case Pages.welcome.rawValue:
            return AnyView(self.welcomePage)
        case Pages.introduction.rawValue:
            return AnyView(self.introduction)
        case Pages.intro2.rawValue ... Pages.intro5.rawValue:
            return AnyView(self.intro(index - Pages.intro2.rawValue))
        case Pages.assignment.rawValue:
            return AnyView(self.assignment)
        case Pages.explain1.rawValue ... Pages.explain4.rawValue:
            return AnyView(self.explain(index - Pages.explain1.rawValue))
        default:
            return AnyView(EmptyView())
        }
    }
    
    //Function Methods
    private func next() {
        if self.index < Pages.size.rawValue - 1 {
            withAnimation(gAnim(.easeOut)) {
                self.index += 1
            }
            if self.index == Pages.assignment.rawValue {
                Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { _ in
                    GFormRouter.gfr().callFirstResponder(formID)
                }
            }
        } else {
            UserCookie.uc().setGhorblinName(name)
        }
    }
    
    //GFieldDelegate Method Implementation
    public func style(_ index: Int, _ textField: GTextField, _ placeholderText: @escaping (String) -> Void) {
        textField.setInsets(top: 0, left: 0, bottom: 0, right: 0)
        textField.textAlignment = .center
        textField.returnKeyType = .default
    }
    
    public func proceedField() -> Bool {
        return true
    }
    
    public func parseInput(_ index: Int, _ textField: UITextField, _ string: String) -> String {
        return cut(trim(removeSpecialChars(textField.text! + smartCase(textField.text!, appendInput: string))), maxLength: 10)
    }
    
    private var welcomeBG: some View {
        ZStack {
            gColor(.blue0)
                .edgesIgnoringSafeArea(.top)
            
            Color.white
                .edgesIgnoringSafeArea(.bottom)
        }
    }

    private func header(_ text: String) -> some View {
        Text(text)
            .foregroundColor(Color(white: 0.2))
            .font(gFont(.ubuntuLight, .width, 3))
    }

    private func paragraph(_ text: String) -> some View {
        Text(text)
            .foregroundColor(Color(white: 0.4))
            .font(gFont(.ubuntuLight, .width, 2))
            .multilineTextAlignment(.center)
            .frame(height: sHeight() * 0.1)
    }
    
    private func image(_ path: String) -> some View {
        Image("GhorblinIcon")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: sHeight() * 0.3, height: sHeight() * 0.3)
            .cornerRadius(10)
            .padding(20)
    }

    private func proceedButton(_ text: String, disabled: Bool = false, _ action: @escaping () -> Void) -> some View {
        Button(action: action, label: {
            Text(text)
                .padding(10)
                .padding([.leading, .trailing], 10)
                .background(disabled ? Color(white: 0.7) : gColor(.blue0))
                .animation(gAnim(.spring))
                .foregroundColor(Color.white)
                .font(gFont(.ubuntuBold, .width, 3))
                .cornerRadius(10)
        }).disabled(disabled)
    }
    
    private var welcomePage: some View {
        VStack(spacing: 10) {
            self.header("Welcome to Grumble!")
            Spacer()
            self.proceedButton("Get Started", next)
        }
    }
    
    private var introduction: some View {
        VStack(spacing: 0) {
            self.header("In the year 2019...")
            self.paragraph("An explorer, unknown by name, was adventuring in the Trojan caves")
            ZStack {
            Image("Cave")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: sHeight() * 0.3)
                .offset(y: sHeight() * 0.02)
            }.frame(height: sHeight() * 0.3)
            .clipped()
            .cornerRadius(10)
            .padding(20)
            Spacer()
            self.proceedButton("Next", next)
        }
    }
    
    private func intro(_ index: Int) -> some View {
        VStack(spacing: 0) {
            self.header(self.introHeader[index])
            self.paragraph(self.introParagraph[index])
            self.image("GhorblinIcon")
            Spacer()
            self.proceedButton("Next", next)
        }
    }
    
    private var assignment: some View {
        VStack(spacing: 0) {
            if self.ko.visible() {
                Spacer()
            }
            VStack(spacing: 10) {
                self.header("Meet Your Ghorblin")
                Image("GhorblinIcon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: sHeight() * 0.25, height: sHeight() * 0.25)
                    .cornerRadius(10)
                self.paragraph("I'll call you ...")
                    .frame(height: sHeight() * 0.03)
                ZStack(alignment: .bottom) {
                    Rectangle()
                        .fill(self.gft.text(0).count < 3 ? Color(white: 0.7) : gColor(.blue0))
                        .frame(height: 3)
                        .animation(gAnim(.spring))
                    GField(formID, 0, self)
                }.frame(width: sWidth() * 0.5, height: 40)
                if self.ko.visible() {
                    Divider().hidden()
                } else {
                    Spacer()
                }
                self.proceedButton("Next", disabled: self.gft.text(0).count < 3) {
                    self.name = self.gft.text(0)
                    self.next()
                }
            }
            if self.ko.visible() {
                Spacer()
                Spacer()
            }
        }.background(
            Color.clear
            .contentShape(Rectangle())
            .gesture(DragGesture().onChanged { drag in
                if drag.translation.height > 0 {
                    UIApplication.shared.endEditing()
                }
            }).onTapGesture {
                UIApplication.shared.endEditing()
            }
        )
    }
    
    private func explain(_ index: Int) -> some View {
        VStack(spacing: 10) {
            self.image("GhorblinIcon")
            self.header(self.explainHeader[index].replacingOccurrences(of: "[NAME]", with: self.name))
            self.paragraph(self.explainParagraph[index].replacingOccurrences(of: "[NAME]", with: self.name))
            Spacer()
            self.proceedButton(Pages.explain1.rawValue + index == Pages.size.rawValue - 1 ? "Begin" : "Next", next)
        }
    }
    
    public var body: some View {
        ZStack {
            self.welcomeBG
            
            VStack(spacing: 0) {
                ZStack {
                    ForEach((0 ..< Pages.size.rawValue).reversed(), id: \.self) { index in
                        self.page(index)
                            .frame(width: sWidth() * 0.8)
                            .background(Color.white)
                            .opacity(index < self.index ? 0 : 1)
                            .disabled(index != self.index)
                    }.frame(maxHeight: sHeight() * 0.7)
                }
                Spacer().frame(height: self.ko.height() + 20)
            }.padding(20)
        }
    }
}

struct Welcome_Previews: PreviewProvider {
    static var previews: some View {
        Welcome()
    }
}
