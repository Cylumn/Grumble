//
//  ColorManager.swift
//  Grumble
//
//  Created by Allen Chang on 3/21/20.
//  Copyright © 2020 Cylumn, Inc. All rights reserved.
//
import SwiftUI

var blue = [UIColor?]()
var inputColor = [Color]()

func initColors(){
    blue.append(UIColor(named: "Columbia"))
    blue.append(UIColor(named: "Picton"))
    blue.append(UIColor(named: "Sea"))
    blue.append(UIColor(named: "Teal"))
    blue.append(UIColor(named: "Turquoise"))
    
    inputColor.append(Color(white: 0.98))
    inputColor.append(Color(red: 167 / 255, green: 239 / 255, blue: 226 / 255, opacity: 0.7))
    
}

func getBlue(_ index: Int) -> UIColor {
    if blue[index] != nil {
        return blue[index]!
    }
    
    return UIColor.blue
}

func getBlue(_ index: Int) -> Color {
    return Color(getBlue(index))
}

func getInputColor(_ index: Int) -> Color {
    return inputColor[index]
}
