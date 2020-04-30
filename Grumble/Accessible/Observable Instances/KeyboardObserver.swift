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
    private static var instance: [KeyboardObserver?]?
    private var notificationCenter: NotificationCenter
    public static var observedFields: Set<GFormID> = [.filterList, .welcome]
    private var formID: GFormID
    @Published private var keyboardVisible: Bool
    @Published private var keyboardHeight: CGFloat
    
    //Initializer
    private init(center: NotificationCenter = .default, _ formID: GFormID) {
        self.notificationCenter = center
        self.formID = formID
        self.keyboardVisible = false
        self.keyboardHeight = 0
        
        self.notificationCenter.addObserver(self, selector: #selector(self.onKeyboardShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        self.notificationCenter.addObserver(self, selector: #selector(self.onKeyboardHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    //Getter Methods
    public static func ko(_ formID: GFormID) -> KeyboardObserver {
        if KeyboardObserver.instance == nil {
            KeyboardObserver.instance = Array(repeating: nil, count: GFormID.size.rawValue)
        }
        if KeyboardObserver.instance![formID.rawValue] == nil {
            KeyboardObserver.instance![formID.rawValue] = KeyboardObserver(formID)
        }
        return KeyboardObserver.instance![formID.rawValue]!
    }
    
    public func visible() -> Bool {
        if KeyboardObserver.observedFields.contains(self.formID) {
            return self.keyboardVisible
        }
        return false
    }
    
    public func height(tabbedView: Bool = true) -> CGFloat {
        if KeyboardObserver.observedFields.contains(self.formID) {
            if !self.keyboardVisible {
                return 0
            }
            
            return self.keyboardHeight - (tabbedView ? tabHeight : 0)
        }
        return 0
    }
    
    //Setter Methods
    public static func appendField(_ field: GFormID, _ beginsVisible: Bool = false) {
        if !KeyboardObserver.observedFields.contains(field) {
            KeyboardObserver.observedFields.insert(field)
        }
        self.ko(field).keyboardVisible = beginsVisible
    }
    
    public static func removeField(_ field: GFormID) {
        KeyboardObserver.observedFields.remove(field)
    }
    
    public static func clearFields() {
        KeyboardObserver.observedFields.removeAll()
    }
    
    //Observer Methods
    @objc private func onKeyboardShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue{
            if !self.keyboardVisible {
                withAnimation(gAnim(.spring)){
                    self.keyboardVisible = true
                    self.keyboardHeight = keyboardSize.height
                }
            }
        }
    }
    
    @objc private func onKeyboardHide(notification: Notification) {
        if self.keyboardVisible {
            withAnimation(gAnim(.spring)){
                self.keyboardVisible = false
                self.keyboardHeight = 0
            }
        }
    }
    
    //Deinitializer
    deinit {
        self.notificationCenter.removeObserver(self)
    }
}
