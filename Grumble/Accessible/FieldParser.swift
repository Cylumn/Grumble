//
//  FieldParser.swift
//  Grumble
//
//  Created by Allen Chang on 4/4/20.
//  Copyright © 2020 Cylumn, Inc. All rights reserved.
//

import Foundation

//MARK: - String Alteration Functions
public func trim(_ string: String, char: Character = " ", allowSingleChars: Bool = false) -> String {
    if string.isEmpty {
        return string
    }
    
    var text = string
    
    //remove all
    if !allowSingleChars {
        text.removeAll(where: {$0 == char})
        return text
    }
    
    //remove front-end
    if let firstAllowedChar = text.firstIndex(where: {$0 != char}) {
        text.removeSubrange(text.startIndex..<firstAllowedChar)
    } else {
        return ""
    }
    
    //remove double char
    while text.contains("\(char)\(char)") {
        text = text.replacingOccurrences(of: "\(char)\(char)", with: "\(char)")
    }
    return text
}

public func cut(_ string: String, maxLength: Int) -> String {
    if string.isEmpty || string.count < maxLength {
        return string
    }
    
    return String(string.dropLast(string.count - maxLength))
}

public func removeSpecialChars(_ string: String, allow: String = "") -> String {
    if string.isEmpty {
        return string
    }
    
    var text = string
    
    do {
        let regexNew = try NSRegularExpression(pattern: "[^\\w\\s\\b0-9" + allow + "\']+")
        text = regexNew.stringByReplacingMatches(in: text, range: NSMakeRange(0, string.count), withTemplate: "")
    } catch {
        print("error: \(error)")
    }
    return text
}

public func capFirst(_ text: String) -> String {
    var string = text
    let firstChar = string.first!.uppercased()
    string.removeFirst()
    string.insert(contentsOf: firstChar, at: string.startIndex)
    return string
}

public func smartCase(_ text: String, appendInput: String, afterChar: Character = " ") -> String {
    if appendInput.isEmpty {
        return appendInput
    }
    
    var string = appendInput
    
    if text.last == nil || text.last == afterChar {
        if string.count > 1 {
            string = capFirst(string)
        } else {
            string = string.uppercased()
        }
    }
    return string
}

public func unparsePrice(_ string: String) -> String {
    if string.isEmpty {
        return string
    }
    
    var text = string
    
    text.removeAll(where: {$0 == "$" || $0 == "."})
    if let firstZero = text.firstIndex(where: {$0 != "0"}) {
        text.removeSubrange(text.startIndex..<firstZero)
    } else {
        text = ""
    }
    return text
}

public func parsePrice(_ string: String) -> String {
    if string.isEmpty {
        return string
    }
    
    var text = string
    
    while text.count < 3 {
        text = "0" + text
    }
    text = "$" + text
    text.insert(contentsOf: ".", at: text.index(text.endIndex, offsetBy: -2))
    return text
}

public func randomString(length: Int) -> String {
  let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
  return String((0 ..< length).map{ _ in letters.randomElement()! })
}
