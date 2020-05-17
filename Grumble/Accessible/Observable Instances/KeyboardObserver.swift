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
    public static var observedFields: Set<GFormID> = [.size]
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
        return self.keyboardVisible
    }
    
    public func height(tabbedView: Bool = false) -> CGFloat {
        if !self.keyboardVisible {
            return 0
        }
        
        return self.keyboardHeight - (tabbedView ? tabHeight : 0)
    }
    
    //Setter Methods
    public static func ignore(_ field: GFormID) {
        if KeyboardObserver.observedFields.contains(field) {
            KeyboardObserver.observedFields.remove(field)
        }
        
        if KeyboardObserver.ko(field).keyboardVisible {
            KeyboardObserver.ko(field).keyboardVisible = false
            KeyboardObserver.ko(field).keyboardHeight = 0
        }
    }
    
    public static func observe(_ field: GFormID, _ beginsVisible: Bool? = nil) {
        if !KeyboardObserver.observedFields.contains(field) {
            KeyboardObserver.observedFields.insert(field)
        }
        
        if KeyboardObserver.ko(.size).keyboardVisible != KeyboardObserver.ko(field).keyboardVisible {
            KeyboardObserver.ko(field).keyboardVisible = KeyboardObserver.ko(.size).keyboardVisible
            KeyboardObserver.ko(field).keyboardHeight = KeyboardObserver.ko(.size).keyboardHeight
        }
        
        if let visible = beginsVisible {
            self.ko(field).keyboardVisible = visible  
        }
    }
    
    public enum ObserveState {
        case useraccess
        case listhome
        case addfood
        case settings
    }
    
    private static func resetFields(_ allowedFields: Set<GFormID>) {
        let allowed: Set<GFormID> = ([.createPass, .welcome] as Set<GFormID>).union(allowedFields)
        var rawIDs: Set<Int> = []
        for field in allowed { rawIDs.insert(field.rawValue) }
        
        for fieldID in 0 ..< GFormID.size.rawValue {
            if rawIDs.contains(fieldID) {
                KeyboardObserver.observe(GFormID(rawValue: fieldID)!)
            } else {
                KeyboardObserver.ignore(GFormID(rawValue: fieldID)!)
            }
        }
    }
    
    public static func reset(_ state: ObserveState) {
        switch state {
        case .useraccess:
            KeyboardObserver.resetFields([.login])
        case .listhome:
            KeyboardObserver.resetFields([.filterList])
        case .addfood:
            KeyboardObserver.resetFields([.addFood])
        case .settings:
            KeyboardObserver.resetFields([.security])
        }
    }
    
    //Observer Methods
    @objc private func onKeyboardShow(notification: Notification) {
        if KeyboardObserver.observedFields.contains(self.formID) {
            if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue{
                withAnimation(gAnim(.spring)){
                    self.keyboardVisible = true
                    self.keyboardHeight = keyboardSize.height
                }
            }
        }
    }
    
    @objc private func onKeyboardHide(notification: Notification) {
        if KeyboardObserver.observedFields.contains(self.formID) {
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
