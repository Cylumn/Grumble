//
//  GField.swift
//  Grumble
//
//  Created by Allen Chang on 4/4/20.
//  Copyright © 2020 Cylumn, Inc. All rights reserved.
//

import SwiftUI

public protocol GFieldDelegate {
    func style(_ index: Int, _ textField: GTextField)
    func proceedField() -> Bool
    func parseInput(_ index: Int, _ textField: UITextField, _ string: String) -> String
}

public class GTextField: UITextField {
    private var padding: UIEdgeInsets = UIEdgeInsets.zero
    
    //Setter Methods
    public func setInsets(_ dimensions: CGRect) {
        self.padding = UIEdgeInsets(top: dimensions.height, left: dimensions.width, bottom: dimensions.height, right: dimensions.width)
    }
    
    public func setInsets(top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat){
        self.padding = UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
    }
    
    //Overriden Padding Methods
    public override func textRect(forBounds bounds: CGRect) -> CGRect { return bounds.inset(by: padding) }
    public override func placeholderRect(forBounds bounds: CGRect) -> CGRect { return bounds.inset(by: padding) }
    public override func editingRect(forBounds bounds: CGRect) -> CGRect { return bounds.inset(by: padding) }

    //Overriden Selector Methods
    public override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool { return false }
    public override func closestPosition(to point: CGPoint) -> UITextPosition? {
        return self.position(from: self.beginningOfDocument, offset: self.text?.count ?? 0)
    }
}

public struct GField: UIViewRepresentable {
    private var formID: GFormID
    private var index: Int
    private var placeholder: String
    private var delegate: GFieldDelegate
    
    //Initializers
    public init(_ formID: GFormID, _ index: Int, _ placeholder: String = "", _ delegate: GFieldDelegate) {
        self.formID = formID
        self.placeholder = placeholder
        self.index = index
        self.delegate = delegate
    }
    
    public init(_ formID: GFormID, _ index: Int, _ delegate: GFieldDelegate) {
        self.init(formID, index, "", delegate)
    }

    //Implemented UIViewRepresentable Methods
    public func makeCoordinator() -> GField.Coordinator {
        Coordinator(self)
    }

    public func makeUIView(context: UIViewRepresentableContext<GField>) -> UITextField {
        let textField = GTextField()
        textField.text = GFormText.gft(self.formID).text(self.index)
        textField.delegate = context.coordinator
        
        //Universal Style Goes Here
        textField.backgroundColor = UIColor.clear
        textField.setInsets(top: 5, left: 15, bottom: 5, right: 15)
        textField.layer.borderWidth = 0
        textField.layer.borderColor = CGColor(srgbRed: 0, green: 0, blue: 0, alpha: 0)
        textField.attributedPlaceholder = NSAttributedString(string: "", attributes: [NSAttributedString.Key.foregroundColor: gColor(.blue0).withAlphaComponent(0.5)])
        textField.font = gFont(.ubuntu, .width, 2.5)
        textField.textColor = gColor(.blue0)
        textField.keyboardType = .alphabet
        textField.keyboardAppearance = .light
        textField.textAlignment = .left
        textField.returnKeyType = .next
        textField.autocorrectionType = UITextAutocorrectionType.no
        textField.setContentCompressionResistancePriority(.sceneSizeStayPut, for: .horizontal)
        textField.frame.size.height = 20
        
        self.delegate.style(self.index, textField)
        GFormRouter.gfr().setRespondingField(self.formID, self.index, textField)
        return textField
    }

    public func updateUIView(_ uiView: UITextField, context: UIViewRepresentableContext<GField>) {
        uiView.text = GFormText.gft(self.formID).text(self.index)
    }

    public class Coordinator: NSObject, UITextFieldDelegate {
        private var parent: GField

        //Initializer
        fileprivate init(_ textFieldContainer: GField) {
            self.parent = textFieldContainer
        }
        
        //Implemented UITextFieldDelegate Methods
        public func textFieldDidBeginEditing(_ textField: UITextField) {
            GFormRouter.gfr().setIndex(self.parent.formID, self.parent.index)
        }
        
        public func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
            textField.text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            return true
        }
        
        public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            if self.parent.delegate.proceedField() {
                textField.resignFirstResponder()
                return false
            }
            return true
        }
        
        public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            if textField.text == nil {
                textField.text = ""
            }
            
            //Universal Parse Rules Go Here
            if string.isEmpty {
                textField.text!.removeLast()
            }
            
            textField.text = self.parent.delegate.parseInput(self.parent.index, textField, string)
            GFormText.gft(self.parent.formID).setText(self.parent.index, textField.text!)
            return false
        }
    }
}

