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
        if KeyboardObserver.visible() {
            sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            sendAction(#selector(UIView.endEditing), to: nil, from: nil, for: nil)
        }
    }
}

public class KeyboardObserver: ObservableObject {
    private static var instance: [KeyboardObserver?]?
    private var notificationCenter: NotificationCenter
    public static var ignoredFields: Set<GFormID> = []
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
            KeyboardObserver.instance = Array(repeating: nil, count: GFormID.size.rawValue + 1)
        }
        if KeyboardObserver.instance![formID.rawValue] == nil {
            KeyboardObserver.instance![formID.rawValue] = KeyboardObserver(formID)
        }
        if KeyboardObserver.instance![GFormID.size.rawValue] == nil {
            KeyboardObserver.instance![GFormID.size.rawValue] = KeyboardObserver(GFormID.size)
        }
        return KeyboardObserver.instance![formID.rawValue]!
    }
    
    public static func visible() -> Bool {
        return KeyboardObserver.ko(GFormID.size).visible()
    }
    
    public func visible() -> Bool {
        if !KeyboardObserver.ignoredFields.contains(self.formID) {
            return self.keyboardVisible
        }
        return false
    }
    
    public func height(tabbedView: Bool = false) -> CGFloat {
        if !KeyboardObserver.ignoredFields.contains(self.formID) {
            if !self.keyboardVisible {
                return 0
            }
            
            return self.keyboardHeight - (tabbedView ? tabHeight : 0)
        }
        return 0
    }
    
    //Setter Methods
    public static func ignore(_ field: GFormID) {
        if !KeyboardObserver.ignoredFields.contains(field) {
            KeyboardObserver.ignoredFields.insert(field)
        }
    }
    
    public static func observe(_ field: GFormID, _ beginsVisible: Bool? = nil) {
        KeyboardObserver.ignoredFields.remove(field)
        
        if let visible = beginsVisible {
            self.ko(field).keyboardVisible = visible  
        }
    }
    
    public static func reset() {
        KeyboardObserver.ignoredFields.removeAll()
    }
    
    //Observer Methods
    @objc private func onKeyboardShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue{
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
