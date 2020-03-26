//
//  IOManager.swift
//  Grumble
//
//  Created by Allen Chang on 3/21/20.
//  Copyright © 2020 Cylumn, Inc. All rights reserved.
//

import SwiftUI

func loadRestaurantJson(filename fileName: String) -> [Restaurant]? {
    if let url = Bundle.main.url(forResource: fileName, withExtension: "json") {
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let jsonData = try decoder.decode(RestaurantList.self, from: data)
            return jsonData.list
        } catch {
            print("error:\(error)")
        }
    }
    return nil
}
