//
//  GForm.swift
//  Grumble
//
//  Created by Allen Chang on 4/3/20.
//  Copyright © 2020 Cylumn, Inc. All rights reserved.
//

import Foundation
import SwiftUI

public enum GFormID: Int {
    case signup = 0
    case login = 1
    case filterList = 2
    case addFood = 3
    case searchTag = 4
    
    case size = 5
}

public func size(_ formID: GFormID) -> Int {
    switch formID {
    case .signup:
        return 5
    case .login:
        return 2
    case .filterList:
        return 1
    case .addFood:
        return 4
    case .searchTag:
        return 1
    default:
        return 0
    }
}

public class GFormText: ObservableObject {
    private static var instances: [GFormText?]?
    @Published private var textName: [String]
    @Published private var textSymbol: [String]
    @Published private var textError: [String]
    @Published private var textFields: [String]
    
    //Initializer
    private init(_ formID: GFormID) {
        self.textName = Array(repeating: "", count: size(formID))
        self.textSymbol = Array(repeating: "", count: size(formID))
        self.textError = Array(repeating: "", count: size(formID))
        self.textFields = Array(repeating: "", count: size(formID))
    }
    
    //Getter Methods
    public static func gft(_ formID: GFormID) -> GFormText {
        if GFormText.instances == nil {
            GFormText.instances = Array(repeating: nil, count: GFormID.size.rawValue)
        }
        if GFormText.instances![formID.rawValue] == nil {
            GFormText.instances![formID.rawValue] = GFormText(formID)
        }
        return GFormText.instances![formID.rawValue]!
    }
    
    public func name(_ index: Int) -> String {
        return self.textName[index]
    }
    
    public func symbol(_ index: Int) -> String {
        return self.textSymbol[index]
    }
    
    public func error(_ index: Int) -> String {
        return self.textError[index]
    }
    
    public func text(_ index: Int) -> String {
        return self.textFields[index]
    }
    
    //Setter Methods
    public func setName(_ index: Int, _ text: String) {
        self.textName[index] = text
    }
    
    public func setNames(_ names: [String]) {
        for i in 0..<names.count {
            self.setName(i, names[i])
        }
    }
    
    public func setSymbol(_ index: Int, _ text: String) {
        self.textSymbol[index] = text
    }
    
    public func setSymbols(_ symbols: [String]) {
        for i in 0..<symbols.count {
            self.setSymbol(i, symbols[i])
        }
    }
    
    public func setError(_ index: Int, _ text: String) {
        self.textError[index] = text
    }
    
    public func setText(_ index: Int, _ text: String) {
        self.textFields[index] = text
    }
}


public class GFormRouter: ObservableObject {
    private static var instance: GFormRouter?
    private var respondingFields: [[UITextField?]?] = Array(repeating: nil, count: GFormID.size.rawValue)
    private var currentIndices: [Int] = Array(repeating: 0, count: GFormID.size.rawValue)
    
    //Getter Methods
    public static func gfr() -> GFormRouter {
        if GFormRouter.instance == nil {
            GFormRouter.instance = GFormRouter()
        }
        return GFormRouter.instance!
    }
    
    public func index(_ formID: GFormID) -> Int {
        return self.currentIndices[formID.rawValue]
    }
    
    //Setter Methods
    public func setRespondingField(_ formID: GFormID, _ index: Int, _ field: UITextField) {
        if self.respondingFields[formID.rawValue] == nil {
            self.respondingFields[formID.rawValue] = Array(repeating: nil, count: size(formID))
        }
        self.respondingFields[formID.rawValue]![index] = field
    }
    
    public func setIndex(_ formID: GFormID, _ index: Int) {
        self.currentIndices[formID.rawValue] = index
    }
    
    private func incrementIndex(_ formID: GFormID) -> Bool {
        if self.currentIndices[formID.rawValue] < size(formID) {
            self.currentIndices[formID.rawValue] += 1
            return self.currentIndices[formID.rawValue] < size(formID)
        } else {
            return false
        }
    }
    
    //Caller Methods
    public func callCurrentResponder(_ formID: GFormID) {
        self.respondingFields[formID.rawValue]![self.currentIndices[formID.rawValue]]!.becomeFirstResponder()
    }
    
    public func callFirstResponder(_ formID: GFormID) {
        self.setIndex(formID, 0)
        self.callCurrentResponder(formID)
    }
    
    public func callNextResponder(_ formID: GFormID) -> Bool {
        if self.incrementIndex(formID) {
            self.callCurrentResponder(formID)
            return true
        }
        return false
    }
}
