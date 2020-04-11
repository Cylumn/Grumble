//
//  KeyboardObserver.swift
//  Grumble
//
//  Created by Allen Chang on 3/29/20.
//  Copyright © 2020 Cylumn, Inc. All rights reserved.
//

import Foundation
import SwiftUI

public extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        sendAction(#selector(UIView.endEditing), to: nil, from: nil, for: nil)
    }
}

public class KeyboardObserver: ObservableObject {
    private static var instance: KeyboardObserver?
    private var notificationCenter: NotificationCenter
    private var observedFields: Set<GFormID>
    @Published private var keyboardVisible: Bool
    @Published private var keyboardHeight: CGFloat
    
    //Initializer
    private init(center: NotificationCenter = .default) {
        self.notificationCenter = center
        self.observedFields = []
        self.keyboardVisible = false
        self.keyboardHeight = 0
        
        self.notificationCenter.addObserver(self, selector: #selector(self.onKeyboardShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        self.notificationCenter.addObserver(self, selector: #selector(self.onKeyboardHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    //Getter Methods
    public static func ko() -> KeyboardObserver {
        if KeyboardObserver.instance == nil {
            KeyboardObserver.instance = KeyboardObserver()
        }
        return KeyboardObserver.instance!
    }
    
    public func visible(_ field: GFormID) -> Bool {
        if self.observedFields.contains(field) {
            return self.keyboardVisible
        }
        return false
    }
    
    public func height(_ field: GFormID, tabbedView: Bool = true) -> CGFloat {
        if self.observedFields.contains(field) {
            if !self.keyboardVisible {
                return 0
            }
            
            return self.keyboardHeight - (tabbedView ? tabHeight : 0)
        }
        return 0
    }
    
    //Setter Methods
    public func appendField(_ field: GFormID, _ beginsVisible: Bool = false) {
        self.observedFields.insert(field)
        self.keyboardVisible = beginsVisible
    }
    
    public func removeField(_ field: GFormID) {
        self.observedFields.remove(field)
    }
    
    public func clearFields() {
        self.observedFields.removeAll()
    }
    
    //Observer Methods
    @objc private func onKeyboardShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            withAnimation(gAnim(.spring)){
                self.keyboardVisible = true
                self.keyboardHeight = keyboardSize.height
            }
        }
    }
    
    @objc private func onKeyboardHide(notification: Notification) {
        withAnimation(gAnim(.spring)){
            self.keyboardVisible = false
            self.keyboardHeight = 0
        }
    }
    
    //Deinitializer
    deinit {
        self.notificationCenter.removeObserver(self)
    }
}
