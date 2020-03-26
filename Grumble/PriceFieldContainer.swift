//
//  PriceFieldContainer.swift
//  Grumble
//
//  Created by Allen Chang on 3/24/20.
//  Copyright © 2020 Cylumn, Inc. All rights reserved.
//

import SwiftUI

struct PriceFieldContainer: UIViewRepresentable {
    private var placeholder : String
    private var text : Binding<String>
    private var geometry: GeometryProxy

    init(_ placeholder:String, text:Binding<String>, _ geometry: GeometryProxy) {
        self.placeholder = placeholder
        self.text = text
        self.geometry = geometry
    }

    func makeCoordinator() -> PriceFieldContainer.Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: UIViewRepresentableContext<PriceFieldContainer>) -> UITextField {

        let innertTextField = UITextFieldPadding()
        innertTextField.placeholder = placeholder
        innertTextField.text = text.wrappedValue
        innertTextField.delegate = context.coordinator
        
        //Style
        innertTextField.font = UIFont (name: "Teko-SemiBold", size: self.geometry.size.width / 17)
        innertTextField.textColor = getBlue(2)
        innertTextField.keyboardType = .numberPad
        innertTextField.textAlignment = .right
        innertTextField.frame.size.height = 50

        context.coordinator.setup(innertTextField)

        return innertTextField
    }

    func updateUIView(_ uiView: UITextField, context: UIViewRepresentableContext<PriceFieldContainer>) {
        uiView.text = self.text.wrappedValue
    }

    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: PriceFieldContainer

        init(_ textFieldContainer: PriceFieldContainer) {
            self.parent = textFieldContainer
        }

        func setup(_ textField:UITextField) {
        }
        
        func textField(_ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String) -> Bool {
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
                        
                        /* //If you want the last item to be updated
                        if text.count >= 2 * x { text.removeSubrange(text.startIndex..<text.index(text.endIndex, offsetBy: -x + 1))
                        } else {
                            text.removeSubrange(text.index(text.startIndex, offsetBy: 2 * x - text.count)..<text.index(text.startIndex, offsetBy: x))
                        }*/
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
            
            return false
        }
    }
}

class UITextFieldPadding : UITextField {

    let padding = UIEdgeInsets(top: 5, left: 35, bottom: 5, right: 15)

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
        //return super.canPerformAction(action, withSender: sender)
    }
}
