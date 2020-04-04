//
//  FieldContainer.swift
//  Grumble
//
//  Created by Allen Chang on 3/24/20.
//  Copyright © 2020 Cylumn, Inc. All rights reserved.
//

import SwiftUI

struct FieldContainer: UIViewRepresentable {
    private var placeholder : String
    private var text : Binding<String>
    private var geometry: GeometryProxy
    private var index: Int
    private var isPriceField: Bool

    init(_ placeholder:String, text:Binding<String>, _ geometry: GeometryProxy, _ index: Int, isPriceField: Bool = false) {
        self.placeholder = placeholder
        self.text = text
        self.geometry = geometry
        self.index = index
        self.isPriceField = isPriceField
    }

    func makeCoordinator() -> FieldContainer.Coordinator {
        Coordinator(self, self.index, self.isPriceField)
    }

    func makeUIView(context: UIViewRepresentableContext<FieldContainer>) -> UITextField {

        let innertTextField = UITextFieldPadding()
        innertTextField.placeholder = placeholder
        innertTextField.text = text.wrappedValue
        innertTextField.delegate = context.coordinator
        
        //Style
        innertTextField.font = UIFont(name: "Teko-SemiBold", size: self.geometry.size.width / 17)
        innertTextField.textColor = gColor(.blue2)
        innertTextField.keyboardAppearance = .light
        innertTextField.autocorrectionType = UITextAutocorrectionType.no
        if index != 3 {
            innertTextField.returnKeyType = UIReturnKeyType.next
        }
        innertTextField.textAlignment = .left
        if self.isPriceField {
            innertTextField.keyboardType = .numberPad
            innertTextField.textAlignment = .right
            innertTextField.setInsets(top: 5, left: 35, bottom: 5, right: 15)
        } else {
            innertTextField.setInsets(top: 5, left: 30, bottom: 5, right: 15)
        }
        innertTextField.frame.size.height = 50
        innertTextField.setContentCompressionResistancePriority(.sceneSizeStayPut, for: .horizontal)
        
        GFormRouter.gfr().setRespondingField(.addFood, self.index, innertTextField)
        return innertTextField
    }

    func updateUIView(_ uiView: UITextField, context: UIViewRepresentableContext<FieldContainer>) {
        uiView.text = self.text.wrappedValue
    }

    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: FieldContainer
        var index: Int
        var isPriceField: Bool

        init(_ textFieldContainer: FieldContainer, _ index: Int, _ isPriceField: Bool) {
            self.parent = textFieldContainer
            self.index = index
            self.isPriceField = isPriceField
        }
        
        func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
            GFormRouter.gfr().setIndex(.addFood, self.index)
            return true
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            if GFormRouter.gfr().callNextResponder(.addFood) {
                textField.resignFirstResponder()
                return false
            }
            return true
        }
        
        func textField(_ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String) -> Bool {
            if self.isPriceField {
                shouldChangePriceChars(textField, replacementString: string)
                return false
            } else {
                do {
                    if string.isEmpty {
                        textField.text?.removeLast()
                        self.parent.text.wrappedValue = textField.text ?? ""
                        return false
                    }
                    
                    if textField.text?.count ?? 0 > 40 {
                        self.parent.text.wrappedValue = textField.text ?? ""
                        return false
                    }

                    let regexNew = try NSRegularExpression(pattern: "[\\w\\s\\b0-9\']+")
                    if regexNew.firstMatch(in: string, range: NSMakeRange(0, string.count)) == nil {
                        self.parent.text.wrappedValue = textField.text ?? ""
                        return false
                    }

                    let text = textField.text ?? ""
                    var newString = string
                    if (text.isEmpty || text.last! == " ") && newString.first! == " " {
                        if let firstSpace = newString.firstIndex(where: {$0 != " "}) {
                            newString.removeSubrange(newString.startIndex..<firstSpace)
                        } else {
                            newString = ""
                        }
                    }
                    
                    newString = newString.lowercased()
                    if text.isEmpty || text.last! == " " {
                        if newString.count > 1 {
                            let firstChar = newString.first!.uppercased()
                            newString.removeFirst()
                            newString.insert(contentsOf: firstChar, at: newString.startIndex)
                        } else {
                            newString = newString.first?.uppercased() ?? ""
                        }
                    }
                    self.parent.text.wrappedValue = text + newString
                    textField.text = text + newString
                    return false
                } catch {
                    print("error:\(error)")
                }
                return false
            }
        }
        
        func shouldChangePriceChars(_ textField: UITextField, replacementString string: String) {
            if textField.text != nil {
                var text = !string.isEmpty ? textField.text! + string : String(textField.text!.dropLast())
                
                if !text.isEmpty {
                    //unparse
                    text.removeAll(where: {$0 == "$" || $0 == "."})
                    if let firstZero = text.firstIndex(where: {$0 != "0"}) {
                        text.removeSubrange(text.startIndex..<firstZero)
                    } else {
                        text = ""
                    }
                    
                    //reparse
                    let x = 6
                    if text.count > x {
                        //If you want to stop typing
                        text.removeLast(text.count - x)
                    }
                    if !text.isEmpty {
                        while text.count < 3 {
                            text = "0" + text
                        }
                        text = "$" + text
                        text.insert(contentsOf: ".", at: text.index(text.endIndex, offsetBy: -2))
                    }
                }
                self.parent.text.wrappedValue = text
                textField.text = text
            } else {
                self.parent.text.wrappedValue = ""
            }
        }
        
        func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
            textField.text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            return true
        }
    }
}

class UITextFieldPadding : UITextField {

    var padding: UIEdgeInsets = UIEdgeInsets.zero
    
    func setInsets(top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat){
        padding = UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override func closestPosition(to point: CGPoint) -> UITextPosition? {
        let beginning = self.beginningOfDocument
        let end = self.position(from: beginning, offset: self.text?.count ?? 0)
        return end
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }
}
