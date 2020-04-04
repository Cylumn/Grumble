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
    case signup = 5
    case login = 2
    case filterList = 1
    case addFood = 4
}

public class GFormText: ObservableObject {
    private static var instance: GFormText?
    @Published private var textName: [GFormID: [Int: String]] = [:]
    @Published private var textSymbol: [GFormID: [Int: String]] = [:]
    @Published private var textError: [GFormID: [Int: String]] = [:]
    @Published private var textFields: [GFormID: [Int: String]] = [:]
    
    //Getter Methods
    public static func gft() -> GFormText {
        if GFormText.instance == nil {
            GFormText.instance = GFormText()
        }
        return GFormText.instance!
    }
    
    public func name(_ formID: GFormID, _ index: Int) -> String {
        return self.textName[formID]?[index] ?? ""
    }
    
    public func symbol(_ formID: GFormID, _ index: Int) -> String {
        return self.textSymbol[formID]?[index] ?? ""
    }
    
    public func error(_ formID: GFormID, _ index: Int) -> String {
        return self.textError[formID]?[index] ?? ""
    }
    
    public func text(_ formID: GFormID, _ index: Int) -> String {
        return self.textFields[formID]?[index] ?? ""
    }
    
    //Setter Methods
    public func setName(_ formID: GFormID, _ index: Int, _ text: String) {
        if self.textName[formID] == nil {
            self.textName[formID] = [:]
        }
        self.textName[formID]![index] = text
    }
    
    public func setNames(_ formID: GFormID, _ names: [String]) {
        if self.textName[formID] == nil {
            self.textName[formID] = [:]
        }
        for i in 0..<names.count {
            self.setName(formID, i, names[i])
        }
    }
    
    public func setSymbol(_ formID: GFormID, _ index: Int, _ text: String) {
        if self.textSymbol[formID] == nil {
            self.textSymbol[formID] = [:]
        }
        self.textSymbol[formID]![index] = text
    }
    
    public func setSymbols(_ formID: GFormID, _ symbols: [String]) {
        if self.textSymbol[formID] == nil {
            self.textSymbol[formID] = [:]
        }
        for i in 0..<symbols.count {
            self.setSymbol(formID, i, symbols[i])
        }
    }
    
    public func setError(_ formID: GFormID, _ index: Int, _ text: String) {
        if self.textError[formID] == nil {
            self.textError[formID] = [:]
        }
        self.textError[formID]![index] = text
    }
    
    public func setText(_ formID: GFormID, _ index: Int, _ text: String) {
        if self.textFields[formID] == nil {
            self.textFields[formID] = [:]
        }
        self.textFields[formID]![index] = text
    }
}


public class GFormRouter: ObservableObject {
    private static var instance: GFormRouter?
    private var respondingFields: [GFormID: [UITextField?]] = [:]
    private var currentIndices: [GFormID: Int] = [:]
    
    //Getter Methods
    public static func gfr() -> GFormRouter {
        if GFormRouter.instance == nil {
            GFormRouter.instance = GFormRouter()
        }
        return GFormRouter.instance!
    }
    
    public func index(_ formID: GFormID) -> Int {
        return self.currentIndices[formID] ?? 0
    }
    
    //Setter Methods
    public func setRespondingField(_ formID: GFormID, _ index: Int, _ field: UITextField) {
        if self.respondingFields[formID] == nil {
            self.respondingFields[formID] = Array(repeating: nil, count: formID.rawValue)
        }
        self.respondingFields[formID]!.insert(field, at: index)
    }
    
    public func setIndex(_ formID: GFormID, _ index: Int) {
        self.currentIndices[formID] = index
    }
    
    private func incrementIndex(_ formID: GFormID) -> Bool {
        if self.currentIndices[formID] == nil {
            self.setIndex(formID, 0)
        }
        if self.currentIndices[formID]! < self.respondingFields[formID]!.count {
            self.currentIndices[formID]! += 1
            return self.currentIndices[formID]! < formID.rawValue
        } else {
            return false
        }
    }
    
    //Caller Methods
    public func callCurrentResponder(_ formID: GFormID) {
        if self.currentIndices[formID] == nil {
            self.setIndex(formID, 0)
        }
        self.respondingFields[formID]![self.currentIndices[formID]!]!.becomeFirstResponder()
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
